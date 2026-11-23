"""Build BLSPASCL.COM or COMPASCL.COM from the original CP/M compiler.

Place this script alongside the original compiler and run it with Python 3.
CP/M addresses in the patch include the 0100h load origin.
"""
from hashlib import sha256
from pathlib import Path

root = Path(__file__).resolve().parent
images = {
    "BLSPAS": "b999c40cc313cfcbc33da665875eb83fd72e5325d34d8f2b9799366a3a38e318",
    "COMPAS": "898647ef5235176f3f869ed8c020944bd56702fc2d7859ba5444b036494b0b16",
}
originals = [name for name in images if (root / (name + ".COM")).is_file()]
if len(originals) != 1:
    raise SystemExit("Expected one original compiler, BLSPAS.COM or COMPAS.COM")
name = originals[0]
image = bytearray((root / (name + ".COM")).read_bytes())
if sha256(image).hexdigest() != images[name]:
    raise SystemExit(f"Unexpected {name}.COM image")
bls = name == "BLSPAS"
base = 0x431B if bls else 0x203A
limit = 0x4400 if bls else 0x2133
sections = []
code = bytearray()
labels = {}
fixups = []


def mark(label):
    labels[label] = base + len(code)


def op(data, target=None, *, relative=False):
    code.extend(bytes.fromhex(data))
    if target is not None:
        fixups.append((len(code), target, relative))
        code.extend(bytes(1 if relative else 2))


def jr(data, target):
    op(data, target, relative=True)


def patch(address, data):
    offset = address - 0x100
    image[offset:offset + len(data)] = data


def hook(address, opcode, label):
    patch(address, bytes([opcode]) + labels[label].to_bytes(2, "little"))


# Parse one current-drive 8.3 source name before the compiler reuses the tail.
mark("start")
op("21 81 00 3a 80 00 47")
mark("spaces")
op("78 b7")
op("ca", "usage")
op("7e 23 05 fe 20")
jr("28", "spaces")
op("11", "filename")
op("0e 00")
mark("stem")
op("fe 2e")
jr("28", "ext")
op("fe 20")
jr("28", "trailing")
op("cd", "upper")
op("fe 41")
jr("38", "number")
op("fe 5b")
jr("38", "store")
mark("number")
op("fe 30")
jr("38", "special")
op("fe 3a")
jr("38", "store")
mark("special")
op("fe 2d")
jr("28", "store")
op("fe 5f")
op("c2", "usage")
mark("store")
op("12 13 0c 79 fe 09")
op("d2", "usage")
op("78 b7")
jr("28", "finish")
op("7e 23 05")
jr("18", "stem")
mark("ext")
op("78 fe 03")
jr("38", "usage")
for char in b"PAS":
    op("7e 23 05 cd", "upper")
    op(f"fe {char:02x}")
    jr("20", "usage")
mark("after_ext")
op("78 b7")
jr("28", "finish")
op("7e 23 05 fe 20")
jr("20", "usage")
mark("trailing")
jr("18", "after_ext")
mark("finish")
op("79 b7")
jr("28", "usage")
op("eb 36 2e 23 36 50 23 36 41 23 36 53 23 36 00")
if bls:
    # BLS otherwise interprets the command tail as a RAM-top setting.
    op("21 02 07 22 01 01 af 32 80 00 c3 02 07")
else:
    op("c3 bf 21")
mark("upper")
op("fe 61 d8 fe 7b d0 e6 df c9")
mark("usage")
op("11", "usage_text")
op("0e 09 cd 05 00")
if bls:
    op("c3", "failure")
    # The compiler can reuse the startup area once source loading begins.
    sections.append((base, limit, code, fixups))
    base, limit = 0xB1F7, 0xB300
    code, fixups = bytearray(), []
mark("failure")
op("11 01 00")
jr("18", "exit")
mark("close_output")
if bls:
    op("cd 9f b6")
else:
    op("cd 80 67 fe ff")
    op("ca", "discard_closed")
    op("3a 81 6f b7")
    op("c2", "discard_closed")
op("11 00 00")
mark("exit")
op("0e 6c cd 05 00 c3 00 00")

# Supply the existing command parser's line buffer after its interactive read.
# A second pass selects the compiler's standalone program output command.
mark("command")
op("3a", "phase")
op("b7")
jr("20", "program")
op("3c 32", "phase")
op("11 c0 0c" if bls else "11 80 6e")
op("3e 4c 12 13 3e 20 12 13 21", "filename")
mark("copy")
op("7e b7")
jr("28", "end_line")
op("12 13 23")
jr("18", "copy")
mark("program")
op("3d")
jr("20", "failure")
op("3e 02 32", "phase")
op("11 c0 0c 3e 54" if bls else "11 80 6e 3e 50")
op("12 13")
mark("end_line")
op("3e 0d" if bls else "3e 1a")
op("12")
op("e1 c3 a6 e1" if bls else "c9")
# Keep the filename and error handling in another unused area of COMPAS.
if not bls:
    sections.append((base, limit, code, fixups))
    base, limit = 0x6D83, 0x6E00
    code, fixups = bytearray(), []

if bls:
    mark("discard_open")
    op("cd eb 02 11 f9 b7 0e 10 cd 05 00")
else:
    mark("open_source")
    op("cd b9 23 fe ff c0")
    op("11", "missing_text")
    op("c3", "diagnostic")
mark("discard_closed")
op("11 f9 b7" if bls else "11 c7 6f")
op("0e 13 cd 05 00 11", "error_text")
mark("diagnostic")
op("0e 09 cd 05 00 c3", "failure")

mark("phase")
op("00")
mark("filename")
code.extend(bytes(13))
mark("usage_text")
code.extend(f"Usage: {name}CL name[.PAS]\r\n$".encode())
mark("error_text")
code.extend(b"\r\nCompilation failed\r\n$")
if not bls:
    mark("missing_text")
    code.extend(b"No such source file\r\n$")

sections.append((base, limit, code, fixups))
for origin, end, section, references in sections:
    for offset, target, relative in references:
        address = labels[target]
        if relative:
            displacement = address - origin - offset - 1
            section[offset:offset + 1] = displacement.to_bytes(1, "little", signed=True)
        else:
            section[offset:offset + 2] = address.to_bytes(2, "little")
    start = origin - 0x100
    if origin + len(section) > end or any(image[start:start + len(section)]):
        raise SystemExit(f"Patch exceeds the reserved space at {origin:04X} to {origin+len(section):04X}")
    patch(origin, section)
if bls:
    hook(0x100, 0xC3, "start")
    hook(0x1177, 0x21, "command")
    # This close call belongs to the generated program, not the source file.
    hook(0xBD7C, 0xCD, "close_output")
    hook(0xB047, 0xC3, "discard_open")
else:
    hook(0x202A, 0xC3, "start")
    patch(0x234A, bytes.fromhex("3e 4e 00"))  # Skip the optional error-file prompt.
    hook(0x2301, 0xCD, "command")
    hook(0x682F, 0xCD, "close_output")
    hook(0x24AF, 0xCD, "open_source")
(root / (name + "CL.COM")).write_bytes(image)

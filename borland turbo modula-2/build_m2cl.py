"""Build the noninteractive Turbo Modula-2 1.00 compiler from M2.COM.

Run with ntvcm -c M2CL.COM NAME.MOD. The original compiler overlays stay
in use, and the linker reads the original M2.COM for the program runtime.
The output files are NAME.MCD and NAME.COM in the current CP/M drive.
"""
from hashlib import sha256
from pathlib import Path

root = Path(__file__).resolve().parent
image = bytearray((root / "M2.COM").read_bytes())
# Both distributed images use the same M-code interpreter and patch sites.
supported_images = {
    "f68f9e7f82f11b4a52ecaf45ea0c149e5e328122c54c857e7839f5e084c84a37",
    "790760ad470718fae900a472e2541e4bba4d902de526a8d4b0367c26a9f8c97b",
}
if sha256(image).hexdigest() not in supported_images:
    raise SystemExit("Expected the original Turbo Modula-2 1.00 M2.COM")

# Addresses are CP/M load addresses, including the 100h load offset.
symbols = {}
patches = []
pending = []


def segment(address):
    patches.append((address, bytearray()))


def mark(name):
    address, code = patches[-1]
    symbols[name] = address + len(code)


def emit(hex_bytes, target=None, relative=False):
    address, code = patches[-1]
    code.extend(bytes.fromhex(hex_bytes))
    if target:
        pending.append((code, len(code), target, address if relative else None))
        code.extend(bytes(1 if relative else 2))


def raw(data):
    patches[-1][1].extend(data)


# The parser runs once, before Turbo starts or reuses the CP/M command tail.
segment(0x5E00)
mark("startup")
emit("21 81 00 3a 80 00 47 b7 ca", "usage")  # HL = tail, B = remaining
mark("trim")
emit("7e fe 20 c2", "stem_start")
emit("23 05 c2", "trim")
emit("c3", "usage")
mark("stem_start")
emit("11", "source")
emit("0e 00")  # C counts stem bytes
mark("stem")
emit("7e fe 20 ca", "trailing")
emit("fe 2e ca", "extension")
emit("cd", "uppercase")
emit("fe 41 da", "digit")
emit("fe 5b da", "store")
mark("digit")
emit("fe 30 da", "punctuation")
emit("fe 3a da", "store")
mark("punctuation")
emit("fe 2d ca", "store")
emit("fe 5f c2", "usage")
mark("store")
emit("12 13 0c 79 fe 09 d2", "usage")
emit("23 05 c2", "stem")
emit("c3", "finish")
mark("extension")
emit("78 fe 04 da", "usage")
emit("23 7e cd", "uppercase")
emit("fe 4d c2", "usage")
emit("23 7e cd", "uppercase")
emit("fe 4f c2", "usage")
emit("23 7e cd", "uppercase")
emit("fe 44 c2", "usage")
emit("23 05 05 05 05 ca", "finish")
mark("trailing")
emit("7e fe 20 c2", "usage")
emit("23 05 c2", "trailing")
mark("finish")
emit("79 b7 ca", "usage")
emit("3e 2e 12 13 3e 4d 12 13 3e 4f 12 13 3e 44 12 13 af 12")
emit("11 01 00 0e 6c cd 05 00 c3 9d 06")
mark("uppercase")
emit("fe 61 d8 fe 7b d0 d6 20 c9")
mark("usage")
emit("11", "help")
emit("0e 09 cd 05 00 11 01 00 c3", "exit")
mark("help")
raw(b"Usage: M2CL name[.MOD]\r\n$")

# Use the IDE banner procedure's space for the code that must remain
# resident after startup. A normal M-code return replaces the banner.
# The interpreter keeps its M-code program counter in DE. Intercept just the
# shell and linker call sites below and leave the other opcodes alone.
segment(0x1FC0)
emit("88 ff")  # Return from the banner procedure.
mark("dispatch")
emit("f5 7a fe 63 28", "shell_menu_check", relative=True)
emit("fe 62 28", "shell_line_check", relative=True)
emit("fe 24 28", "link_output_check", relative=True)
emit("fe 6e ca", "link_all_check")
emit("fe 3b ca", "compiler_error_check")
emit("fe 1c 20", "regular", relative=True)
emit("7b fe 66 ca", "failed")
mark("regular")
emit("f1 1a 13 6f c3 1d 04")  # Original opcode fetch
# Select the compiler or linker in the shell using its command variable.
# Phase is 0 at startup, 1/2 while compiling/after publishing MCD,
# and 3/4 while linking/after publishing COM.
mark("shell_menu_check")
emit("7b fe 2f 20", "regular", relative=True)
emit("3a", "phase")
emit("b7 28", "compile", relative=True)
emit("fe 02 28", "link", relative=True)
emit("fe 04 ca", "ok")
emit("c3", "failed")
mark("compile")
emit("3e 01 32", "phase")
emit("3e 43 18", "menu_command", relative=True)
mark("link")
emit("3e 03 32", "phase")
emit("3e 4c")
mark("menu_command")
emit("33 33 e1 77 23 36 00 13 13 fd e9")
# Set the shell filename buffer directly, and resume past the line reader.
# The module check distinguishes SHELL from LINK in the same overlay slot.
mark("shell_line_check")
emit("7b fe bf 20", "regular", relative=True)
emit("3a 12 03 fe d1 20", "regular", relative=True)
mark("source_line")
emit("21", "source")
emit("11 81 00 01 0d 00 ed b0")
emit("f1 e1 e1 e1 e1 11 c0 62 fd e9")
# Fill the linker output argument and enable automatic dependency inclusion.
mark("link_output_check")
emit("7b fe ef ca", "failed")  # Missing SHELL.MCD, before the disk prompt.
emit("fe 90 20", "regular", relative=True)
emit("3a", "phase")
emit("fe 03 c2", "regular")
emit("f1 e1 d1 21", "source")
mark("copy_output")
emit("7e fe 2e 28", "output_suffix", relative=True)
emit("12 23 13 18", "copy_output", relative=True)
mark("output_suffix")
emit("21", "com_suffix")
emit("01 05 00 ed b0 11 92 24 fd e9")
mark("link_all_check")
emit("7b fe 85 c2", "regular")
emit("3a", "phase")
emit("fe 03 c2", "regular")
emit("f1 e1 e1 21 01 00 e5 11 87 6e fd e9")

# Track the compiler's successful .MCD rename and the linker's successful
# .COM rename. Existing files do not count as a successful new build.
mark("bdos")
emit("c5 cd 05 00 c1 f5 b7 20", "bdos_done", relative=True)
emit("79 fe 17 20", "bdos_done", relative=True)
emit("3a", "phase")
emit("fe 01 28", "published", relative=True)
emit("fe 03 20", "bdos_done", relative=True)
mark("published")
emit("3c 32", "phase")
mark("bdos_done")
emit("f1 c9")
mark("ok")
emit("11 00 00 c3", "exit")
mark("failed")
emit("11 01 00")
mark("exit")
emit("0e 6c cd 05 00 c3 00 00")
# Supply the compiler error handler's Quit result so that it closes and
# deletes the temporary .@@@ file before control returns to the shell.
segment(0x1FA5)
mark("compiler_error_check")
emit("7b fe e8 c2", "regular")
emit("3a 12 03 fe 45 c2", "regular")
emit("3e 51 c3", "menu_command")

# The fatal-error debugger prompt at 1C66h is unreachable in CLI mode.
segment(0x1C68)
mark("phase")
raw(b"\0")
mark("com_suffix")
raw(b".COM\0")
mark("source")
raw(bytes(13))

segment(0x05A0)
emit("af c9")  # Background key polling always reports no pending input.
segment(0x0100)
emit("c3", "startup")
segment(0x041A)
emit("c3", "dispatch")
segment(0x14E9)
emit("cd", "bdos")

for code, offset, target, origin in pending:
    if origin is None:
        code[offset:offset + 2] = symbols[target].to_bytes(2, "little")
    else:
        code[offset:offset + 1] = (symbols[target] - origin - offset - 1).to_bytes(1, "little", signed=True)
for address, code in patches:
    limit = {0x1FC0: 0x20C1, 0x1FA5: 0x1FBE, 0x1C68: 0x1C8C}.get(address)
    if limit is not None and address + len(code) > limit:
        raise ValueError("Resident code exceeds banner space")
    offset = address - 0x100
    image.extend(bytes(max(0, offset + len(code) - len(image))))
    image[offset:offset + len(code)] = code
(root / "M2CL.COM").write_bytes(image)

"""Build TURBOCL.COM from this directory's Turbo Pascal 1.00 image.

Run with ntvcm -c TURBOCL.COM NAME.PAS alongside TURBOMSG.OVR.
Use uppercase filenames on case-sensitive hosts with ntvcm's default settings.

Addresses below are Z80 load addresses. The new code occupies the original
banner and menu space above 1D76h, where Turbo's compiler proper begins.
"""

from hashlib import sha256
from pathlib import Path

ROOT = Path(__file__).resolve().parent
image = bytearray((ROOT / "TURBO.COM").read_bytes())
if sha256(image).hexdigest() != "73c257254c36aa3068606678dbdb9d84d243ccb26f37eda3213aebca3685d007":
    raise SystemExit("Expected this distribution's original Turbo Pascal 1.00 TURBO.COM")


def patch(address, code, limit=None):
    if isinstance(code, str):
        code = bytes.fromhex(code)
    if limit is not None and address + len(code) > limit:
        raise ValueError(f"Patch at {address:04X} exceeds its reserved region")
    offset = address - 0x100
    image[offset:offset + len(code)] = code


def message(address, text, next_address, limit):
    # Turbo's inline print takes a NUL-terminated string after the CALL.
    patch(address, b"\xcd\xf8\x01" + text.encode("ascii") + b"\0\xc3"
          + next_address.to_bytes(2, "little"), limit)


# Reuse Turbo's FCB parser and its source loader, select COM mode, then compile.
# Save the tail before loading the diagnostic overlay, which reuses the FCB.
patch(0x1DCE, """
    cd aa 1e       3e 01          32 6d 3e
    cd a3 29       cd 8e 29
    11 d7 70       cd 42 29
    cd 4e 21       cd 96 23       cd 74 24
    11 00 00       c3 65 1e
""", 0x1E10)

# Suppress Turbo's startup terminal attributes.
patch(0x1D9B, "00 00 00 00 00 00")

# Track whether BDOS created the output. The original compiler closes it
# before reporting a syntax error. Remove partial output on any failure.
patch(0x1E10, """
    cd b0 68       fe ff          c8
    3e 01          32 04 1e       af             c9
""", 0x1E40)
patch(0x1E04, "00")  # Output-created flag
patch(0x24B4, "cd 10 1e")

# Reject CP/M delimiters and host path or wildcard characters in filenames.
# Keep HL and BC intact for the command-tail copy loop around the CPIR.
patch(0x1E20, bytes.fromhex(
    "e5 c5 21 30 1e 01 0c 00 ed b1 c1 e1 ca 80 1e c9"
) + b'<>;,=?*[]/\\"', 0x1E40)

# Check the output close that Turbo's compiler ordinarily ignores.
patch(0x1E05, """
    cd b0 68       fe ff          c0
    c3 a2 26
""", 0x1E0E)
patch(0x6962, "cd 05 1e")

# Turbo's error path ordinarily prompts for ESC and enters the editor.
# Print a newline and, if compilation created a file, close and delete it.
patch(0x1E40, """
    cd b6 01       3a 04 1e       b7             28 10
    11 33 6f       0e 10          cd 05 00
    11 33 6f       0e 13          cd 05 00
    c3 62 1e
""", 0x1E62)
patch(0x2A6C, "c3 40 1e")
patch(0x1E7A, "c3 40 1e")

# Return through BDOS function 108, supported by ntvcm.
patch(0x1E62, """
    11 01 00       0e 6c          cd 05 00       c3 00 00
""", 0x1E7A)
message(0x1E80, "Usage: TURBOCL [drive:]name[.PAS]\r\n", 0x1E62, 0x1EAA)

# Each entry encodes Z80 instructions or a relative branch to a local label.
# Parse the length-prefixed CP/M tail into Turbo's 1Ah-terminated input buffer.
# Accept one filename, with an optional A: through P: and a .PAS suffix.
parser = [
    ("",       "21 80 00 46 23"),  # HL = tail, B = remaining bytes
    ("skip",   "78 b7 ca 80 1e fe 80 d2 80 1e 7e fe 20"),
    ("",       "20", "copy_start"),
    ("",       "23 05"),
    ("",       "18", "skip"),
    ("copy_start", "11 d7 70"),
    ("copy",   "7e fe 20"),
    ("",       "28", "trailing"),
    ("",       "fe 21 da 80 1e fe 7d d2 80 1e"),
    ("",       "cd 20 1e"),  # Check CP/M filename characters
    ("",       "cd 57 04 12 13 23"),  # Uppercase and copy one byte
    ("",       "10", "copy"),
    ("",       "18", "validate"),
    ("trailing", "7e fe 20 c2 80 1e 23"),
    ("",       "10", "trailing"),  # Only spaces may follow the token
    ("validate", "3e 1a 12 21 d7 70 23 7e 2b fe 3a"),
    ("",       "20", "stem_start"),
    ("",       "7e fe 41 da 80 1e fe 51 d2 80 1e 23 23"),
    ("stem_start", "06 00"),
    ("stem",   "7e fe 1a"),
    ("",       "28", "check_stem"),
    ("",       "fe 2e"),
    ("",       "28", "check_stem"),
    ("",       "fe 3a ca 80 1e 04 78 fe 09 d2 80 1e 23"),
    ("",       "18", "stem"),
    ("check_stem", "4f 78 b7 ca 80 1e 79 fe 1a c8"),
    ("",       "23 7e fe 50 c2 80 1e 23 7e fe 41 c2 80 1e"),
    ("",       "23 7e fe 53 c2 80 1e 23 7e fe 1a c2 80 1e c9"),
]
labels = {}
branches = []
code = bytearray()
for label, hex_bytes, *target in parser:
    if label:
        labels[label] = len(code)
    code.extend(bytes.fromhex(hex_bytes))
    if target:
        branches.append((len(code), target[0]))
        code.append(0)
for offset, label in branches:
    displacement = labels[label] - offset - 1
    code[offset:offset + 1] = displacement.to_bytes(1, "little", signed=True)
patch(0x1EAA, code, 0x1F5B)

(ROOT / "TURBOCL.COM").write_bytes(image)

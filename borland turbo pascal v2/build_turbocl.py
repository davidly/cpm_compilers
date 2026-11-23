"""Build the command-line compiler for Turbo Pascal 2.00A or 3.01A.

Run with ntvcm -c TURBOCL.COM NAME.PAS alongside TURBO.MSG.
The addresses below are Z80 load addresses for the two original images.
"""

from hashlib import sha256
from pathlib import Path

ROOT = Path(__file__).resolve().parent
image = bytearray((ROOT / "TURBO.COM").read_bytes())
digest = sha256(image).hexdigest()

if digest == "aba6c2c78bb40b5d96076b8dbc69bc0b887cebde798a4b3f29c1f19fb1aa1bbb":
    startup, driver, palette = 0x205D, 0x206C, 0x1FEE
    parser_start, parser_limit, buffer = 0x2177, 0x2235, 0x7958
    diagnostics, reset_source, parse_filename = 0x2CC5, 0x2CB0, 0x2C4B
    load_source, com_mode, compile_source = 0x2401, 0x264C, 0x2730
    bdos, print_inline, newline, uppercase = 0x70C9, 0x0225, 0x01E1, 0x0484
    output_fcb, make_call, close_call = 0x77B4, 0x2770, 0x717B
    disk_error, pause, menu, poll = 0x2970, 0x2D97, 0x2138, 0x7000
elif digest == "920e1925884c352d6b6d6fa80e947265fe5001692899477456824dec2d21808e":
    startup, driver, palette = 0x2153, 0x2162, 0x20FF
    parser_start, parser_limit, buffer = 0x2259, 0x2317, 0x7AD7
    diagnostics, reset_source, parse_filename = 0x2D83, 0x2D6E, 0x2D09
    load_source, com_mode, compile_source = 0x24D8, 0x2723, 0x2806
    bdos, print_inline, newline, uppercase = 0x7247, 0x0201, 0x01E2, 0x04A7
    output_fcb, make_call, close_call = 0x7933, 0x2846, 0x72F9
    disk_error, pause, menu, poll = 0x2A39, 0x2E55, 0x221A, 0x7198
else:
    raise SystemExit("Expected this distribution's original TURBO.COM")

make, created, close = driver + 0x25, driver + 0x34, driver + 0x35
filter_address, failure = driver + 0x40, driver + 0x60
fail_status, exit_status, usage = driver + 0x80, driver + 0x83, driver + 0x90


def word(value):
    return value.to_bytes(2, "little").hex()


def patch(address, code, limit=None):
    if isinstance(code, str):
        code = bytes.fromhex(code)
    if limit is not None and address + len(code) > limit:
        raise ValueError(f"Patch at {address:04X} exceeds its reserved region")
    offset = address - 0x100
    image[offset:offset + len(code)] = code


# Skip the IDE. Keep the leading "TURBO " in its banner because the
# diagnostics loader uses it as the stem of TURBO.MSG.
patch(startup, f"c3 {word(driver)}")
patch(palette, "c9")
patch(driver, f"""
    cd {word(parser_start)}
    cd {word(diagnostics)}     cd {word(reset_source)}
    11 {word(buffer)}          cd {word(parse_filename)}
    cd {word(load_source)}     cd {word(com_mode)}
    cd {word(compile_source)}
    11 00 00                   c3 {word(exit_status)}
""", make)

# Disable the compiler's keyboard poll, which normally opens an abort prompt.
patch(poll, "af 00 00")

# Record file creation and check the compiler's final close.
patch(make_call, f"cd {word(make)}")
patch(make, f"cd {word(bdos)} fe ff c8 3e 01 32 {word(created)} af c9", created)
patch(created, "00")
patch(close_call, f"cd {word(close)}")
patch(close, f"cd {word(bdos)} fe ff c0 c3 {word(disk_error)}", filter_address)

# Reject CP/M delimiters and host path or wildcard characters.
patch(filter_address, bytes.fromhex(
    f"e5 c5 21 {word(filter_address + 16)} 01 0c 00 ed b1 c1 e1 ca {word(usage)} c9"
) + b'<>;,=?*[]/\\"', failure)

# Return after diagnostics instead of waiting for ESC or entering the editor.
# If the compiler created an output, close and remove the partial COM file.
patch(pause, f"c3 {word(failure)}")
patch(menu, f"c3 {word(failure)}")
patch(failure, f"""
    cd {word(newline)}        3a {word(created)} b7 28 10
    11 {word(output_fcb)}     0e 10 cd 05 00
    11 {word(output_fcb)}     0e 13 cd 05 00
    c3 {word(fail_status)}
""", fail_status)
patch(fail_status, "11 01 00")
patch(exit_status, "0e 6c cd 05 00 c3 00 00", usage)
patch(usage, bytes.fromhex(f"cd {word(print_inline)}")
      + b"Usage: TURBOCL [drive:]name[.PAS]\r\n\0"
      + bytes.fromhex(f"c3 {word(fail_status)}"), parser_start)

# Each entry encodes Z80 instructions or a relative branch to a local label.
# Parse the length-prefixed CP/M tail into Turbo's 1Ah-terminated input buffer.
# Accept one filename, with an optional A: through P: and a .PAS suffix.
parser = [
    ("",       "21 80 00 46 23"),  # HL = tail, B = remaining bytes
    ("skip",   "78 b7 ca {usage} fe 80 d2 {usage} 7e fe 20"),
    ("",       "20", "copy_start"),
    ("",       "23 05"),
    ("",       "18", "skip"),
    ("copy_start", "11 {buffer}"),
    ("copy",   "7e fe 20"),
    ("",       "28", "trailing"),
    ("",       "fe 21 da {usage} fe 7d d2 {usage}"),
    ("",       "cd {filter_address}"),  # Check CP/M filename characters
    ("",       "cd {uppercase} 12 13 23"),  # Uppercase and copy one byte
    ("",       "10", "copy"),
    ("",       "18", "validate"),
    ("trailing", "7e fe 20 c2 {usage} 23"),
    ("",       "10", "trailing"),  # Only spaces may follow the token
    ("validate", "3e 1a 12 21 {buffer} 23 7e 2b fe 3a"),
    ("",       "20", "stem_start"),
    ("",       "7e fe 41 da {usage} fe 51 d2 {usage} 23 23"),
    ("stem_start", "06 00"),
    ("stem",   "7e fe 1a"),
    ("",       "28", "check_stem"),
    ("",       "fe 2e"),
    ("",       "28", "check_stem"),
    ("",       "fe 3a ca {usage} 04 78 fe 09 d2 {usage} 23"),
    ("",       "18", "stem"),
    ("check_stem", "4f 78 b7 ca {usage} 79 fe 1a c8"),
    ("",       "23 7e fe 50 c2 {usage} 23 7e fe 41 c2 {usage}"),
    ("",       "23 7e fe 53 c2 {usage} 23 7e fe 1a c2 {usage} c9"),
]
labels = {}
branches = []
code = bytearray()
for label, hex_bytes, *target in parser:
    if label:
        labels[label] = len(code)
    code.extend(bytes.fromhex(hex_bytes.format(
        usage=word(usage), filter_address=word(filter_address),
        buffer=word(buffer), uppercase=word(uppercase),
    )))
    if target:
        branches.append((len(code), target[0]))
        code.append(0)
for offset, label in branches:
    displacement = labels[label] - offset - 1
    code[offset:offset + 1] = displacement.to_bytes(1, "little", signed=True)
patch(parser_start, code, parser_limit)

(ROOT / "TURBOCL.COM").write_bytes(image)

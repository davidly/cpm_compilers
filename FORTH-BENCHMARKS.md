# Forth benchmark improvements

Measured on 2026-11-01 with `ntvcm`, comparing the updated examples
with commit `db73dc306c814f502857ac2f96286a1634f25832`. Values are median emulated CPU cycles
from three complete invocations, including interpreter startup, source loading,
compilation, output and stack checks. They are not modern-host timings.
Sieve retains ten passes over the original 8190 flags; e prints 192 digits;
TTT retains ten iterations, three openings and 6493 search nodes per iteration.

| Forth | App | Before cycles | After cycles | Reduction |
| --- | --- | ---: | ---: | ---: |
| 8080 Forth 83 v2.1.0 | SIEVE | 328,055,104 | 257,103,929 | 21.6% |
| 8080 Forth 83 v2.1.0 | E | 222,413,690 | 199,510,559 | 10.3% |
| 8080 Forth 83 v2.1.0 | TTT | 1,947,893,721 | 1,558,701,798 | 20.0% |
| 8080 Forth 83 v2.1.1 | SIEVE | 328,035,450 | 257,088,172 | 21.6% |
| 8080 Forth 83 v2.1.1 | E | 222,417,435 | 199,502,533 | 10.3% |
| 8080 Forth 83 v2.1.1 | TTT | 1,948,109,425 | 1,559,112,240 | 20.0% |
| DX-FORTH for CPM 4.30 | SIEVE | 271,038,779 | 194,397,936 | 28.3% |
| DX-FORTH for CPM 4.30 | E | 139,863,961 | 122,690,350 | 12.3% |
| DX-FORTH for CPM 4.30 | TTT | 1,534,495,366 | 1,272,204,140 | 17.1% |
| DX-FORTH for CPM 4.56 | SIEVE | 269,191,916 | 193,760,339 | 28.0% |
| DX-FORTH for CPM 4.56 | E | 138,961,713 | 122,902,595 | 11.6% |
| DX-FORTH for CPM 4.56 | TTT | 1,530,956,075 | 1,268,914,407 | 17.1% |
| Z80 CamelForth v101 | SIEVE | 236,838,699 | 205,739,310 | 13.1% |
| Z80 CamelForth v101 | E | 279,923,791 | 261,695,086 | 6.5% |
| Z80 CamelForth v101 | TTT | 1,483,675,222 | 1,264,916,303 | 14.7% |

## Changes

* Sieve uses a guarded `DO ... +LOOP` for marking multiples and keeps just
  the final pass count. The old version leaked nine counts onto the data stack.
* E keeps its accumulator on the data stack instead of in global `X`, reuses
  `/MOD` results, and drops both loop bookkeeping values when finished.
  The old version leaked its final high-water index (`9`). Its existing
  space-separated numeric output is preserved.
* TTT passes the last move explicitly, checks only winning lines through that
  move, reuses its board address, and keeps returned scores on the stack.
  Recursive move enumeration uses `DO`/`I` instead of global `boardIndex`.
  DX-Forth and CamelForth use `UNLOOP EXIT` on cutoffs; F83 uses its native
  immediate `LEAVE`, followed by the normal score return. No kernel is changed.
  Portable `< 0=` / `> 0=` comparisons avoid DX-Forth's missing `>=` / `<=`.

## Reproduce and validate

From this repository root:

```sh
python3 bench_forth.py --emulator ../ntvcm/ntvcm --output /tmp/forth-current.json
```

The runner works in temporary copies and leaves the checkout unchanged. It
independently checks all 192 digits using Python Decimal, the 1899-prime result,
TTT ties and node count, preservation of a caller stack value, and zero stack
growth. All updated examples pass those checks in all included Forth versions.
For a baseline checkout, use `--root /path/to/old/checkout` with
`--allow-old-stack-leaks`; this records the known old stack leaks while still
checking application results. `--samples` changes the number of invocations.

F83 source is temporarily converted into 1024-byte screens and loaded with
`FROM TEST.BLK 1 LOAD`. This avoids counting long, host-scheduled keyboard
polling loops while feeding entire source files as keystrokes. DX-Forth uses
`include TEST.F`; CamelForth uses redirected input. The usual `m.sh` and
`m.bat` workflows still run the examples normally. DOS keyboard/timer activity
causes some cycle variation, so the raw samples and binary SHA-256 are retained
in [forth-benchmark-results.json](forth-benchmark-results.json). Results measure
the local emulator binaries; no emulator changes are part of this update.

Intel PL/M-80 v4.1, the 1976 PL/M-80 cross-compiler that ran as a PDP-10
Fortran program on Tymshare. It runs today through the plm80 tools in the
ntvcm repository (https://github.com/davidly/ntvcm/tree/main/plm80), which
recover the compiler from an archived Tymshare tape and emulate the PDP-10.
The compiler images are not included here or there.

SIEVE.PLM, E.PLM and TTT.PLM are ports of the PLMX benchmarks in
"../Systems Consultants PLMX v23". Changes for this early dialect:

- No operating-system interface: MON1 jumps to the BDOS at 5. The compiler
  passes the last argument in E/DE and the one before in C/BC, as the BDOS
  expects. Programs start at 100H: and end with CALL MON1(0,0).
- No inline string constants or (*) dimensions: strings are INITIAL arrays.
  Declaring them after the 8K sieve array made PLM82 fail with ERROR 102.
- Uppercase only: the compiler turns other characters into spaces, even in
  strings, and ignores columns past 72.
- PRT$NUM resets its last digit so a value of 0 prints. The PLMX version left
  it blank, which dropped zeros from e's digits.
- No recursion (like PLMX): TTT's MINMAX saves each level's alpha, beta,
  value, move and piece in arrays and loops instead of calling itself. The
  search and the 6493-move count are unchanged.

Build with m.sh / m.bat (for example "./m.sh sieve"), then "ntvcm SIEVE".
4 MHz Z80 times from ntvcm -p: sieve 18,459 ms, e 28,135 ms, ttt 57,638 ms;
TTT.COM is 2,683 bytes.

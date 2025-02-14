# cpm_compilers
CP/M 2.2 compilers, assemblers, and interpreters

The license for this repo applies to code I wrote for this repo including versions of the sieve, e, ttt, and tm benchmarks and the build scripts to invoke the tools. The various CP/M 2.2 tools and documentation each have their own respective license terms. In a few cases I used the sieve benchmark that shipped with the tools, so obviously those copies fall under the license of the respective tool.

I do not own the copyright for any of these tools. This repo is simply an aggregation of the tools to ease testing of my NTVCM CP/M 2.2 emulator.

In some cases where required I've copied an assembler or linker that did not ship with a given compiler into folders so binaries can be produced. These tools belong to their respective owners.

These tools are available for download from many sites on the internet. They are often in forms that make their extraction and/or use difficult. This repo simplifies the process.

**If you own the copyright to any of these tools and want me to take them down, please let me know and I'll do so ASAP. It's not my intention to pirate anyone's software.**

I cannot vouch that any of these tools matches their official distribution form. Many of these were apparently taken from snapshots on peoples' machines through the years and include changes, files, and/or configuration not found in a pristine distribution. The FTL Modula-2 compiler install is broken in that the Write family of functions can't be linked. See the benchmarks for a work-around.

In some cases I've included user manuals in PDF form that I've found online for the various compilers. They sometimes match the version and sometimes not, but they are always helpful.

I can vouch that the m.bat script in each folder builds working benchmark binaries. In the cases of tools that can't be invoked via the command-line (e.g. Turbo Pascal), those tools also produce working benchmark binaries.

It is my intention to show each tool in its best light with respect to the benchmarks. If you know of better optimization flags or ways to improve the benchmark source code for a given tool, please feel free to submit a pull request or open an issue. That said, I want to avoid cheap hacks like using peek/poke in BASIC instead of variables.

The benchmarks include:
  * sieve: The classic from BYTE Magazine that counts prime numbers. Measures array and loop performance.
  * e: Computes the irrational number e to 192 digits. Measures integer multiply/divide along with array and loop performance.
  * ttt: proves you can't win at tic-tac-toe if the opponent is competent. Measures function call and stack access along with array and loop performance.
  * tm: test malloc. This calls malloc/calloc/free in the C runtime to measure performance. It's C only and many compilers can't run it.

To run the compilers on Windows, use the m.bat script in each folder. e.g.:
  * m sieve
  * m e
  * m ttt

On Linux or MacOS use m.sh:
  * m.sh sieve
  * m.sh e
  * m.sh ttt

To run the resulting apps, use NTVCM's -c flag to force console mode and -p flag to show performance information. The interpreters have other modes for running; see their respective m.bat files for details.
  * ntvcm -c -p sieve
  * ntvcm -c -p e
  * ntvcm -c -p ttt
 
The m80 Z80 Macro Assembler only has ttt.mac and no sieve or e implementations. The 8080 code in the asm folder is already faster than any Z80 code the compilers produce.

The Borland Pascal and Modula-2 products don't support command-line builds, so you have to run the apps, load the source file, and build manually.

The build scripts assume ntvcm is in your path. Linux systems generally have case-sensitive file systems and CP/M generally forces uppercase filenames. You're best off if you change all tool files, source files, and arguments to uppercase on Linux.

If you're running Linux or MacOS and see perplexing compilation errors, it could be your source files don't have cr/lf line separators. Use unix2dos to add them; nearly all these compilers require them. Some compilers require a ^Z / 0x1a at the end of files. Since CP/M text files end in ^z/0x1a, unix2dos requires -f to force the conversion of what it thinks is a binary file.

The BA compiler is in the [tic-tac-toe and its applicability to nuclear war](https://github.com/davidly/ttt) repo. It generates code for 6502, 8080, 8086, x86, x64, arm32, arm64, and 64-bit RISC-V.

The Cowgol 0.6.1 compiler has not yet been tested with NTVCM and the benchmark and build scripts don't yet exist. If you have the interest have at it and send a pull request.

Here are runtimes for the benchmarks in milliseconds for a 4Mhz Z80 as emulated by [NTVCM](https://github.com/davidly/ntvcm/)

![table](https://github.com/user-attachments/assets/ad2a31c7-6503-418b-8ffe-079afa083f15)

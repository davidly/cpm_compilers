# cpm_compilers
CP/M 2.2 compilers, assemblers, and interpreters

The license for this repo applies to code I wrote for this repo including versions of the sieve, e, ttt, and tm benchmarks and the build scripts to invoke the tools. The various CP/M 2.2 tools and documentation each have their own respective license terms. In a few cases I used the sieve benchmark that shipped with the tools, so obviously those copies fall under the license of the respective tool.

I do not own licensing for any of these tools. This repo is simply an aggregation of the tools to ease testing of my NTVCM CP/M 2.2 emulator.

These tools are available for download from many sites on the internet. They are often in forms that make their extraction and/or use difficult. This repo simplifies the process.

If you own the copyright to any of these tools and want me to take them down, please let me know and I'll do so ASAP. It's not my intention to pirate anyone's software.

I cannot vouch that any of these tools matches their official distribution form. Many of these were apparently taken from snapshots on peoples' machines through the years and include changes, files, and/or configuration not found in a pristine distribution.

I can vouch that the m.bat script in each folder builds working benchmark binaries. In the cases of tools that can't be invoked via the command-line (e.g. Turbo Pascal), those tools also produce working benchmark binaries.

It is my intention to show each tool in its best light with respect to the benchmarks. If you know of better optimization flags or ways to improve the benchmark source code for a given tool, please feel free to submit a pull request or open an issue. That said, I want to avoid cheap hacks like using peek/poke in BASIC instead of local variables :)

The benchmarks include:

  * sieve: The classic from BYTE Magazine.
  * e: Computes the irrational number e to 192 digits.
  * ttt: proves you can't win at tic-tac-toe if the opponent is competent
  * tm: test malloc. This calls malloc/calloc/free in the C runtime to measure performance. It's C only.

If you're running Linux or MacOS and see perplexing compilation errors, it could be your source files don't have cr/lf line separators. Use unix2dos to add them; nearly all these compilers require them.



MESCC v1.24 (14 Sep 2021), Mike's Enhanced Small C Compiler for Z80 and CP/M,
by Miguel Garcia / FloppySoftware.

The compiler is also available here:

https://github.com/MiguelVis/mescc

It's licensed under the GNU GPL v2; see COPYING.TXT and README.MD.

Unlike most compilers in this repo, it's a recent compiler, not something that
was used in the 1980's.

m.sh / m.bat build an app: CC compiles to Z80 assembly, CCOPT optimizes it,
ZSM assembles it to a .HEX file, and HEXTOCOM makes the .COM.

The read() implementation in libc.lib for this compiler is broken for some scenarios.

I've compiled the fixed version of read.c I downloaded from https://www.zimmers.net/anonftp/pub/cpm/programming/HiTech_C/

The resulting read.obj is in the main directory above this one.

When building, include read.obj on the build line like this:

    ntvcm -c c309.com %1.c read.obj -O -LF -DHISOFTC


#!/bin/bash
str=$(tr '[a-z]' '[A-Z]' <<< $1)

if [ ! -f "$str.COW" ]; then
    echo "Error: not a regular file: $str.COW"
    exit 1
fi

if [ ! -r "$str.COW" ]; then
    echo "Error: file not readable: $str.COW"
    exit 1
fi

ntvcm -r:0 INIT
# the cowgol passes read their data files past the soft eof; with ^z fill there,
# tokenise fails and so can codegen (depending on file sizes). 0 fill works.
ntvcm -r:0 TOKENISE runtime0.cow runtime1.cow runtime2.cow $str.COW

ntvcm -r:0 PARSER
ntvcm -r:0 TYPECHCK

rm IOPS.DAT > /dev/null 2>&1
mv IOPSOUT.DAT IOPS.DAT
ntvcm -r:0 BACKEND

rm IOPS.DAT
mv IOPSOUT.DAT IOPS.DAT
ntvcm -r:0 CLASSIFY
ntvcm -r:0 BLOCKIFY

rm IOPS.DAT
mv IOPSOUT.DAT IOPS.DAT
ntvcm -r:0 CODEGEN

rm IOPS.DAT
mv IOPSOUT.DAT IOPS.DAT
ntvcm -r:0 PLACER

rm IOPS.DAT
mv IOPSOUT.DAT IOPS.DAT
ntvcm -r:0 EMITTER

rm $str.COM > /dev/null 2>&1
mv COW.COM $str.COM


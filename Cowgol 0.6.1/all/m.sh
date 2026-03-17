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

ntvcm INIT
# note that tokenise fails if data past the soft eof is ^z. 0 works. hack is in ntvcm.
ntvcm TOKENISE runtime0.cow runtime1.cow runtime2.cow $str.COW

ntvcm PARSER
ntvcm TYPECHCK

rm IOPS.DAT > /dev/null 2>&1
mv IOPSOUT.DAT IOPS.DAT
ntvcm BACKEND

rm IOPS.DAT
mv IOPSOUT.DAT IOPS.DAT
ntvcm CLASSIFY
ntvcm BLOCKIFY

rm IOPS.DAT
mv IOPSOUT.DAT IOPS.DAT
ntvcm CODEGEN

rm IOPS.DAT
mv IOPSOUT.DAT IOPS.DAT
ntvcm PLACER

rm IOPS.DAT
mv IOPSOUT.DAT IOPS.DAT
ntvcm EMITTER

rm $str.COM > /dev/null 2>&1
mv COW.COM $str.COM


#!/bin/bash
str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.PCO 2>/dev/null

ntvcm -c PRUN PASCAL $str.PAS, L=$str.LST
ntvcm -p -c PRUN $str.PCO

rm $str.PCO 2>/dev/null
rm $str.LST 2>/dev/null

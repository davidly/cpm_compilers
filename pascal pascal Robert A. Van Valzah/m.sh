#!/bin/bash
str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.PCO 2>/dev/null
rm $str.OCO 2>/dev/null
rm $str.COM 2>/dev/null

# pascal1 reads one character from the console
echo x | ntvcm -c PASCAL1 $str.PAS $str.PCO
ntvcm -c PASCAL2 $str.PCO $str.OCO
cat PASCAL3.COM filler.dat $str.OCO >>$str.COM

rm $str.PCO 2>/dev/null
rm $str.OCO 2>/dev/null

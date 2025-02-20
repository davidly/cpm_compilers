str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COM 2>/dev/null
rm $str.S 2>/dev/null
rm $str.O 2>/dev/null
rm $str.TM1 2>/dev/null
rm $str.TM2 2>/dev/null

ntvcm PP -x -o $str.TM1 $str.C
ntvcm P1 -b0 -n8 -o $str.TM2 $str.TM1
ntvcm P280 -o $str.S $str.TM2
ntvcm AS80 -o $str.O $str.S
ntvcm LINK -eb__memory -ed__edata -tb0x100 -htr -o $str.COM CRTS.80 $str.O LIBU.80 LIBC.80

rm $str.S 2>/dev/null
rm $str.O 2>/dev/null
rm $str.TM1 2>/dev/null
rm $str.TM2 2>/dev/null

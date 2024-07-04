str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COM 2>/dev/null
rm $str.S 2>/dev/null
rm $str.O 2>/dev/null
rm $str.TM1 2>/dev/null
rm $str.TM2 2>/dev/null

ntvcm PP -x -o $str.TM1 $str.C
ntvcm P1 -b0 -n8 -o $str.TM2 $str.TM1
ntvcm P2 -o $str.S $str.TM2
ntvcm AN -o $str.O $str.S
ntvcm LD80 -o $str.COM CHDR.R $str.O CLIB.A MLIB.A

rm $str.S 2>/dev/null
rm $str.O 2>/dev/null
rm $str.TM1 2>/dev/null
rm $str.TM2 2>/dev/null

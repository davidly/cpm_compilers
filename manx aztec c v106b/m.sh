str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.LST 2>/dev/null
rm $str.SYM 2>/dev/null
rm $str.ASM 2>/dev/null
rm $str.O 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm C80 -DAZTECCPM -T -F -DCPMTIME $str.C
ntvcm AS -L $str.ASM
ntvcm LN -T $str.O M.LIB C.LIB

rm $str.LST 2>/dev/null
rm $str.SYM 2>/dev/null
rm $str.ASM 2>/dev/null
rm $str.O 2>/dev/null

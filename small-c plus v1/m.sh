str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.ASM 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm CC0 $str
ntvcm ZOPT $str
ntvcm ZMAC $str=$str
ntvcm ZRES a: clib $str
ntvcm ZLINK $str=$str,IOLIB,CLIB

rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.ASM 2>/dev/null

echo 



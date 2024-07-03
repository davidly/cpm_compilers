str=${1^^}

rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.ASM 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm CC $str
ntvcm ZMAC $str=$str

# if you need floating point...
# ntvcm ZLINK $str,$str=$str,IOLIB,FLOAT,PRINTF2

# if you don't
ntvcm ZLINK $str,$str=$str,IOLIB,PRINTF1

rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.ASM 2>/dev/null

echo 



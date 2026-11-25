str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.ASM 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm CC $str
ntvcm ZMAC $str=$str

# floating point (MM) needs FLOAT and the printf that formats doubles
if [ "$str" = "MM" ]; then
    ntvcm ZLINK $str,$str=$str,IOLIB,FLOAT,PRINTF2
else
    ntvcm ZLINK $str,$str=$str,IOLIB,PRINTF1
fi

rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.ASM 2>/dev/null

echo 



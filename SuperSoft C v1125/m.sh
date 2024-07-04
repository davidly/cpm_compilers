str=$(tr '[a-z]' '[A-Z]' <<< $1)

ntvcm CC $str.C
ntvcm C2 $str.COD
ntvcm M80 =$str.ASM
ntvcm L80 $str,FORMATIO,CRUNT2,FUNC,STDIO,ALLOC,C2RT,$str/N/E:CCSTAR

rm $str.COD 2>/dev/null
rm $str.ASM 2>/dev/null
rm $str.REL 2>/dev/null


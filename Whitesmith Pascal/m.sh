str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COM 2>/dev/null
rm PRG.S 2>/dev/null
rm PRG.O 2>/dev/null
rm PRG.TM1 2>/dev/null
rm PRG.TM2 2>/dev/null

ntvcm PTC -o PRG.TM0 $str.PAS
ntvcm CPP -o PRG.TM1 -x PRG.TM0
ntvcm CP1 -cem -b0 -n8 -u -o PRG.TM2 PRG.TM1
ntvcm CP2 -o PRG.S PRG.TM2
rm PRG.TM1 2>/dev/null
rm PRG.TM2 2>/dev/null
ntvcm A80 -o PRG.O PRG.S
ntvcm LNK -u_main -eb__memory -tb0x100 -htr -o $str.COM CRTX.O PRG.O LIBP.80 LIBC.80

rm PRG.S 2>/dev/null
rm PRG.O 2>/dev/null

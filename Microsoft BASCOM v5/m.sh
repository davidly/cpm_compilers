str=$(tr '[a-z]' '[A-Z]' <<< $1)

ntvcm BASCOM $str=$str.BAS/Z
ntvcm L80 $str,$str/N/E



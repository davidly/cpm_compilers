str=$(tr '[a-z]' '[A-Z]' <<< $1)

ntvcm -8 MBASIC $str

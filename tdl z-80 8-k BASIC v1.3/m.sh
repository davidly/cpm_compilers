str=$(tr '[a-z]' '[A-Z]' <<< $1)

ntvcm -p SBASIC <$str.TXT

str=$(tr '[a-z]' '[A-Z]' <<< $1)

ntvcm -n -p SBASIC <$str.TXT

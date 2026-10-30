str=$(tr '[a-z]' '[A-Z]' <<< $1)

ntvcm ALGOL.COM $str
ntvcm -p ARUN.COM $str


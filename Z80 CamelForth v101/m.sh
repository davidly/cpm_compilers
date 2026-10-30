str=$(tr '[a-z]' '[A-Z]' <<< $1)

#ntvcm -p -f:$str.F CAMEL80
ntvcm -p CAMEL80 <$str.F

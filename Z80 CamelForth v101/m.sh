str=$(tr '[a-z]' '[A-Z]' <<< $1)

../ntvcm -p -f:$str.F CAMEL80

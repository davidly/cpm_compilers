str=$(tr '[a-z]' '[A-Z]' <<< $1)

ntvcm CC.COM $str.C -o
ntvcm CLINK.COM $str -sw


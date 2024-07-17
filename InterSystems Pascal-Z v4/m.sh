str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COM 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.REL 2>/dev/null
rm $str.SRC 2>/dev/null

ntvcm PASCAL48 $str

# pasopt just goes into an infinite loop writing to the output file
# ntvcm pasopt %1.SRC

ntvcm ASMBL main,$str/rel

# /e means link. /g means link and run
ntvcm LINK $str /n:$str /e

rm $str.LST 2>/dev/null
rm $str.REL 2>/dev/null
rm $str.SRC 2>/dev/null

ntvcm -c -p $str

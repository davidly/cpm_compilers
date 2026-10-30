str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COM 2>/dev/null
rm $str.ORG 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.REL 2>/dev/null
rm $str.SRC 2>/dev/null

ntvcm PASCAL48 $str

# pasopt requires some uninitialized RAM to be non-zero to work. It depends on some other
# app having run to initialize that memory. It's a byte at BDOS - 30eh, which is 0fbeeh
# for NTVCM, which fills this byte for this app.
ntvcm PASOPT $str.SRC

ntvcm ASMBL main,$str/rel

# /e means link. /g means link and run
ntvcm LINK $str /n:$str /e

rm $str.ORG 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.REL 2>/dev/null
rm $str.SRC 2>/dev/null

ntvcm -c -p $str

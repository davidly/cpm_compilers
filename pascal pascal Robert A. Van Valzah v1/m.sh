#!/bin/bash
str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COM 2>/dev/null
rm A.PCO 2>/dev/null
rm A.OCO 2>/dev/null

ntvcm PPC $str.PAS A.PCO
ntvcm PFET A.PCO A.OCO

# the app is the runtime followed by the generated code
cat RTP.COM A.OCO > $str.COM

rm A.PCO 2>/dev/null
rm A.OCO 2>/dev/null

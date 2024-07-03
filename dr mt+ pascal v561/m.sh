str=${1^^}

rm $str.ERL 2>/dev/null
rm $str.PRN 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm MTPLUS $1 \$Z PA
ntvcm LINKMT $1,paslib,trancend,fpreals/S

rm $str.ERL 2>/dev/null
rm $str.PRN 2>/dev/null

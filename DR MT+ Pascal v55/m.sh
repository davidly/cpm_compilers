str=$(tr '[a-z]' '[A-Z]' <<< $1)

ntvcm MTPLUS $str \$Z
ntvcm LINKMT $str,paslib,fpreals
# ntvcm LINKMT %1,paslib

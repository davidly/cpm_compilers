
str=$(tr '[a-z]' '[A-Z]' <<< $1)

ntvcm MC $str
echo
ntvcm ML $str
echo 


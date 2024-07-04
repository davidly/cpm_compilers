str=$(tr '[a-z]' '[A-Z]' <<< $1)

ntvcm JANUS $str /L
ntvcm JLINK $str



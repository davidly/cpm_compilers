#!/bin/bash
str=$(tr '[a-z]' '[A-Z]' <<< $1)

ntvcm -n -c F83.COM <$str.F

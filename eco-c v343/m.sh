#!/bin/bash

str=${1^^}

rm $str.MAC 2>/dev/null
rm $str.REL 2>/dev/null
rm $str.COM 2>/dev/null

ntvcm CP.COM $str.C
ntvcm M80.COM =$str
ntvcm L80.COM $str,bdos,qsort,$str/N/E

rm $str.MAC 2>/dev/null
rm $str.REL 2>/dev/null


#!/bin/bash
# Build e.g. "./m.sh sieve" with Intel's PL/M-80 4.1 through ntvcm's plm80
# tools; set NTVCM to the ntvcm repository (default: ../../ntvcm).
str=$(tr '[a-z]' '[A-Z]' <<< $1)
"${PYTHON:-python3}" "${NTVCM:-../../ntvcm}/plm80/compile.py" $str.PLM -o $str.COM

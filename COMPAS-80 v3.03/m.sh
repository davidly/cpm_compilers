#!/bin/sh
set -eu
CDPATH= cd -- "$(dirname -- "$0")"
exec ntvcm -c COMPASCL.COM "$@" < /dev/null

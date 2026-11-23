#!/bin/sh
set -eu
CDPATH= cd -- "$(dirname -- "$0")"
exec ntvcm -c BLSPASCL.COM "$@" < /dev/null

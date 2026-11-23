#!/bin/sh
set -eu
CDPATH= cd -- "$(dirname -- "$0")"
exec ntvcm -c M2CL.COM "$@" < /dev/null

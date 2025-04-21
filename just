#!/usr/bin/env /bin/sh

set -o errtrace
set -o nounset
set -o pipefail
set -eu

function offer () {
    image="$(guix system image -t qcow2 --save-provenance config.scm)"
    cat $image | nc -l -p 8000
}

case "$1" in
    "offer") $@;;
    *) echo "Unknown subcommand $1"; exit 1;;
esac

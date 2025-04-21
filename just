#!/usr/bin/env /bin/sh

set -o errtrace
set -o nounset
set -o pipefail
set -eu

function offer () {
    image="$(guix system image -t qcow2 --save-provenance config.scm)"
    dir="$(mktemp -d)"
    path="$dir/image.qcow2"
    ln -s $image $path
    echo "listening on 8000"
    guix shell python -- python3 -m http.server -d $dir
}

case "$1" in
    "offer") $@;;
    *) echo "Unknown subcommand $1"; exit 1;;
esac

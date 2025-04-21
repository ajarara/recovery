#!/usr/bin/env /bin/sh

set -o errtrace
set -o nounset
set -o pipefail
set -eu

function build_sync () {
    image="$(guix system image -t qcow2 --save-provenance config.scm)"
    guix shell rsync -- rsync $image image.qcow2
}

function listen () {
    guix shell python -- python3 -m http.server
}

case "$1" in
    "build_sync" | "listen") $@;;
    *) echo "Unknown subcommand $1"; exit 1;;
esac

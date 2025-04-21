#!/usr/bin/env /bin/sh

set -o errtrace
set -o nounset
set -o pipefail
set -eu

function build () {
    guix system image -t qcow2 --save-provenance --image-size=20G config.scm
}

function offer () {
    image="$(build)"
    dir="$(mktemp -d)"
    path="$dir/image.qcow2"
    ln -s $image $path
    echo "listening on 8000"
    guix shell python -- python3 -m http.server -d $dir
}

function test () {
    image="$(build)"
    mutable="/tmp/image.qcow2"
    rsync -ra $image $mutable
    chmod +w $mutable
    sudo qemu-system-x86_64 --enable-kvm \
                       -device qemu-xhci \
                       -usb -device usb-host,vendorid=0x1050 \
                       -net user,hostfwd=tcp::8000-:8000,hostfwd=tcp::10022-:22 -net nic \
                       -vga virtio -device virtio-mouse -device virtio-keyboard \
                       -m 16G $mutable
}

case "$1" in
    "build" | "offer" | "test") $@;;
    *) echo "Unknown subcommand $1"; exit 1;;
esac

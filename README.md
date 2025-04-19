# security-key aided guix recovery
a convenient, easy to access place to minimize research needed during recovery scenarios (in case all computers are lost).

Security keys form the basis of my digital security, they're cheap, easy to offsite, can (and should) be pin guarded. Ootb guix does not support them, but it's in the cookbook. This gist consolidates the important info so that in case I don't have easy access to info I can just consult this simple playbook to get started.

There are two possible restore flows: either we are using qemu or running guix system natively. Both flows are well supported by off-the-shelf guix downloads, provided hosts are x86_64.
## restoring through qemu
- download the guix qemu image. 
- git clone this repository
- `rsync "$(guix system image -t qcow2 --save-provenance config.scm) ~/`
- stand up a python server (or use nc) and download the built image
- clone the self repository

## restoring on a bare install
- download the install disk
- set up the machine normally
- incorporate service definitions into the generated config
- clone the self repository

The self repository is where I have all guix configs, sops credentials. This is locked behind yubikey access. Once the self repository is accessed, things become much easier: restoring from backup, accessing credentials, updating deployments. From the point of view of this public repository, that is the end goal.

### useful links
- [github.com/ajarara/.emacs.d]()


### qemu flags for MacOS
swap out vendor id for your vendor (1050 is yubico), probably omitting it altogether works too.

rather than do ssh forwarding, we forward an arbitrary port: the only reason we want access is to download qcow files, we don't need to send anything (as far as I know)
```
qemu-system-x86_64 --accel hvf -cpu host \
                       -device qemu-xhci \
                       -usb -device usb-host,vendorid=0x1050 \
                       -net user,hostfwd=tcp::8000-:8000 -net nic \
                       -vga virtio -device virtio-mouse -device virtio-keyboard
                       -m $MEMORY $QCOW_IMAGE
```

### qemu flags for linux
the only difference is kvm acceleration instead of hvf
```
qemu-system-x86_64 --enable-kvm -cpu host \
                       -device qemu-xhci \
                       -usb -device usb-host,vendorid=0x1050 \
                       -net user,hostfwd=tcp::8000-:8000 -net nic \
                       -m $MEMORY $QCOW_IMAGE
```

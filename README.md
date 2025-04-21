# security-key aided guix recovery
a convenient, easy to access place to recover into a guix installation during recovery scenarios (in case all computers are lost).

Security keys form the basis of my digital security, they're cheap, easy to offsite, can (and should) be pin guarded. Guix does not support them ootb, but this github repo consolidates the important info so that in case I don't have easy access to info I can just consult this simple playbook to get started.

There are two possible restore flows: either we are using qemu or running guix system natively. Both flows are well supported by off-the-shelf guix downloads, provided hosts are x86_64. Testing has shown that restore flows in these two modes (qemu vs a bare install) are too different to consolidate into one path (as attempted in previous iterations).

## restoring through qemu
- download the guix qemu image: https://guix.gnu.org/download/
- launch it with the flags in the below sections
- `guix shell git -- git clone https://github.com/ajarara/recovery`
- `./just offer` builds the image and serves it over http
- pull the built image out into the host with curl or wget or whatever
- switch into the built image (don't reconfigure, actually kill the VM and boot from the host)
- use the yubikey capable image to clone the self repository and here you can switch into that qemu config directly

## restoring on a bare install
- download the install disk: https://guix.gnu.org/download/
- go through the installer
- right before the install occurs (and after config is generated and written to disk), switch into another virtual terminal
- git clone this repository
- run substitutes.sh (adds nonguix as a channel, adds nonguix substitute servers)
- source the preamble (it points to the substitute servers)
- use the non-free linux kernel (see nonfree.scm)
- copy-paste the service definitions in sk-services.scm into the generated config

The self repository is where I have all guix configs, sops credentials. This is locked behind yubikey access. Once the self repository is accessed, things become much easier: restoring from backup, accessing credentials, updating deployments. From the point of view of this public repository, that is the end goal.

### useful links
- [github.com/ajarara/.emacs.d]()

### qemu flags for MacOS
These config options should be good for any image, however they were tested to maximize time to build for qemu images.

Now for some reason building in the recovery image is _really_ slow, though these flags improve things. I'm not sure why, and it's probably not worth investing time in fixing it since it'll make things more complicated (for example, relying on virt-manager to generate a better config means a lengthy host install process and a flaky gui whereas this uses qemu raw).

Once you're in a 'real' qemu host things improve much more.

An explanation of the config:
- We sudo here for USB passthrough (otherwise, you'll see the key but won't actually be able to interact with it).
- qemu-xhci is not the default afaict, it gets usb forwarding working
- forward ssh, forward the port that the python http.server uses (for simplicity, it can be changed, but one less thing to remember)
- use virtio for vga -- this makes things feel native, and has the UI respond to resizes
- hvf/kvm acceleration
- use virtio for the mouse, keyboard. the trackpad feels native with this.
- use virtio for the file system (for speed)
- optionally, use `-nographic` or `-display none`

```
sudo qemu-system-x86_64 -cpu max -smp 6 \
                       -device qemu-xhci \
                       -usb -device usb-host,vendorid=0x1050 \
                       -net user,hostfwd=tcp::10022-:22,hostfwd=tcp::8000-:8000 -net nic \
                       -vga virtio \
                       -accel hvf \
                       -vga virtio -device virtio-mouse -device virtio-keyboard \
                       -m $MEMORY -drive file=$QCOW_IMAGE,if=virtio
```

### qemu flags for linux
kvm acceleration instead of hvf. We might need sudo, depending on the host OS (guix needs it).
```
qemu-system-x86_64 --enable-kvm \
                       -device qemu-xhci \
                       -usb -device usb-host,vendorid=0x1050 \
                       -net user,hostfwd=tcp::8000-:8000,hostfwd=tcp::10022-:22 -net nic \
                       -vga virtio -device virtio-mouse -device virtio-keyboard \
                       -m $MEMORY $QCOW_IMAGE
```


### TODO
Why does generation of the recovery image with a vda layout result in an _sda_ layout? Is this a given? It seems to work on linux.

# a repo for recovery
a convenient place to put bare minimum configuration + encrypted backup creds so that backup recovery can be done with as little research as possible.

The restore flow looks something like:
- have a new computer, USB
- use an off the shelf guix ISO, burn to USB (using any OS)
- install normally (so that all the boot/luks partitioning complexity is handled by the gui installer)
- reboot into the fresh machine
- `guix install git restic gpg`
- clone this repository (or just download the tree)
- stick in a yubikey and use the kit in recovery to... recover.

### yubikey-restic.scm
contains yubikey configuration: namely pcscd, yubikey udev rules

### channels.scm
place in .config/guix/channels.scm

(just for nonguix, easily found online I'm just making this a one stop shop for recovery)

on that note, also download and authorize the signing key: https://substitutes.nonguix.org/signing-key.pub

### pub
public half of gpg keys.

to create it:
```
gpgtar -e -o keys --symmetric *.pub ownertrust.txt
```

to decrypt:
```
gpgtar -d pub
```

phrase is name of repo

### backup
contains restic information, encrypted to the public keys above

## additional notes
to get block ids: sudo blkid

mapped-device-uuid is the underlying block device of the crypt

boot-device-uuid is the vfat boot partition, everything else should be drop in

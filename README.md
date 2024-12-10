# a repo for recovery
a convenient place to put bare minimum configuration + encrypted creds so that backup recovery can be done with as little research as possible

### yubikey-restic.scm
contains yubikey configuration: namely pcscd, yubikey udev rules

### channels.scm
place in .config/guix/channels.scm

(just for nonguix, easily found online I'm just making this a one stop shop for recovery)

### pub
public half of gpg keys. It would be great to not have to upload this but public keys are designed to be uploaded so I'm not too worried

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

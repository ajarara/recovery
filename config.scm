;; guix system build config.scm
(use-modules
 (gnu bootloader)
 (gnu bootloader grub)
 (gnu packages)
 (gnu services base)
 (gnu services desktop)
 (gnu services ssh)
 (gnu services security-token)
 (gnu system)
 (gnu system file-systems)
 (gnu system keyboard)
 (guix gexp))

(define %nonguix-signing-key
  (plain-file "nonguix-signing-key.pub"
"(public-key 
 (ecc 
  (curve Ed25519)
  (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)
  )
 )"))

(operating-system
  (host-name "recovery")
  (timezone "America/New_York")
  (locale "en_US.utf8")
  (keyboard-layout (keyboard-layout "us"))
  (services
   (cons*
    (service pcscd-service-type)
    (udev-rules-service 'yubikey-rules
                        (specification->package+output "libfido2")
                        #:groups '("plugdev"))
    (service openssh-service-type
             (openssh-configuration
              (allow-empty-passwords? #t)))
    (modify-services %desktop-services
      (guix-service-type
       config =>
       (guix-configuration
        (inherit config)
        (substitute-urls
         (cons* "https://substitutes.nonguix.org" %default-substitute-urls))
        (authorized-keys
         (cons* %nonguix-signing-key
                %default-authorized-guix-keys))))
      )))
  (packages
   (append
    (specifications->packages
     (list
      "git"
      "gnupg"
      "emacs"
      "openssh"
      "parted"))
    %base-packages))
  (bootloader
   (bootloader-configuration
    (bootloader grub-bootloader)
    (targets '("/dev/sda"))
    (terminal-outputs '(console))))
  (file-systems
   (cons*
    (file-system
      (mount-point "/")
      (device "/dev/sda2")
      (type "ext4"))
    (file-system
      (mount-point "/gnu/store")
      (device "/dev/sda2")
      (type "ext4"))
    %base-file-systems))
  (users
   (cons*
    (user-account
     (name "ajarara")
     (password (crypt "" "salt"))
     (group "users")
     (supplementary-groups '("wheel" "netdev" "audio" "video" "plugdev")))
    %base-user-accounts)))

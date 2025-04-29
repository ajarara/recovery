;; guix system build config.scm
(use-modules
 (gnu bootloader)
 (gnu bootloader grub)
 (gnu packages)
 (gnu services base)
 (gnu services ssh)
 (gnu services networking)
 (gnu services security-token)
 (gnu system)
 (gnu system file-systems)
 (gnu system keyboard))


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
    (service network-manager-service-type)
    (service wpa-supplicant-service-type)
    (modify-services %base-services
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
      ;; remove after the guix qemu image updates to 1.5.0, where these are defaulted into %base-packages
      "nss-certs"
      "git"
      "gnupg"
      "emacs"
      "openssh"
      "parted"))
    %base-packages))
  (bootloader
   (bootloader-configuration
    (bootloader grub-bootloader)
    (targets '("/dev/vda"))
    (terminal-outputs '(console))))
  (file-systems
   (cons*
    (file-system
      (mount-point "/")
      (device "/dev/vda1")
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

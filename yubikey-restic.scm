(define-module (yubikey-restic)
  #:use-module (guix gexp)
  #:use-module (guix transformations)
  #:use-module (gnu services security-token)
  #:use-module (gnu services base))

(define yubikey-udev-rules
  (file->udev-rule
   "35-yubikey-udev.rules"
   (local-file "35-yubikey-udev.rules")))

(define yubikey-udev-rules-service
  (udev-rules-service 'yubikey-rules yubikey-udev-rules #:groups '("plugdev")))

;; for whatever reason, the current ccid expects glibc 3.28
;; and we updated to 3.29 in 70b2015ec5
;; I think it's due to a bad build, since simply updating to 1.5.3
;; (which triggers a rebuild of pcsc) fixes things
(define pcscd-fixed-configuration
  (let* ((ccid-transformer (options->transformation
                            '((with-version . "ccid=1.5.3"))))
         (ccid-transformed (ccid-transformer
                            (specification->package "ccid"))))
    (pcscd-configuration
     (usb-drivers
      (list ccid-transformed)))))

;; for wifi: (@ (nongnu packages linux) linux iwlwifi)
;; (kernel linux)
;; (firmware (cons* iwlwifi-firmware %base-firmware))

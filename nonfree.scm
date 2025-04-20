(use-modules (nongnu packages linux)
             (nongnu system linux-initrd))

(define (transformer operating-system-config)
  (operating-system
   (inherit operating-system-config)
   (kernel linux)
   (initrd microcode-initrd)
   (firmware (cons* linux-firmware %base-firmware))))

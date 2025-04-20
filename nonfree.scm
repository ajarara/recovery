(define (transformer operating-system-config)
  (operating-system
   (inherit operating-system-config)
   (kernel (@ (nongnu packages linux) linux))
   (initrd (@ (nongnu system linux-initrd) microcode-initrd))
   (firmware (cons* (@ (nongnu packages linux) linux-firmware) %base-firmware))))

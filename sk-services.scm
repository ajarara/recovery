(use-modules (gnu packages security-token)
             (gnu services)
             (gnu services base)
             (gnu services security-token))

;; the rules require users to be added to the plugdev group
(define sk-services
    (list
     (udev-rules-service 'fido2 libfido2 #:groups '("plugdev"))
     (service pcscd-service-type)))

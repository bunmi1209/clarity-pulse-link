;; Health Data Storage Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-invalid-data (err u101))

;; Data structures
(define-map health-records
  principal
  {
    heart-rate: uint,
    steps: uint,
    last-updated: uint,
    device-id: (string-utf8 36)
  }
)

;; Public functions
(define-public (store-health-data 
  (heart-rate uint) 
  (steps uint) 
  (device-id (string-utf8 36)))
  (let
    (
      (user tx-sender)
      (timestamp (get-block-info? time (- block-height u1)))
    )
    (ok (map-set health-records
      user
      {
        heart-rate: heart-rate,
        steps: steps,
        last-updated: (default-to u0 timestamp),
        device-id: device-id
      }
    ))
  )
)

;; Read only functions
(define-read-only (get-health-data (user principal))
  (ok (map-get? health-records user))
)

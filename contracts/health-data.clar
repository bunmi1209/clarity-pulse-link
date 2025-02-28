;; Health Data Storage Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-invalid-data (err u101))
(define-constant err-invalid-range (err u102))

;; Data validation constants
(define-constant max-heart-rate u220)
(define-constant max-daily-steps u100000)

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

;; Events
(define-data-var last-event-id uint u0)
(define-map events
  uint
  {
    user: principal,
    heart-rate: uint,
    steps: uint,
    timestamp: uint
  }
)

;; Private functions
(define-private (validate-health-data (heart-rate uint) (steps uint))
  (if (and
    (<= heart-rate max-heart-rate)
    (<= steps max-daily-steps))
    (ok true)
    err-invalid-range
  )
)

;; Public functions
(define-public (store-health-data 
  (heart-rate uint) 
  (steps uint) 
  (device-id (string-utf8 36)))
  (let
    (
      (user tx-sender)
      (timestamp (unwrap! (get-block-info? time (- block-height u1)) err-invalid-data))
      (validation-result (try! (validate-health-data heart-rate steps)))
    )
    (map-set health-records
      user
      {
        heart-rate: heart-rate,
        steps: steps,
        last-updated: timestamp,
        device-id: device-id
      }
    )
    (var-set last-event-id (+ (var-get last-event-id) u1))
    (map-set events (var-get last-event-id)
      {
        user: user,
        heart-rate: heart-rate,
        steps: steps,
        timestamp: timestamp
      }
    )
    (ok true)
  )
)

;; Read only functions
(define-read-only (get-health-data (user principal))
  (ok (map-get? health-records user))
)

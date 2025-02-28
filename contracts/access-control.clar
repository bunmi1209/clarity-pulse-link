;; Access Control Contract

;; Constants
(define-constant err-unauthorized (err u100))

;; Data structures
(define-map authorized-providers
  { user: principal, provider: principal }
  { authorized: bool }
)

;; Events
(define-data-var last-event-id uint u0)
(define-map access-events
  uint
  {
    user: principal,
    provider: principal,
    action: (string-utf8 10),
    timestamp: uint
  }
)

;; Public functions
(define-public (grant-access (provider principal))
  (let
    ((timestamp (unwrap! (get-block-info? time (- block-height u1)) err-unauthorized)))
    (map-set authorized-providers
      { user: tx-sender, provider: provider }
      { authorized: true }
    )
    (var-set last-event-id (+ (var-get last-event-id) u1))
    (map-set access-events (var-get last-event-id)
      {
        user: tx-sender,
        provider: provider,
        action: "grant",
        timestamp: timestamp
      }
    )
    (ok true)
  )
)

(define-public (revoke-access (provider principal))
  (let
    ((timestamp (unwrap! (get-block-info? time (- block-height u1)) err-unauthorized)))
    (map-set authorized-providers
      { user: tx-sender, provider: provider }
      { authorized: false }
    )
    (var-set last-event-id (+ (var-get last-event-id) u1))
    (map-set access-events (var-get last-event-id)
      {
        user: tx-sender,
        provider: provider,
        action: "revoke",
        timestamp: timestamp
      }
    )
    (ok true)
  )
)

;; Read only functions
(define-read-only (check-access (user principal) (provider principal))
  (default-to
    { authorized: false }
    (map-get? authorized-providers { user: user, provider: provider })
  )
)

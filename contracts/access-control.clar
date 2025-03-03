;; Access Control Contract

;; Constants
(define-constant err-unauthorized (err u100))
(define-constant err-already-set (err u101))

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
    timestamp: uint,
    success: bool
  }
)

;; Private functions
(define-private (verify-access-status (provider principal) (expected-status bool))
  (let ((current-status (get authorized (default-to 
    { authorized: false }
    (map-get? authorized-providers { user: tx-sender, provider: provider })))))
    (if (is-eq current-status expected-status)
      err-already-set
      (ok true))
  )
)

;; Public functions
(define-public (grant-access (provider principal))
  (let
    (
      (timestamp (unwrap! (get-block-info? time (- block-height u1)) err-unauthorized))
      (status-check (try! (verify-access-status provider true)))
    )
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
        timestamp: timestamp,
        success: true
      }
    )
    (ok true)
  )
)

(define-public (revoke-access (provider principal))
  (let
    (
      (timestamp (unwrap! (get-block-info? time (- block-height u1)) err-unauthorized))
      (status-check (try! (verify-access-status provider false)))
    )
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
        timestamp: timestamp,
        success: true
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

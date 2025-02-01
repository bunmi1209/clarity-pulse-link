;; Access Control Contract

;; Constants
(define-constant err-unauthorized (err u100))

;; Data structures
(define-map authorized-providers
  { user: principal, provider: principal }
  { authorized: bool }
)

;; Public functions
(define-public (grant-access (provider principal))
  (ok (map-set authorized-providers
    { user: tx-sender, provider: provider }
    { authorized: true }
  ))
)

(define-public (revoke-access (provider principal))
  (ok (map-set authorized-providers
    { user: tx-sender, provider: provider }
    { authorized: false }
  ))
)

;; Read only functions
(define-read-only (check-access (user principal) (provider principal))
  (default-to
    { authorized: false }
    (map-get? authorized-providers { user: user, provider: provider })
  )
)

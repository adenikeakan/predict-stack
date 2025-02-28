;; PredictStack: Simple Base Implementation
;; Basic prediction market factory for Stacks blockchain

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-PARAMETERS (err u101))
(define-constant MINIMUM-CREATION-FEE u1000000) ;; 1 STX in microSTX

;; Data maps
(define-map markets 
  { market-id: uint }
  { 
    creator: principal,
    question: (string-utf8 256),
    outcomes: (list 5 (string-utf8 64)),
    resolution-deadline: uint,
    creation-block: uint,
    is-resolved: bool
  }
)

;; Variables
(define-data-var last-market-id uint u0)
(define-data-var creation-fee uint MINIMUM-CREATION-FEE)

;; Read-only functions

(define-read-only (get-market (market-id uint))
  (map-get? markets { market-id: market-id })
)

(define-read-only (get-last-market-id)
  (var-get last-market-id)
)

(define-read-only (get-creation-fee)
  (var-get creation-fee)
)

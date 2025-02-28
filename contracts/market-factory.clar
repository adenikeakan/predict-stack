;; PredictStack Market Factory Contract
;; This contract is responsible for creating new prediction markets and tracking them

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-PARAMETERS (err u101))
(define-constant ERR-MARKET-ALREADY-EXISTS (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-DEADLINE-PASSED (err u104))
(define-constant ERR-INVALID-OUTCOMES (err u105))
(define-constant ERR-MARKET-NOT-FOUND (err u106))
(define-constant MINIMUM-CREATION-FEE u1000000) ;; 1 STX in microSTX

;; Data maps
(define-map markets 
  { market-id: uint }
  { 
    creator: principal,
    question: (string-utf8 256),
    description: (string-utf8 1024),
    outcomes: (list 5 (string-utf8 64)),
    outcome-count: uint,
    resolution-deadline: uint,
    creation-block: uint,
    contract-address: principal,
    is-resolved: bool,
    status: (string-ascii 20)
  }
)

;; Creator to markets mapping
(define-map creator-markets
  { creator: principal }
  { market-ids: (list 100 uint) }
)

;; Variables
(define-data-var last-market-id uint u0)
(define-data-var treasury-address principal CONTRACT-OWNER)
(define-data-var creation-fee uint MINIMUM-CREATION-FEE)
(define-data-var is-paused bool false)

;; Private functions
(define-private (is-owner)
  (is-eq tx-sender CONTRACT-OWNER)
)

(define-private (add-market-to-creator-list (creator principal) (market-id uint))
  (let
    (
      (current-markets (default-to { market-ids: (list) } (map-get? creator-markets { creator: creator })))
      (current-market-list (get market-ids current-markets))
      (new-market-list (unwrap! (as-max-len? (append current-market-list market-id) u100) ERR-INVALID-PARAMETERS))
    )
    (map-set creator-markets { creator: creator } { market-ids: new-market-list })
    (ok true)
  )
)

(define-private (validate-outcomes (outcomes (list 5 (string-utf8 64))))
  (let
    (
      (outcome-count (len outcomes))
    )
    (and 
      (>= outcome-count u2) ;; Must have at least 2 outcomes
      (<= outcome-count u5) ;; Cannot have more than 5 outcomes
    )
  )
)

;; Read-only functions
(define-read-only (get-market (market-id uint))
  (map-get? markets { market-id: market-id })
)

(define-read-only (get-markets-by-creator (creator principal))
  (map-get? creator-markets { creator: creator })
)

(define-read-only (get-last-market-id)
  (var-get last-market-id)
)

(define-read-only (get-creation-fee)
  (var-get creation-fee)
)

(define-read-only (is-contract-paused)
  (var-get is-paused)
)


;; Public functions

(define-public (create-market 
  (question (string-utf8 256)) 
  (outcomes (list 5 (string-utf8 64))) 
  (resolution-deadline uint))
  (let
    (
      (new-market-id (+ (var-get last-market-id) u1))
      (current-block block-height)
      (curr-fee (var-get creation-fee))
    )
    ;; Validate parameters
    (asserts! (> (len question) u0) ERR-INVALID-PARAMETERS)
    (asserts! (>= (len outcomes) u2) ERR-INVALID-PARAMETERS)
    (asserts! (> resolution-deadline current-block) ERR-INVALID-PARAMETERS)

    ;; Process creation fee
    (try! (stx-transfer? curr-fee tx-sender CONTRACT-OWNER))

    ;; Create market entry
    (map-set markets 
      { market-id: new-market-id }
      { 
        creator: tx-sender,
        question: question,
        outcomes: outcomes,
        resolution-deadline: resolution-deadline,
        creation-block: current-block,
        is-resolved: false
      }
    )

    ;; Update last market ID
    (var-set last-market-id new-market-id)

    ;; Return the new market ID
    (ok new-market-id)
  )
)

;; Admin functions

(define-public (set-creation-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set creation-fee new-fee)
    (ok true)
  )
)

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

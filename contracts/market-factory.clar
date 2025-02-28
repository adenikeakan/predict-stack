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

;; Public functions
(define-public (create-market 
  (question (string-utf8 256)) 
  (description (string-utf8 1024)) 
  (outcomes (list 5 (string-utf8 64))) 
  (resolution-deadline uint))
  (let
    (
      (new-market-id (+ (var-get last-market-id) u1))
      (current-block block-height)
      (curr-fee (var-get creation-fee))
      (outcome-count (len outcomes))
    )
    ;; Check if contract is paused
    (asserts! (not (var-get is-paused)) ERR-NOT-AUTHORIZED)
    
    ;; Validate parameters
    (asserts! (> (len question) u0) ERR-INVALID-PARAMETERS)
    (asserts! (validate-outcomes outcomes) ERR-INVALID-OUTCOMES)
    (asserts! (> resolution-deadline current-block) ERR-DEADLINE-PASSED)
    
    ;; Process creation fee
    (try! (stx-transfer? curr-fee tx-sender (var-get treasury-address)))
    
    ;; Create market entry
    (map-set markets 
      { market-id: new-market-id }
      { 
        creator: tx-sender,
        question: question,
        description: description,
        outcomes: outcomes,
        outcome-count: outcome-count,
        resolution-deadline: resolution-deadline,
        creation-block: current-block,
        contract-address: tx-sender, ;; To be updated later with actual contract address
        is-resolved: false,
        status: "active"
      }
    )
    
    ;; Add market to creator's list
    (try! (add-market-to-creator-list tx-sender new-market-id))
    
    ;; Update last market ID
    (var-set last-market-id new-market-id)
    
    ;; Return the new market ID
    (ok new-market-id)
  )
)

;; Update market contract address
(define-public (update-market-contract-address (market-id uint) (market-contract principal))
  (let
    (
      (market (unwrap! (map-get? markets { market-id: market-id }) ERR-MARKET-NOT-FOUND))
    )
    ;; Only allow creator to update contract address
    (asserts! (is-eq (get creator market) tx-sender) ERR-NOT-AUTHORIZED)

    ;; Update contract address
    (map-set markets
      { market-id: market-id }
      (merge market { contract-address: market-contract })
    )

    (ok true)
  )
)

;; Update market status
(define-public (update-market-status (market-id uint) (new-status (string-ascii 20)))
  (let
    (
      (market (unwrap! (map-get? markets { market-id: market-id }) ERR-MARKET-NOT-FOUND))
    )
    ;; Only allow owner or creator to update status
    (asserts! (or (is-eq (get creator market) tx-sender) (is-owner)) ERR-NOT-AUTHORIZED)

    ;; Update market status
    (map-set markets
      { market-id: market-id }
      (merge market { status: new-status })
    )

    (ok true)
  )
)

;; Mark market as resolved
(define-public (mark-market-resolved (market-id uint))
  (let
    (
      (market (unwrap! (map-get? markets { market-id: market-id }) ERR-MARKET-NOT-FOUND))
    )
    ;; Verify the caller is authorized (should be the market contract itself)
    (asserts! (is-eq (get contract-address market) tx-sender) ERR-NOT-AUTHORIZED)

    ;; Update resolution status
    (map-set markets
      { market-id: market-id }
      (merge market { is-resolved: true, status: "resolved" })
    )

    (ok true)
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

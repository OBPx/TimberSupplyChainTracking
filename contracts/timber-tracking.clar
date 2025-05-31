;; Timber Supply Chain Tracking Contract
;; Tracks timber from forest to consumer with sustainability verification

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-status (err u103))
(define-constant err-invalid-input (err u104))
(define-constant err-invalid-volume (err u105))
(define-constant err-empty-string (err u106))

;; Input validation helpers
(define-private (is-valid-string (str (string-ascii 50)))
  (> (len str) u0)
)

(define-private (is-valid-volume (volume uint))
  (> volume u0)
)

(define-private (is-valid-status (status uint))
  (and (>= status u1) (<= status u4))
)

(define-private (is-valid-batch-id (batch-id uint))
  (and (> batch-id u0) (< batch-id (var-get next-batch-id)))
)

(define-map timber-batches
  { batch-id: uint }
  {
    origin-forest: (string-ascii 50),
    harvest-date: uint,
    volume: uint,
    current-owner: principal,
    sustainability-certified: bool,
    current-status: uint,
    location: (string-ascii 50),
    history-count: uint
  }
)

(define-map batch-history
  { batch-id: uint, sequence: uint }
  {
    timestamp: uint,
    from-owner: principal,
    to-owner: principal,
    status: uint,
    location: (string-ascii 50)
  }
)

(define-data-var next-batch-id uint u1)

;; Status codes: 1=harvested, 2=processed, 3=shipped, 4=delivered
(define-public (create-timber-batch 
  (origin-forest (string-ascii 50)) 
  (volume uint) 
  (sustainability-certified bool)
  (location (string-ascii 50))
)
  (let ((batch-id (var-get next-batch-id)))
    ;; Input validation
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-valid-string origin-forest) err-empty-string)
    (asserts! (is-valid-volume volume) err-invalid-volume)
    (asserts! (is-valid-string location) err-empty-string)

    ;; Create batch record
    (map-set timber-batches
      { batch-id: batch-id }
      {
        origin-forest: origin-forest,
        harvest-date: block-height,
        volume: volume,
        current-owner: tx-sender,
        sustainability-certified: sustainability-certified,
        current-status: u1,
        location: location,
        history-count: u1
      }
    )

    ;; Create initial history entry
    (map-set batch-history
      { batch-id: batch-id, sequence: u1 }
      {
        timestamp: block-height,
        from-owner: tx-sender,
        to-owner: tx-sender,
        status: u1,
        location: location
      }
    )

    (var-set next-batch-id (+ batch-id u1))
    (ok batch-id)
  )
)

(define-public (transfer-batch (batch-id uint) (new-owner principal) (new-location (string-ascii 50)))
  (let (
    (batch (unwrap! (map-get? timber-batches { batch-id: batch-id }) err-not-found))
    (current-history-count (get history-count batch))
    (new-sequence (+ current-history-count u1))
  )
    ;; Input validation
    (asserts! (is-valid-batch-id batch-id) err-invalid-input)
    (asserts! (is-valid-string new-location) err-empty-string)
    (asserts! (is-eq tx-sender (get current-owner batch)) err-unauthorized)

    ;; Update batch record
    (map-set timber-batches
      { batch-id: batch-id }
      (merge batch { 
        current-owner: new-owner,
        location: new-location,
        history-count: new-sequence
      })
    )

    ;; Add history entry
    (map-set batch-history
      { batch-id: batch-id, sequence: new-sequence }
      {
        timestamp: block-height,
        from-owner: tx-sender,
        to-owner: new-owner,
        status: (get current-status batch),
        location: new-location
      }
    )

    (ok true)
  )
)

(define-public (update-batch-status (batch-id uint) (new-status uint) (location (string-ascii 50)))
  (let (
    (batch (unwrap! (map-get? timber-batches { batch-id: batch-id }) err-not-found))
    (current-history-count (get history-count batch))
    (new-sequence (+ current-history-count u1))
  )
    ;; Input validation
    (asserts! (is-valid-batch-id batch-id) err-invalid-input)
    (asserts! (is-valid-status new-status) err-invalid-status)
    (asserts! (is-valid-string location) err-empty-string)
    (asserts! (is-eq tx-sender (get current-owner batch)) err-unauthorized)

    ;; Update batch record
    (map-set timber-batches
      { batch-id: batch-id }
      (merge batch { 
        current-status: new-status,
        location: location,
        history-count: new-sequence
      })
    )

    ;; Add history entry
    (map-set batch-history
      { batch-id: batch-id, sequence: new-sequence }
      {
        timestamp: block-height,
        from-owner: tx-sender,
        to-owner: tx-sender,
        status: new-status,
        location: location
      }
    )

    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-batch-info (batch-id uint))
  (if (is-valid-batch-id batch-id)
    (map-get? timber-batches { batch-id: batch-id })
    none
  )
)

(define-read-only (get-batch-history (batch-id uint) (sequence uint))
  (if (and (is-valid-batch-id batch-id) (> sequence u0))
    (map-get? batch-history { batch-id: batch-id, sequence: sequence })
    none
  )
)

(define-read-only (get-batch-full-history (batch-id uint))
  (match (get-batch-info batch-id)
    batch (some (get history-count batch))
    none
  )
)

(define-read-only (get-total-batches)
  (- (var-get next-batch-id) u1)
)

(define-read-only (is-batch-sustainable (batch-id uint))
  (match (get-batch-info batch-id)
    batch (get sustainability-certified batch)
    false
  )
)

(define-read-only (get-current-owner (batch-id uint))
  (match (get-batch-info batch-id)
    batch (some (get current-owner batch))
    none
  )
)

(define-read-only (get-batch-status (batch-id uint))
  (match (get-batch-info batch-id)
    batch (some (get current-status batch))
    none
  )
)

(define-read-only (get-batch-location (batch-id uint))
  (match (get-batch-info batch-id)
    batch (some (get location batch))
    none
  )
)

;; Utility function to check if batch exists
(define-read-only (batch-exists (batch-id uint))
  (is-some (get-batch-info batch-id))
)
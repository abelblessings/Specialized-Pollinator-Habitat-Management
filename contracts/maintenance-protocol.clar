;; Maintenance Protocol Contract
;; Documents habitat management practices

;; Define data maps
(define-map maintenance-protocols
  { id: uint }
  {
    name: (string-ascii 100),
    description: (string-ascii 500),
    frequency: (string-ascii 50),
    season: (string-ascii 50),
    created-by: principal,
    creation-time: uint,
    active: bool
  }
)

;; Define data maps for protocol tasks
(define-map protocol-tasks
  { protocol-id: uint, task-id: uint }
  {
    name: (string-ascii 100),
    description: (string-ascii 200),
    estimated-hours: uint,
    equipment-needed: (string-ascii 200)
  }
)

;; Define data maps for maintenance logs
(define-map maintenance-logs
  { site-id: uint, log-id: uint }
  {
    protocol-id: uint,
    performed-by: principal,
    date: uint,
    hours-spent: uint,
    notes: (string-ascii 500),
    weather-conditions: (string-ascii 100)
  }
)

;; Define ID counters
(define-data-var next-protocol-id uint u1)
(define-data-var next-task-id uint u1)
(define-data-var next-log-id uint u1)

;; Error codes
(define-constant err-invalid-input u1)
(define-constant err-not-found u2)
(define-constant err-not-authorized u3)

;; Read-only functions
(define-read-only (get-maintenance-protocol (id uint))
  (map-get? maintenance-protocols { id: id })
)

(define-read-only (get-protocol-task (protocol-id uint) (task-id uint))
  (map-get? protocol-tasks { protocol-id: protocol-id, task-id: task-id })
)

(define-read-only (get-maintenance-log (site-id uint) (log-id uint))
  (map-get? maintenance-logs { site-id: site-id, log-id: log-id })
)

;; Public functions
(define-public (create-maintenance-protocol
    (name (string-ascii 100))
    (description (string-ascii 500))
    (frequency (string-ascii 50))
    (season (string-ascii 50)))

  (begin
    ;; Check inputs
    (asserts! (> (len name) u0) (err err-invalid-input))
    (asserts! (> (len description) u0) (err err-invalid-input))
    (asserts! (> (len frequency) u0) (err err-invalid-input))
    (asserts! (> (len season) u0) (err err-invalid-input))

    ;; Create protocol
    (map-set maintenance-protocols
      { id: (var-get next-protocol-id) }
      {
        name: name,
        description: description,
        frequency: frequency,
        season: season,
        created-by: tx-sender,
        creation-time: block-height,
        active: true
      }
    )

    ;; Increment protocol ID counter
    (var-set next-protocol-id (+ (var-get next-protocol-id) u1))

    ;; Return success with protocol ID
    (ok (- (var-get next-protocol-id) u1))
  )
)

(define-public (add-protocol-task
    (protocol-id uint)
    (name (string-ascii 100))
    (description (string-ascii 200))
    (estimated-hours uint)
    (equipment-needed (string-ascii 200)))

  (let ((protocol (unwrap! (get-maintenance-protocol protocol-id) (err err-not-found))))
    ;; Check authorization
    (asserts! (is-eq tx-sender (get created-by protocol)) (err err-not-authorized))

    ;; Check inputs
    (asserts! (> (len name) u0) (err err-invalid-input))
    (asserts! (> (len description) u0) (err err-invalid-input))
    (asserts! (> estimated-hours u0) (err err-invalid-input))

    ;; Add task
    (map-set protocol-tasks
      { protocol-id: protocol-id, task-id: (var-get next-task-id) }
      {
        name: name,
        description: description,
        estimated-hours: estimated-hours,
        equipment-needed: equipment-needed
      }
    )

    ;; Increment task ID counter
    (var-set next-task-id (+ (var-get next-task-id) u1))

    ;; Return success with task ID
    (ok (- (var-get next-task-id) u1))
  )
)

(define-public (log-maintenance-activity
    (site-id uint)
    (protocol-id uint)
    (hours-spent uint)
    (notes (string-ascii 500))
    (weather-conditions (string-ascii 100)))

  (begin
    ;; Check inputs
    (asserts! (> site-id u0) (err err-invalid-input))
    (asserts! (> protocol-id u0) (err err-invalid-input))
    (asserts! (> hours-spent u0) (err err-invalid-input))
    (asserts! (> (len notes) u0) (err err-invalid-input))
    (asserts! (> (len weather-conditions) u0) (err err-invalid-input))

    ;; Check protocol exists
    (asserts! (is-some (get-maintenance-protocol protocol-id)) (err err-not-found))

    ;; Log maintenance activity
    (map-set maintenance-logs
      { site-id: site-id, log-id: (var-get next-log-id) }
      {
        protocol-id: protocol-id,
        performed-by: tx-sender,
        date: block-height,
        hours-spent: hours-spent,
        notes: notes,
        weather-conditions: weather-conditions
      }
    )

    ;; Increment log ID counter
    (var-set next-log-id (+ (var-get next-log-id) u1))

    ;; Return success with log ID
    (ok (- (var-get next-log-id) u1))
  )
)

(define-public (update-protocol-status (protocol-id uint) (active bool))
  (let ((protocol (unwrap! (get-maintenance-protocol protocol-id) (err err-not-found))))
    ;; Check authorization
    (asserts! (is-eq tx-sender (get created-by protocol)) (err err-not-authorized))

    ;; Update protocol status
    (map-set maintenance-protocols
      { id: protocol-id }
      (merge protocol { active: active })
    )

    ;; Return success
    (ok true)
  )
)


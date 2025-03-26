;; Impact Assessment Contract
;; Monitors pollinator population responses

;; Define data maps
(define-map pollinator-species
  { id: uint }
  {
    scientific-name: (string-ascii 100),
    common-name: (string-ascii 100),
    type: (string-ascii 50),
    conservation-status: (string-ascii 50),
    registered-by: principal,
    registration-time: uint
  }
)

;; Define data maps for monitoring sessions
(define-map monitoring-sessions
  { id: uint }
  {
    site-id: uint,
    monitor: principal,
    date: uint,
    start-time: uint,
    end-time: uint,
    temperature: int,
    wind-speed: uint,
    cloud-cover: uint,
    notes: (string-ascii 200)
  }
)

;; Define data maps for pollinator observations
(define-map pollinator-observations
  { session-id: uint, observation-id: uint }
  {
    species-id: uint,
    count: uint,
    behavior: (string-ascii 50),
    plant-species-id: uint,
    notes: (string-ascii 200)
  }
)

;; Define data maps for site assessments
(define-map site-assessments
  { site-id: uint, assessment-id: uint }
  {
    assessor: principal,
    date: uint,
    pollinator-diversity-score: uint,
    pollinator-abundance-score: uint,
    habitat-quality-score: uint,
    recommendations: (string-ascii 500)
  }
)

;; Define ID counters
(define-data-var next-species-id uint u1)
(define-data-var next-session-id uint u1)
(define-data-var next-observation-id uint u1)
(define-data-var next-assessment-id uint u1)

;; Error codes
(define-constant err-invalid-input u1)
(define-constant err-not-found u2)
(define-constant err-not-authorized u3)

;; Read-only functions
(define-read-only (get-pollinator-species (id uint))
  (map-get? pollinator-species { id: id })
)

(define-read-only (get-monitoring-session (id uint))
  (map-get? monitoring-sessions { id: id })
)

(define-read-only (get-pollinator-observation (session-id uint) (observation-id uint))
  (map-get? pollinator-observations { session-id: session-id, observation-id: observation-id })
)

(define-read-only (get-site-assessment (site-id uint) (assessment-id uint))
  (map-get? site-assessments { site-id: site-id, assessment-id: assessment-id })
)

;; Public functions
(define-public (register-pollinator-species
    (scientific-name (string-ascii 100))
    (common-name (string-ascii 100))
    (type (string-ascii 50))
    (conservation-status (string-ascii 50)))

  (begin
    ;; Check inputs
    (asserts! (> (len scientific-name) u0) (err err-invalid-input))
    (asserts! (> (len common-name) u0) (err err-invalid-input))
    (asserts! (> (len type) u0) (err err-invalid-input))
    (asserts! (> (len conservation-status) u0) (err err-invalid-input))

    ;; Register species
    (map-set pollinator-species
      { id: (var-get next-species-id) }
      {
        scientific-name: scientific-name,
        common-name: common-name,
        type: type,
        conservation-status: conservation-status,
        registered-by: tx-sender,
        registration-time: block-height
      }
    )

    ;; Increment species ID counter
    (var-set next-species-id (+ (var-get next-species-id) u1))

    ;; Return success with species ID
    (ok (- (var-get next-species-id) u1))
  )
)

(define-public (create-monitoring-session
    (site-id uint)
    (start-time uint)
    (end-time uint)
    (temperature int)
    (wind-speed uint)
    (cloud-cover uint)
    (notes (string-ascii 200)))

  (begin
    ;; Check inputs
    (asserts! (> site-id u0) (err err-invalid-input))
    (asserts! (> end-time start-time) (err err-invalid-input))
    (asserts! (<= cloud-cover u100) (err err-invalid-input))

    ;; Create session
    (map-set monitoring-sessions
      { id: (var-get next-session-id) }
      {
        site-id: site-id,
        monitor: tx-sender,
        date: block-height,
        start-time: start-time,
        end-time: end-time,
        temperature: temperature,
        wind-speed: wind-speed,
        cloud-cover: cloud-cover,
        notes: notes
      }
    )

    ;; Increment session ID counter
    (var-set next-session-id (+ (var-get next-session-id) u1))

    ;; Return success with session ID
    (ok (- (var-get next-session-id) u1))
  )
)

(define-public (record-pollinator-observation
    (session-id uint)
    (species-id uint)
    (count uint)
    (behavior (string-ascii 50))
    (plant-species-id uint)
    (notes (string-ascii 200)))

  (let ((session (unwrap! (get-monitoring-session session-id) (err err-not-found))))
    ;; Check authorization
    (asserts! (is-eq tx-sender (get monitor session)) (err err-not-authorized))

    ;; Check inputs
    (asserts! (> species-id u0) (err err-invalid-input))
    (asserts! (> count u0) (err err-invalid-input))
    (asserts! (> (len behavior) u0) (err err-invalid-input))
    (asserts! (> plant-species-id u0) (err err-invalid-input))

    ;; Record observation
    (map-set pollinator-observations
      { session-id: session-id, observation-id: (var-get next-observation-id) }
      {
        species-id: species-id,
        count: count,
        behavior: behavior,
        plant-species-id: plant-species-id,
        notes: notes
      }
    )

    ;; Increment observation ID counter
    (var-set next-observation-id (+ (var-get next-observation-id) u1))

    ;; Return success with observation ID
    (ok (- (var-get next-observation-id) u1))
  )
)

(define-public (create-site-assessment
    (site-id uint)
    (pollinator-diversity-score uint)
    (pollinator-abundance-score uint)
    (habitat-quality-score uint)
    (recommendations (string-ascii 500)))

  (begin
    ;; Check inputs
    (asserts! (> site-id u0) (err err-invalid-input))
    (asserts! (<= pollinator-diversity-score u10) (err err-invalid-input))
    (asserts! (<= pollinator-abundance-score u10) (err err-invalid-input))
    (asserts! (<= habitat-quality-score u10) (err err-invalid-input))
    (asserts! (> (len recommendations) u0) (err err-invalid-input))

    ;; Create assessment
    (map-set site-assessments
      { site-id: site-id, assessment-id: (var-get next-assessment-id) }
      {
        assessor: tx-sender,
        date: block-height,
        pollinator-diversity-score: pollinator-diversity-score,
        pollinator-abundance-score: pollinator-abundance-score,
        habitat-quality-score: habitat-quality-score,
        recommendations: recommendations
      }
    )

    ;; Increment assessment ID counter
    (var-set next-assessment-id (+ (var-get next-assessment-id) u1))

    ;; Return success with assessment ID
    (ok (- (var-get next-assessment-id) u1))
  )
)


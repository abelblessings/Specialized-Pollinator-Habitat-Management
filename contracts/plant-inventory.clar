;; Plant Inventory Contract
;; Tracks species that support bees and other pollinators

;; Define data maps
(define-map plant-species
  { id: uint }
  {
    scientific-name: (string-ascii 100),
    common-name: (string-ascii 100),
    plant-type: (string-ascii 50),
    bloom-season: (string-ascii 50),
    registered-by: principal,
    registration-time: uint
  }
)

;; Define data maps for pollinator support
(define-map pollinator-support
  { species-id: uint }
  {
    nectar-value: uint,
    pollen-value: uint,
    supported-pollinators: (string-ascii 200),
    bloom-duration-days: uint
  }
)

;; Define data maps for site plantings
(define-map site-plantings
  { site-id: uint, planting-id: uint }
  {
    species-id: uint,
    quantity: uint,
    planting-date: uint,
    planting-area: uint,
    status: (string-ascii 20),
    planted-by: principal
  }
)

;; Define ID counters
(define-data-var next-species-id uint u1)
(define-data-var next-planting-id uint u1)

;; Error codes
(define-constant err-invalid-input u1)
(define-constant err-not-found u2)
(define-constant err-not-authorized u3)

;; Read-only functions
(define-read-only (get-plant-species (id uint))
  (map-get? plant-species { id: id })
)

(define-read-only (get-pollinator-support (species-id uint))
  (map-get? pollinator-support { species-id: species-id })
)

(define-read-only (get-site-planting (site-id uint) (planting-id uint))
  (map-get? site-plantings { site-id: site-id, planting-id: planting-id })
)

;; Public functions
(define-public (register-plant-species
    (scientific-name (string-ascii 100))
    (common-name (string-ascii 100))
    (plant-type (string-ascii 50))
    (bloom-season (string-ascii 50)))

  (begin
    ;; Check inputs
    (asserts! (> (len scientific-name) u0) (err err-invalid-input))
    (asserts! (> (len common-name) u0) (err err-invalid-input))
    (asserts! (> (len plant-type) u0) (err err-invalid-input))
    (asserts! (> (len bloom-season) u0) (err err-invalid-input))

    ;; Register plant species
    (map-set plant-species
      { id: (var-get next-species-id) }
      {
        scientific-name: scientific-name,
        common-name: common-name,
        plant-type: plant-type,
        bloom-season: bloom-season,
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

(define-public (add-pollinator-support
    (species-id uint)
    (nectar-value uint)
    (pollen-value uint)
    (supported-pollinators (string-ascii 200))
    (bloom-duration-days uint))

  (let ((species (unwrap! (get-plant-species species-id) (err err-not-found))))
    ;; Check authorization
    (asserts! (is-eq tx-sender (get registered-by species)) (err err-not-authorized))

    ;; Check inputs
    (asserts! (<= nectar-value u10) (err err-invalid-input))
    (asserts! (<= pollen-value u10) (err err-invalid-input))
    (asserts! (> (len supported-pollinators) u0) (err err-invalid-input))
    (asserts! (> bloom-duration-days u0) (err err-invalid-input))

    ;; Add pollinator support data
    (map-set pollinator-support
      { species-id: species-id }
      {
        nectar-value: nectar-value,
        pollen-value: pollen-value,
        supported-pollinators: supported-pollinators,
        bloom-duration-days: bloom-duration-days
      }
    )

    ;; Return success
    (ok true)
  )
)

(define-public (record-site-planting
    (site-id uint)
    (species-id uint)
    (quantity uint)
    (planting-area uint))

  (begin
    ;; Check inputs
    (asserts! (> site-id u0) (err err-invalid-input))
    (asserts! (> species-id u0) (err err-invalid-input))
    (asserts! (> quantity u0) (err err-invalid-input))
    (asserts! (> planting-area u0) (err err-invalid-input))

    ;; Record planting
    (map-set site-plantings
      { site-id: site-id, planting-id: (var-get next-planting-id) }
      {
        species-id: species-id,
        quantity: quantity,
        planting-date: block-height,
        planting-area: planting-area,
        status: "PLANTED",
        planted-by: tx-sender
      }
    )

    ;; Increment planting ID counter
    (var-set next-planting-id (+ (var-get next-planting-id) u1))

    ;; Return success with planting ID
    (ok (- (var-get next-planting-id) u1))
  )
)

(define-public (update-planting-status
    (site-id uint)
    (planting-id uint)
    (status (string-ascii 20)))

  (let ((planting (unwrap! (get-site-planting site-id planting-id) (err err-not-found))))
    ;; Check authorization
    (asserts! (is-eq tx-sender (get planted-by planting)) (err err-not-authorized))

    ;; Check input
    (asserts! (or
      (is-eq status "THRIVING")
      (is-eq status "STRUGGLING")
      (is-eq status "REPLACED")
      (is-eq status "REMOVED")
    ) (err err-invalid-input))

    ;; Update planting status
    (map-set site-plantings
      { site-id: site-id, planting-id: planting-id }
      (merge planting { status: status })
    )

    ;; Return success
    (ok true)
  )
)


;; Site Registration Contract
;; Records details of pollinator-friendly areas

;; Define data maps
(define-map sites
  { id: uint }
  {
    name: (string-ascii 100),
    location: (string-ascii 100),
    size-hectares: uint,
    habitat-type: (string-ascii 50),
    owner: principal,
    registration-time: uint,
    active: bool
  }
)

;; Define data maps for site coordinates
(define-map site-coordinates
  { site-id: uint }
  {
    latitude: int,
    longitude: int,
    elevation: int
  }
)

;; Define data maps for site characteristics
(define-map site-characteristics
  { site-id: uint }
  {
    soil-type: (string-ascii 50),
    sun-exposure: (string-ascii 50),
    water-source: (string-ascii 50),
    surrounding-land-use: (string-ascii 100)
  }
)

;; Define ID counter
(define-data-var next-site-id uint u1)

;; Error codes
(define-constant err-invalid-input u1)
(define-constant err-not-found u2)
(define-constant err-not-authorized u3)

;; Read-only functions
(define-read-only (get-site (id uint))
  (map-get? sites { id: id })
)

(define-read-only (get-site-coordinates (site-id uint))
  (map-get? site-coordinates { site-id: site-id })
)

(define-read-only (get-site-characteristics (site-id uint))
  (map-get? site-characteristics { site-id: site-id })
)

;; Public functions
(define-public (register-site
    (name (string-ascii 100))
    (location (string-ascii 100))
    (size-hectares uint)
    (habitat-type (string-ascii 50)))

  (begin
    ;; Check inputs
    (asserts! (> (len name) u0) (err err-invalid-input))
    (asserts! (> (len location) u0) (err err-invalid-input))
    (asserts! (> size-hectares u0) (err err-invalid-input))
    (asserts! (> (len habitat-type) u0) (err err-invalid-input))

    ;; Register site
    (map-set sites
      { id: (var-get next-site-id) }
      {
        name: name,
        location: location,
        size-hectares: size-hectares,
        habitat-type: habitat-type,
        owner: tx-sender,
        registration-time: block-height,
        active: true
      }
    )

    ;; Increment site ID counter
    (var-set next-site-id (+ (var-get next-site-id) u1))

    ;; Return success with site ID
    (ok (- (var-get next-site-id) u1))
  )
)

(define-public (add-site-coordinates
    (site-id uint)
    (latitude int)
    (longitude int)
    (elevation int))

  (let ((site (unwrap! (get-site site-id) (err err-not-found))))
    ;; Check authorization
    (asserts! (is-eq tx-sender (get owner site)) (err err-not-authorized))

    ;; Add coordinates
    (map-set site-coordinates
      { site-id: site-id }
      {
        latitude: latitude,
        longitude: longitude,
        elevation: elevation
      }
    )

    ;; Return success
    (ok true)
  )
)

(define-public (add-site-characteristics
    (site-id uint)
    (soil-type (string-ascii 50))
    (sun-exposure (string-ascii 50))
    (water-source (string-ascii 50))
    (surrounding-land-use (string-ascii 100)))

  (let ((site (unwrap! (get-site site-id) (err err-not-found))))
    ;; Check authorization
    (asserts! (is-eq tx-sender (get owner site)) (err err-not-authorized))

    ;; Check inputs
    (asserts! (> (len soil-type) u0) (err err-invalid-input))
    (asserts! (> (len sun-exposure) u0) (err err-invalid-input))
    (asserts! (> (len water-source) u0) (err err-invalid-input))
    (asserts! (> (len surrounding-land-use) u0) (err err-invalid-input))

    ;; Add characteristics
    (map-set site-characteristics
      { site-id: site-id }
      {
        soil-type: soil-type,
        sun-exposure: sun-exposure,
        water-source: water-source,
        surrounding-land-use: surrounding-land-use
      }
    )

    ;; Return success
    (ok true)
  )
)

(define-public (update-site-status (site-id uint) (active bool))
  (let ((site (unwrap! (get-site site-id) (err err-not-found))))
    ;; Check authorization
    (asserts! (is-eq tx-sender (get owner site)) (err err-not-authorized))

    ;; Update site status
    (map-set sites
      { id: site-id }
      (merge site { active: active })
    )

    ;; Return success
    (ok true)
  )
)


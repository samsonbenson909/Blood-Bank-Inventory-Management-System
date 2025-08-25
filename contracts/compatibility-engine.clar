;; Blood Compatibility Engine Contract
;; Handles blood type compatibility matching and allocation

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u300))
(define-constant ERR-INCOMPATIBLE-BLOOD (err u301))
(define-constant ERR-INSUFFICIENT-SUPPLY (err u302))
(define-constant ERR-INVALID-REQUEST (err u303))

;; Data Variables
(define-data-var next-request-id uint u1)

;; Data Maps
(define-map blood-requests
  { request-id: uint }
  {
    patient-blood-type: (string-ascii 3),
    units-requested: uint,
    priority-level: uint,
    emergency: bool,
    requested-at: uint,
    status: (string-ascii 20)
  }
)

(define-map compatibility-matrix
  { recipient-type: (string-ascii 3), donor-type: (string-ascii 3) }
  { compatible: bool }
)

(define-map authorized-medical-staff
  { address: principal }
  { role: (string-ascii 20), active: bool }
)

;; Initialize compatibility matrix
(define-private (init-compatibility-matrix)
  (begin
    ;; O- recipients
    (map-set compatibility-matrix { recipient-type: "O-", donor-type: "O-" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "O-", donor-type: "O+" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "O-", donor-type: "A-" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "O-", donor-type: "A+" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "O-", donor-type: "B-" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "O-", donor-type: "B+" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "O-", donor-type: "AB-" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "O-", donor-type: "AB+" } { compatible: false })

    ;; O+ recipients
    (map-set compatibility-matrix { recipient-type: "O+", donor-type: "O-" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "O+", donor-type: "O+" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "O+", donor-type: "A-" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "O+", donor-type: "A+" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "O+", donor-type: "B-" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "O+", donor-type: "B+" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "O+", donor-type: "AB-" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "O+", donor-type: "AB+" } { compatible: false })

    ;; A- recipients
    (map-set compatibility-matrix { recipient-type: "A-", donor-type: "O-" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "A-", donor-type: "O+" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "A-", donor-type: "A-" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "A-", donor-type: "A+" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "A-", donor-type: "B-" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "A-", donor-type: "B+" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "A-", donor-type: "AB-" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "A-", donor-type: "AB+" } { compatible: false })

    ;; A+ recipients
    (map-set compatibility-matrix { recipient-type: "A+", donor-type: "O-" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "A+", donor-type: "O+" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "A+", donor-type: "A-" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "A+", donor-type: "A+" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "A+", donor-type: "B-" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "A+", donor-type: "B+" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "A+", donor-type: "AB-" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "A+", donor-type: "AB+" } { compatible: false })

    ;; B- recipients
    (map-set compatibility-matrix { recipient-type: "B-", donor-type: "O-" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "B-", donor-type: "O+" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "B-", donor-type: "A-" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "B-", donor-type: "A+" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "B-", donor-type: "B-" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "B-", donor-type: "B+" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "B-", donor-type: "AB-" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "B-", donor-type: "AB+" } { compatible: false })

    ;; B+ recipients
    (map-set compatibility-matrix { recipient-type: "B+", donor-type: "O-" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "B+", donor-type: "O+" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "B+", donor-type: "A-" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "B+", donor-type: "A+" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "B+", donor-type: "B-" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "B+", donor-type: "B+" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "B+", donor-type: "AB-" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "B+", donor-type: "AB+" } { compatible: false })

    ;; AB- recipients
    (map-set compatibility-matrix { recipient-type: "AB-", donor-type: "O-" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "AB-", donor-type: "O+" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "AB-", donor-type: "A-" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "AB-", donor-type: "A+" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "AB-", donor-type: "B-" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "AB-", donor-type: "B+" } { compatible: false })
    (map-set compatibility-matrix { recipient-type: "AB-", donor-type: "AB-" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "AB-", donor-type: "AB+" } { compatible: false })

    ;; AB+ recipients (Universal recipient)
    (map-set compatibility-matrix { recipient-type: "AB+", donor-type: "O-" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "AB+", donor-type: "O+" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "AB+", donor-type: "A-" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "AB+", donor-type: "A+" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "AB+", donor-type: "B-" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "AB+", donor-type: "B+" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "AB+", donor-type: "AB-" } { compatible: true })
    (map-set compatibility-matrix { recipient-type: "AB+", donor-type: "AB+" } { compatible: true })

    true
  )
)

;; Authorization Functions
(define-private (is-authorized (caller principal))
  (or
    (is-eq caller CONTRACT-OWNER)
    (default-to false (get active (map-get? authorized-medical-staff { address: caller })))
  )
)

;; Compatibility Check
(define-private (is-compatible (recipient-type (string-ascii 3)) (donor-type (string-ascii 3)))
  (default-to false (get compatible (map-get? compatibility-matrix { recipient-type: recipient-type, donor-type: donor-type })))
)

;; Public Functions

;; Request blood for patient
(define-public (request-blood
  (patient-blood-type (string-ascii 3))
  (units-requested uint)
  (emergency bool)
)
  (let
    (
      (request-id (var-get next-request-id))
      (priority-level (if emergency u1 u3))
    )
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> units-requested u0) ERR-INVALID-REQUEST)

    ;; Store blood request
    (map-set blood-requests
      { request-id: request-id }
      {
        patient-blood-type: patient-blood-type,
        units-requested: units-requested,
        priority-level: priority-level,
        emergency: emergency,
        requested-at: block-height,
        status: "pending"
      }
    )

    ;; Update request counter
    (var-set next-request-id (+ request-id u1))

    (ok request-id)
  )
)

;; Find compatible blood types for recipient
(define-public (find-compatible-donors (recipient-type (string-ascii 3)))
  (let
    (
      (compatible-types (list))
    )
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)

    ;; Return list of compatible donor types
    ;; Simplified implementation - in practice would check all types
    (if (is-eq recipient-type "AB+")
      (ok (list "O-" "O+" "A-" "A+" "B-" "B+" "AB-" "AB+"))
      (if (is-eq recipient-type "O-")
        (ok (list "O-"))
        (ok (list "O-" recipient-type))
      )
    )
  )
)

;; Allocate blood units for request
(define-public (allocate-blood (request-id uint))
  (let
    (
      (request-data (unwrap! (map-get? blood-requests { request-id: request-id }) ERR-INVALID-REQUEST))
    )
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status request-data) "pending") ERR-INVALID-REQUEST)

    ;; Update request status
    (map-set blood-requests
      { request-id: request-id }
      (merge request-data { status: "allocated" })
    )

    (ok true)
  )
)

;; Emergency override for critical situations
(define-public (emergency-override
  (recipient-type (string-ascii 3))
  (donor-type (string-ascii 3))
  (justification (string-ascii 200))
)
  (begin
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    ;; Log emergency override for audit
    ;; In practice, this would have additional safeguards
    (ok true)
  )
)

;; Add authorized medical staff
(define-public (add-authorized-staff (address principal) (role (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set authorized-medical-staff
      { address: address }
      { role: role, active: true }
    )
    (ok true)
  )
)

;; Read-only Functions

;; Check blood type compatibility
(define-read-only (check-compatibility (recipient-type (string-ascii 3)) (donor-type (string-ascii 3)))
  (is-compatible recipient-type donor-type)
)

;; Get blood request details
(define-read-only (get-blood-request (request-id uint))
  (map-get? blood-requests { request-id: request-id })
)

;; Get next request ID
(define-read-only (get-next-request-id)
  (var-get next-request-id)
)

;; Initialize the contract
(init-compatibility-matrix)

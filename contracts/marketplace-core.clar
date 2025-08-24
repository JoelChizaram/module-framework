;; Module Framework: Decentralized Marketplace Core Contract
;; Provides a flexible, modular infrastructure for secure peer-to-peer transactions

;; Error codes representing different system states and validation checks
(define-constant err-unauthorized (err u100))
(define-constant err-not-found (err u101))
(define-constant err-resource-inactive (err u102))
(define-constant err-insufficient-balance (err u103))
(define-constant err-already-exists (err u104))
(define-constant err-validation-failed (err u105))

;; Status constants for tracking resource lifecycle
(define-constant status-draft u0)
(define-constant status-active u1)
(define-constant status-completed u2)
(define-constant status-suspended u3)

;; Core data structures for marketplace interactions
(define-map marketplace-listings 
  { listing-id: uint }
  {
    creator: principal,
    title: (string-ascii 100),
    description: (string-utf8 1000),
    unit-price: uint,
    total-quantity: uint,
    available-quantity: uint,
    category: (string-ascii 50),
    created-at: uint,
    status: uint
  }
)

(define-map marketplace-transactions
  { transaction-id: uint }
  {
    listing-id: uint,
    buyer: principal,
    seller: principal,
    quantity: uint,
    total-price: uint,
    timestamp: uint,
    status: uint
  }
)

;; Tracking global state and incremental IDs
(define-data-var next-listing-id uint u1)
(define-data-var next-transaction-id uint u1)

;; Private helper: Validate listing creation parameters
(define-private (validate-listing-params 
  (title (string-ascii 100))
  (description (string-utf8 1000))
  (unit-price uint)
  (total-quantity uint)
)
  (and 
    (> (len title) u0)
    (> (len description) u0)
    (> unit-price u0)
    (> total-quantity u0)
  )
)

;; Create a new marketplace listing
(define-public (create-listing
  (title (string-ascii 100))
  (description (string-utf8 1000))
  (unit-price uint)
  (total-quantity uint)
  (category (string-ascii 50))
)
  (let (
    (listing-id (var-get next-listing-id))
    (creator tx-sender)
  )
    ;; Validate input parameters
    (asserts! 
      (validate-listing-params title description unit-price total-quantity) 
      err-validation-failed
    )

    ;; Create listing record
    (map-set marketplace-listings 
      { listing-id: listing-id }
      {
        creator: creator,
        title: title,
        description: description,
        unit-price: unit-price,
        total-quantity: total-quantity,
        available-quantity: total-quantity,
        category: category,
        created-at: block-height,
        status: status-active
      }
    )

    ;; Increment listing ID
    (var-set next-listing-id (+ listing-id u1))

    (ok listing-id)
  )
)

;; Retrieve listing details
(define-read-only (get-listing (listing-id uint))
  (map-get? marketplace-listings { listing-id: listing-id })
)

;; Initialize the contract
(define-public (initialize)
  (ok true)
)
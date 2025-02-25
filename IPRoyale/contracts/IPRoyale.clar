;; IPRoyale: Intellectual Property Rights Management Contract

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INVALID-IP (err u101))
(define-constant ERR-ALREADY-EXISTS (err u102))
(define-constant ERR-NOT-FOUND (err u103))
(define-constant ERR-INSUFFICIENT-BALANCE (err u104))
(define-constant ERR-INVALID-INPUT (err u105))

;; Input validation functions
(define-private (is-valid-title (title (string-ascii 100)))
  (and 
    (> (len title) u0)
    (<= (len title) u100)
  )
)

(define-private (is-valid-description (description (string-ascii 500)))
  (and 
    (> (len description) u0)
    (<= (len description) u500)
  )
)

(define-private (is-valid-base-price (base-price uint))
  (> base-price u0)
)

(define-private (is-valid-license-type (license-type (string-ascii 50)))
  (and 
    (> (len license-type) u0)
    (<= (len license-type) u50)
  )
)

(define-private (is-valid-ip-id (ip-id uint))
  (> ip-id u0)
)

(define-private (is-valid-shares (shares uint))
  (> shares u0)
)

(define-private (is-valid-usage-count (usage-count uint))
  (> usage-count u0)
)

(define-private (is-valid-expiration (expiration uint))
  (> expiration block-height)
)

;; Store information about an Intellectual Property (IP) asset
(define-map ip-registry 
  {ip-id: uint} 
  {
    creator: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    total-shares: uint,
    base-price: uint,
    license-type: (string-ascii 50)
  }
)

;; Track IP ownership shares
(define-map ip-ownership
  {ip-id: uint, owner: principal}
  {shares: uint}
)

;; Track licensing and usage rights
(define-map ip-licenses
  {ip-id: uint, licensee: principal}
  {
    license-type: (string-ascii 50),
    usage-count: uint,
    expiration: uint,
    royalty-rate: uint
  }
)

;; Track revenue and royalty distribution
(define-map ip-revenue
  {ip-id: uint}
  {total-revenue: uint, distributed-revenue: uint}
)

;; Register a new IP asset
(define-public (register-ip 
  (title (string-ascii 100))
  (description (string-ascii 500))
  (total-shares uint)
  (base-price uint)
  (license-type (string-ascii 50))
)
  (let 
    (
      (ip-id (var-get next-ip-id))
    )
    ;; Comprehensive input validation
    (asserts! (is-valid-title title) ERR-INVALID-INPUT)
    (asserts! (is-valid-description description) ERR-INVALID-INPUT)
    (asserts! (is-valid-shares total-shares) ERR-INVALID-INPUT)
    (asserts! (is-valid-base-price base-price) ERR-INVALID-INPUT)
    (asserts! (is-valid-license-type license-type) ERR-INVALID-INPUT)
    
    ;; Create IP registry entry
    (map-set ip-registry 
      {ip-id: ip-id}
      {
        creator: tx-sender,
        title: title,
        description: description,
        total-shares: total-shares,
        base-price: base-price,
        license-type: license-type
      }
    )
    
    ;; Assign initial ownership to creator
    (map-set ip-ownership 
      {ip-id: ip-id, owner: tx-sender}
      {shares: total-shares}
    )
    
    ;; Increment IP ID for next registration
    (var-set next-ip-id (+ ip-id u1))
    
    (ok ip-id)
  )
)

;; Transfer IP ownership shares
(define-public (transfer-ip-shares 
  (ip-id uint)
  (recipient principal)
  (shares uint)
)
  (let 
    (
      ;; Validate inputs
      (validated-ip-id (asserts! (is-valid-ip-id ip-id) ERR-INVALID-INPUT))
      (validated-recipient (asserts! (not (is-eq tx-sender recipient)) ERR-UNAUTHORIZED))
      
      ;; Get current shares
      (sender-shares (default-to u0 (get shares (map-get? ip-ownership {ip-id: ip-id, owner: tx-sender}))))
      (recipient-shares (default-to u0 (get shares (map-get? ip-ownership {ip-id: ip-id, owner: recipient}))))
    )
    
    ;; Additional validation
    (asserts! (is-valid-shares shares) ERR-INVALID-INPUT)
    (asserts! (>= sender-shares shares) ERR-INSUFFICIENT-BALANCE)
    
    ;; Update sender's shares
    (map-set ip-ownership 
      {ip-id: ip-id, owner: tx-sender}
      {shares: (- sender-shares shares)}
    )
    
    ;; Update recipient's shares
    (map-set ip-ownership 
      {ip-id: ip-id, owner: recipient}
      {shares: (+ recipient-shares shares)}
    )
    
    (ok true)
  )
)

;; Issue a license for IP usage
(define-public (issue-license 
  (ip-id uint)
  (licensee principal)
  (license-type (string-ascii 50))
  (usage-count uint)
  (expiration uint)
  (royalty-rate uint)
)
  (let 
    (
      ;; Validate inputs
      (validated-ip-id (asserts! (is-valid-ip-id ip-id) ERR-INVALID-INPUT))
      (validated-licensee (asserts! (not (is-eq tx-sender licensee)) ERR-UNAUTHORIZED))
      
      ;; Fetch IP details
      (ip-details (unwrap! (map-get? ip-registry {ip-id: ip-id}) ERR-NOT-FOUND))
    )
    
    ;; Comprehensive input validation
    (asserts! (is-valid-license-type license-type) ERR-INVALID-INPUT)
    (asserts! (is-valid-usage-count usage-count) ERR-INVALID-INPUT)
    (asserts! (is-valid-expiration expiration) ERR-INVALID-INPUT)
    
    ;; Validate royalty rate
    (asserts! (<= royalty-rate u100) ERR-UNAUTHORIZED)
    
    ;; Create license entry
    (map-set ip-licenses 
      {ip-id: ip-id, licensee: licensee}
      {
        license-type: license-type,
        usage-count: usage-count,
        expiration: expiration,
        royalty-rate: royalty-rate
      }
    )
    
    (ok true)
  )
)

;; Record IP usage and calculate royalties
(define-public (record-ip-usage 
  (ip-id uint)
  (licensee principal)
)
  (let 
    (
      ;; Validate inputs
      (validated-ip-id (asserts! (is-valid-ip-id ip-id) ERR-INVALID-INPUT))
      
      ;; Fetch license details
      (license-details (unwrap! (map-get? ip-licenses {ip-id: ip-id, licensee: licensee}) ERR-NOT-FOUND))
      
      (current-usage (get usage-count license-details))
      (total-revenue-map (default-to {total-revenue: u0, distributed-revenue: u0} (map-get? ip-revenue {ip-id: ip-id})))
      (ip-details (unwrap! (map-get? ip-registry {ip-id: ip-id}) ERR-NOT-FOUND))
      (royalty-amount (/ (* (get base-price ip-details) (get royalty-rate license-details)) u100))
    )
    
    ;; Check license expiration and usage limits
    (asserts! (< current-usage (get usage-count license-details)) ERR-UNAUTHORIZED)
    (asserts! (< block-height (get expiration license-details)) ERR-UNAUTHORIZED)
    
    ;; Update license usage
    (map-set ip-licenses 
      {ip-id: ip-id, licensee: licensee}
      (merge license-details {usage-count: (+ current-usage u1)})
    )
    
    ;; Update revenue tracking
    (map-set ip-revenue 
      {ip-id: ip-id}
      {
        total-revenue: (+ (get total-revenue total-revenue-map) royalty-amount),
        distributed-revenue: (get distributed-revenue total-revenue-map)
      }
    )
    
    (ok royalty-amount)
  )
)

;; Distribute royalties to IP owners
(define-public (distribute-royalties 
  (ip-id uint)
)
  (let 
    (
      ;; Validate inputs
      (validated-ip-id (asserts! (is-valid-ip-id ip-id) ERR-INVALID-INPUT))
      
      ;; Fetch revenue details
      (revenue-details (unwrap! (map-get? ip-revenue {ip-id: ip-id}) ERR-NOT-FOUND))
      
      (total-revenue (get total-revenue revenue-details))
      (distributed-revenue (get distributed-revenue revenue-details))
    )
    
    (asserts! (> total-revenue distributed-revenue) ERR-INSUFFICIENT-BALANCE)
    
    ;; Add logic to distribute royalties proportionally to IP owners
    ;; This would involve iterating through ip-ownership map and sending proportional amounts
    
    (ok true)
  )
)

;; Initialize the next IP ID variable
(define-data-var next-ip-id uint u1)
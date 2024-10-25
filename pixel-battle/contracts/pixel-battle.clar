;; Pixel Battle - A decentralized pixel art canvas game
;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant CANVAS_SIZE u100)  ;; 100x100 grid
(define-constant PIXEL_PRICE u1000)  ;; in microSTX
(define-constant INTERACTION_REWARD u100)  ;; reward for pixel interactions

;; Data vars
(define-data-var total-pixels-claimed uint u0)
(define-data-var total-rewards-paid uint u0)

;; Define pixel structure
(define-map pixels 
    { x: uint, y: uint }
    {
        owner: principal,
        color: (string-utf8 7),  ;; hex color code
        last-updated: uint,
        interaction-count: uint
    }
)

;; Define user stats
(define-map user-stats
    principal
    {
        pixels-owned: uint,
        total-rewards: uint
    }
)

;; Error constants
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_POSITION (err u101))
(define-constant ERR_PIXEL_OWNED (err u102))
(define-constant ERR_INSUFFICIENT_FUNDS (err u103))

;; Read-only functions

(define-read-only (get-pixel (x uint) (y uint))
    (map-get? pixels {x: x, y: y})
)

(define-read-only (get-user-stats (user principal))
    (default-to 
        { pixels-owned: u0, total-rewards: u0 }
        (map-get? user-stats user)
    )
)

(define-read-only (is-valid-position (x uint) (y uint))
    (and 
        (< x CANVAS_SIZE)
        (< y CANVAS_SIZE)
    )
)

;; Public functions

(define-public (claim-pixel (x uint) (y uint) (color (string-utf8 7)))
    (let
        (
            (caller tx-sender)
            (current-pixel (get-pixel x y))
        )
        (asserts! (is-valid-position x y) ERR_INVALID_POSITION)
        (asserts! (is-none current-pixel) ERR_PIXEL_OWNED)
        (try! (stx-transfer? PIXEL_PRICE caller CONTRACT_OWNER))
        
        (map-set pixels 
            {x: x, y: y}
            {
                owner: caller,
                color: color,
                last-updated: block-height,
                interaction-count: u0
            }
        )
        
        (let
            ((current-stats (get-user-stats caller)))
            (map-set user-stats
                caller
                {
                    pixels-owned: (+ (get pixels-owned current-stats) u1),
                    total-rewards: (get total-rewards current-stats)
                }
            )
        )
        
        (var-set total-pixels-claimed (+ (var-get total-pixels-claimed) u1))
        (ok true)
    )
)

(define-public (update-pixel (x uint) (y uint) (new-color (string-utf8 7)))
    (let
        (
            (caller tx-sender)
            (current-pixel (unwrap! (get-pixel x y) ERR_INVALID_POSITION))
        )
        (asserts! (is-valid-position x y) ERR_INVALID_POSITION)
        (asserts! (is-eq (get owner current-pixel) caller) ERR_UNAUTHORIZED)
        
        (map-set pixels
            {x: x, y: y}
            {
                owner: caller,
                color: new-color,
                last-updated: block-height,
                interaction-count: (get interaction-count current-pixel)
            }
        )
        (ok true)
    )
)

(define-public (interact-with-pixel (x uint) (y uint))
    (let
        (
            (caller tx-sender)
            (current-pixel (unwrap! (get-pixel x y) ERR_INVALID_POSITION))
            (pixel-owner (get owner current-pixel))
        )
        (asserts! (not (is-eq caller pixel-owner)) ERR_UNAUTHORIZED)
        
        ;; Update pixel interaction count
        (map-set pixels
            {x: x, y: y}
            {
                owner: pixel-owner,
                color: (get color current-pixel),
                last-updated: (get last-updated current-pixel),
                interaction-count: (+ (get interaction-count current-pixel) u1)
            }
        )
        
        ;; Pay reward to pixel owner
        (try! (stx-transfer? INTERACTION_REWARD CONTRACT_OWNER pixel-owner))
        
        ;; Update owner stats
        (let
            ((owner-stats (get-user-stats pixel-owner)))
            (map-set user-stats
                pixel-owner
                {
                    pixels-owned: (get pixels-owned owner-stats),
                    total-rewards: (+ (get total-rewards owner-stats) INTERACTION_REWARD)
                }
            )
        )
        
        (var-set total-rewards-paid (+ (var-get total-rewards-paid) INTERACTION_REWARD))
        (ok true)
    )
)

;; Admin functions

(define-public (withdraw-funds (amount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (try! (stx-transfer? amount CONTRACT_OWNER tx-sender))
        (ok true)
    )
)
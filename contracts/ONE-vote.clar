;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Vote Yes / No Smart Contract
;; Language : Clarity
;; Tooling  : Clarinet
;;
;; GOAL
;; ----
;; Implement a very simple on-chain voting system where:
;; - Each address can vote exactly once
;; - Votes are either YES or NO
;; - Results are publicly readable
;;
;; This contract is intentionally verbose and beginner-friendly.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SECTION 1: GLOBAL STATE (DATA VARIABLES)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data variables store persistent contract state.
;; They survive across transactions.

;; Total number of YES votes
(define-data-var yes-count uint u0)

;; Total number of NO votes
(define-data-var no-count uint u0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SECTION 2: MAPS (USER TRACKING)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Maps store key-value records.
;; Here we use a map to prevent double voting.


;; voters map:
;; key   -> wallet address (principal)
;; value -> record showing the user has voted
;; If an address exists in this map, it already voted.
(define-map voters principal bool)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SECTION 3: ERROR CODES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Error codes are unsigned integers.
;; Keep them simple and documented.

;; u100 => user already voted
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SECTION 4: PUBLIC FUNCTIONS (STATE-CHANGING)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ---------------------------------------------------------------
;; vote
;; ---------------------------------------------------------------
;; Allows a user to vote YES or NO.
;;
;; PARAMETERS:
;; - choice : bool
;;   true  = YES
;;   false = NO
;;
;; RULES:
;; - Caller must not have voted before
;; - Vote is permanently recorded
;;
;; RETURNS:
;; - (ok true/false) on success
;; - (err u100) if user already voted
;; ---------------------------------------------------------------

(define-public (vote (choice bool))
  (begin

    ;; STEP 1: Check if sender has already voted
    ;; map-get? returns (some ...) or none
    ;; If NOT none, user already voted -> error

    (asserts!
      (is-none (map-get? voters tx-sender))
      (err u100))

    ;; STEP 2: Record that the sender has voted
    ;; We don't care about the value, only existence

    (map-set voters tx-sender true)

    ;; STEP 3: Increment vote counter
    ;; Clarity `if` is expression-based

    (if choice
        ;; YES vote
        (var-set yes-count (+ (var-get yes-count) u1))

        ;; NO vote
        (var-set no-count (+ (var-get no-count) u1))
    )

    ;; STEP 4: Return the vote choice
    (ok choice)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SECTION 5: READ-ONLY FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read-only functions:
;; - Do NOT modify blockchain state
;; - Cost less gas
;; - Ideal for frontends and queries
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ---------------------------------------------------------------
;; get-results
;; ---------------------------------------------------------------
;; Returns the current vote totals
;;
;; RETURNS:
;; {
;;   yes: uint,
;;   no:  uint
;; }
;; ---------------------------------------------------------------

(define-read-only (get-results)
  (ok {
    yes: (var-get yes-count),
    no:  (var-get no-count)
  })
)

;; ---------------------------------------------------------------
;; has-voted
;; ---------------------------------------------------------------
;; Checks whether a given address already voted
;;
;; PARAMETER:
;; - who : principal
;;
;; RETURNS:
;; - true  => already voted
;; - false => has not voted
;; ---------------------------------------------------------------

(define-read-only (has-voted (who principal))
  (ok
    (is-some (map-get? voters who)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; END OF CONTRACT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

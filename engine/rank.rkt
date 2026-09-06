#lang racket/base

;; Rank/level progression (game-progression: Rank and Level Progression).
;; Purely derived from a completed-module count - no separate persisted
;; state, so it can never drift from actual completion.

(provide RANK-THRESHOLDS
         rank-for-completed-count)

;; RANK-THRESHOLDS : (listof (cons exact-nonnegative-integer? string?))
;; Six Starfleet-style labels spanning the 15-module curriculum (every 3
;; modules is a promotion). Visual/thematic only, per AGENTS.md - no
;; narrative missions attached.
(define RANK-THRESHOLDS
  '((0 . "Курсант")
    (3 . "Энсин")
    (6 . "Лейтенант младшего ранга")
    (9 . "Лейтенант")
    (12 . "Лейтенант-коммандер")
    (15 . "Коммандер")))

;; rank-for-completed-count : exact-nonnegative-integer? -> string?
;; The label for the highest threshold <= n.
(define (rank-for-completed-count n)
  (cdr (for/fold ([best (car RANK-THRESHOLDS)])
                 ([entry (in-list RANK-THRESHOLDS)])
         (if (<= (car entry) n) entry best))))

(module+ test
  (require rackunit)

  (test-case "exact threshold values map to their rank"
    (check-equal? (rank-for-completed-count 0) "Курсант")
    (check-equal? (rank-for-completed-count 3) "Энсин")
    (check-equal? (rank-for-completed-count 6) "Лейтенант младшего ранга")
    (check-equal? (rank-for-completed-count 9) "Лейтенант")
    (check-equal? (rank-for-completed-count 12) "Лейтенант-коммандер")
    (check-equal? (rank-for-completed-count 15) "Коммандер"))

  (test-case "just-below-threshold values map to the previous rank"
    (check-equal? (rank-for-completed-count 2) "Курсант")
    (check-equal? (rank-for-completed-count 5) "Энсин")
    (check-equal? (rank-for-completed-count 8) "Лейтенант младшего ранга")
    (check-equal? (rank-for-completed-count 11) "Лейтенант")
    (check-equal? (rank-for-completed-count 14) "Лейтенант-коммандер"))

  (test-case "above the top threshold still maps to the top rank"
    (check-equal? (rank-for-completed-count 20) "Коммандер")))

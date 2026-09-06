#lang racket/gui

;; Journal panel (gui-lcars: Journal as Primary Navigation). Lists
;; completed modules in the order engine/progress.rkt already stores them
;; (most-recent-first - see gui-shell-navigation's design.md), the
;; player's current rank (game-progression), and earned achievements.

(require "../engine/rank.rkt"
         "../engine/achievements.rkt"
         "lcars-style.rkt")

(provide journal-entries
         achievement-entries
         make-journal-panel
         refresh-journal-panel!)

;; journal-entries : (listof symbol?) -> (listof string?)
;; Pure: the display strings for a completed-modules list, in stored order.
(define (journal-entries completed-modules)
  (map symbol->string completed-modules))

;; achievement-entries : (listof symbol?) -> (listof string?)
;; Pure: the display labels for an earned-achievements list.
(define (achievement-entries earned-achievements)
  (map achievement-label earned-achievements))

;; make-journal-panel : (is-a?/c area-container<%>) (listof symbol?) (listof symbol?) -> (is-a?/c panel%)
(define (make-journal-panel parent completed-modules earned-achievements)
  (define panel (new vertical-panel% [parent parent]))
  (define heading (new message%
                        [parent panel]
                        [label "БОРТОВОЙ ЖУРНАЛ"]
                        [color ACCENT-AMBER]
                        [font LCARS-FONT]))
  (define rank-label
    (new message%
         [parent panel]
         [label (format "Звание: ~a" (rank-for-completed-count (length completed-modules)))]
         [color ACCENT-LAVENDER]))
  (define list-box
    (new list-box%
         [parent panel]
         [label #f]
         [choices (journal-entries completed-modules)]
         [style '(single)]))
  (define achievements-heading
    (new message% [parent panel] [label "ДОСТИЖЕНИЯ"] [color ACCENT-AMBER]))
  (define achievements-list
    (new list-box%
         [parent panel]
         [label #f]
         [choices (achievement-entries earned-achievements)]
         [style '(single)]))
  panel)

;; refresh-journal-panel! : (is-a?/c panel%) (listof symbol?) (listof symbol?) -> void?
;; Updates a panel built by make-journal-panel in place to reflect a new
;; completed-modules/earned-achievements pair, without rebuilding the
;; panel itself.
(define (refresh-journal-panel! panel completed-modules earned-achievements)
  (define list-boxes (filter (lambda (c) (is-a? c list-box%)) (send panel get-children)))
  (define entries-lb (first list-boxes))
  (define achievements-lb (second list-boxes))
  (send entries-lb set (journal-entries completed-modules))
  (send achievements-lb set (achievement-entries earned-achievements))
  (define rank-msg (findf (lambda (c) (and (is-a? c message%)
                                            (regexp-match? #rx"^Звание:" (send c get-label))))
                           (send panel get-children)))
  (send rank-msg set-label (format "Звание: ~a" (rank-for-completed-count (length completed-modules)))))

(module+ test
  (require rackunit)

  (test-case "journal-entries: empty completed-set is an empty list"
    (check-equal? (journal-entries '()) '()))

  (test-case "journal-entries: lists exactly the given modules, in stored order"
    (check-equal? (journal-entries '(higher-order-fn closures s-expr-basics))
                  '("higher-order-fn" "closures" "s-expr-basics")))

  (test-case "achievement-entries: lists exactly the given achievements' labels"
    (check-equal? (achievement-entries '(no-let-needed)) '("Обошлась без let")))

  (test-case "make-journal-panel builds both list-boxes with matching item counts, no window shown"
    (define frame (new frame% [label "test"] [width 200] [height 200]))
    (define panel (make-journal-panel frame '(a b c) '(no-let-needed)))
    (define lbs (filter (lambda (c) (is-a? c list-box%)) (send panel get-children)))
    (check-equal? (length lbs) 2)
    (check-equal? (send (first lbs) get-number) 3)
    (check-equal? (send (first lbs) get-string 0) "a")
    (check-equal? (send (second lbs) get-number) 1)
    (check-equal? (send (second lbs) get-string 0) "Обошлась без let"))

  (test-case "make-journal-panel shows the rank for the given completed count"
    (define frame (new frame% [label "test"] [width 200] [height 200]))
    (define panel (make-journal-panel frame '(a b) '()))
    (define rank-msg (findf (lambda (c) (and (is-a? c message%) (regexp-match? #rx"^Звание:" (send c get-label))))
                             (send panel get-children)))
    (check-equal? (send rank-msg get-label) "Звание: Курсант"))

  (test-case "refresh-journal-panel! updates both list-boxes and the rank label in place"
    (define frame (new frame% [label "test"] [width 200] [height 200]))
    (define panel (make-journal-panel frame '(a b c) '()))
    (refresh-journal-panel! panel '(a b c x y z) '(no-let-needed))
    (define lbs (filter (lambda (c) (is-a? c list-box%)) (send panel get-children)))
    (check-equal? (send (first lbs) get-number) 6)
    (check-equal? (send (second lbs) get-number) 1)
    (check-equal? (send (second lbs) get-string 0) "Обошлась без let")
    (define rank-msg (findf (lambda (c) (and (is-a? c message%) (regexp-match? #rx"^Звание:" (send c get-label))))
                             (send panel get-children)))
    (check-equal? (send rank-msg get-label) "Звание: Лейтенант младшего ранга")))

#lang racket/gui

;; Journal panel (gui-lcars: Journal as Primary Navigation). Lists
;; completed modules in the order engine/progress.rkt already stores them
;; (most-recent-first - see this change's design.md).

(require "lcars-style.rkt")

(provide journal-entries
         make-journal-panel)

;; journal-entries : (listof symbol?) -> (listof string?)
;; Pure: the display strings for a completed-modules list, in stored order.
(define (journal-entries completed-modules)
  (map symbol->string completed-modules))

;; make-journal-panel : (is-a?/c area-container<%>) (listof symbol?) -> (is-a?/c panel%)
(define (make-journal-panel parent completed-modules)
  (define panel (new vertical-panel% [parent parent]))
  (define heading (new message%
                        [parent panel]
                        [label "БОРТОВОЙ ЖУРНАЛ"]
                        [color ACCENT-AMBER]
                        [font LCARS-FONT]))
  (define list-box
    (new list-box%
         [parent panel]
         [label #f]
         [choices (journal-entries completed-modules)]
         [style '(single)]))
  panel)

(module+ test
  (require rackunit)

  (test-case "journal-entries: empty completed-set is an empty list"
    (check-equal? (journal-entries '()) '()))

  (test-case "journal-entries: lists exactly the given modules, in stored order"
    (check-equal? (journal-entries '(higher-order-fn closures s-expr-basics))
                  '("higher-order-fn" "closures" "s-expr-basics")))

  (test-case "make-journal-panel builds a list-box with matching item count, no window shown"
    (define frame (new frame% [label "test"] [width 200] [height 200]))
    (define panel (make-journal-panel frame '(a b c)))
    (define lb (findf (lambda (c) (is-a? c list-box%)) (send panel get-children)))
    (check-not-false lb)
    (check-equal? (send lb get-number) 3)
    (check-equal? (send lb get-string 0) "a")))

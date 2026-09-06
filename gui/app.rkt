#lang racket/gui

;; Native application shell (gui-lcars: Native Desktop Application). A
;; frame with a two-tab tab-panel%: Journal (primary) and Skill Tree
;; (secondary).

(require "../engine/progress.rkt"
         "journal-panel.rkt"
         "skill-tree-panel.rkt")

(provide make-app-frame)

(define TAB-LABELS '("Бортовой журнал" "Древо навыков"))

;; make-app-frame : progress-state? -> (is-a?/c frame%)
(define (make-app-frame state)
  (define frame (new frame% [label "zchemer"] [width 640] [height 480]))
  (define tabs
    (new tab-panel%
         [parent frame]
         [choices TAB-LABELS]
         [callback
          (lambda (t e)
            (define sel (send t get-selection))
            (for ([child (send t get-children)] [i (in-naturals)])
              (send child show (= i sel))))]))
  (define journal (make-journal-panel tabs (progress-state-completed-modules state)))
  (define skill-tree (make-skill-tree-panel tabs (progress-state-completed-modules state)))
  (send skill-tree show #f)
  frame)

(module+ test
  (require rackunit)

  (test-case "make-app-frame builds a tab-panel with exactly two tabs, Journal then Skill Tree"
    (define frame (make-app-frame (fresh-progress)))
    (define tabs (findf (lambda (c) (is-a? c tab-panel%)) (send frame get-children)))
    (check-not-false tabs)
    (check-equal? (send tabs get-number) 2)
    (check-equal? (send tabs get-item-label 0) "Бортовой журнал")
    (check-equal? (send tabs get-item-label 1) "Древо навыков")))

#lang racket/gui

;; Skill Tree panel (gui-lcars: Skill Tree as Secondary Navigation).
;; Lists every module from engine/curriculum.rkt's MODULE-TABLE with its
;; computed status and color.

(require "../engine/curriculum.rkt"
         "lcars-style.rkt")

(provide module-rows
         make-skill-tree-panel)

;; module-rows : (listof symbol?) -> (listof (list symbol? symbol? (is-a?/c color%) string?))
;; Pure: (module-id status color status-label) for every MODULE-TABLE entry,
;; in table order.
(define (module-rows completed-set)
  (for/list ([entry (in-list MODULE-TABLE)])
    (define module-id (car entry))
    (define status (module-status module-id completed-set))
    (list module-id status (status->color status) (status->label status))))

;; make-skill-tree-panel : (is-a?/c area-container<%>) (listof symbol?) -> (is-a?/c panel%)
(define (make-skill-tree-panel parent completed-set)
  (define panel (new vertical-panel% [parent parent]))
  (define heading (new message%
                        [parent panel]
                        [label "ДРЕВО НАВЫКОВ"]
                        [color ACCENT-LAVENDER]
                        [font LCARS-FONT]))
  (for ([row (in-list (module-rows completed-set))])
    (define module-id (first row))
    (define color (third row))
    (define status-label (fourth row))
    (define row-panel (new horizontal-panel% [parent panel] [stretchable-height #f]))
    (define swatch
      (new canvas%
           [parent row-panel]
           [min-width 16] [min-height 16] [stretchable-width #f] [stretchable-height #f]
           [paint-callback
            (lambda (c dc)
              (send dc set-brush color 'solid)
              (send dc set-pen color 1 'solid)
              (send dc draw-rectangle 0 0 16 16))]))
    (new message% [parent row-panel] [label (symbol->string module-id)])
    (new message% [parent row-panel] [label status-label] [color color]))
  panel)

(module+ test
  (require rackunit)

  (test-case "module-rows: every MODULE-TABLE entry appears exactly once"
    (define rows (module-rows '()))
    (check-equal? (length rows) (length MODULE-TABLE))
    (check-equal? (sort (map first rows) symbol<?)
                  (sort (map car MODULE-TABLE) symbol<?)))

  (test-case "module-rows: locked/available/completed each get the right color"
    (define completed '(s-expr-basics binding conditionals first-class-fn))
    (define (row-for id) (assf (lambda (x) (eq? x id)) (map (lambda (r) (cons (car r) r)) (module-rows completed)))
    (define (status-of id) (second (cdr (row-for id))))
    (define (color-of id) (third (cdr (row-for id))))
    ;; first-class-fn: completed
    (check-eq? (status-of 'first-class-fn) 'completed)
    (check-equal? (color-of 'first-class-fn) (status->color 'completed))
    ;; mutable-state: available (unlocked right after first-class-fn)
    (check-eq? (status-of 'mutable-state) 'available)
    (check-equal? (color-of 'mutable-state) (status->color 'available))
    ;; closures: locked (needs tail-recursion first)
    (check-eq? (status-of 'closures) 'locked)
    (check-equal? (color-of 'closures) (status->color 'locked)))

  (test-case "make-skill-tree-panel builds one row per MODULE-TABLE entry, no window shown"
    (define frame (new frame% [label "test"] [width 200] [height 200]))
    (define panel (make-skill-tree-panel frame '()))
    ;; heading + one horizontal-panel per module row
    (check-equal? (length (send panel get-children)) (+ 1 (length MODULE-TABLE))))))

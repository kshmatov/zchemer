#lang racket/base

;; Achievement catalog and mechanism (game-progression: Achievements for
;; Notable Actions, Retroactive Achievement Recognition During Review;
;; achievement-catalog-content). Conditions are pure functions over a
;; submission's source text - callers decide when to invoke them (only
;; after a passing grade - see gui/editor-panel.rkt, gui/project-panel.rkt).

(require racket/list
         "static-check.rkt")

(provide ACHIEVEMENT-CATALOG
         check-achievements
         achievements-for-module
         achievement-label)

;; ACHIEVEMENT-CATALOG : (listof (list symbol? symbol? string? (string? -> boolean?)))
;; Each entry: (module-id achievement-id label condition). Three entries,
;; three distinct condition styles, demonstrating the mechanism
;; generalizes - not an exhaustive catalog for every module.
(define ACHIEVEMENT-CATALOG
  (list
   (list 'binding 'no-let-needed "Обошлась без let"
         (lambda (src) (not (ormap (lambda (f) (contains-symbol? f 'let)) (read-all-forms src)))))
   (list 'recursion-basic 'single-form "Ни одной лишней строчки"
         (lambda (src) (= (length (read-all-forms src)) 1)))
   (list 'higher-order-fn 'concise-solution "Компактное решение"
         (lambda (src) (< (string-length src) 90)))))

;; Note: `no-let-needed`'s condition checks for the symbol `let` anywhere
;; in the parsed forms (not just at the top level), reusing the same
;; recursive-walk idea static-check.rkt's find-disallowed-symbols already
;; uses, just checking absence rather than presence. read-all-forms
;; returns top-level forms only, so we walk them ourselves here since
;; `let` could appear nested inside a definition's body.
(define (contains-symbol? datum sym)
  (cond
    [(eq? datum sym) #t]
    [(pair? datum) (or (contains-symbol? (car datum) sym) (contains-symbol? (cdr datum) sym))]
    [(vector? datum) (for/or ([v (in-vector datum)]) (contains-symbol? v sym))]
    [else #f]))

;; achievements-for-module : symbol? -> (listof (list symbol? string? (string? -> boolean?)))
;; The (achievement-id label condition) triples defined for module-id.
(define (achievements-for-module module-id)
  (for/list ([entry (in-list ACHIEVEMENT-CATALOG)] #:when (eq? (car entry) module-id))
    (cdr entry)))

;; check-achievements : symbol? string? -> (listof (cons symbol? string?))
;; Which of module-id's achievements this submission's source satisfies,
;; as (achievement-id . label) pairs. Pure - callers must only invoke
;; this after confirming the submission passed the exercise's own
;; correctness tests (achievement-catalog-content's Achievement
;; Conditions Are Independent of, but Subsequent to, Correctness Grading).
(define (check-achievements module-id src)
  (for/list ([entry (in-list (achievements-for-module module-id))]
             #:when ((third entry) src))
    (cons (first entry) (second entry))))

;; achievement-label : symbol? -> string?
;; The catalog label for an achievement id (falls back to the id's own
;; name if somehow not found, rather than erroring - display code should
;; never crash over a display string).
(define (achievement-label achievement-id)
  (define entry (findf (lambda (e) (eq? (second e) achievement-id)) ACHIEVEMENT-CATALOG))
  (if entry (third entry) (symbol->string achievement-id)))

(module+ test
  (require rackunit)

  (test-case "no-let-needed: accepts a submission avoiding let, rejects one using it"
    (check-true (and (memq 'no-let-needed (map car (check-achievements 'binding "(define (f w) (* w 100))"))) #t))
    (check-false (memq 'no-let-needed (map car (check-achievements 'binding "(define (f w) (let ((c (* w 100))) c))")))))

  (test-case "single-form: accepts exactly one top-level form, rejects more"
    (check-true (and (memq 'single-form (map car (check-achievements 'recursion-basic "(define (f x) (if (null? x) 0 (+ 1 (f (cdr x)))))"))) #t))
    (check-false (memq 'single-form (map car (check-achievements 'recursion-basic "(define (helper x) x) (define (f x) (helper x))")))))

  (test-case "concise-solution: accepts a short submission, rejects a long one"
    (check-true (and (memq 'concise-solution (map car (check-achievements 'higher-order-fn "(define (f lst) (map (lambda (x) x) lst))"))) #t))
    (check-false (memq 'concise-solution
                        (map car (check-achievements
                                  'higher-order-fn
                                  (make-string 100 #\a))))))

  (test-case "a module with no catalog entries yields no achievements"
    (check-equal? (check-achievements 'conditionals "(define (f x) x)") '()))

  (test-case "Achievement Catalog Coverage: at least three distinct modules have a condition"
    (check-true (>= (length (remove-duplicates (map car ACHIEVEMENT-CATALOG))) 3)))

  (test-case "achievement-label finds the catalog label for a known id"
    (check-equal? (achievement-label 'no-let-needed) "Обошлась без let")))

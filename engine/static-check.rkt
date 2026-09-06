#lang racket/base

;; Generic static-check mechanism (code-evaluation: Static Checks Before
;; Execution). Scans a submission's already-read top-level forms for any
;; symbol on a per-exercise disallow-list, wherever it appears (not only in
;; operator position, so a submission cannot dodge the check by aliasing a
;; disallowed symbol to a new name and calling it indirectly).

(require racket/port)

(provide find-disallowed-symbols
         read-all-forms)

;; read-all-forms : string? -> (listof any/c)
;; Reads every top-level datum from a submission's source string.
(define (read-all-forms src)
  (with-input-from-string src
    (lambda ()
      (let loop ([forms '()])
        (define form (read))
        (if (eof-object? form)
            (reverse forms)
            (loop (cons form forms)))))))

;; find-disallowed-symbols : (listof any/c) (listof symbol?) -> (listof symbol?)
;; Returns the subset of `disallowed` that appears anywhere in `forms`,
;; searching recursively through nested lists/pairs. Empty means the check
;; passed.
(define (find-disallowed-symbols forms disallowed)
  (define found (make-hash))
  (define disallowed-set (make-hasheq (map (lambda (s) (cons s #t)) disallowed)))
  (define (walk datum)
    (cond
      [(symbol? datum)
       (when (hash-ref disallowed-set datum #f)
         (hash-set! found datum #t))]
      [(pair? datum)
       (walk (car datum))
       (walk (cdr datum))]
      [(vector? datum)
       (for ([v (in-vector datum)]) (walk v))]
      [else (void)]))
  (for ([form (in-list forms)]) (walk form))
  (filter (lambda (s) (hash-ref found s #f)) disallowed))

(module+ test
  (require rackunit)

  (test-case "no disallowed symbols present"
    (check-equal?
     (find-disallowed-symbols (read-all-forms "(define (f x) (+ x 1))") '(eval dynamic-require))
     '()))

  (test-case "disallowed symbol used directly is found"
    (check-equal?
     (find-disallowed-symbols (read-all-forms "(define (f x) (eval x))") '(eval dynamic-require))
     '(eval)))

  (test-case "disallowed symbol used indirectly (aliased, not called) is still found"
    (check-equal?
     (find-disallowed-symbols (read-all-forms "(define my-eval eval)") '(eval dynamic-require))
     '(eval)))

  (test-case "multiple disallowed symbols across forms are all found"
    (check-equal?
     (sort (find-disallowed-symbols
            (read-all-forms "(define a eval)\n(define b dynamic-require)")
            '(eval dynamic-require))
           symbol<?)
     '(dynamic-require eval))))

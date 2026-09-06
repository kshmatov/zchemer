#lang racket/base

;; Shared sandboxed-execution wrapper (scheme-runtime: Isolated,
;; Resource-Bounded Execution + Fresh Evaluation Isolation).

(require racket/sandbox)

(provide run-in-sandbox
         (struct-out sandbox-result))

;; A sandbox-result reports exactly one of: successful output (plus whatever
;; value `use-evaluator` returned), a timeout, an out-of-memory abort, or an
;; uncaught error raised by the submission itself.
(struct sandbox-result (status output value) #:transparent)
;; status is one of 'ok 'timeout 'out-of-memory 'error
;; value is meaningful only when status is 'ok; #f otherwise.

(define DEFAULT-TIME-LIMIT 5)   ; seconds
(define DEFAULT-MEMORY-LIMIT 64) ; MB

;; run-in-sandbox : string? (evaluator? -> any) -> sandbox-result?
;;
;; Creates a fresh sandboxed evaluator loaded with `submission-src` (a string
;; of Racket/Scheme source defining whatever the submission is expected to
;; define), then calls `use-evaluator` with that evaluator so the caller can
;; invoke the submission's exports. Captures everything the submission prints
;; to stdout during both loading and `use-evaluator`, and turns a sandbox
;; timeout or memory-limit violation into a reported status rather than an
;; uncaught exception, per scheme-runtime's Isolated, Resource-Bounded
;; Execution requirement. Each call creates a brand-new evaluator, so no state
;; leaks between calls, per Fresh Evaluation Isolation.
(define (run-in-sandbox submission-src use-evaluator
                         #:time-limit [time-limit DEFAULT-TIME-LIMIT]
                         #:memory-limit [memory-limit DEFAULT-MEMORY-LIMIT])
  (define out (open-output-string))
  (parameterize ([sandbox-output out]
                 [sandbox-error-output out]
                 [sandbox-eval-limits (list time-limit memory-limit)]
                 [sandbox-memory-limit memory-limit])
    (define evaluator
      (with-handlers ([exn:fail:resource?
                        (lambda (e) #f)])
        (make-evaluator 'racket/base submission-src)))
    (cond
      [(not evaluator)
       (sandbox-result 'out-of-memory (get-output-string out) #f)]
      [else
       (define result
         (with-handlers
           ([exn:fail:sandbox-terminated?
             (lambda (e)
               (if (eq? (exn:fail:sandbox-terminated-reason e) 'out-of-memory)
                   'out-of-memory
                   'timeout))]
            [exn:fail:resource?
             (lambda (e)
               (if (eq? (exn:fail:resource-resource e) 'time)
                   'timeout
                   'out-of-memory))]
            [exn:fail?
             (lambda (e) (cons 'error (exn-message e)))])
           (cons 'ok (use-evaluator evaluator))))
       (kill-evaluator evaluator)
       (cond
         [(and (pair? result) (eq? (car result) 'ok))
          (sandbox-result 'ok (get-output-string out) (cdr result))]
         [(pair? result) (sandbox-result 'error (get-output-string out) #f)]
         [else (sandbox-result result (get-output-string out) #f)])])))

(module+ test
  (require rackunit)

  (test-case "captures ordinary stdout output"
    (define r (run-in-sandbox
               "(define (go) (display \"hi\"))"
               (lambda (ev) (ev '(go)))))
    (check-equal? (sandbox-result-status r) 'ok)
    (check-equal? (sandbox-result-output r) "hi"))

  (test-case "reports timeout for a non-terminating submission"
    (define r (run-in-sandbox
               "(define (go) (let loop () (loop)))"
               (lambda (ev) (ev '(go)))
               #:time-limit 1))
    (check-equal? (sandbox-result-status r) 'timeout))

  (test-case "reports out-of-memory for a submission that allocates without bound"
    (define r (run-in-sandbox
               "(define (go) (let loop ([acc '()]) (loop (cons (make-bytes 1000000) acc))))"
               (lambda (ev) (ev '(go)))
               #:time-limit 5
               #:memory-limit 8))
    (check-equal? (sandbox-result-status r) 'out-of-memory))

  (test-case "fresh evaluator per call: no state leaks between submissions"
    (define r1 (run-in-sandbox
                "(define x 1)\n(display x)"
                (lambda (ev) (void))))
    (check-equal? (sandbox-result-output r1) "1"))

  (test-case "reports the evaluated value of the caller's expression"
    (define r (run-in-sandbox
               "(define (square x) (* x x))"
               (lambda (ev) (ev '(square 6)))))
    (check-equal? (sandbox-result-status r) 'ok)
    (check-equal? (sandbox-result-value r) 36))

  (test-case "value is #f when the submission errors"
    (define r (run-in-sandbox
               "(define (boom) (error \"nope\"))"
               (lambda (ev) (ev '(boom)))))
    (check-equal? (sandbox-result-status r) 'error)
    (check-equal? (sandbox-result-value r) #f)))

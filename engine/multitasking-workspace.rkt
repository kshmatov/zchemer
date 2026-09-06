#lang racket/base

;; Multitasking track grading harness (advanced-project-sandboxes:
;; Multitasking Track Uses Real Concurrency; code-evaluation: Automated
;; Test-Based Grading).

(require racket/runtime-path
         "sandbox.rkt")

(provide grade-multitasking-submission
         (struct-out multitasking-grade-report)
         (struct-out run-outcome)
         load-exercise-params)

(define-runtime-path exercise-params-path
  "../content/multitasking-track/workspace/exercise.rktd")

;; load-exercise-params : -> (listof (cons symbol? any/c))
(define (load-exercise-params)
  (call-with-input-file exercise-params-path read))

;; run-outcome: one repeated-execution run's grading outcome.
(struct run-outcome (run-index passed? actual-output) #:transparent)

;; multitasking-grade-report:
;; - 'passed  : every run's invariant held; `runs` has one run-outcome per completed run
;; - 'failed  : grading stopped at the first violating run; `runs` includes the failing run as its last element
(struct multitasking-grade-report (status runs) #:transparent)

;; grade-multitasking-submission : string? -> multitasking-grade-report?
;; Runs the submission's `run-ledger` call `run-count` times (fail-fast on
;; the first invariant violation), per advanced-project-sandboxes' "Grading
;; repeats execution to surface non-deterministic failures" scenario.
(define (grade-multitasking-submission submission-src)
  (define params (load-exercise-params))
  (define num-workers (cdr (assq 'num-workers params)))
  (define ops-per-worker (cdr (assq 'ops-per-worker params)))
  (define run-count (cdr (assq 'run-count params)))
  (define expected (number->string (* num-workers ops-per-worker)))
  (define call-expr (list 'run-ledger num-workers ops-per-worker))
  (let loop ([i 1] [acc '()])
    (cond
      [(> i run-count)
       (multitasking-grade-report 'passed (reverse acc))]
      [else
       (define r (run-in-sandbox submission-src (lambda (ev) (ev call-expr))))
       (define passed? (and (eq? (sandbox-result-status r) 'ok)
                             (equal? (sandbox-result-output r) expected)))
       (define outcome (run-outcome i passed? (sandbox-result-output r)))
       (if passed?
           (loop (add1 i) (cons outcome acc))
           (multitasking-grade-report 'failed (reverse (cons outcome acc))))])))

(module+ test
  (require rackunit)

  (define correct-ledger-src #<<SRC
(define (run-ledger num-workers ops-per-worker)
  (define balance 0)
  (define sem (make-semaphore 1))
  (define done-ch (make-channel))
  (define (worker)
    (let loop ([i 0])
      (when (< i ops-per-worker)
        (semaphore-wait sem)
        (set! balance (add1 balance))
        (semaphore-post sem)
        (loop (add1 i))))
    (channel-put done-ch 'done))
  (for ([w (in-range num-workers)]) (thread worker))
  (let loop ([remaining num-workers])
    (when (> remaining 0)
      (channel-get done-ch)
      (loop (sub1 remaining))))
  (display balance))
SRC
    )

  (define racy-ledger-src #<<SRC
(define (run-ledger num-workers ops-per-worker)
  (define balance 0)
  (define done-ch (make-channel))
  (define (worker)
    (let loop ([i 0])
      (when (< i ops-per-worker)
        (define old balance)
        (sleep 0)
        (set! balance (add1 old))
        (loop (add1 i))))
    (channel-put done-ch 'done))
  (for ([w (in-range num-workers)]) (thread worker))
  (let loop ([remaining num-workers])
    (when (> remaining 0)
      (channel-get done-ch)
      (loop (sub1 remaining))))
  (display balance))
SRC
    )

  (test-case "correctly synchronized solution passes every run"
    (define report (grade-multitasking-submission correct-ledger-src))
    (check-eq? (multitasking-grade-report-status report) 'passed)
    (check-equal? (length (multitasking-grade-report-runs report)) 10)
    (for ([r (in-list (multitasking-grade-report-runs report))])
      (check-true (run-outcome-passed? r))))

  (test-case "unsynchronized solution fails within the run count"
    (define report (grade-multitasking-submission racy-ledger-src))
    (check-eq? (multitasking-grade-report-status report) 'failed)
    (define runs (multitasking-grade-report-runs report))
    (check-false (run-outcome-passed? (car (reverse runs))))
    ;; fail-fast: grading stopped at the failing run, not all run-count runs
    (check-true (<= (length runs) 10))))

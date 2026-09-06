#lang racket/base

;; Generic lesson grader (code-evaluation: Static Checks Before Execution,
;; Automated Test-Based Grading). Grades a base-course/track-intro lesson's
;; `tests.rktd` against a player submission, reusing sandbox.rkt/static-check.rkt.
;; See openspec/changes/archive/*/lesson-grader/design.md for the call/expr
;; entry-format contract.

(require racket/list
         racket/string
         "sandbox.rkt"
         "static-check.rkt")

(provide grade-lesson-submission
         (struct-out lesson-grade-report)
         (struct-out entry-result))

;; entry-result: one tests.rktd entry's grading outcome.
;; `actual` is the returned value on success, or the sandbox status symbol
;; ('timeout / 'out-of-memory / 'error) when the submission didn't succeed.
(struct entry-result (index passed? actual expected) #:transparent)

;; lesson-grade-report:
;; - 'blocked : static check failed, `results` is empty
;; - 'graded  : every tests.rktd entry was attempted
(struct lesson-grade-report (status blocked-symbols results) #:transparent)

;; grade-lesson-submission : path-string? string? -> lesson-grade-report?
(define (grade-lesson-submission lesson-dir submission-src)
  (define forms (read-all-forms submission-src))
  (define checks-path (build-path lesson-dir "checks.rktd"))
  (define blocked
    (if (file-exists? checks-path)
        (find-disallowed-symbols forms (call-with-input-file checks-path read))
        '()))
  (cond
    [(not (null? blocked))
     (lesson-grade-report 'blocked blocked '())]
    [else
     (define entries (call-with-input-file (build-path lesson-dir "tests.rktd") read))
     (define results
       (for/list ([entry (in-list entries)] [i (in-naturals)])
         (grade-one-entry forms entry i)))
     (lesson-grade-report 'graded '() results)]))

;; grade-one-entry : (listof any/c) any/c exact-nonnegative-integer? -> entry-result?
(define (grade-one-entry forms entry index)
  (define tag (car entry))
  (define-values (load-forms call-expr expected)
    (case tag
      [(expr) (values (drop-right forms 1) (last forms) (cadr entry))]
      [(call) (values forms (cadr entry) (caddr entry))]
      [else (error 'lesson-grader "unknown tests.rktd entry tag: ~a" tag)]))
  (define load-src (forms->source load-forms))
  (define r (run-in-sandbox load-src (lambda (ev) (ev call-expr))))
  (cond
    [(eq? (sandbox-result-status r) 'ok)
     (entry-result index (equal? (sandbox-result-value r) expected)
                   (sandbox-result-value r) expected)]
    [else
     (entry-result index #f (sandbox-result-status r) expected)]))

;; forms->source : (listof any/c) -> string?
;; Re-serializes a list of already-`read` Scheme forms back to source text
;; (valid, since a form representing code is just nested lists/symbols,
;; which `~s`/`write` prints back as re-readable source).
(define (forms->source forms)
  (string-join (map (lambda (f) (format "~s" f)) forms) "\n"))

(module+ test
  (require rackunit
           racket/file
           racket/runtime-path)

  (define-runtime-path content-root "../content")

  (define (lesson-path . segments)
    (apply build-path content-root segments))

  ;; --- 01-s-expr-basics (`expr` format) ---

  (test-case "s-expr-basics: correct submission passes"
    (define report (grade-lesson-submission
                    (lesson-path "base-course" "01-s-expr-basics")
                    "(quote (hull shields sensors))"))
    (check-eq? (lesson-grade-report-status report) 'graded)
    (check-true (entry-result-passed? (car (lesson-grade-report-results report)))))

  (test-case "s-expr-basics: incorrect submission fails"
    (define report (grade-lesson-submission
                    (lesson-path "base-course" "01-s-expr-basics")
                    "(quote (wrong list))"))
    (check-false (entry-result-passed? (car (lesson-grade-report-results report)))))

  ;; --- 03-conditionals (`call` format, multiple entries) ---

  (define conditionals-correct-src
    "(define (shield-status level) (cond ((< level 20) 'critical) ((< level 80) 'stable) (else 'optimal)))")

  ;; Off-by-one boundary bug: uses <= instead of < for the stable branch,
  ;; so shield-status of exactly 80 is misclassified as 'stable instead of
  ;; 'optimal.
  (define conditionals-buggy-src
    "(define (shield-status level) (cond ((< level 20) 'critical) ((<= level 80) 'stable) (else 'optimal)))")

  (test-case "conditionals: correct submission passes every entry"
    (define report (grade-lesson-submission
                    (lesson-path "base-course" "03-conditionals")
                    conditionals-correct-src))
    (for ([r (in-list (lesson-grade-report-results report))])
      (check-true (entry-result-passed? r) (format "entry ~a failed" (entry-result-index r)))))

  (test-case "conditionals: buggy submission fails only the boundary entry"
    (define report (grade-lesson-submission
                    (lesson-path "base-course" "03-conditionals")
                    conditionals-buggy-src))
    (define results (lesson-grade-report-results report))
    ;; entries in tests.rktd: 10 critical, 20 stable, 79 stable, 80 optimal, 100 optimal
    (check-true (entry-result-passed? (list-ref results 0)))
    (check-true (entry-result-passed? (list-ref results 1)))
    (check-true (entry-result-passed? (list-ref results 2)))
    (check-false (entry-result-passed? (list-ref results 3)))
    (check-true (entry-result-passed? (list-ref results 4))))

  ;; --- 09-mutable-state: fresh sandbox load per entry ---

  (define mutable-state-correct-src
    "(define (make-counter) (define count 0) (lambda () (set! count (+ count 1)) count))")

  ;; Bug: every counter shares one module-level count instead of each
  ;; make-counter call getting its own independent closure over a fresh
  ;; binding.
  (define mutable-state-shared-bug-src
    "(define count 0) (define (make-counter) (lambda () (set! count (+ count 1)) count))")

  (test-case "mutable-state: correct submission passes, including independent-counters entry"
    (define report (grade-lesson-submission
                    (lesson-path "base-course" "09-mutable-state")
                    mutable-state-correct-src))
    (for ([r (in-list (lesson-grade-report-results report))])
      (check-true (entry-result-passed? r) (format "entry ~a failed: ~a" (entry-result-index r) (entry-result-actual r)))))

  (test-case "mutable-state: submission sharing state across counters fails the independence entry"
    (define report (grade-lesson-submission
                    (lesson-path "base-course" "09-mutable-state")
                    mutable-state-shared-bug-src))
    (define results (lesson-grade-report-results report))
    ;; entries in tests.rktd: single call -> 1, three calls -> 3, then the
    ;; independence check (c1 c1 c2 -> 1), which this bug fails (c2 sees
    ;; the shared count already advanced by c1's two prior calls).
    (check-true (entry-result-passed? (list-ref results 0)))
    (check-true (entry-result-passed? (list-ref results 1)))
    (check-false (entry-result-passed? (list-ref results 2))))

  ;; --- checks.rktd static-check path ---

  (test-case "no lesson currently ships a checks.rktd"
    ;; base-course-content's design reserved checks.rktd for a future
    ;; lesson that needs it; confirm grading proceeds normally in its
    ;; absence.
    (define lesson-dir (lesson-path "base-course" "02-binding"))
    (check-false (file-exists? (build-path lesson-dir "checks.rktd")))
    (define report (grade-lesson-submission
                    lesson-dir
                    "(define (convert-to-cochranes w) (let ((c (* w 100))) c))"))
    (check-eq? (lesson-grade-report-status report) 'graded))

  (test-case "static check blocks grading before any entry runs, when checks.rktd exists"
    ;; No real lesson has a checks.rktd yet, so exercise the block path
    ;; end-to-end against a throwaway temp directory that mirrors a real
    ;; lesson's shape (tests.rktd + checks.rktd).
    (define tmp-dir (make-temporary-file "lesson-grader-check~a" 'directory))
    (dynamic-wind
     void
     (lambda ()
       (call-with-output-file (build-path tmp-dir "tests.rktd")
         (lambda (out) (write '((call (f 1) 1)) out)))
       (call-with-output-file (build-path tmp-dir "checks.rktd")
         (lambda (out) (write '(eval dynamic-require) out)))
       (define report (grade-lesson-submission
                       tmp-dir
                       "(define (f x) (eval x))"))
       (check-eq? (lesson-grade-report-status report) 'blocked)
       (check-equal? (lesson-grade-report-blocked-symbols report) '(eval))
       (check-equal? (lesson-grade-report-results report) '()))
     (lambda ()
       (delete-file (build-path tmp-dir "tests.rktd"))
       (delete-file (build-path tmp-dir "checks.rktd"))
       (delete-directory tmp-dir)))))

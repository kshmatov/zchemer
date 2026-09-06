#lang racket/base

;; Interpreter track grading harness (advanced-project-sandboxes:
;; Interpreter Track Evaluation Workspace, Minimal Interpreted-Program
;; Error Detection; code-evaluation: Static Checks, Automated Test-Based
;; Grading).

(require racket/list
         racket/runtime-path
         "sandbox.rkt"
         "static-check.rkt")

(provide grade-interpreter-submission
         (struct-out interpreter-grade-report)
         (struct-out program-result)
         load-reference-suite
         DISALLOWED-SYMBOLS)

(define-runtime-path reference-suite-path
  "../content/interpreter-track/workspace/reference-suite.rktd")

(define DISALLOWED-SYMBOLS '(eval dynamic-require))

;; load-reference-suite : -> (listof (list symbol? (listof any/c) (or/c string? 'raises-error)))
(define (load-reference-suite)
  (call-with-input-file reference-suite-path read))

;; program-result: one reference program's grading outcome.
(struct program-result (name passed? detail) #:transparent)

;; interpreter-grade-report:
;; - 'blocked   : static check failed, `results` is empty and `blocked-symbols` names why
;; - 'graded    : every reference program was run; `results` has one program-result per entry
(struct interpreter-grade-report (status blocked-symbols results) #:transparent)

;; grade-interpreter-submission : string? -> interpreter-grade-report?
(define (grade-interpreter-submission submission-src)
  (define forms (read-all-forms submission-src))
  (define blocked (find-disallowed-symbols forms DISALLOWED-SYMBOLS))
  (cond
    [(not (null? blocked))
     (interpreter-grade-report 'blocked blocked '())]
    [else
     (define suite (load-reference-suite))
     (define results
       (for/list ([entry (in-list suite)])
         (define name (car entry))
         (define program-forms (cadr entry))
         (define expected (caddr entry))
         (define r (run-in-sandbox
                    submission-src
                    (lambda (ev) (ev (list 'run-program (list 'quote program-forms))))))
         (cond
           [(eq? expected 'raises-error)
            (program-result name (eq? (sandbox-result-status r) 'error)
                             (sandbox-result-status r))]
           [else
            (program-result name
                             (and (eq? (sandbox-result-status r) 'ok)
                                  (equal? (sandbox-result-output r) expected))
                             (sandbox-result-output r))])))
     (interpreter-grade-report 'graded '() results)]))

(module+ test
  (require rackunit)

  (define correct-evaluator-src #<<SRC
(struct closure (params body env))

(define (env-lookup env name)
  (cond [(null? env) (error 'run-program "unbound variable: ~a" name)]
        [(hash-has-key? (car env) name) (hash-ref (car env) name)]
        [else (env-lookup (cdr env) name)]))

(define (env-define! env name val)
  (hash-set! (car env) name val))

(define (my-eval expr env)
  (cond
    [(symbol? expr) (env-lookup env expr)]
    [(pair? expr)
     (define op (car expr))
     (cond
       [(eq? op 'quote) (cadr expr)]
       [(eq? op 'if) (if (not (eq? (my-eval (cadr expr) env) #f))
                          (my-eval (caddr expr) env)
                          (my-eval (cadddr expr) env))]
       [(eq? op 'lambda) (closure (cadr expr) (caddr expr) env)]
       [(eq? op 'define)
        (define target (cadr expr))
        (if (pair? target)
            (env-define! env (car target) (closure (cdr target) (caddr expr) env))
            (env-define! env target (my-eval (caddr expr) env)))
        'defined]
       [else
        (define proc (my-eval op env))
        (define args (map (lambda (a) (my-eval a env)) (cdr expr)))
        (my-apply proc args)])]
    [else expr]))

(define (my-apply proc args)
  (cond
    [(procedure? proc) (apply proc args)]
    [(closure? proc)
     (define params (closure-params proc))
     (unless (= (length params) (length args))
       (error 'run-program "arity mismatch"))
     (define frame (make-hasheq))
     (for ([p params] [a args]) (hash-set! frame p a))
     (my-eval (closure-body proc) (cons frame (closure-env proc)))]
    [else (error 'run-program "non-procedure application: ~a" proc)]))

(define (run-program forms)
  (define global-frame (make-hasheq))
  (define global (list global-frame))
  (hash-set! global-frame '+ +)
  (hash-set! global-frame '- -)
  (hash-set! global-frame '* *)
  (hash-set! global-frame '/ /)
  (hash-set! global-frame '< <)
  (hash-set! global-frame '= =)
  (hash-set! global-frame 'display display)
  (for ([f forms]) (my-eval f global)))
SRC
    )

  (define arity-blind-evaluator-src
    ;; Same as correct-evaluator-src but my-apply never checks arity: extra
    ;; args are silently ignored, missing args are silently bound to #f.
    #<<SRC
(struct closure (params body env))

(define (env-lookup env name)
  (cond [(null? env) (error 'run-program "unbound variable: ~a" name)]
        [(hash-has-key? (car env) name) (hash-ref (car env) name)]
        [else (env-lookup (cdr env) name)]))

(define (env-define! env name val)
  (hash-set! (car env) name val))

(define (my-eval expr env)
  (cond
    [(symbol? expr) (env-lookup env expr)]
    [(pair? expr)
     (define op (car expr))
     (cond
       [(eq? op 'quote) (cadr expr)]
       [(eq? op 'if) (if (not (eq? (my-eval (cadr expr) env) #f))
                          (my-eval (caddr expr) env)
                          (my-eval (cadddr expr) env))]
       [(eq? op 'lambda) (closure (cadr expr) (caddr expr) env)]
       [(eq? op 'define)
        (define target (cadr expr))
        (if (pair? target)
            (env-define! env (car target) (closure (cdr target) (caddr expr) env))
            (env-define! env target (my-eval (caddr expr) env)))
        'defined]
       [else
        (define proc (my-eval op env))
        (define args (map (lambda (a) (my-eval a env)) (cdr expr)))
        (my-apply proc args)])]
    [else expr]))

(define (my-apply proc args)
  (cond
    [(procedure? proc) (apply proc args)]
    [(closure? proc)
     (define params (closure-params proc))
     (define frame (make-hasheq))
     (let loop ([ps params] [as args])
       (cond [(and (null? ps) (null? as)) (void)]
             [(null? ps) (void)]
             [(null? as) (hash-set! frame (car ps) #f) (loop (cdr ps) '())]
             [else (hash-set! frame (car ps) (car as)) (loop (cdr ps) (cdr as))]))
     (my-eval (closure-body proc) (cons frame (closure-env proc)))]
    [else (error 'run-program "non-procedure application: ~a" proc)]))

(define (run-program forms)
  (define global-frame (make-hasheq))
  (define global (list global-frame))
  (hash-set! global-frame '+ +)
  (hash-set! global-frame '- -)
  (hash-set! global-frame '* *)
  (hash-set! global-frame '/ /)
  (hash-set! global-frame '< <)
  (hash-set! global-frame '= =)
  (hash-set! global-frame 'display display)
  (for ([f forms]) (my-eval f global)))
SRC
    )

  (define eval-delegating-src
    "(define (run-program forms) (for ([f forms]) (display (eval f))))")

  (test-case "correct evaluator passes every reference program"
    (define report (grade-interpreter-submission correct-evaluator-src))
    (check-eq? (interpreter-grade-report-status report) 'graded)
    (for ([r (in-list (interpreter-grade-report-results report))])
      (check-true (program-result-passed? r) (format "~a failed: ~a" (program-result-name r) (program-result-detail r)))))

  (test-case "arity-blind evaluator fails specifically the arity-mismatch program"
    (define report (grade-interpreter-submission arity-blind-evaluator-src))
    (check-eq? (interpreter-grade-report-status report) 'graded)
    (define results (interpreter-grade-report-results report))
    (define (result-for name)
      (findf (lambda (r) (eq? (program-result-name r) name)) results))
    (check-false (program-result-passed? (result-for 'error-arity-mismatch)))
    ;; unrelated programs still pass
    (check-true (program-result-passed? (result-for 'definitions-and-application)))
    (check-true (program-result-passed? (result-for 'quotation))))

  (test-case "submission delegating to Racket's own eval is statically blocked"
    (define report (grade-interpreter-submission eval-delegating-src))
    (check-eq? (interpreter-grade-report-status report) 'blocked)
    (check-equal? (interpreter-grade-report-blocked-symbols report) '(eval))
    (check-equal? (interpreter-grade-report-results report) '())))

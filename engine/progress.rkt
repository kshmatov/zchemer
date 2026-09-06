#lang racket/base

;; Progress persistence (progress-persistence: Local Account-Free
;; Persistence, Human-Inspectable Save Format, Independent Per-Track
;; State, Resilience to Missing or Corrupt Save Data, Last Successful
;; Submission Retained, Project-Based Exercise Reference Retained).
;;
;; progress-state is a plain immutable value; every update returns a new
;; one. Module ids are the same vocabulary engine/curriculum.rkt's
;; MODULE-TABLE uses.

(require racket/list)

(provide fresh-progress
         mark-completed
         record-submission
         record-project-ref
         save-progress
         load-progress
         (struct-out progress-state))

;; completed-modules  : (listof symbol?)
;; last-submissions   : (listof (cons symbol? string?))          -- module-id -> retained source
;; project-refs       : (listof (cons symbol? (list string? string? boolean?)))
;;                        -- module-id -> (folder-path entry-point pass-fail?)
(struct progress-state (completed-modules last-submissions project-refs) #:transparent)

(define (fresh-progress)
  (progress-state '() '() '()))

;; mark-completed : progress-state? symbol? -> progress-state?
(define (mark-completed state module-id)
  (if (member module-id (progress-state-completed-modules state))
      state
      (progress-state (cons module-id (progress-state-completed-modules state))
                       (progress-state-last-submissions state)
                       (progress-state-project-refs state))))

;; record-submission : progress-state? symbol? string? -> progress-state?
;; Always replaces any prior entry for module-id - covers both "first
;; completion" and "a later passing resubmission during review" with one
;; code path.
(define (record-submission state module-id src)
  (define others (filter (lambda (e) (not (eq? (car e) module-id)))
                          (progress-state-last-submissions state)))
  (progress-state (progress-state-completed-modules state)
                   (cons (cons module-id src) others)
                   (progress-state-project-refs state)))

;; record-project-ref : progress-state? symbol? string? string? boolean? -> progress-state?
(define (record-project-ref state module-id folder-path entry-point pass-fail?)
  (define others (filter (lambda (e) (not (eq? (car e) module-id)))
                          (progress-state-project-refs state)))
  (progress-state (progress-state-completed-modules state)
                   (progress-state-last-submissions state)
                   (cons (cons module-id (list folder-path entry-point pass-fail?)) others)))

;; save-progress : progress-state? path-string? -> void?
(define (save-progress state path)
  (call-with-output-file path #:exists 'replace
    (lambda (out)
      (write (list (cons 'completed-modules (progress-state-completed-modules state))
                   (cons 'last-submissions (progress-state-last-submissions state))
                   (cons 'project-refs (progress-state-project-refs state)))
             out))))

;; load-progress : path-string? -> progress-state?
;; Never raises: a missing or unparseable save file yields a fresh state.
(define (load-progress path)
  (cond
    [(not (file-exists? path)) (fresh-progress)]
    [else
     (with-handlers ([exn:fail? (lambda (e) (fresh-progress))])
       (define data (call-with-input-file path read))
       (progress-state (cdr (assq 'completed-modules data))
                        (cdr (assq 'last-submissions data))
                        (cdr (assq 'project-refs data))))]))

(module+ test
  (require rackunit
           racket/file)

  (define (with-temp-path proc)
    (define path (make-temporary-file "progress-test~a"))
    (delete-file path) ; the file itself shouldn't exist yet for some tests
    (dynamic-wind
     void
     (lambda () (proc path))
     (lambda () (when (file-exists? path) (delete-file path)))))

  (test-case "full round-trip: save then load reproduces the same state"
    (with-temp-path
     (lambda (path)
       (define state
         (record-project-ref
          (record-submission
           (mark-completed
            (mark-completed (fresh-progress) 's-expr-basics)
            'binding)
           's-expr-basics "(quote (hull shields sensors))")
          'interpreter-eval-workspace "/home/player/projects/my-eval" "main.rkt" #t))
       (save-progress state path)
       (define loaded (load-progress path))
       (check-equal? loaded state))))

  (test-case "missing file: load-progress returns a fresh state"
    (with-temp-path
     (lambda (path)
       (check-false (file-exists? path))
       (check-equal? (load-progress path) (fresh-progress)))))

  (test-case "corrupt file: load-progress returns a fresh state instead of raising"
    (with-temp-path
     (lambda (path)
       (call-with-output-file path (lambda (out) (display "(not valid #%$ data" out)))
       (check-equal? (load-progress path) (fresh-progress)))))

  (test-case "independent per-track state"
    (define state
      (record-submission
       (mark-completed
        (mark-completed (fresh-progress) 'symbolic-data)
        'environment-model)
       'symbolic-data "(quote x)"))
    (check-true (and (member 'symbolic-data (progress-state-completed-modules state)) #t))
    (check-true (and (member 'environment-model (progress-state-completed-modules state)) #t))
    (check-false (and (member 'concurrency-primitives (progress-state-completed-modules state)) #t))
    (check-false (assq 'concurrency-primitives (progress-state-last-submissions state))))

  (test-case "record-submission replaces the prior source for the same module"
    (define state1 (record-submission (fresh-progress) 'binding "(define x 1)"))
    (define state2 (record-submission state1 'binding "(define x 2)"))
    (check-equal? (cdr (assq 'binding (progress-state-last-submissions state2))) "(define x 2)")
    (check-equal? (length (progress-state-last-submissions state2)) 1)))

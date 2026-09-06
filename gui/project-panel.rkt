#lang racket/gui

;; Project view (gui-lcars: Dedicated Loaded-Project View;
;; advanced-project-sandboxes: Loadable Multi-File Projects). Loads a
;; folder of .scm files, lets the player edit them and pick an entry
;; point, and grades that entry point through one of the two MVP
;; workspaces' existing graders.

(require "../engine/interpreter-workspace.rkt"
         "../engine/multitasking-workspace.rkt"
         "../engine/progress.rkt"
         "code-editor.rkt"
         "lcars-style.rkt")

(provide scan-project-files
         WORKSPACES
         make-project-panel
         current-get-directory)

;; current-get-directory : parameter of (string? -> (or/c path? #f))
;; Swappable in tests to avoid popping a real native folder-choose dialog;
;; defaults to racket/gui's own get-directory.
(define current-get-directory (make-parameter get-directory))

;; scan-project-files : path-string? -> (listof string?)
;; Pure (given the folder's current contents): the sorted list of .scm
;; filenames directly inside `folder` (no subdirectories, no other
;; extensions), per advanced-project-sandboxes' ".scm files" wording.
(define (scan-project-files folder)
  (sort
   (for/list ([p (in-list (directory-list folder))]
              #:when (and (file-exists? (build-path folder p))
                          (regexp-match? #px"\\.scm$" (path->string p))))
     (path->string p))
   string<?))

;; --- Interpreter workspace report adapters ---

(define (interpreter-passed? report)
  (and (eq? (interpreter-grade-report-status report) 'graded)
       (andmap program-result-passed? (interpreter-grade-report-results report))))

(define (interpreter-lines report)
  (cond
    [(eq? (interpreter-grade-report-status report) 'blocked)
     (list (format "ЗАБЛОКИРОВАНО: ~a" (interpreter-grade-report-blocked-symbols report)))]
    [else
     (append
      (for/list ([r (in-list (interpreter-grade-report-results report))])
        (format "  [~a] ~a: ~a"
                (if (program-result-passed? r) "OK" "FAIL")
                (program-result-name r) (program-result-detail r)))
      (list (if (interpreter-passed? report) "ПРОЙДЕНО" "ПРОВАЛЕНО")))]))

;; --- Multitasking workspace report adapters ---

(define (multitasking-passed? report)
  (eq? (multitasking-grade-report-status report) 'passed))

(define (multitasking-lines report)
  (append
   (for/list ([r (in-list (multitasking-grade-report-runs report))])
     (format "  прогон ~a: ~a"
             (run-outcome-run-index r)
             (if (run-outcome-passed? r) "OK" (format "FAIL (~a)" (run-outcome-actual-output r)))))
   (list (if (multitasking-passed? report) "ПРОЙДЕНО" "ПРОВАЛЕНО"))))

;; WORKSPACES : (listof (list symbol? string? (string? -> any/c) (any/c -> (listof string?)) (any/c -> boolean?)))
(define WORKSPACES
  (list
   (list 'interpreter-eval-workspace "Интерпретатор (eval/apply)"
         grade-interpreter-submission interpreter-lines interpreter-passed?)
   (list 'multitasking-ledger-workspace "Многозадачность (ledger)"
         grade-multitasking-submission multitasking-lines multitasking-passed?)))

;; make-project-panel : (is-a?/c area-container<%>) (box progress-state?) string? (-> void?) -> (is-a?/c panel%)
(define (make-project-panel parent progress-box save-path on-changed)
  (define panel (new vertical-panel% [parent parent]))

  (define current-folder (box #f))
  (define current-entry-point (box #f))
  (define current-open-file (box #f))

  (define workspace-picker
    (new list-box%
         [parent panel]
         [label "Рабочее пространство:"]
         [choices (map second WORKSPACES)]
         [style '(single)]
         [stretchable-height #f]))
  (send workspace-picker set-selection 0)

  (define folder-row (new horizontal-panel% [parent panel] [stretchable-height #f]))
  (define load-button
    (new button% [parent folder-row] [label "Загрузить папку"]
         [callback (lambda (b e)
                     (define dir ((current-get-directory) "Выберите папку проекта"))
                     (when dir (load-folder! (if (path? dir) (path->string dir) dir))))]))
  (define entry-point-label
    (new message% [parent folder-row] [label "Точка входа: (нет)"] [color ACCENT-AMBER]))

  (define file-list
    (new list-box%
         [parent panel]
         [label "Файлы:"]
         [choices '()]
         [style '(single)]
         [stretchable-height #f]
         [callback (lambda (l e) (select-file! (get-selected-filename)))]))

  (define set-entry-button
    (new button% [parent panel] [label "Назначить точкой входа"]
         [callback (lambda (b e) (assign-entry-point!))]))

  (define-values (code-canvas code-text) (make-code-editor panel))

  (define run-button
    (new button% [parent panel] [label "Запустить"]
         [callback (lambda (b e) (do-run!))]))

  (define results (new text%))
  (define results-canvas
    (new editor-canvas% [parent panel] [editor results] [stretchable-height #f] [min-height 100]))

  (define (get-selected-filename)
    (define sel (send file-list get-selection))
    (and sel (send file-list get-string sel)))

  (define (save-current-file!)
    (define f (unbox current-open-file))
    (when (and f (unbox current-folder))
      (call-with-output-file (build-path (unbox current-folder) f) #:exists 'replace
        (lambda (out) (display (send code-text get-text) out)))))

  (define (select-file! filename)
    (when filename
      (save-current-file!)
      (send code-text erase)
      (send code-text insert (call-with-input-file (build-path (unbox current-folder) filename) port->string))
      (set-box! current-open-file filename)))

  (define (assign-entry-point!)
    (define f (unbox current-open-file))
    (when f
      (set-box! current-entry-point f)
      (send entry-point-label set-label (format "Точка входа: ~a" f))))

  ;; load-folder! : path-string? -> void?
  ;; Scans `folder-path` for .scm files, populates the file list, and
  ;; defaults the entry point to the alphabetically-first one.
  (define (load-folder! folder-path)
    (set-box! current-folder folder-path)
    (set-box! current-open-file #f)
    (define files (scan-project-files folder-path))
    (send file-list set files)
    (set-box! current-entry-point (and (pair? files) (car files)))
    (send entry-point-label set-label
          (format "Точка входа: ~a" (or (unbox current-entry-point) "(нет)")))
    (when (pair? files)
      (send file-list set-selection 0)
      (select-file! (car files))))

  (define (show-results! lines)
    (send results erase)
    (send results insert (string-join lines "\n")))

  (define (selected-workspace)
    (list-ref WORKSPACES (send workspace-picker get-selection)))

  (define (do-run!)
    (save-current-file!)
    (define entry (unbox current-entry-point))
    (define folder (unbox current-folder))
    (when (and entry folder)
      (define src (call-with-input-file (build-path folder entry) port->string))
      (match-define (list module-id label grade-fn lines-fn passed?-fn) (selected-workspace))
      (define report (grade-fn src))
      (show-results! (lines-fn report))
      (define state (unbox progress-box))
      (define already-completed? (and (member module-id (progress-state-completed-modules state)) #t))
      (cond
        [(passed?-fn report)
         (set-box! progress-box
                   (record-project-ref (mark-completed state module-id) module-id folder entry #t))
         (save-progress (unbox progress-box) save-path)
         (on-changed)]
        [already-completed?
         (set-box! progress-box (record-project-ref state module-id folder entry #f))
         (save-progress (unbox progress-box) save-path)]
        [else (void)])))

  panel)

(module+ test
  (require rackunit racket/file)

  (test-case "scan-project-files: only .scm files directly in the folder, sorted"
    (define dir (make-temporary-file "project-test~a" 'directory))
    (dynamic-wind
     void
     (lambda ()
       (call-with-output-file (build-path dir "b.scm") void)
       (call-with-output-file (build-path dir "a.scm") void)
       (call-with-output-file (build-path dir "notes.txt") void)
       (make-directory (build-path dir "subdir"))
       (call-with-output-file (build-path dir "subdir" "c.scm") void)
       (check-equal? (scan-project-files dir) '("a.scm" "b.scm")))
     (lambda () (delete-directory/files dir))))

  (define (find-widget container pred)
    (or (findf pred (send container get-children))
        (for/or ([c (in-list (send container get-children))])
          (and (is-a? c area-container<%>) (find-widget c pred)))))

  (define (find-button panel label)
    (find-widget panel (lambda (c) (and (is-a? c button%) (equal? (send c get-label) label)))))

  (define (find-list-box panel label-substring)
    (find-widget panel (lambda (c) (and (is-a? c list-box%)
                                         (regexp-match? (regexp-quote label-substring) (or (send c get-label) ""))))))

  (define (find-message panel label-prefix)
    (find-widget panel (lambda (c) (and (is-a? c message%)
                                         (regexp-match? (pregexp (string-append "^" (regexp-quote label-prefix))) (send c get-label))))))

  (define (find-code-text panel)
    (define canvases
      (let loop ([container panel])
        (append (filter (lambda (c) (is-a? c editor-canvas%)) (send container get-children))
                (append-map (lambda (c) (if (is-a? c area-container<%>) (loop c) '()))
                            (send container get-children)))))
    (send (car canvases) get-editor))

  ;; test-project-panel! : (-> void?) -> void?
  ;; Builds a fresh temp project folder + progress box + panel, runs
  ;; `body` with them all in scope via parameters, cleans up after.
  (define current-test-panel (make-parameter #f))
  (define current-test-dir (make-parameter #f))
  (define current-pbox (make-parameter #f))
  (define current-save-path (make-parameter #f))
  (define current-changed? (make-parameter #f))

  (define (with-test-panel proc)
    (define dir (make-temporary-file "project-test~a" 'directory))
    (define tmp-save (make-temporary-file "project-test-save~a"))
    (delete-file tmp-save)
    (dynamic-wind
     void
     (lambda ()
       (define pbox (box (fresh-progress)))
       (define changed? (box #f))
       (define frame (new frame% [label "test"] [width 500] [height 500]))
       (define panel (make-project-panel frame pbox tmp-save (lambda () (set-box! changed? #t))))
       (parameterize ([current-test-panel panel]
                      [current-test-dir dir]
                      [current-pbox pbox]
                      [current-save-path tmp-save]
                      [current-changed? changed?])
         (proc)))
     (lambda ()
       (delete-directory/files dir)
       (when (file-exists? tmp-save) (delete-file tmp-save)))))

  (test-case "loading a folder populates the file list and defaults entry point to first .scm alphabetically"
    (with-test-panel
     (lambda ()
       (define dir (current-test-dir))
       (call-with-output-file (build-path dir "zeta.scm") (lambda (o) (display "(define (run-program f) (void))" o)))
       (call-with-output-file (build-path dir "alpha.scm") (lambda (o) (display "(define (run-program f) (void))" o)))
       (parameterize ([current-get-directory (lambda (msg) dir)])
         (send (find-button (current-test-panel) "Загрузить папку") command (new control-event% [event-type 'button])))
       (define fl (find-list-box (current-test-panel) "Файлы"))
       (check-equal? (for/list ([i (in-range (send fl get-number))]) (send fl get-string i))
                     '("alpha.scm" "zeta.scm"))
       (define entry-label (find-message (current-test-panel) "Точка входа:"))
       (check-equal? (send entry-label get-label) "Точка входа: alpha.scm"))))

  (test-case "reassigning the entry point changes it to the currently open file"
    (with-test-panel
     (lambda ()
       (define dir (current-test-dir))
       (call-with-output-file (build-path dir "alpha.scm") (lambda (o) (display "(define (run-program f) (void))" o)))
       (call-with-output-file (build-path dir "beta.scm") (lambda (o) (display "(define (run-program f) (void))" o)))
       (parameterize ([current-get-directory (lambda (msg) dir)])
         (send (find-button (current-test-panel) "Загрузить папку") command (new control-event% [event-type 'button])))
       (define fl (find-list-box (current-test-panel) "Файлы"))
       (send fl set-selection 1) ;; beta.scm
       (send fl command (new control-event% [event-type 'list-box]))
       (send (find-button (current-test-panel) "Назначить точкой входа") command (new control-event% [event-type 'button]))
       (define entry-label (find-message (current-test-panel) "Точка входа:"))
       (check-equal? (send entry-label get-label) "Точка входа: beta.scm"))))

  (define CORRECT-EVALUATOR-SRC #<<SRC
(struct closure (params body env))
(define (env-lookup env name)
  (cond [(null? env) (error 'run-program "unbound variable: ~a" name)]
        [(hash-has-key? (car env) name) (hash-ref (car env) name)]
        [else (env-lookup (cdr env) name)]))
(define (env-define! env name val) (hash-set! (car env) name val))
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
     (unless (= (length params) (length args)) (error 'run-program "arity mismatch"))
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

  (define WRONG-EVALUATOR-SRC "(define (run-program forms) (display \"nope\"))")

  (define CORRECT-LEDGER-SRC #<<SRC
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
    (when (> remaining 0) (channel-get done-ch) (loop (sub1 remaining))))
  (display balance))
SRC
    )

  (define WRONG-LEDGER-SRC "(define (run-ledger n o) (display 0))")

  ;; do-run! : select workspace by index, click Запустить
  (define (run-with-workspace! idx)
    (define wp (find-list-box (current-test-panel) "Рабочее пространство"))
    (send wp set-selection idx)
    (send (find-button (current-test-panel) "Запустить") command (new control-event% [event-type 'button])))

  (define (setup-project! filename src)
    (define dir (current-test-dir))
    (call-with-output-file (build-path dir filename) (lambda (o) (display src o)))
    (parameterize ([current-get-directory (lambda (msg) dir)])
      (send (find-button (current-test-panel) "Загрузить папку") command (new control-event% [event-type 'button]))))

  (test-case "end-to-end (Interpreter): correct entry point marks completed and persists a project ref"
    (with-test-panel
     (lambda ()
       (setup-project! "main.scm" CORRECT-EVALUATOR-SRC)
       (run-with-workspace! 0) ;; Interpreter
       (check-true (unbox (current-changed?)))
       (define state (unbox (current-pbox)))
       (check-true (and (member 'interpreter-eval-workspace (progress-state-completed-modules state)) #t))
       (define ref (cdr (assq 'interpreter-eval-workspace (progress-state-project-refs state))))
       (check-equal? (third ref) #t) ;; pass-fail?
       (check-equal? (load-progress (current-save-path)) state))))

  (test-case "end-to-end (Multitasking): correct entry point marks completed and persists a project ref"
    (with-test-panel
     (lambda ()
       (setup-project! "main.scm" CORRECT-LEDGER-SRC)
       (run-with-workspace! 1) ;; Multitasking
       (check-true (unbox (current-changed?)))
       (define state (unbox (current-pbox)))
       (check-true (and (member 'multitasking-ledger-workspace (progress-state-completed-modules state)) #t)))))

  (test-case "end-to-end: incorrect entry point for a not-yet-completed workspace persists nothing"
    (with-test-panel
     (lambda ()
       (setup-project! "main.scm" WRONG-EVALUATOR-SRC)
       (run-with-workspace! 0)
       (check-false (unbox (current-changed?)))
       (check-false (file-exists? (current-save-path))))))

  (test-case "end-to-end: incorrect re-check on an already-completed workspace updates pass-fail? without un-completing"
    (with-test-panel
     (lambda ()
       (setup-project! "main.scm" CORRECT-EVALUATOR-SRC)
       (run-with-workspace! 0)
       (check-true (and (member 'interpreter-eval-workspace (progress-state-completed-modules (unbox (current-pbox)))) #t))
       ;; now edit the entry point to a wrong solution and re-check (review)
       (define ct (find-code-text (current-test-panel)))
       (send ct erase)
       (send ct insert WRONG-EVALUATOR-SRC)
       (run-with-workspace! 0)
       (define state (unbox (current-pbox)))
       (check-true (and (member 'interpreter-eval-workspace (progress-state-completed-modules state)) #t))
       (define ref (cdr (assq 'interpreter-eval-workspace (progress-state-project-refs state))))
       (check-equal? (third ref) #f))))

  (test-case "switching the selected file auto-saves edits to the previously open file"
    (with-test-panel
     (lambda ()
       (define dir (current-test-dir))
       (call-with-output-file (build-path dir "alpha.scm") (lambda (o) (display "original-alpha" o)))
       (call-with-output-file (build-path dir "beta.scm") (lambda (o) (display "original-beta" o)))
       (parameterize ([current-get-directory (lambda (msg) dir)])
         (send (find-button (current-test-panel) "Загрузить папку") command (new control-event% [event-type 'button])))
       (define fl (find-list-box (current-test-panel) "Файлы"))
       ;; alpha.scm is open (index 0); edit it, then switch to beta.scm
       (define ct (find-code-text (current-test-panel)))
       (send ct erase)
       (send ct insert "edited-alpha")
       (send fl set-selection 1)
       (send fl command (new control-event% [event-type 'list-box]))
       (check-equal? (call-with-input-file (build-path dir "alpha.scm") port->string) "edited-alpha")))))

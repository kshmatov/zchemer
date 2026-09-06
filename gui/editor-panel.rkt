#lang racket/gui

;; Editor panel (gui-lcars: Inline Code Editor for Simple Examples).
;; Lesson picker + read-only instructional text + code editor + check
;; button + results area. Wires engine/lesson-grader.rkt and
;; engine/progress.rkt together for the first time.

(require racket/runtime-path
         "../engine/lesson-grader.rkt"
         "../engine/progress.rkt"
         "code-editor.rkt"
         "lcars-style.rkt")

(provide LESSON-DIRS
         lesson-md-body
         make-editor-panel)

(define-runtime-path content-root "../content")

;; LESSON-DIRS : (listof (cons symbol? path-string?))
;; The 13 lesson module ids this editor can grade, mapped to their
;; content/ directory. Excludes the two workspace module ids
;; (interpreter-eval-workspace, multitasking-ledger-workspace), which use
;; a different submission contract and belong to the future project view.
(define LESSON-DIRS
  (list
   (cons 's-expr-basics (build-path content-root "base-course" "01-s-expr-basics"))
   (cons 'binding (build-path content-root "base-course" "02-binding"))
   (cons 'conditionals (build-path content-root "base-course" "03-conditionals"))
   (cons 'first-class-fn (build-path content-root "base-course" "04-first-class-fn"))
   (cons 'recursion-basic (build-path content-root "base-course" "05-recursion-basic"))
   (cons 'tail-recursion (build-path content-root "base-course" "06-tail-recursion"))
   (cons 'closures (build-path content-root "base-course" "07-closures"))
   (cons 'higher-order-fn (build-path content-root "base-course" "08-higher-order-fn"))
   (cons 'mutable-state (build-path content-root "base-course" "09-mutable-state"))
   (cons 'data-structures (build-path content-root "base-course" "10-data-structures"))
   (cons 'symbolic-data (build-path content-root "interpreter-track" "01-symbolic-data"))
   (cons 'environment-model (build-path content-root "interpreter-track" "02-environment-model"))
   (cons 'concurrency-primitives (build-path content-root "multitasking-track" "01-concurrency-primitives"))))

;; lesson-md-body : path-string? -> string?
;; Strips the YAML front matter (the leading "---...---" block) from a
;; lesson.md file, returning just the Log Entry + Exercise text.
(define (lesson-md-body lesson-dir)
  (define content (call-with-input-file (build-path lesson-dir "lesson.md") port->string))
  (define parts (regexp-split #px"(?m:^---\\s*$)" content))
  (if (>= (length parts) 3) (string-trim (caddr parts)) content))

;; result->string : entry-result? -> string?
(define (result->string r)
  (format "  [~a] entry ~a: expected ~a, got ~a"
          (if (entry-result-passed? r) "OK" "FAIL")
          (entry-result-index r) (entry-result-expected r) (entry-result-actual r)))

;; make-editor-panel : (is-a?/c area-container<%>) (box progress-state?) string? (-> void?) -> (is-a?/c panel%)
;; progress-box holds the current progress-state; save-path is where it's
;; persisted; on-changed is called after a successful check-and-persist so
;; the caller can refresh other views.
(define (make-editor-panel parent progress-box save-path on-changed)
  (define panel (new vertical-panel% [parent parent]))
  (define picker
    (new list-box%
         [parent panel]
         [label "Урок:"]
         [choices (map (lambda (e) (symbol->string (car e))) LESSON-DIRS)]
         [style '(single)]
         [stretchable-height #f]
         [callback (lambda (l e) (load-selected!))]))
  (define instructions
    (new text%))
  (define instructions-canvas
    (new editor-canvas% [parent panel] [editor instructions] [stretchable-height #f] [min-height 120]))
  (send instructions lock #f)
  (define-values (code-canvas code-text) (make-code-editor panel))
  (define check-button
    (new button% [parent panel] [label "Проверить"]
         [callback (lambda (b e) (do-check!))]))
  (define results
    (new text%))
  (define results-canvas
    (new editor-canvas% [parent panel] [editor results] [stretchable-height #f] [min-height 100]))

  (define (selected-entry)
    (define sel (send picker get-selection))
    (and sel (list-ref LESSON-DIRS sel)))

  (define (load-selected!)
    (define entry (selected-entry))
    (when entry
      (send instructions erase)
      (send instructions insert (lesson-md-body (cdr entry)))
      (send code-text erase)))

  (define (show-results! lines)
    (send results erase)
    (send results insert (string-join lines "\n")))

  (define (do-check!)
    (define entry (selected-entry))
    (when entry
      (define module-id (car entry))
      (define lesson-dir (cdr entry))
      (define src (send code-text get-text))
      (define report (grade-lesson-submission lesson-dir src))
      (cond
        [(eq? (lesson-grade-report-status report) 'blocked)
         (show-results! (list (format "ЗАБЛОКИРОВАНО: запрещённые конструкции: ~a"
                                       (lesson-grade-report-blocked-symbols report))))]
        [else
         (define entries (lesson-grade-report-results report))
         (show-results! (map result->string entries))
         (when (andmap entry-result-passed? entries)
           (set-box! progress-box
                     (record-submission (mark-completed (unbox progress-box) module-id) module-id src))
           (save-progress (unbox progress-box) save-path)
           (on-changed))])))

  (send picker set-selection 0)
  (load-selected!)
  panel)

(module+ test
  (require rackunit)

  (test-case "LESSON-DIRS: every entry points at a directory with lesson.md and tests.rktd"
    (for ([e (in-list LESSON-DIRS)])
      (check-true (file-exists? (build-path (cdr e) "lesson.md")) (format "missing lesson.md for ~a" (car e)))
      (check-true (file-exists? (build-path (cdr e) "tests.rktd")) (format "missing tests.rktd for ~a" (car e)))))

  (test-case "LESSON-DIRS: has exactly the 13 lesson module ids, no workspace ids"
    (check-equal? (length LESSON-DIRS) 13)
    (check-false (assq 'interpreter-eval-workspace LESSON-DIRS))
    (check-false (assq 'multitasking-ledger-workspace LESSON-DIRS)))

  (test-case "lesson-md-body strips front matter"
    (define body (lesson-md-body (cdr (assq 's-expr-basics LESSON-DIRS))))
    (check-false (regexp-match? #px"^---" body))
    (check-true (regexp-match? #px"Log Entry" body)))

  (test-case "end-to-end: a correct submission through the editor marks the module completed and persists"
    (define tmp-save (make-temporary-file "editor-test~a"))
    (delete-file tmp-save)
    (dynamic-wind
     void
     (lambda ()
       (define pbox (box (fresh-progress)))
       (define changed? (box #f))
       (define frame (new frame% [label "test"] [width 400] [height 400]))
       (define panel (make-editor-panel frame pbox tmp-save (lambda () (set-box! changed? #t))))
       (define picker (findf (lambda (c) (is-a? c list-box%)) (send panel get-children)))
       ;; select binding (index 1) and submit a correct solution
       (send picker set-selection 1)
       (send picker command (new control-event% [event-type 'list-box]))
       (define code-canvas (findf (lambda (c) (is-a? c editor-canvas%)) (list-tail (send panel get-children) 2)))
       (define code-text (send code-canvas get-editor))
       (send code-text erase)
       (send code-text insert "(define (convert-to-cochranes w) (let ((c (* w 100))) c))")
       (define btn (findf (lambda (c) (is-a? c button%)) (send panel get-children)))
       (send btn command (new control-event% [event-type 'button]))
       (check-true (unbox changed?))
       (check-true (and (member 'binding (progress-state-completed-modules (unbox pbox))) #t))
       (check-equal? (load-progress tmp-save) (unbox pbox)))
     (lambda () (when (file-exists? tmp-save) (delete-file tmp-save)))))

  (test-case "end-to-end: an incorrect submission does not mark completed or persist"
    (define tmp-save (make-temporary-file "editor-test~a"))
    (delete-file tmp-save)
    (dynamic-wind
     void
     (lambda ()
       (define pbox (box (fresh-progress)))
       (define changed? (box #f))
       (define frame (new frame% [label "test"] [width 400] [height 400]))
       (define panel (make-editor-panel frame pbox tmp-save (lambda () (set-box! changed? #t))))
       (define picker (findf (lambda (c) (is-a? c list-box%)) (send panel get-children)))
       (send picker set-selection 1)
       (send picker command (new control-event% [event-type 'list-box]))
       (define code-canvas (findf (lambda (c) (is-a? c editor-canvas%)) (list-tail (send panel get-children) 2)))
       (define code-text (send code-canvas get-editor))
       (send code-text erase)
       (send code-text insert "(define (convert-to-cochranes w) 0)") ;; wrong
       (define btn (findf (lambda (c) (is-a? c button%)) (send panel get-children)))
       (send btn command (new control-event% [event-type 'button]))
       (check-false (unbox changed?))
       (check-false (file-exists? tmp-save)))
     (lambda () (when (file-exists? tmp-save) (delete-file tmp-save))))))

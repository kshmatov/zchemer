#lang racket/gui

;; Editor panel (gui-lcars: Inline Code Editor for Simple Examples).
;; Lesson picker + read-only instructional text + code editor + check
;; button + results area. Wires engine/lesson-grader.rkt and
;; engine/progress.rkt together for the first time.

(require racket/runtime-path
         framework
         "../engine/lesson-grader.rkt"
         "../engine/progress.rkt"
         "../engine/achievements.rkt"
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
  (define panel (new horizontal-panel% [parent parent]))
  (define left-column
    (new vertical-panel% [parent panel] [min-width 220] [stretchable-width #f]))
  (define right-column
    (new vertical-panel% [parent panel]))

  (define picker-label
    (new message% [parent left-column] [label "Урок:"] [color ACCENT-AMBER]))
  (define picker
    (new list-box%
         [parent left-column]
         [label #f]
         [choices (map (lambda (e) (symbol->string (car e))) LESSON-DIRS)]
         [style '(single)]
         [callback (lambda (l e) (load-selected!))]))

  ;; A draggable sash between the instructions and the code editor, so the
  ;; player can resize each block by hand (defaults to 30/70).
  (define editor-split (new panel:vertical-dragable% [parent right-column]))

  (define instructions
    (new text%))
  (send instructions auto-wrap #t)
  (define instructions-canvas
    (new editor-canvas% [parent editor-split] [editor instructions]
         [style '(no-hscroll)]))
  (send instructions lock #f)
  (define-values (code-canvas code-text) (make-code-editor editor-split #:min-height 100))
  (send editor-split set-percentages '(3/10 7/10))
  (define button-row (new horizontal-panel% [parent right-column] [stretchable-height #f]))
  (define check-button
    (new button% [parent button-row] [label "Проверить"]
         [callback (lambda (b e) (do-check!))]))
  (define clear-button
    (new button% [parent button-row] [label "Очистить"]
         [callback (lambda (b e) (send code-text erase))]))
  (define results
    (new text%))
  (send results auto-wrap #t)
  (define results-canvas
    (new editor-canvas% [parent right-column] [editor results] [stretchable-height #f] [min-height 120]
         [style '(no-hscroll)]))

  (define (selected-entry)
    (define sel (send picker get-selection))
    (and sel (list-ref LESSON-DIRS sel)))

  ;; retained-submission : symbol? -> (or/c string? #f)
  ;; The player's retained last-successful-submission for module-id, if
  ;; it is already completed and has one - the Review Mode Editor preload
  ;; source (gui-lcars).
  (define (retained-submission module-id)
    (define state (unbox progress-box))
    (and (member module-id (progress-state-completed-modules state))
         (let ([entry (assq module-id (progress-state-last-submissions state))])
           (and entry (cdr entry)))))

  (define (load-selected!)
    (define entry (selected-entry))
    (when entry
      (send instructions erase)
      (send instructions insert (lesson-md-body (cdr entry)))
      (send code-text erase)
      (define retained (retained-submission (car entry)))
      (when retained (send code-text insert retained))))

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
         (cond
           [(andmap entry-result-passed? entries)
            (set-box! progress-box
                      (record-submission (mark-completed (unbox progress-box) module-id) module-id src))
            ;; Retroactive Achievement Recognition During Review (game-progression):
            ;; checked on every pass, first-time or review, regardless of prior
            ;; completion status; grant-achievement is itself idempotent.
            (define already-earned (progress-state-earned-achievements (unbox progress-box)))
            (define earned (check-achievements module-id src))
            (define newly-earned (filter (lambda (a) (not (member (car a) already-earned))) earned))
            (for ([a (in-list earned)]) (set-box! progress-box (grant-achievement (unbox progress-box) (car a))))
            (save-progress (unbox progress-box) save-path)
            (on-changed)
            (show-results! (append (map result->string entries)
                                    (map (lambda (a) (format "Достижение получено: ~a" (cdr a))) newly-earned)))]
           [else (show-results! (map result->string entries))])])))

  (send picker set-selection 0)
  (load-selected!)
  panel)

(module+ test
  (require rackunit)

  ;; find-widget : (is-a?/c area-container<%>) (any/c -> boolean?) -> any/c
  ;; Recursively searches a panel's children (and their children) for the
  ;; first widget matching pred - robust against this panel's internal
  ;; child layout (e.g. buttons nested inside a button-row sub-panel).
  (define (find-widget container pred)
    (or (findf pred (send container get-children))
        (for/or ([c (in-list (send container get-children))])
          (and (is-a? c area-container<%>) (find-widget c pred)))))

  (define (find-button panel label)
    (find-widget panel (lambda (c) (and (is-a? c button%) (equal? (send c get-label) label)))))

  (define (find-code-text panel)
    ;; the code editor's editor-canvas% is the second editor-canvas% found
    ;; in proper depth-first document order (the first is the read-only
    ;; instructions canvas) - each child is either collected directly or
    ;; recursed into, never both/out-of-order, so nesting (e.g. the
    ;; instructions+editor draggable split) doesn't reshuffle the result.
    (define (collect-canvases container)
      (append-map
       (lambda (c)
         (cond
           [(is-a? c editor-canvas%) (list c)]
           [(is-a? c area-container<%>) (collect-canvases c)]
           [else '()]))
       (send container get-children)))
    (send (cadr (collect-canvases panel)) get-editor))

  (define (select-lesson! panel index)
    (define picker (find-widget panel (lambda (c) (is-a? c list-box%))))
    (send picker set-selection index)
    (send picker command (new control-event% [event-type 'list-box])))

  (test-case "instructions and code editor sit in a resizable (draggable-sash) split, adjustable by the player"
    (define pbox (box (fresh-progress)))
    (define frame (new frame% [label "test"] [width 400] [height 400]))
    (define panel (make-editor-panel frame pbox "/tmp/no-such-editor-split-test.rktd" void))
    (define split (find-widget panel (lambda (c) (is-a? c panel:vertical-dragable%))))
    (check-not-false split)
    (check-equal? (send split get-percentages) '(3/10 7/10))
    (send split set-percentages '(1/2 1/2))
    (check-equal? (send split get-percentages) '(1/2 1/2)))

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
       (select-lesson! panel 1) ;; binding
       (define code-text (find-code-text panel))
       (send code-text erase)
       (send code-text insert "(define (convert-to-cochranes w) (let ((c (* w 100))) c))")
       (send (find-button panel "Проверить") command (new control-event% [event-type 'button]))
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
       (select-lesson! panel 1) ;; binding
       (define code-text (find-code-text panel))
       (send code-text erase)
       (send code-text insert "(define (convert-to-cochranes w) 0)") ;; wrong
       (send (find-button panel "Проверить") command (new control-event% [event-type 'button]))
       (check-false (unbox changed?))
       (check-false (file-exists? tmp-save)))
     (lambda () (when (file-exists? tmp-save) (delete-file tmp-save)))))

  (test-case "review mode: selecting an already-completed lesson preloads its retained submission"
    (define tmp-save (make-temporary-file "editor-test~a"))
    (delete-file tmp-save)
    (dynamic-wind
     void
     (lambda ()
       (define retained-src "(define (convert-to-cochranes w) (let ((c (* w 100))) c))")
       (define pbox (box (record-submission (mark-completed (fresh-progress) 'binding) 'binding retained-src)))
       (define frame (new frame% [label "test"] [width 400] [height 400]))
       (define panel (make-editor-panel frame pbox tmp-save void))
       (select-lesson! panel 1) ;; binding
       (define code-text (find-code-text panel))
       (check-equal? (send code-text get-text) retained-src))
     (lambda () (when (file-exists? tmp-save) (delete-file tmp-save)))))

  (test-case "review mode: selecting a not-yet-completed lesson still starts blank"
    (define tmp-save (make-temporary-file "editor-test~a"))
    (delete-file tmp-save)
    (dynamic-wind
     void
     (lambda ()
       (define pbox (box (fresh-progress)))
       (define frame (new frame% [label "test"] [width 400] [height 400]))
       (define panel (make-editor-panel frame pbox tmp-save void))
       (select-lesson! panel 1) ;; binding, not completed
       (define code-text (find-code-text panel))
       (check-equal? (send code-text get-text) ""))
     (lambda () (when (file-exists? tmp-save) (delete-file tmp-save)))))

  (test-case "Очистить empties a preloaded code editor"
    (define tmp-save (make-temporary-file "editor-test~a"))
    (delete-file tmp-save)
    (dynamic-wind
     void
     (lambda ()
       (define retained-src "(define (convert-to-cochranes w) (let ((c (* w 100))) c))")
       (define pbox (box (record-submission (mark-completed (fresh-progress) 'binding) 'binding retained-src)))
       (define frame (new frame% [label "test"] [width 400] [height 400]))
       (define panel (make-editor-panel frame pbox tmp-save void))
       (select-lesson! panel 1) ;; binding, preloaded
       (define code-text (find-code-text panel))
       (check-equal? (send code-text get-text) retained-src)
       (send (find-button panel "Очистить") command (new control-event% [event-type 'button]))
       (check-equal? (send code-text get-text) ""))
     (lambda () (when (file-exists? tmp-save) (delete-file tmp-save)))))

  (test-case "review mode: re-passing a completed lesson replaces its retained submission"
    (define tmp-save (make-temporary-file "editor-test~a"))
    (delete-file tmp-save)
    (dynamic-wind
     void
     (lambda ()
       (define old-src "(define (convert-to-cochranes w) (let ((c (* w 100))) c))")
       (define new-src "(define (convert-to-cochranes w) (* w 100))")
       (define pbox (box (record-submission (mark-completed (fresh-progress) 'binding) 'binding old-src)))
       (define frame (new frame% [label "test"] [width 400] [height 400]))
       (define panel (make-editor-panel frame pbox tmp-save void))
       (select-lesson! panel 1) ;; binding, preloaded with old-src
       (define code-text (find-code-text panel))
       (send (find-button panel "Очистить") command (new control-event% [event-type 'button]))
       (send code-text insert new-src)
       (send (find-button panel "Проверить") command (new control-event% [event-type 'button]))
       (check-equal? (cdr (assq 'binding (progress-state-last-submissions (unbox pbox)))) new-src)
       ;; still exactly one completion of binding, not duplicated
       (check-equal? (length (filter (lambda (m) (eq? m 'binding)) (progress-state-completed-modules (unbox pbox)))) 1))
     (lambda () (when (file-exists? tmp-save) (delete-file tmp-save)))))

  (test-case "a correct submission satisfying an achievement condition earns and persists it"
    (define tmp-save (make-temporary-file "editor-test~a"))
    (delete-file tmp-save)
    (dynamic-wind
     void
     (lambda ()
       (define pbox (box (fresh-progress)))
       (define frame (new frame% [label "test"] [width 400] [height 400]))
       (define panel (make-editor-panel frame pbox tmp-save void))
       (select-lesson! panel 1) ;; binding
       (define code-text (find-code-text panel))
       (send code-text erase)
       (send code-text insert "(define (convert-to-cochranes w) (* w 100))") ;; no let - earns no-let-needed
       (send (find-button panel "Проверить") command (new control-event% [event-type 'button]))
       (check-true (and (member 'no-let-needed (progress-state-earned-achievements (unbox pbox))) #t))
       (check-equal? (progress-state-earned-achievements (load-progress tmp-save)) '(no-let-needed)))
     (lambda () (when (file-exists? tmp-save) (delete-file tmp-save)))))

  (test-case "Retroactive Achievement Recognition: a review pass can earn an achievement the first pass didn't"
    (define tmp-save (make-temporary-file "editor-test~a"))
    (delete-file tmp-save)
    (dynamic-wind
     void
     (lambda ()
       (define pbox (box (fresh-progress)))
       (define frame (new frame% [label "test"] [width 400] [height 400]))
       (define panel (make-editor-panel frame pbox tmp-save void))
       (select-lesson! panel 1) ;; binding
       (define code-text (find-code-text panel))
       ;; first pass: uses let, no achievement
       (send code-text insert "(define (convert-to-cochranes w) (let ((c (* w 100))) c))")
       (send (find-button panel "Проверить") command (new control-event% [event-type 'button]))
       (check-true (and (member 'binding (progress-state-completed-modules (unbox pbox))) #t))
       (check-equal? (progress-state-earned-achievements (unbox pbox)) '())
       ;; review pass: no let this time - earns the achievement despite module already completed
       (send code-text erase)
       (send code-text insert "(define (convert-to-cochranes w) (* w 100))")
       (send (find-button panel "Проверить") command (new control-event% [event-type 'button]))
       (check-true (and (member 'no-let-needed (progress-state-earned-achievements (unbox pbox))) #t))
       ;; still exactly one completion, not duplicated (Idempotent Review Grading)
       (check-equal? (length (filter (lambda (m) (eq? m 'binding)) (progress-state-completed-modules (unbox pbox)))) 1))
     (lambda () (when (file-exists? tmp-save) (delete-file tmp-save)))))

  (test-case "an incorrect submission never earns an achievement even if its source would satisfy the condition"
    (define tmp-save (make-temporary-file "editor-test~a"))
    (delete-file tmp-save)
    (dynamic-wind
     void
     (lambda ()
       (define pbox (box (fresh-progress)))
       (define frame (new frame% [label "test"] [width 400] [height 400]))
       (define panel (make-editor-panel frame pbox tmp-save void))
       (select-lesson! panel 1) ;; binding
       (define code-text (find-code-text panel))
       ;; no let, but wrong result - fails grading
       (send code-text insert "(define (convert-to-cochranes w) 0)")
       (send (find-button panel "Проверить") command (new control-event% [event-type 'button]))
       (check-equal? (progress-state-earned-achievements (unbox pbox)) '()))
     (lambda () (when (file-exists? tmp-save) (delete-file tmp-save))))))

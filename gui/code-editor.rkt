#lang racket/gui

;; Inline syntax-highlighting code editor (gui-lcars: Inline Code Editor
;; for Simple Examples), built directly on text%/editor-canvas% per
;; AGENTS.md.

(require "lcars-style.rkt")

(provide keyword-positions
         KEYWORDS
         lcars-code-text%
         make-code-editor)

(define KEYWORDS
  '("define" "lambda" "if" "cond" "else" "let" "let*" "letrec"
    "quote" "quasiquote" "unquote" "set!" "begin" "and" "or" "case"
    "when" "unless"))

;; keyword-positions : string? -> (listof (cons exact-nonnegative-integer? exact-nonnegative-integer?))
;; Pure: the (start . end) span of every whole-word keyword occurrence in
;; `text`, in order. Uses a lookahead for the trailing boundary and a
;; captured leading-boundary character class (via #:match-select cadr) to
;; avoid needing lookbehind, which Racket's pregexp doesn't support.
(define (keyword-positions text)
  (define all
    (for*/list ([kw (in-list KEYWORDS)]
                [pos (in-list
                      (regexp-match-positions*
                       (pregexp (string-append "(?:^|[ \t\n()])(" (regexp-quote kw) ")(?=[ \t\n()]|$)"))
                       text
                       #:match-select cadr))])
      pos))
  (sort all < #:key car))

;; keyword-style-delta : a style-delta% coloring text amber.
(define keyword-style-delta
  (let ([d (make-object style-delta% 'change-normal)])
    (send d set-delta-foreground ACCENT-AMBER)
    d))

(define default-style-delta
  (let ([d (make-object style-delta% 'change-normal)])
    (send d set-delta-foreground TEXT-COLOR)
    d))

;; lcars-code-text% : a text% that re-highlights its whole buffer after
;; every edit. Correct and simple at lesson-sized buffers (a few lines);
;; see design.md for why a full DrRacket-style colorer wasn't used.
(define lcars-code-text%
  (class text%
    (super-new)
    (define/public (highlight!)
      (define content (send this get-text))
      (send this change-style default-style-delta 0 (send this last-position) #f)
      (for ([span (in-list (keyword-positions content))])
        (send this change-style keyword-style-delta (car span) (cdr span) #f)))
    (define/augment (after-insert start len)
      (inner (void) after-insert start len)
      (highlight!))
    (define/augment (after-delete start len)
      (inner (void) after-delete start len)
      (highlight!))))

;; make-code-editor : (is-a?/c area-container<%>) -> (values (is-a?/c editor-canvas%) (is-a?/c lcars-code-text%))
(define (make-code-editor parent #:min-height [min-height 180])
  (define t (new lcars-code-text%))
  (define canvas (new editor-canvas% [parent parent] [editor t] [min-height min-height]))
  ;; The style deltas below paint text foreground (TEXT-COLOR/ACCENT-AMBER,
  ;; both light colors); without also darkening the canvas's own
  ;; background, that text renders against the system's default (usually
  ;; white) background and becomes unreadable.
  (send canvas set-canvas-background PANEL-COLOR)
  (values canvas t))

(module+ test
  (require rackunit)

  (test-case "keyword-positions: matches a whole-word keyword"
    (check-equal? (keyword-positions "(define (f x) (+ x 1))") '((1 . 7))))

  (test-case "keyword-positions: does not match a keyword as a substring of another identifier"
    (check-equal? (keyword-positions "(defined-thing 1)") '()))

  (test-case "keyword-positions: finds multiple distinct keywords, in order"
    (define spans (keyword-positions "(define (f x) (if (< x 0) 'neg 'pos))"))
    (define text "(define (f x) (if (< x 0) 'neg 'pos))")
    (check-equal? (map (lambda (s) (substring text (car s) (cdr s))) spans)
                  '("define" "if")))

  (test-case "keyword-positions: keyword at the very start and very end of the buffer"
    (check-equal? (keyword-positions "begin") '((0 . 5))))

  (test-case "regression: the canvas background is darkened to match the white/amber text styles"
    ;; Without this, text painted via style deltas (white/amber
    ;; foreground) renders against the system's default (usually white)
    ;; background and becomes unreadable.
    (define-values (canvas text) (make-code-editor (new frame% [label "test"])))
    (define bg (send canvas get-canvas-background))
    (check-equal? (list (send bg red) (send bg green) (send bg blue))
                  (list (send PANEL-COLOR red) (send PANEL-COLOR green) (send PANEL-COLOR blue)))))

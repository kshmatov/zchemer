#lang racket/gui

;; Shared LCARS-inspired color palette (gui-lcars: Consistent LCARS
;; Visual Styling). Every panel imports this module for its colors so a
;; future palette change touches one file.

(provide BG-COLOR
         PANEL-COLOR
         ACCENT-AMBER
         ACCENT-LAVENDER
         TEXT-COLOR
         STATUS-LOCKED-COLOR
         STATUS-AVAILABLE-COLOR
         STATUS-COMPLETED-COLOR
         LCARS-FONT
         status->color
         status->label)

(define BG-COLOR (make-object color% 0 0 0))
(define PANEL-COLOR (make-object color% 20 20 30))
(define ACCENT-AMBER (make-object color% 255 153 0))
(define ACCENT-LAVENDER (make-object color% 204 153 255))
(define TEXT-COLOR (make-object color% 255 255 255))

(define STATUS-LOCKED-COLOR (make-object color% 90 90 90))
(define STATUS-AVAILABLE-COLOR ACCENT-AMBER)
(define STATUS-COMPLETED-COLOR (make-object color% 0 200 120))

(define LCARS-FONT (make-object font% 11 'swiss 'normal 'bold))

;; status->color : (or/c 'locked 'available 'completed) -> (is-a?/c color%)
(define (status->color status)
  (case status
    [(locked) STATUS-LOCKED-COLOR]
    [(available) STATUS-AVAILABLE-COLOR]
    [(completed) STATUS-COMPLETED-COLOR]
    [else (error 'status->color "unknown status: ~a" status)]))

;; status->label : (or/c 'locked 'available 'completed) -> string?
(define (status->label status)
  (case status
    [(locked) "ЗАБЛОКИРОВАНО"]
    [(available) "ДОСТУПНО"]
    [(completed) "ПРОЙДЕНО"]
    [else (error 'status->label "unknown status: ~a" status)]))

(module+ test
  (require rackunit)

  (test-case "status->color covers every status curriculum.rkt can return"
    (check-equal? (status->color 'locked) STATUS-LOCKED-COLOR)
    (check-equal? (status->color 'available) STATUS-AVAILABLE-COLOR)
    (check-equal? (status->color 'completed) STATUS-COMPLETED-COLOR))

  (test-case "status->label covers every status curriculum.rkt can return"
    (check-equal? (status->label 'locked) "ЗАБЛОКИРОВАНО")
    (check-equal? (status->label 'available) "ДОСТУПНО")
    (check-equal? (status->label 'completed) "ПРОЙДЕНО")))

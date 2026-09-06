#lang racket/gui

;; Runnable entry point. Usage: racket gui/main.rkt [save-path]

(require "../engine/progress.rkt"
         "app.rkt")

(define save-path
  (if (> (vector-length (current-command-line-arguments)) 0)
      (vector-ref (current-command-line-arguments) 0)
      "progress.rktd"))

(define state (load-progress save-path))
(define frame (make-app-frame state save-path))
(send frame show #t)

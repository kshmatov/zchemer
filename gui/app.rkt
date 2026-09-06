#lang racket/gui

;; Native application shell (gui-lcars: Native Desktop Application). A
;; frame with a four-tab tab-panel%: Journal (primary), Skill Tree
;; (secondary), the inline code editor, and the project view.

(require "../engine/progress.rkt"
         "journal-panel.rkt"
         "skill-tree-panel.rkt"
         "editor-panel.rkt"
         "project-panel.rkt")

(provide make-app-frame)

(define TAB-LABELS '("Бортовой журнал" "Древо навыков" "Редактор" "Проект"))

;; make-app-frame : progress-state? path-string? -> (is-a?/c frame%)
(define (make-app-frame state save-path)
  (define frame (new frame% [label "zchemer"] [width 640] [height 480]))
  (define progress-box (box state))
  (define tabs
    (new tab-panel%
         [parent frame]
         [choices TAB-LABELS]
         [callback
          (lambda (t e)
            (define sel (send t get-selection))
            (for ([child (send t get-children)] [i (in-naturals)])
              (send child show (= i sel))))]))
  (define journal (make-journal-panel tabs (progress-state-completed-modules state)
                                       (progress-state-earned-achievements state)))
  (define skill-tree (make-skill-tree-panel tabs (progress-state-completed-modules state)))
  (define (refresh-other-tabs!)
    (define current (unbox progress-box))
    (refresh-journal-panel! journal (progress-state-completed-modules current)
                            (progress-state-earned-achievements current))
    (refresh-skill-tree-panel! skill-tree (progress-state-completed-modules current)))
  (define editor (make-editor-panel tabs progress-box save-path refresh-other-tabs!))
  (define project (make-project-panel tabs progress-box save-path refresh-other-tabs!))
  (send skill-tree show #f)
  (send editor show #f)
  (send project show #f)
  frame)

(module+ test
  (require rackunit racket/file)

  (test-case "make-app-frame builds a tab-panel with exactly four tabs"
    (define tmp-save (make-temporary-file "app-test~a"))
    (delete-file tmp-save)
    (dynamic-wind
     void
     (lambda ()
       (define frame (make-app-frame (fresh-progress) tmp-save))
       (define tabs (findf (lambda (c) (is-a? c tab-panel%)) (send frame get-children)))
       (check-not-false tabs)
       (check-equal? (send tabs get-number) 4)
       (check-equal? (send tabs get-item-label 0) "Бортовой журнал")
       (check-equal? (send tabs get-item-label 1) "Древо навыков")
       (check-equal? (send tabs get-item-label 2) "Редактор")
       (check-equal? (send tabs get-item-label 3) "Проект"))
     (lambda () (when (file-exists? tmp-save) (delete-file tmp-save))))))

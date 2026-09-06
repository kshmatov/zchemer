#lang racket/base

;; Curriculum sequencing engine (curriculum: Base Course Scope, Free
;; Advanced Track Selection, Explicit Prerequisite Graph, Track
;; Availability Boundary, Completed Module Accessibility;
;; advanced-project-sandboxes: Unavailable Tracks Are Visible but
;; Disabled). Encodes the fixed module graph as data and answers "what is
;; this module's status given a completed-set" with no I/O of its own.

(require racket/list)

(provide module-status
         available-modules
         BASE-COURSE-NODES
         ENABLED-TRACKS
         PLANNED-TRACKS
         MODULE-TABLE)

;; The ten base-course nodes, in the order fixed by
;; define-base-course-skill-graph / base-course-content's design.md.
(define BASE-COURSE-NODES
  '(s-expr-basics binding conditionals first-class-fn
    recursion-basic mutable-state data-structures
    tail-recursion closures higher-order-fn))

;; MODULE-TABLE : (listof (cons symbol? (listof symbol?)))
;; Each entry is (module-id . direct-prereqs). 'base-course in a prereq
;; list is a virtual token meaning "every id in BASE-COURSE-NODES," not a
;; literal module id.
(define MODULE-TABLE
  `((s-expr-basics . ())
    (binding . (s-expr-basics))
    (conditionals . (binding))
    (first-class-fn . (conditionals))
    (recursion-basic . (first-class-fn))
    (mutable-state . (first-class-fn))
    (data-structures . (first-class-fn))
    (tail-recursion . (recursion-basic))
    (closures . (tail-recursion))
    (higher-order-fn . (closures))

    (symbolic-data . (base-course))
    (environment-model . (symbolic-data))
    (interpreter-eval-workspace . (environment-model))

    (concurrency-primitives . (base-course))
    (multitasking-ledger-workspace . (concurrency-primitives))))

(define ENABLED-TRACKS '(interpreter multitasking))
(define PLANNED-TRACKS '(network database oop))

;; prereq-satisfied? : symbol? (listof symbol?) -> boolean?
(define (prereq-satisfied? prereq-id completed-set)
  (if (eq? prereq-id 'base-course)
      (andmap (lambda (n) (member n completed-set)) BASE-COURSE-NODES)
      (and (member prereq-id completed-set) #t)))

;; module-status : symbol? (listof symbol?) -> (or/c 'completed 'available 'locked)
(define (module-status module-id completed-set)
  (cond
    [(member module-id completed-set) 'completed]
    [else
     (define entry (assq module-id MODULE-TABLE))
     (unless entry (error 'module-status "unknown module: ~a" module-id))
     (define prereqs (cdr entry))
     (if (andmap (lambda (p) (prereq-satisfied? p completed-set)) prereqs)
         'available
         'locked)]))

;; available-modules : (listof symbol?) -> (listof symbol?)
(define (available-modules completed-set)
  (for/list ([entry (in-list MODULE-TABLE)]
             #:when (eq? (module-status (car entry) completed-set) 'available))
    (car entry)))

(module+ test
  (require rackunit)

  (test-case "base-course edges: mutable-state/data-structures unlock right after first-class-fn"
    (define completed '(s-expr-basics binding conditionals first-class-fn))
    (check-eq? (module-status 'mutable-state completed) 'available)
    (check-eq? (module-status 'data-structures completed) 'available)
    ;; the tail-recursion branch isn't unlocked by first-class-fn alone
    (check-eq? (module-status 'tail-recursion completed) 'locked)
    (check-eq? (module-status 'closures completed) 'locked))

  (test-case "Base Course Scope: track intro locked until every base-course node is complete"
    (define nine-of-ten (remove 'higher-order-fn BASE-COURSE-NODES))
    (check-eq? (module-status 'symbolic-data nine-of-ten) 'locked)
    (check-eq? (module-status 'concurrency-primitives nine-of-ten) 'locked)
    (check-eq? (module-status 'symbolic-data BASE-COURSE-NODES) 'available)
    (check-eq? (module-status 'concurrency-primitives BASE-COURSE-NODES) 'available))

  (test-case "Free Advanced Track Selection: both tracks' first nodes available at once, independently"
    (define completed BASE-COURSE-NODES)
    (check-eq? (module-status 'symbolic-data completed) 'available)
    (check-eq? (module-status 'concurrency-primitives completed) 'available)
    ;; completing one track's intro doesn't affect the other's status
    (define after-symbolic-data (cons 'symbolic-data completed))
    (check-eq? (module-status 'concurrency-primitives after-symbolic-data) 'available)
    (check-eq? (module-status 'environment-model after-symbolic-data) 'available))

  (test-case "Completed Module Accessibility: a completed module always reports completed"
    ;; even an inconsistent completed-set (higher-order-fn done without its
    ;; own prerequisites) must still report 'completed for itself - status
    ;; is never revoked by unrelated missing prerequisites
    (check-eq? (module-status 'higher-order-fn '(higher-order-fn)) 'completed))

  (test-case "Track internal chain and workspace gating"
    (define base-done BASE-COURSE-NODES)
    (check-eq? (module-status 'environment-model base-done) 'locked)
    (check-eq? (module-status 'environment-model (cons 'symbolic-data base-done)) 'available)
    (check-eq? (module-status 'interpreter-eval-workspace (cons 'symbolic-data base-done)) 'locked)
    (define interpreter-intro-done (list* 'symbolic-data 'environment-model base-done))
    (check-eq? (module-status 'interpreter-eval-workspace interpreter-intro-done) 'available)

    (check-eq? (module-status 'multitasking-ledger-workspace base-done) 'locked)
    (define multitasking-intro-done (cons 'concurrency-primitives base-done))
    (check-eq? (module-status 'multitasking-ledger-workspace multitasking-intro-done) 'available))

  (test-case "Enabled vs. planned tracks"
    (check-equal? ENABLED-TRACKS '(interpreter multitasking))
    (check-equal? PLANNED-TRACKS '(network database oop))
    ;; planned tracks contribute no module-table entries
    (for ([t (in-list PLANNED-TRACKS)])
      (check-false (assq t MODULE-TABLE))))

  (test-case "available-modules reports exactly the currently unlockable set"
    (define completed '(s-expr-basics binding conditionals first-class-fn))
    (check-equal? (sort (available-modules completed) symbol<?)
                  (sort '(recursion-basic mutable-state data-structures) symbol<?))))

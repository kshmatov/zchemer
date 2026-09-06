;; Reference-program suite for the Interpreter track's main workspace.
;;
;; Format: a list of (name forms expected) entries.
;; - `forms` is a list of pre-parsed top-level Scheme forms, supplied to the
;;   player's submitted `(run-program forms)` exactly as read here (per
;;   advanced-project-sandboxes' "Reference programs are provided pre-parsed"
;;   scenario) - the player's evaluator never parses raw source text.
;; - `expected` is either a string (the exact stdout a correct evaluator must
;;   produce) or the symbol `raises-error` (a correct evaluator must signal
;;   the problem via a host `error` call rather than printing a plausible-
;;   looking but wrong result or crashing some other way - see this change's
;;   design.md).
((definitions-and-application
   ((define (square x) (* x x))
    (display (square 5)))
   "25")

 (lambda-as-value
  ((define add1 (lambda (x) (+ x 1)))
   (display (add1 41)))
  "42")

 (conditionals-if
  ((define (abs-val x) (if (< x 0) (- 0 x) x))
   (display (abs-val -7))
   (display " ")
   (display (abs-val 7)))
  "7 7")

 (procedure-as-argument
  ((define (apply-twice f x) (f (f x)))
   (define (inc x) (+ x 1))
   (display (apply-twice inc 10)))
  "12")

 (quotation
  ((display (quote (a b c))))
  "(a b c)")

 (recursive-definition
  ((define (fact n) (if (= n 0) 1 (* n (fact (- n 1)))))
   (display (fact 5)))
  "120")

 (error-unbound-variable
  ((display totally-unbound-name))
  raises-error)

 (error-arity-mismatch
  ((define (add2 a b) (+ a b))
   (display (add2 1 2 3)))
  raises-error)

 (error-non-procedure-application
  ((define x 5)
   (display (x 1 2)))
  raises-error))

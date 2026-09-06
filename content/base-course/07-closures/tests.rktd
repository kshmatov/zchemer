;; Формат: (call <expression> expected)
((call ((compose car cdr) (quote (1 2 3))) 2)
 (call ((compose (lambda (x) (* x x)) (lambda (x) (+ x 1))) 3) 16))

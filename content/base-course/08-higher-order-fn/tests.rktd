;; Формат: (call <expression> expected)
((call (sum-of-squares (quote (1 2 3))) 14)
 (call (sum-of-squares (quote ())) 0)
 (call (evens-only (quote (1 2 3 4 5 6))) (2 4 6)))

;; Формат: (call <expression> expected)
((call (list-length (quote (a b c))) 3)
 (call (list-length (quote ())) 0)
 (call (list-length (quote (1 2 3 4 5))) 5))

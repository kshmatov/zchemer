;; Формат: (call <expression> expected)
((call (let ((c (make-counter))) (c)) 1)
 (call (let ((c (make-counter))) (c) (c) (c)) 3)
 (call (let ((c1 (make-counter)) (c2 (make-counter))) (c1) (c1) (c2)) 1))

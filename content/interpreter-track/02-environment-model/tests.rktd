;; Формат: (call <expression> expected)
((call (lookup-var (make-frame (quote ((x . 10))) (make-frame (quote ((x . 1) (y . 2))) #f)) (quote x)) 10)
 (call (lookup-var (make-frame (quote ((x . 10))) (make-frame (quote ((x . 1) (y . 2))) #f)) (quote y)) 2)
 (call (lookup-var (make-frame (quote ((x . 1) (y . 2))) #f) (quote x)) 1))

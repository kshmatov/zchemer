;; Формат: (call <expression> expected)
;; <expression> может быть произвольным вложенным применением, не только
;; (fn-name arg ...) — например, вызовом процедуры, возвращённой другой процедурой.
((call ((make-multiplier 3) 4) 12)
 (call ((make-multiplier 0) 9) 0)
 (call (apply-twice (make-multiplier 2) 5) 20))

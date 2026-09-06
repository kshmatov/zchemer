;; Формат: (call <expression> expected)
;; Все ожидаемые значения детерминированы (см. design.md этого change'а):
;; при корректной синхронизации итог не зависит от порядка чередования потоков.
((call (synchronized-sum 1) 2)
 (call (synchronized-sum 100) 200)
 (call (synchronized-sum 2000) 4000)
 (call (ping-pong 5) 15)
 (call (ping-pong 100) 5050))

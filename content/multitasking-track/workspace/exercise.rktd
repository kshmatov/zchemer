;; Multitasking track main workspace exercise.
;;
;; The player defines `(run-ledger num-workers ops-per-worker)`: spawn
;; `num-workers` threads, each incrementing a shared balance
;; `ops-per-worker` times, guarded by a semaphore so increments never race;
;; each worker signals completion over a shared channel; the main thread
;; waits for every completion signal, then `display`s the final balance
;; (no trailing newline needed - grading compares the exact printed string).
;;
;; Invariant: the printed balance always equals
;; (* num-workers ops-per-worker), regardless of thread interleaving.
;;
;; num-workers/ops-per-worker are tuned (see this change's design.md) so an
;; unsynchronized submission's race is reliably observable within run-count
;; repeated grading runs, while a correct submission never misreports.
((num-workers . 4)
 (ops-per-worker . 5000)
 (run-count . 10))

;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s --rse -all -S -o - | filecheck %s

(module
  ;; CHECK:      (tag $e (param i32))
  (tag $e (param i32))
  ;; CHECK:      (tag $e2 (param))
  (tag $e2)

  ;; CHECK:      (func $try1
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (try $try
  ;; CHECK-NEXT:   (do
  ;; CHECK-NEXT:    (nop)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (catch_all
  ;; CHECK-NEXT:    (local.set $x
  ;; CHECK-NEXT:     (i32.const 1)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (local.set $x
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $try1
    (local $x i32)
    (try
      (do)
      (catch_all
        (local.set $x (i32.const 1))
      )
    )
    ;; try will not throw. So this should NOT be dropped
    (local.set $x (i32.const 1))
  )

  ;; CHECK:      (func $try2
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (try $try
  ;; CHECK-NEXT:   (do
  ;; CHECK-NEXT:    (throw $e
  ;; CHECK-NEXT:     (i32.const 0)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (local.set $x
  ;; CHECK-NEXT:     (i32.const 1)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (catch_all
  ;; CHECK-NEXT:    (nop)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (local.set $x
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $try2
    (local $x i32)
    (try
      (do
        (throw $e (i32.const 0))
        (local.set $x (i32.const 1))
      )
      (catch_all)
    )
    ;; local.set is after 'throw' so it will not run. This should NOT be
    ;; dropped.
    (local.set $x (i32.const 1))
  )

  ;; CHECK:      (func $try3
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (try $try
  ;; CHECK-NEXT:   (do
  ;; CHECK-NEXT:    (throw $e
  ;; CHECK-NEXT:     (i32.const 0)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (catch_all
  ;; CHECK-NEXT:    (local.set $x
  ;; CHECK-NEXT:     (i32.const 1)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $try3
    (local $x i32)
    (try
      (do
        (throw $e (i32.const 0))
      )
      (catch_all
        (local.set $x (i32.const 1))
      )
    )
    ;; try body will throw and catch_all contains the same local.set. This
    ;; should be dropped.
    (local.set $x (i32.const 1))
  )

  ;; CHECK:      (func $foo
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $foo)

  ;; CHECK:      (func $try4
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (try $try
  ;; CHECK-NEXT:   (do
  ;; CHECK-NEXT:    (call $foo)
  ;; CHECK-NEXT:    (local.set $x
  ;; CHECK-NEXT:     (i32.const 1)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (catch_all
  ;; CHECK-NEXT:    (nop)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (local.set $x
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $try4
    (local $x i32)
    (try
      (do
        (call $foo)
        (local.set $x (i32.const 1))
      )
      (catch_all)
    )
    ;; (call $foo) may throw and the local.set may not run, so this should NOT
    ;; be dropped
    (local.set $x (i32.const 1))
  )

  ;; CHECK:      (func $try5
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (try $try
  ;; CHECK-NEXT:   (do
  ;; CHECK-NEXT:    (local.set $x
  ;; CHECK-NEXT:     (i32.const 1)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (call $foo)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (catch_all
  ;; CHECK-NEXT:    (nop)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $try5
    (local $x i32)
    (try
      (do
        (local.set $x (i32.const 1))
        (call $foo)
      )
      (catch_all)
    )
    ;; Even if (call $foo) throws, local.set runs before it, so this should be
    ;; dropped
    (local.set $x (i32.const 1))
  )

  ;; CHECK:      (func $nested-try1
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (try $try
  ;; CHECK-NEXT:   (do
  ;; CHECK-NEXT:    (try $l0
  ;; CHECK-NEXT:     (do
  ;; CHECK-NEXT:      (throw $e
  ;; CHECK-NEXT:       (i32.const 0)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:     (catch_all
  ;; CHECK-NEXT:      (rethrow $l0)
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (catch_all
  ;; CHECK-NEXT:    (local.set $x
  ;; CHECK-NEXT:     (i32.const 1)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $nested-try1
    (local $x i32)
    (try
      (do
        (try $l0
          (do
            (throw $e (i32.const 0))
          )
          (catch_all
            (rethrow $l0)
          )
        )
      )
      (catch_all
        (local.set $x (i32.const 1))
      )
    )
    ;; The exception is caught by the inner catch_all and rethrown and again
    ;; caught by the outer catch_all, which runs the local.set. So this should
    ;; be dropped.
    (local.set $x (i32.const 1))
  )

  ;; CHECK:      (func $nested-try2
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (try $try
  ;; CHECK-NEXT:   (do
  ;; CHECK-NEXT:    (try $l0
  ;; CHECK-NEXT:     (do
  ;; CHECK-NEXT:      (throw $e
  ;; CHECK-NEXT:       (i32.const 0)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:     (catch_all
  ;; CHECK-NEXT:      (local.set $x
  ;; CHECK-NEXT:       (i32.const 1)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:      (rethrow $l0)
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (catch_all
  ;; CHECK-NEXT:    (nop)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $nested-try2
    (local $x i32)
    (try
      (do
        (try $l0
          (do
            (throw $e (i32.const 0))
          )
          (catch_all
            (local.set $x (i32.const 1))
            (rethrow $l0)
          )
        )
      )
      (catch_all)
    )
    ;; The exception is caught by the inner catch_all, which runs the local.set,
    ;; so this should be dropped
    (local.set $x (i32.const 1))
  )

  ;; CHECK:      (func $nested-try3
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (try $try
  ;; CHECK-NEXT:   (do
  ;; CHECK-NEXT:    (try $l0
  ;; CHECK-NEXT:     (do
  ;; CHECK-NEXT:      (throw $e
  ;; CHECK-NEXT:       (i32.const 0)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:     (catch $e
  ;; CHECK-NEXT:      (drop
  ;; CHECK-NEXT:       (pop i32)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:      (local.set $x
  ;; CHECK-NEXT:       (i32.const 1)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:      (rethrow $l0)
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (catch_all
  ;; CHECK-NEXT:    (nop)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (local.set $x
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $nested-try3
    (local $x i32)
    (try
      (do
        (try $l0
          (do
            (throw $e (i32.const 0))
          )
          (catch $e
            (drop (pop i32))
            (local.set $x (i32.const 1))
            (rethrow $l0)
          )
        )
      )
      (catch_all)
    )
    ;; Unlike nested-try2, the exception may not be caught by the inner catch,
    ;; so the local.set may not run. So this should NOT be dropped.
    (local.set $x (i32.const 1))
  )

  ;; CHECK:      (func $nested-catch1
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (try $try
  ;; CHECK-NEXT:   (do
  ;; CHECK-NEXT:    (throw $e
  ;; CHECK-NEXT:     (i32.const 0)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (catch $e
  ;; CHECK-NEXT:    (drop
  ;; CHECK-NEXT:     (pop i32)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (catch $e2
  ;; CHECK-NEXT:    (try $try0
  ;; CHECK-NEXT:     (do
  ;; CHECK-NEXT:      (throw $e
  ;; CHECK-NEXT:       (i32.const 0)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:     (catch $e
  ;; CHECK-NEXT:      (drop
  ;; CHECK-NEXT:       (pop i32)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:     (catch $e2
  ;; CHECK-NEXT:      (local.set $x
  ;; CHECK-NEXT:       (i32.const 1)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (local.set $x
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $nested-catch1
    (local $x i32)
    (try
      (do
        (throw $e (i32.const 0))
      )
      (catch $e
        (drop (pop i32))
      )
      (catch $e2
        (try
          (do
            (throw $e (i32.const 0))
          )
          (catch $e
            (drop (pop i32))
          )
          (catch $e2
            (local.set $x (i32.const 1))
          )
        )
      )
    )
    ;; This should NOT be dropped because the exception might not be caught by
    ;; the inner catches, and the local.set above us may not have run, and
    ;; other possible code paths do not even set the local.
    (local.set $x (i32.const 1))
  )

  ;; CHECK:      (func $nested-catch2
  ;; CHECK-NEXT:  (local $x i32)
  ;; CHECK-NEXT:  (try $try
  ;; CHECK-NEXT:   (do
  ;; CHECK-NEXT:    (throw $e
  ;; CHECK-NEXT:     (i32.const 0)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (catch $e
  ;; CHECK-NEXT:    (drop
  ;; CHECK-NEXT:     (pop i32)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (local.set $x
  ;; CHECK-NEXT:     (i32.const 1)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (catch_all
  ;; CHECK-NEXT:    (try $try1
  ;; CHECK-NEXT:     (do
  ;; CHECK-NEXT:      (throw $e
  ;; CHECK-NEXT:       (i32.const 0)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:     (catch $e
  ;; CHECK-NEXT:      (drop
  ;; CHECK-NEXT:       (pop i32)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:      (local.set $x
  ;; CHECK-NEXT:       (i32.const 1)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:     (catch_all
  ;; CHECK-NEXT:      (local.set $x
  ;; CHECK-NEXT:       (i32.const 1)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $nested-catch2
    (local $x i32)
    (try
      (do
        (throw $e (i32.const 0))
      )
      (catch $e
        (drop (pop i32))
        (local.set $x (i32.const 1))
      )
      (catch_all
        (try
          (do
            (throw $e (i32.const 0))
          )
          (catch $e
            (drop (pop i32))
            (local.set $x (i32.const 1))
          )
          (catch_all
            (local.set $x (i32.const 1))
          )
        )
      )
    )
    ;; This should be dropped because the exception is guaranteed to be caught
    ;; by one of the catches and it will set the local to 1.
    (local.set $x (i32.const 1))
  )
)

;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s -all --possible-types -S -o - | filecheck %s

(module
  ;; CHECK:      (type $struct (struct ))
  (type $struct (struct))

  ;; CHECK:      (func $no-non-null (result (ref any))
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (ref.null any)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (unreachable)
  ;; CHECK-NEXT: )
  (func $no-non-null (result (ref any))
    ;; Cast a null to non-null in order to get wasm to validate, but of course
    ;; this will trap at runtime. The possible-types pass will see that no
    ;; actual type can reach the function exit, and will add an unreachable
    ;; here. (Replacing the ref.as with an unreachable is not terribly useful in
    ;; this instance, but it checks that we properly infer things, and in other
    ;; cases replacing with an unreachable can be good.)
    (ref.as_non_null
      (ref.null any)
    )
  )

  ;; CHECK:      (func $nested (result i32)
  ;; CHECK-NEXT:  (ref.is_null
  ;; CHECK-NEXT:   (block
  ;; CHECK-NEXT:    (block
  ;; CHECK-NEXT:     (nop)
  ;; CHECK-NEXT:     (block
  ;; CHECK-NEXT:      (block
  ;; CHECK-NEXT:       (drop
  ;; CHECK-NEXT:        (ref.null any)
  ;; CHECK-NEXT:       )
  ;; CHECK-NEXT:       (unreachable)
  ;; CHECK-NEXT:      )
  ;; CHECK-NEXT:      (unreachable)
  ;; CHECK-NEXT:     )
  ;; CHECK-NEXT:     (unreachable)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:    (unreachable)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $nested (result i32)
    ;; As above, but add other instructions on the outside, which can also be
    ;; replaced.
    (ref.is_null
      (loop (result (ref func))
        (nop)
        (ref.as_func
          (ref.as_non_null
            (ref.null any)
          )
        )
      )
    )
  )

  ;; CHECK:      (func $yes-non-null (result (ref any))
  ;; CHECK-NEXT:  (ref.as_non_null
  ;; CHECK-NEXT:   (struct.new_default $struct)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $yes-non-null (result (ref any))
    ;; Similar to the above but now there *is* an allocation, and so we have
    ;; nothing to optimize. (The ref.as is redundant, but we leave that for
    ;; other passes, and we keep it in this test to keep the testcase identical
    ;; to the above in all ways except for having a possible type.)
    (ref.as_non_null
      (struct.new $struct)
    )
  )
)
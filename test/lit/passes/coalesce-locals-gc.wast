;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s --coalesce-locals -all -S -o - \
;; RUN:   | filecheck %s

(module
 ;; CHECK:      (func $test-fallthrough (param $0 dataref)
 ;; CHECK-NEXT:  (unreachable)
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (local.get $0)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $test-fallthrough (param $func (ref data))
  (unreachable)
  (drop
   ;; A get of a non-nullable parameter in unreachable code. We cannot replace
   ;; it with a null, and so we cannot remove as we'd like.
   (local.get $func)
  )
 )
)

;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.

;; Check that string types are emitted properly in the binary format.

;; RUN: foreach %s %t wasm-opt -all --roundtrip -S -o - | filecheck %s

(module
  ;; CHECK:      (func $foo (param $a stringref) (param $b stringview_wtf8) (param $c stringview_wtf16) (param $d stringview_iter) (param $e stringref) (param $f stringview_wtf8) (param $g stringview_wtf16) (param $h stringview_iter) (param $i (ref string)) (param $j (ref stringview_wtf8)) (param $k (ref stringview_wtf16)) (param $l (ref stringview_iter))
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (string.new_wtf8 utf8
  ;; CHECK-NEXT:    (i32.const 1)
  ;; CHECK-NEXT:    (i32.const 2)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (string.new_wtf8 wtf8
  ;; CHECK-NEXT:    (i32.const 3)
  ;; CHECK-NEXT:    (i32.const 4)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (string.new_wtf8 replace
  ;; CHECK-NEXT:    (i32.const 5)
  ;; CHECK-NEXT:    (i32.const 6)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (string.new_wtf16
  ;; CHECK-NEXT:    (i32.const 7)
  ;; CHECK-NEXT:    (i32.const 8)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $foo
    (param $a stringref)
    (param $b stringview_wtf8)
    (param $c stringview_wtf16)
    (param $d stringview_iter)
    (param $e (ref null string))
    (param $f (ref null stringview_wtf8))
    (param $g (ref null stringview_wtf16))
    (param $h (ref null stringview_iter))
    (param $i (ref string))
    (param $j (ref stringview_wtf8))
    (param $k (ref stringview_wtf16))
    (param $l (ref stringview_iter))
    (drop
      (string.new_wtf8 utf8
        (i32.const 1)
        (i32.const 2)
      )
    )
    (drop
      (string.new_wtf8 wtf8
        (i32.const 3)
        (i32.const 4)
      )
    )
    (drop
      (string.new_wtf8 replace
        (i32.const 5)
        (i32.const 6)
      )
    )
    (drop
      (string.new_wtf16
        (i32.const 7)
        (i32.const 8)
      )
    )
  )
)

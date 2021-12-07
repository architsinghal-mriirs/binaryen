;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s -all --precompute -S -o - | filecheck %s

;; Regression test for a bug (#3843) in which the LUB calculation done during
;; the refinalization of the select incorrectly produced a new type rather than
;; returning (ref null $A).

(module
 ;; CHECK:      (type $A (struct (field (ref null $C))))
 (type $A (struct (field (ref null $C))))

 ;; CHECK:      (type $B (struct (field (ref null $D))))
 (type $B (struct (field (ref null $D))))

 ;; CHECK:      (type $D (struct (field (mut (ref $A))) (field (mut (ref $A)))))

 ;; CHECK:      (type $C (struct (field (mut (ref $A)))))
 (type $C (struct (field (mut (ref $A)))))
 (type $D (struct (field (mut (ref $A))) (field (mut (ref $A)))))

 ;; CHECK:      (func $foo (param $a (ref null $A)) (result (ref null $A))
 ;; CHECK-NEXT:  (select (result (ref null $A))
 ;; CHECK-NEXT:   (local.get $a)
 ;; CHECK-NEXT:   (ref.null $B)
 ;; CHECK-NEXT:   (i32.const 0)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $foo (param $a (ref null $A)) (result (ref null $A))
  ;; the select should have type $A
  (select (result (ref null $A))
   ;; one arm has type $A
   (local.get $a)
   ;; one arm has type $B (a subtype of $A)
   (ref.null $B)
   (i32.const 0)
  )
 )
)

.386
.model flat, stdcall
option casemap :none

.code

calculateLib proc valuesA: ptr qword, valuesB: ptr qword, valuesC: ptr qword,
  valuesD: ptr qword, one: ptr qword, two: ptr qword,
  four: ptr qword, twentyThree: ptr qword, result: ptr qword

finit

mov ebx, twentyThree
fld qword ptr [ebx]     ;; 23 in stack

mov ebx, valuesB
fmul qword ptr [ebx]    ;; 23*b
fsqrt                   ;; sqrt(23*b) 

mov ebx, two            
fld qword ptr [ebx]     ;; 2 in stack

mov ebx, valuesC
fmul qword ptr [ebx]    ;; 2*c

mov ebx, valuesD
fsub qword ptr [ebx]    ;; 2*c - d

fadd                    ;; numerator calculated

mov ebx, valuesA
fld qword ptr [ebx]     ;; a in stack

mov ebx, four
fdiv qword ptr [ebx]    ;; a/4

mov ebx, one
fsub qword ptr [ebx]    ;; a/4 - 1

fxch st(1)              ;; change positions
fdiv st(0), st(1)       ;; numerator/denominator
 
mov ebx, result
fstp qword ptr [ebx]

ret

calculateLib endp
end

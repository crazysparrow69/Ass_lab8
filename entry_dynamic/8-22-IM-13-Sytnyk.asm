.386
.model flat, stdcall
option casemap :none

include \masm32\include\masm32rt.inc
includelib \masm32\lib\kernel32.lib

mov_constant macro const
  mov edx, offset const
  push edx
endm

lea_value macro value
  lea edx, value
  push edx
endm

push_into_stack macro
  mov_constant result
  mov_constant twentyThree
  mov_constant four
  mov_constant two 
  mov_constant one
  
  lea_value valuesD[ebp * 8]
  lea_value valuesC[ebp * 8]
  lea_value valuesB[ebp * 8]
  lea_value valuesA[ebp * 8]
endm

coprocessorState macro
  ftst
  fnstsw ax
  sahf
endm

successMessage macro
  invoke wsprintf, addr buff, addr dataFormat, 
    addr valueA, addr valueB, addr valueC, addr valueD,
    addr valueC, addr valueD, addr valueB, addr valueA, addr resultStr
  invoke szCatStr, addr data, addr buff
  invoke MessageBox, 0, offset data, offset labTitle, 0
endm

errorMessage macro messageFormat
  invoke wsprintf, addr buff, addr messageFormat,
    addr valueA, addr valueB, addr valueC, addr valueD, 
    addr valueC, addr valueD, addr valueB, addr valueA
  invoke szCatStr, addr data, addr buff
  invoke MessageBox, 0, offset data, offset labTitle, 0 
endm

.data?
  library_loader    dd ?
  procedure_pointer dd ?

  result    dq 32 dup(?)
  resultStr db 32 dup(?)

  valueA db 32 dup(?)
  valueB db 32 dup(?)
  valueC db 32 dup(?)
  valueD db 32 dup(?)

  data db 32 dup(?)
  buff db 32 dup(?)
  
.data 
  procedure_name db "calculateLib", 0
  library_name   db "8-22-IM-13-Sytnyk-lib", 0
  
  labTitle                    db "8-22-IM-13-Sytnyk-entry-dynamic", 0
  dataFormat                  db "Formula: (2*c - d + sqrt(23*b))/(a/4 - 1)", 10,
                                 "a = %s", 10,
                                 "b = %s", 10,
                                 "c = %s", 10,
                                 "d = %s", 10,
                                 "(2*%s - %s + sqrt(23*%s))/(%s/4 - 1) = %s", 10, 0

  zeroDenominatorFormat       db "Formula: (2*c - d + sqrt(23*b))/(a/4 - 1)", 10,
                                 "a = %s", 10,
                                 "b = %s", 10,
                                 "c = %s", 10,
                                 "d = %s", 10,
                                 "(2*%s - %s + sqrt(23*%s))/(%s/4 - 1) = undefined", 10,
                                 "Cannot divide by 0", 10, 0

  invalidDefinitionAreaFormat db "Formula: (2*c - d + sqrt(23*b))/(a/4 - 1)", 10,
                                 "a = %s", 10,
                                 "b = %s", 10,
                                 "c = %s", 10,
                                 "d = %s", 10,
                                 "(2*%s - %s + sqrt(23*%s))/(%s/4 - 1) = undefined", 10,
                                 "The root expression is less than zero", 10, 0

  valuesA dq 4.0,  5.6, -6.3, -2.7, -0.4,  7.2
  valuesB dq 3.3,  1.5, -1.3,  3.3,  2.2,  1.1
  valuesC dq 2.2, -2.3, -3.2,  0.4,  1.1,  0.2
  valuesD dq 1.1, -4.7, -2.9, -1.2, 12.2, 10.5

  one         dq 1.0
  two         dq 2.0
  four        dq 4.0
  twentyThree dq 23.0

.code 
main:
  mov ebp, 0
  
  invoke LoadLibrary, addr library_name                      
      mov library_loader, eax
  invoke GetProcAddress, library_loader, addr procedure_name    
      mov procedure_pointer, eax
      
  .while ebp < 6
    ;; Converting numbers to strings
    invoke FloatToStr2, valuesA[ebp * 8], addr valueA
    invoke FloatToStr2, valuesB[ebp * 8], addr valueB
    invoke FloatToStr2, valuesC[ebp * 8], addr valueC
    invoke FloatToStr2, valuesD[ebp * 8], addr valueD

    push_into_stack

    ;; Checking denominator
    finit
    fld four             ;; 4 in ctack
    fld valuesA[ebp * 8] ;; a in ctack
    fdiv st(0), st(1)    ;; a/4
    fld one              ;; 1 in stack
    fxch st(1)           ;; change positions
    fsub st(0), st(1)    ;; a/4 - 1   

    coprocessorState
    jz zeroDenominator

    ;; Checking square root
    fld twentyThree       ;; 23 in stack
    fmul valuesB[ebp * 8] ;; 23*b
    fsqrt                 ;; sqrt(23*b)

    coprocessorState
    test ah, 01000000b
    jnz invalidDefinitionArea

    call procedure_pointer

    invoke FloatToStr2, result, addr resultStr  ;; converting result into string
    successMessage
    jmp next

    zeroDenominator:
      errorMessage zeroDenominatorFormat
      jmp next
    invalidDefinitionArea:
      errorMessage invalidDefinitionAreaFormat
      jmp next
    next:
      inc ebp
      mov data, 0h
  .endw
  invoke ExitProcess, 0
end main

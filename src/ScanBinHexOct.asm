; Don't forget to use
; $ echo $?
; To check the exit status of the program
%macro exit 1
            mov rdi, %1
            call Exit
%endmacro

;data
section .data
NUM:        db "123456", 0

section .text
;code
;=========================================================================
;                               MAIN                                     ;
;                       MODE : 0 - bin, 1 - hex, 2 - dec                 ;
;=========================================================================
    global _start                                                           
                                                                            
_start:                                                                     
                                                                            
            mov rdi, NUM
            call SscanDec

            call OkExit
;=========================================================================


;=========================================================================;
;                 ┌───────────────────────────────────────────────┐       ;
;                 │ Scan(Bin/Dec/Hex) - translates string in      │       ;
;                 │ Bin/Dec/Hex representation into number in RAX │       ;
;                 ├───────────────────────────────────────────────┤       ;
;                 │ Entry - RDI - string pointer                  │       ;
;                 │ Exit  - RAX - numeric value                   │       ;
;                 │ Destr - RCX, RBX, RSI, R8                     │       ;
;                 └───────────────────────────────────────────────┘       ;
;=========================================================================;
;------------set numeric base--------------------                   
SscanBin:
            mov rax, 2
            jmp SscanStart
SscanDec: 
            mov rax, 0ah
            jmp SscanStart
SscanHex:
            mov rax, 010h
;------------------------------------------------                    
SscanStart:
            push rbp           ; Put numeric base
            mov rbp, rsp       ; into first
            sub rsp, 8         ; local variable
            mov [rbp - 8], rax ; [rbp - 8]. Also rax 
                               ; stores numeric base

            xor rbx, rbx       ; Init char counter

            jmp CheckSscanLoopCondition

SscanWhileLoop:
            mul rcx            ; rax = rcx * rax
            mov rcx, rax       ; rcx = rax
            mov rax, [rbp - 8] ; restore rax, cleaned in the 'mul'
            lea rcx, [rcx + rsi - '0'] ; rcx = rcx + rdi[rbx] - '0'
            ;As a result 
            ; rcx = rcx * numericBase + (currentChar - '0')
;------------PutCharSwitch-----------------------                   
            cmp rax, 2
            jne PutCharDec
                    ;Checks
                    cmp rsi, '1'  ; assert(
                    jg  ErrorExit ; (curChar >= '0') &&
                    cmp rsi, '0'  ; (curChar <= '1')    )
                    jl  ErrorExit ; 
                    ;\Checks
            jmp PutCharSwitchEnd
PutCharDec:
            cmp rax, 10
            jne PutCharHex
                    ;Checks
                    cmp rsi, '9'   ; assert(
                    jg  ErrorExit  ; (curChar >= '0') &&
                    cmp rsi, '0'   ; (curChar <= '9')    )
                    jl  ErrorExit  ; 
                    ;\Checks
            jmp PutCharSwitchEnd
PutCharHex:
            cmp rax, 16
            jne PutCharDefault
                    ;Checks
                    cmp rsi, '0'  ;
                    jl  ErrorExit ;       
                    cmp rsi, '9'  ;
                    jle PutCharSwitchEnd ; We already know that digit is decimal
                    cmp rsi, 'A'  ; assert( ((curChar >= '0') && (curChar <= '9')) ||
                    jl  ErrorExit ;         ((curChar >= 'A') && (curChar <= 'F'))    )
                    cmp rsi, 'F'  ;
                    jg  ErrorExit
                    ;\Checks
                    ;This point is reached only if ((curChar >= 'A') && (curChar <= 'F'))
                    lea rcx, [rcx + '0' - 'A'] ;│rcx = rcx * rax + ([rdi + rbx] - 'A')
            jmp PutCharSwitchEnd
PutCharDefault:
            call ErrorExit
PutCharSwitchEnd:
;------------------------------------------------                    
            inc rbx ; counter += 1
CheckSscanLoopCondition:
            mov sil, byte [rdi + rbx] ; sil = rdi[rbx]
            test rsi, rsi             ; if (sil != '\0')
            jne SscanWhileLoop        ;     goto whileLoop;

            mov rax, rcx              ; rax = rcx, because rcx stores the value
            ;Outro
            add rsp, 8                
            pop rbp
            ret
;=========================================================================

;==========================EXIT ROUTINES==================================
ErrorExit:
            mov    rdi, 1     ; return value <- 1
            jmp __exit
OkExit:
            mov    rdi, 0     ; return value <- 0
            jmp __exit
__exit:
            mov    rax, 3Ch   ; syscall <- exit                             
            syscall                                                         
;=========================================================================

        NUMSTRINGLEN equ 64
section .bss
        NUMSTRING resb NUMSTRINGLEN + 1 ; To store 64-bit value plus null-terminator
section .text
;=========================================================================;
;                 ┌───────────────────────────────────────────┐           ;
;                 │ Sprint(Bin/Dec/Hex) - puts number's       │           ;
;                 │ Bin/Dec/Hex representation in string      │           ;
;                 ├───────────────────────────────────────────┤           ;
;                 │ Entry - RAX - value to print              │           ;
;                 │ Exit  - RAX - string pointer              │           ;
;                 │ Exit  - RBX - string length               │           ;
;                 │ Destr - RDI, RDX, RCX                     │           ;
;                 └───────────────────────────────────────────┘           ;
;=========================================================================;
;---set numeric base---
SprintBin:
            mov rcx, 2
            jmp SprintStart
SprintDec: 
            mov rcx, 10
            jmp SprintStart
SprintHex:
            mov rcx, 16
;-----------------------
SprintStart:
            xor rbx, rbx    ; Init ((-1) * length) counter
            mov [NUMSTRING + NUMSTRINGLEN + 1], byte 0 ; put the null-terminator
                                                       ; in the end of the string
            jmp CheckLoopConditionSprint

SprintLoop:
;-----------GetCharSwitch----------------------------------------
            cmp rcx, 2
            jne GetCharDec
                    mov rdi, rax  ; rdi  =  rax │
                    and rdi,  1   ; rdi &=   1  │ rdi = '0' + (rax % 2)
                    add rdi, '0'  ; rdi +=  '0' │
                    shr rax, 1    ; rax >>= 1
            jmp GetCharSwitchEnd
GetCharDec:
            cmp rcx, 10
            jne GetCharHex            
                    xor rdx, rdx          ; rdx = 0
                    div rcx               ; rdx = rax % rcx = rdi % 10
                                          ; rax /= 10
                    lea rdi, ['0' + rdx]  ; rdi = '0' + rdx             
            jmp GetCharSwitchEnd
GetCharHex:
            cmp rcx, 16
            jne GetCharDefault
                    xor rdx, rdx               ; rdx = 0 
                    div rcx                    ; rdx = rax % rcx = rdi % 16
                                               ; rax /= 16
                    lea rdi, ['0' + rdx]       ; rdi  = '0' + (rdi % 16)
                    cmp rdx, 10                ; 
                    lea rdx, ['A' + rdx - 10]  ; rdx  = 'A' + (rdi % 16)
                    cmovge rdi, rdx            ; rdi = (rdi % 16 >= 10) ? rdx : rdi
            jmp GetCharSwitchEnd
GetCharDefault:
            call ErrorExit
GetCharSwitchEnd:
;-----------GetCharSwitchEnd-------------------------------------

            mov [NUMSTRING + NUMSTRINGLEN + rbx], dil ; NUMSTRING[64 - currentLen] = dil

            dec rbx          ; rbx -=  1 - dec counter


CheckLoopConditionSprint: 
            test rax, rax    ; if (!rdi)
            jne SprintLoop   ;    break;

                                       ; '+ 1' because there was one extra 'dec rbx'
            lea rax, [NUMSTRING + NUMSTRINGLEN + rbx + 1] ; put string pointer in rax
            imul rbx, -1      ; put length value in the rbx

            ret
;=========================================================================

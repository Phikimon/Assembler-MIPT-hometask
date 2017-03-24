;Required input buffer size
NUMSTRINGLEN equ 65

section .text
;=========================================================================;
;                 ┌───────────────────────────────────────────┐           ;
;                 │ SprintBin           - puts number's       │           ;
;                 │ Bin         representation in string      │           ;
;                 ├───────────────────────────────────────────┤           ;
;                 │ Entry - RAX - value to print              │           ;
;                 │ Entry - R15 - string pointer              │           ;
;                 │ Exit  - R15 - string pointer              │           ;
;                 │ Exit  - RBX - string length               │           ;
;                 │ Destr - RDI, RDX, RCX                     │           ;
;                 └───────────────────────────────────────────┘           ;
;=========================================================================;
SprintBin:

            xor rbx, rbx    ; Init ((-1) * length) counter
            mov [r15 + NUMSTRINGLEN + 1], byte 0 ; put the null-terminator
                                                 ; in the end of the string
            jmp SprintBinCheckLoopCondition

SprintBinLoop:
            mov rdi, rax  ; rdi  =  rax │
            and rdi,  1   ; rdi &=   1  │ rdi = '0' + (rax % 2)
            add rdi, '0'  ; rdi +=  '0' │
            shr rax, 1    ; rax >>= 1

            mov [r15 + NUMSTRINGLEN + rbx], dil ; NUMSTRING[64 - currentLen] = dil

            dec rbx          ; rbx -=  1 - dec counter

SprintBinCheckLoopCondition: 
            test rax, rax    ; if (!rdi)
            jne SprintBinLoop   ;    break;

                                       ; '+ 1' because there was one extra 'dec rbx'
            lea r15, [r15 + NUMSTRINGLEN + rbx + 1] ; put string pointer in rax
            imul rbx, -1      ; put length value in the rbx

            ret
;=========================================================================
;=========================================================================;
;                 ┌───────────────────────────────────────────┐           ;
;                 │ SprintDec           - puts number's       │           ;
;                 │     Dec     representation in string      │           ;
;                 ├───────────────────────────────────────────┤           ;
;                 │ Entry - RAX - value to print              │           ;
;                 │ Entry - R15 - string pointer              │           ;
;                 │ Exit  - R15 - string pointer              │           ;
;                 │ Exit  - RBX - string length               │           ;
;                 │ Destr - RDI, RDX, RCX                     │           ;
;                 └───────────────────────────────────────────┘           ;
;=========================================================================;
SprintDec:
            mov rcx, 10
            xor rbx, rbx    ; Init ((-1) * length) counter
            mov [r15 + NUMSTRINGLEN + 1], byte 0 ; put the null-terminator
                                                       ; in the end of the string
            jmp SprintDecCheckLoopCondition

SprintDecLoop:
            xor rdx, rdx          ; rdx = 0
            div rcx               ; rdx = rax % rcx = rdi % 10
                                  ; rax /= 10
            lea rdi, ['0' + rdx]  ; rdi = '0' + rdx             

            mov [r15 + NUMSTRINGLEN + rbx], dil ; NUMSTRING[64 - currentLen] = dil

            dec rbx          ; rbx -=  1 - dec counter


SprintDecCheckLoopCondition: 
            test rax, rax    ; if (!rdi)
            jne SprintDecLoop   ;    break;

                                       ; '+ 1' because there was one extra 'dec rbx'
            lea r15, [r15 + NUMSTRINGLEN + rbx + 1] ; put string pointer in rax
            neg rbx                   ; put length value in the rbx

            ret
;=========================================================================
;=========================================================================;
;                 ┌───────────────────────────────────────────┐           ;
;                 │ SprintHex           - puts number's       │           ;
;                 │         Hex representation in string      │           ;
;                 ├───────────────────────────────────────────┤           ;
;                 │ Entry - RAX - value to print              │           ;
;                 │ Entry - R15 - string pointer              │           ;
;                 │ Exit  - R15 - string pointer              │           ;
;                 │ Exit  - RBX - string length               │           ;
;                 │ Destr - RDI, RDX, RCX                     │           ;
;                 └───────────────────────────────────────────┘           ;
;=========================================================================;
SprintHex:
            xor rbx, rbx    ; Init ((-1) * length) counter
            mov [r15 + NUMSTRINGLEN + 1], byte 0 ; put the null-terminator
                                                       ; in the end of the string
            jmp SprintHexCheckLoopCondition

SprintHexLoop:
            mov rdx, rax   ;|
            and rdx, 0Fh   ;|rdx = rax % 16
            shr rax, 4     ;|rax /= 16

            lea rdi, ['0' + rdx]       ; rdi  = '0' + (rdi % 16)
            cmp rdx, 10                ; 
            lea rdx, ['A' + rdx - 10]  ; rdx  = 'A' + (rdi % 16)
            cmovge rdi, rdx            ; rdi = (rdi % 16 >= 10) ? rdx : rdi

            mov [r15 + NUMSTRINGLEN + rbx], dil ; NUMSTRING[64 - currentLen] = dil

            dec rbx          ; rbx -=  1 - dec counter


SprintHexCheckLoopCondition: 
            test rax, rax    ; if (!rdi)
            jne SprintHexLoop   ;    break;

                                       ; '+ 1' because there was one extra 'dec rbx'
            lea r15, [r15 + NUMSTRINGLEN + rbx + 1] ; put string pointer in rax
            neg rbx          ; put length value in the rbx

            ret
;=========================================================================
;=========================================================================;
;                 ┌───────────────────────────────────────────┐           ;
;                 │ SprintOct           - puts number's       │           ;
;                 │         Oct representation in string      │           ;
;                 ├───────────────────────────────────────────┤           ;
;                 │ Entry - RAX - value to print              │           ;
;                 │ Entry - R15 - string pointer              │           ;
;                 │ Exit  - R15 - string pointer              │           ;
;                 │ Exit  - RBX - string length               │           ;
;                 │ Destr - RDI, RDX, RCX                     │           ;
;                 └───────────────────────────────────────────┘           ;
;=========================================================================;
SprintOct:
            xor rbx, rbx    ; Init ((-1) * length) counter
            mov [r15 + NUMSTRINGLEN + 1], byte 0 ; put the null-terminator
                                                       ; in the end of the string
            jmp SprintOctCheckLoopCondition

SprintOctLoop:
            mov rdx, rax   ;|
            and rdx, 07h   ;|rdx = rax % 8 
            shr rax, 3     ;|rax /= 8

            lea rdi, ['0' + rdx]       ; rdi  = '0' + (rdi % 16)

            mov [r15 + NUMSTRINGLEN + rbx], dil ; NUMSTRING[64 - currentLen] = dil

            dec rbx          ; rbx -=  1 - dec counter


SprintOctCheckLoopCondition: 
            test rax, rax    ; if (!rdi)
            jne SprintOctLoop   ;    break;

                                       ; '+ 1' because there was one extra 'dec rbx'
            lea r15, [r15 + NUMSTRINGLEN + rbx + 1] ; put string pointer in rax
            neg rbx          ; put length value in the rbx

            ret
;=========================================================================

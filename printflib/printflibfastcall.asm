%include "PrintBinHexOct.asm"
%include "exit.asm"

global PhilPrintf
;====================MACROS=================================
;Entry = string address; string length
;Destr = RDI, RDX, RSI, RAX
%macro printdata 2
            mov     rdi, 1  ; file descriptor  <- stdout           
            mov     rdx, %2 ; buffer size      <- %2
            mov     rsi, %1 ; buffer to print  <- %1              
            mov     rax, 1  ; syscall          <- sys_write    
            syscall             
            test rax, rax ; if no byte is written,
            je ErrorExit  ;     exit(1)
%endmacro
;===========================================================

;==========================PRINTF===================================================
;=========================================================================;
;                 ┌───────────────────────────────────────────────┐       ;
;                 │ PhilPrintf - printf written by Phil           │       ;
;                 ├───────────────────────────────────────────────┤       ;
;                 │ Entry - Stack. Arguments and format string    │       ;
;                 │ similar to standard printf                    │       ;
;                 │ Exit  - R8 - number of chars in the input     │       ;
;                 │ string                                        │       ;
;                 │ Exit  - R9 - number of arguments printed      │       ;
;                 │ Destr - RAX, RBX, RCX, RDX, RSI, RDI, R8, R9, │       ;
;                 │ R10, R15                                      │       ;
;                 └───────────────────────────────────────────────┘       ;
;=========================================================================;
PhilPrintf:
    ; FASTCALL TO CDECL
    pop  rax ;pop return address
    push r9
    push r8
    push rcx
    push rdx
    push rsi
    push rdi
    push rax ;push return address back
    ; FASTCALL TO CDECL
    push rbp
    mov rbp, rsp
    sub rsp, NUMSTRINGLEN ; Allocate memory for temporary string
                          ; that will contain sprintxxx result
                          ; r9 - argument counter
    xor r8, r8            ; r8 - char counter
    mov r9, 2             ; to skip and oldrbp
    mov r10, [rbp + r9 * 8] ; r10 - format string pointer
    inc r9                  ; to skip format string
            
;===================LOOP==================================================
printfLoopDo:
;===============SWITCH=================
printfSwitchSpecification:
    cmp byte [r10 + r8], '%'
    jne printfSwitchSlashZero          
        inc r8; skip percent char
    ;========SUBSWITCH================
printfSubSwitchDec:
        cmp byte [r10 + r8], 'd'
        jne printfSubSwitchHex
            mov rax, [rbp + r9 * 8]   ; pass value to print to the Sprint
            lea r15, [rbp - NUMSTRINGLEN]       ; pass string pointer to the Sprint
            call SprintDec 
            printdata r15, rbx
        inc r9  ;skip this argument in stack
        jmp printfSubSwitchEnd
    ;---------------------------------
printfSubSwitchHex:
        cmp byte [r10 + r8], 'x'
        jne printfSubSwitchBin
            mov rax, [rbp + r9 * 8]   ; pass value to print to the Sprint
            lea r15, [rbp - NUMSTRINGLEN] ; pass string pointer to the Sprint
            call SprintHex 
            printdata r15, rbx
        inc r9  ;skip this argument in stack
        jmp printfSubSwitchEnd
    ;---------------------------------
printfSubSwitchBin:
        cmp byte [r10 + r8], 'b'
        jne printfSubSwitchOct
            mov rax, [rbp + r9 * 8]   ; pass value to print to the Sprint
            lea r15, [rbp - NUMSTRINGLEN]       ; pass string pointer to the Sprint
            call SprintBin 
            printdata r15, rbx
        inc r9  ;skip this argument in stack
        jmp printfSubSwitchEnd
    ;---------------------------------
printfSubSwitchOct:
        cmp byte [r10 + r8], 'o'
        jne printfSubSwitchStr    
            mov rax, [rbp + r9 * 8]   ; pass value to print to the Sprint
            lea r15, [rbp - NUMSTRINGLEN]   ; pass string pointer to the Sprint
            call SprintOct 
            printdata r15, rbx
        inc r9  ;skip this argument in stack
        jmp printfSubSwitchEnd
    ;---------------------------------
printfSubSwitchStr:
        cmp byte [r10 + r8], 's'
        jne printfSubSwitchChar   
            mov rax, [rbp + r9 * 8]   ; put string pointer in rax

            xor rbx, rbx
            jmp printfSubSwitchLenLoopCond ;|
printfSubSwitchLenLoop:                    ;| 
            inc rbx                        ;| Get string length
printfSubSwitchLenLoopCond:                ;| 
            cmp byte [rax + rbx], 0        ;|
            jne printfSubSwitchLenLoop     ;|

            printdata rax, rbx
        inc r9  ;skip this argument in stack
        jmp printfSubSwitchEnd
    ;---------------------------------
printfSubSwitchChar:
        cmp byte [r10 + r8], 'c'
        jne printfSubSwitchPercent
            lea rsi, [rbp + r9 * 8]
            printdata rsi, 1   ; pass char address to the macro
        inc r9  ;skip this argument in stack
        jmp printfSubSwitchEnd
    ;---------------------------------
printfSubSwitchPercent:
        cmp byte [r10 + r8], '%'
        jne printfSubSwitchDefault
            lea rsi, [r10 + r8]
            printdata rsi, 1   ; print percent
        jmp printfSubSwitchEnd
    ;---------------------------------
printfSubSwitchDefault:
        jmp ErrorExit
    ;---------------------------------
printfSubSwitchEnd:
        jmp printfSwitchEnd
    ;========SUBSWITCH END============
;-------------------------------------
printfSwitchSlashZero:
    cmp byte [r10 + r8], 0
    je printfLoopEnd
;--------------------------------------
printfSwitchNotSpecification:
    lea rsi, [r10 + r8]
    printdata rsi, 1      ; print found char
   ;jmp printfSwitchEnd
;-------------------------------------
printfSwitchEnd:
    inc r8  ;skip this char
    jmp printfLoopDo
;===============SWITCH END=============
printfLoopEnd:
;===================LOOP END==============================================
    mov r10, 6 ;|
    cmp r9,  6 ;| 6 is maximum number of arguments passed by registers
    cmovg r10, r9
    ;           8 is size of return address
    lea   r10, [8 + NUMSTRINGLEN + r10 * 8]
    add   rsp, r10
    pop rbp
    ret
;==========================PRINTF END===============================================

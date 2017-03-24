%include "PrintBinHexOct.asm"
%include "ScanBinHexOct.asm"

;   Typical usage example:
;   .../Assembler-MIPT-hometask$ mkdir ./executables<Enter>
;   .../Assembler-MIPT-hometask$ make PrintBinHexOct<Enter>
;   .../Assembler-MIPT-hometask$ cd ./executables<Enter>
;   .../Assembler-MIPT-hometask/executables$ ./PrintBinHexOct<Enter>
;   2<C-d>            //Firstly you have to enter mode: 0 - bin, 1 - hex, 2 - dec
;   1<C-d>            //Secondly you have to enter number to print: '1' is 0x31 and 0d49
;   49
;   .../Assembler-MIPT-hometask/executables$
;___________________________________________________
; Don't forget to use
; $ echo $?
; To check the exit status of the program


;====================MACROS=================================
;Entry = char address
%macro putchar 1
            mov     rdi, 1  ; file descriptor  <- stdout           
            mov     rdx, 1  ; buffer size      <- 1                 
            mov     rsi, %1 ; buffer to print  <- %1
            mov     rax, 1  ; syscall          <- sys_write    
            syscall             
            test rax, rax ; if no byte is written,
            je ErrorExit  ;     exit(1)
%endmacro

;Entry = address of allocated memory
%macro getchar 1
            mov     rdi, 0  ; file descriptor <- stdin   
            mov     rsi, %1 ; buffer          <- %1      
            mov     rdx, 1  ; buffer size     <- 1       
            mov     rax, 0  ; syscall         <- sys_read
            syscall                                                         
            test rax, rax ; if no byte is read,
            je ErrorExit  ;     exit(1)
%endmacro

;Entry = string address; string length
%macro printdata 2
            mov     rdi, 1  ; file descriptor  <- stdout           
            mov     rdx, %2 ; buffer size      <- %2
            mov     rsi, %1 ; buffer to print  <- %1              
            mov     rax, 1  ; syscall          <- sys_write    
            syscall             
            test rax, rax ; if no byte is written,
            je ErrorExit  ;     exit(1)
%endmacro

;Entry = string address; string length
%macro getdata 2
            mov     rdi, 0  ; file descriptor   <- stdin          
            mov     rsi, %1 ; buffer to scan to <- %1              
            mov     rdx, %2 ; chars to scan     <- %2
            mov     rax, 0  ; syscall           <- sys_read
            syscall             
            test rax, rax ; if no byte is read,
            je ErrorExit  ;     exit(1)
%endmacro
;===========================================================

;data

section .bss 
            NUM       resd 65
            MODE1     resb 1
            MODE2     resb 1

section .data
SLASHN:     db 0ah

MODE1INV:   db "Enter, how the input value is represented(b - bin, h - hex, d - dec)", 0ah
MODE1INVLEN equ $-MODE1INV

MODE2INV:   db "Enter, how to represent output value(b - bin, h - hex, d - dec)", 0ah
MODE2INVLEN equ $-MODE2INV

NUMINV:     db "Enter the number in specified numeric system", 0ah
NUMINVLEN   equ $-NUMINV

section .text
;code
;=========================================================================
;                               MAIN                                     ;
;=========================================================================
    global _start                                                           
                                                                            
_start:                                                                     

    printdata MODE1INV, MODE1INVLEN
    getchar   MODE1
    putchar   SLASHN; putchar('\n');

    printdata NUMINV, NUMINVLEN
    getdata   NUM, 65; the 64-bit value in the binary arithmetic occupies 64 chars +
                     ; + null terminator
    putchar   SLASHN ; putchar('\n');

    mov rdi, NUM     ; rdi is entry for the Sscan(Bin/Dec/Hex)
    mov rsi, [MODE1] ; rsi is used to switch representing mode

;----------------MODE 1 switch---------------------
            cmp rsi, 'b'        
            jne Mode1HexCase          
                        call SscanBin
            jmp Mode1SwitchEnd
Mode1HexCase:                         
            cmp rsi, 'h'        
            jne Mode1DecCase        
                        call SscanHex
            jmp Mode1SwitchEnd
Mode1DecCase:                         
            cmp rsi, 'd'        
            jne Mode1DefaultCase    
                        call SscanDec 
            jmp Mode1SwitchEnd
Mode1DefaultCase:                     
            call ErrorExit
Mode1SwitchEnd:
;--------------------------------------------------
    push rax ;push numeric value
    
    printdata MODE2INV, MODE2INVLEN
    getchar   MODE2
    putchar   SLASHN ; putchar('\n');

    pop rax          ; rax = entry for Sprint(Bin/Dec/Hex)
    mov rsi, [MODE2] ; rsi = MODE2

;----------------MODE 2 switch---------------------
            cmp rsi, 'b'        
            jne Mode2HexCase          
                        call SprintBin
            jmp Mode2SwitchEnd
Mode2HexCase:                         
            cmp rsi, 'h'        
            jne Mode2DecCase        
                        call SprintHex
            jmp Mode2SwitchEnd
Mode2DecCase:                         
            cmp rsi, 'd'        
            jne Mode2DefaultCase    
                        call SprintDec 
            jmp Mode2SwitchEnd
Mode2DefaultCase:                     
            call ErrorExit
Mode2SwitchEnd:
;--------------------------------------------------
            
    printdata rax, rbx ; rax stores result string pointer
                       ; rbx stores string length

    putchar SLASHN     ; putchar('\n');

    call OkExit
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

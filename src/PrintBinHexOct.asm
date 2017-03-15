;   Typical usage example:
;   .../Assembler-MIPT-hometask$ mkdir ./executables<Enter>
;   .../Assembler-MIPT-hometask$ make PrintBinHexOct<Enter>
;   .../Assembler-MIPT-hometask$ cd ./executables<Enter>
;   .../Assembler-MIPT-hometask/executables$ ./PrintBinHexOct<Enter>
;   2<C-d>            //Firstly you have to enter mode: 0 - bin, 1 - hex, 2 - dec
;   1<C-d>            //Secondly you have to enter number to print: '1' is 0x31 and 0d49
;   49
;   .../Assembler-MIPT-hometask/executables$

;define constant
        NUMSTRINGLEN equ 64
;macros
%macro exit 1
    ;Exit from program                                            
        mov    rax, 3Ch      ; syscall <- exit                             
        mov    rdi, %1       ; return  <- %1                                
        syscall                                                         
%endmacro

%macro putchar 1
            mov     [PUTCHAR_CHAR], byte %1 ; NUM <- %1
            mov     rdi, 1                  ; file descriptor  <- stdout           
            mov     rdx, 1                  ; buffer size      <- 1                 
            mov     rsi, PUTCHAR_CHAR       ; buffer to print  <- NUM
            mov     rax, 1                  ; syscall          <- sys_write    
            syscall             
%endmacro

;data
section .bss 
            PUTCHAR_CHAR resb 1
            NUM       resd 2
            MODE      resb 1
            NUMSTRING resb NUMSTRINGLEN + 1 ; To store 64-bit value plus null-terminator


section .text
;code
;=========================================================================
;                               MAIN                                     ;
;                       MODE : 0 - bin, 1 - hex, 2 - dec                 ;
;=========================================================================
    global _start                                                           
                                                                            
_start:                                                                     
    ;Read 'MODE' - how to represent value(bin, hex, oct)                    
            mov     rax, 0    ; syscall          <- sys_read                
            mov     rdi, 0    ; file descriptor  <- stdin                   
            mov     rsi, MODE ; buffer           <- mode                    
            mov     rdx, 1    ; buffer size      <- 1                       
            syscall                                                         
                                                                            
    putchar 0ah; putchar('\n');
                                                                            
    ;Read 'NUM' - value to print                                            
            mov     rax, 0    ; syscall          <- sys_read                
            mov     rdi, 0    ; file descriptor  <- stdin                   
            mov     rsi, NUM  ; buffer      <- num                          
            mov     rdx, 8    ; buffer size <- 2 dword size                 
            syscall                                                         

    putchar 0ah; putchar('\n');
                                                                            
    ;Put read value in string according to the 'MODE'                               
            mov rax, [NUM]       ; rdi = NUM                    
            mov rsi, [MODE]      ; rsi = MODE

                                 ; switch (MODE)              (rsi = &MODE) 

            cmp rsi, '0'         ; case '0':                  (*rsi == '0') 
            jne HexCase          ;                                          
            call SprintBin       ;   SprintBin(NUM); break;                
            jmp SwitchEnd
HexCase:                         ;                                          
            cmp rsi, '1'         ; case '1':                  (*rsi == '0') 
            jne DecCase          ;                                          
            call SprintHex       ;   SprintHex(NUM); break;                 
            jmp SwitchEnd
DecCase:                         ;                                          
            cmp rsi, '2'         ; case '2':                  (*rsi == '0') 
            jne DefaultCase      ;                                          
            call SprintDec       ;   SprintOct(NUM); break;                 
            jmp SwitchEnd
DefaultCase:                     
            exit 1 ; macro
SwitchEnd:
            
    ;Print value translated to bin/hex/dec
            mov     rdi, 1    ; file descriptor  <- stdout           
            mov     rdx, rbx  ; buffer size      <- rbx              
            mov     rsi, rax  ; buffer to print  <- rax             
            mov     rax, 1    ; syscall          <- sys_write    
            syscall             

    putchar 0ah; putchar('\n');

    ;Exit the program                                                       
            mov    rax, 3Ch   ; syscall <- exit                             
            mov    rdi, 0     ; return  <- 0                                
            syscall                                                         
;=========================================================================


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
            exit 1 ; macro
GetCharSwitchEnd:
;-----------GetCharSwitchEnd-------------------------------------

            mov [NUMSTRING + NUMSTRINGLEN + rbx], dil ; NUMSTRING[64 - currentLen] = al

            dec rbx          ; rbx -=  1 - dec counter


CheckLoopConditionSprint: 
            test rax, rax    ; if (!rdi)
            jne SprintLoop      ;    break;

                                       ; '+ 1' because there was one extra 'dec rbx'
            lea rax, [NUMSTRING + NUMSTRINGLEN + rbx + 1] ; put string pointer in rax
            imul rbx, -1      ; put length value in the rbx

            ret
;=========================================================================

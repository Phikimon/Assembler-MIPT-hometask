section .bss 
            num   resd 2
            mode  resb 1
            digit resb 1

section .text

;┌───────────────────────────────────────────────────────────────────────────┐
    global _start                                                           ;│
                                                                            ;│
_start:                                                                     ;│
    ;Read 'mode' - how to represent value(bin, hex, oct)                    ;│
            mov     rax, 0    ; syscall          <- sys_read                ;│
            mov     rdi, 0    ; file descriptor  <- stdin                   ;│
            mov     rsi, mode ; buffer           <- mode                    ;│
            mov     rdx, 1    ; buffer size      <- 1                       ;│
            syscall                                                         ;│
                                                                            ;│
                                                                            ;│
    ;Read 'num' - value to print                                            ;│
            mov     rax, 0    ; syscall          <- sys_read                ;│
            mov     rdi, 0    ; file descriptor  <- stdin                   ;│
            mov     rsi, num  ; buffer      <- num                          ;│
            mov     rdx, 8    ; buffer size <- 2 dword size                 ;│
            syscall                                                         ;│
                                                                            ;│
                                                                            ;│
    ;Print read value according to the 'mode'                               ;│
            mov r9, [rsi]        ; r9 = *rsi = num = argument               ;│
            mov rsi, mode        ; switch (mode)              (rsi = &mode) ;│
            cmp [rsi], dword '0' ; case '0':                  (*rsi == '0') ;│
            jne HexCase          ;                                          ;│
            call PrintBin        ;    PrintBin(num); break;                 ;│
HexCase:                         ;                                          ;│
            cmp [rsi], dword '1' ; case '1':                  (*rsi == '0') ;│
            jne OctCase          ;                                          ;│
           ;call PrintHex        ;    PrintHex(num); break;                 ;│
OctCase:                         ;                                          ;│
            cmp [rsi], dword '2' ; case '2':                  (*rsi == '0') ;│
            jne DefaultCase      ;                                          ;│
           ;call PrintOct        ;    PrintOct(num); break;                 ;│
DefaultCase:                                                                ;│
                                                                            ;│
                                                                            ;│
    ;Exit the program                                                       ;│
            mov    rax, 3Ch   ; syscall <- exit                             ;│
            mov    rdi, 0     ; return  <- 0                                ;│
            syscall                                                         ;│
;└───────────────────────────────────────────────────────────────────────────┘

;┌────────────────────────────────────────────────────────────────────┐
;│                ┌───────────────────────────────────────────┐      ;│
;│                │ PrintBin - prints number in bin           │      ;│
;│                ├───────────────────────────────────────────┤      ;│
;│                │ Entry - R9 = value to print               │      ;│
;│                │ Exit  - None                              │      ;│
;│                │ Destr - R8, R9, R10, RAX, RDI, RDX, RSI   │      ;│
;│                └───────────────────────────────────────────┘      ;│
PrintBin:                                                            ;│
            mov r8, 40h       ; Init counter                         ;│
    ;For sys_write:                                                  ;│
            mov     rdi, 1    ; file descriptor  <- stdout           ;│
            mov     rdx, 1    ; buffer size      <- 1                ;│
            mov     rax, 1    ; syscall          <- sys_write        ;│
                                                                     ;│
BinLoop:                                                             ;│
            mov r10, r9   ; r10  =  r9  │                            ;│
            and r10,  1   ; r10 &=   1  │ r10 = '0' + (r9 % 2)       ;│
            add r10, '0'  ; r10 +=  '0' │                            ;│
                                                                     ;│
    ;Print binary digit                                              ;│
            mov      rsi , digit ;│  rsi = &digit -> buffer to print ;│
            mov     [rsi], r10   ;│ *rsi = digit = r10               ;│
            syscall              ;│  sys_write(&digit = rsi)         ;│
                                                                     ;│
            dec r8          ; r8 -=  1 - dec counter                 ;│
            shr r9, 1       ; r9 >>= 1 - shift value                 ;│
                                                                     ;│
            cmp r8, 0       ; if (!r8)                               ;│
            jne BinLoop     ;    break;                              ;│
                                                                     ;│
                                                                     ;│
            ret                                                      ;│
;└────────────────────────────────────────────────────────────────────┘

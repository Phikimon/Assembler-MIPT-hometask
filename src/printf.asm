%include "printflib.asm"
%include "exit.asm"

section .data

PRINTFORMATSTRING: db "I love %s, and %s loves me %d(%x(%b(%o))) %%%cimes", 0ah, 0
STR_SCANF:         db "scanf",  0
STR_PRINTF:        db "printf", 0

section .text
;=========================================================================
;                               MAIN                                     ;
;=========================================================================
    global _start                                                           
                                                                            
_start:                                                                     
    push 't' ;%c
    push 100 ;%o
    push 100 ;%b
    push 100 ;%h
    push 100 ;%d
    push STR_PRINTF ;%s
    push STR_SCANF  ;%s
    push PRINTFORMATSTRING
    call _PhilPrintf
    add rsp, 8*8
    
    call OkExit
;=========================================================================

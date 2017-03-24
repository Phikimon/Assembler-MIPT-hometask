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


section .text
    global _start

_start:
    ; push some test values 
    push     0
    push     3
    push     -1
    push     2
    push     4
    push     10
    push     7
    push     8
    call     sum_until_zero
    ; pop values from stack
    add      rsp, 8 * 2      

    ;Exit the program
    mov    rax, 3Ch   ; syscall <- exit
    mov    rdi, 0     ; return  <- 0
    syscall


;----------------------------------------------------------------------
; sum_until_zero - sums arguments in stack. 0 is kinda null-terminator
;----------------------------------------------------------------------
; Entry - arguments are stored in stack
; Return value - %rax
;----------------------------------------------------------------------
sum_until_zero:
    xor  rdi, rdi   ; %rdi is counter
    inc rdi         ; skip rbp pushed in stack
    xor  rax, rax   ; %rax is sum
    jmp check_condition

loop:
    add rax, rsi    ; sum += next_argument
    
check_condition:
    inc rdi         ; inc counter. Is needed in first iteration to skip 
                    ; return address, stored in stack
    mov  rsi, [rsp + rdi*8] ; %rsi is temporal register
    test rsi, rsi ; if (rsi)
    jne loop      ;    goto loop;
    ret

    

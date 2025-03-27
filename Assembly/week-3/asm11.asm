section .bss
    operand1 resq 1    ; Changed to resq for 64-bit integers
    operand2 resq 1
    ans resq 1
    choice resb 8      ; Kept as resb since we read a string

section .data
    menu db "Choose one of the following operations", 0xa
    add_menu db "1. Add", 0xa
    sub_menu db "2. Subtract", 0xa
    mul_menu db "3. Multiply", 0xa
    div_menu db "4. Divide", 0xa
    choice_menu db "Your choice: ", 0x20
    op1_menu db "Please enter the first operand: ", 0x20
    op2_menu db "Please enter the second operand: ", 0x20
    ans_menu db "Answer is: ", 0x20
    space db 0x20
    endline db 0xa

section .text
    global _start

; read(fd=rdi, buf=rsi, cnt=rdx) -> rax
read:
    push rbp
    mov rbp, rsp
    xor rax, rax    ; syscall: read
    syscall
    leave
    ret

; write(fd=rdi, buf=rsi, cnt=rdx)
write:
    push rbp
    mov rbp, rsp
    mov rax, 1      ; syscall: write
    syscall
    leave
    ret

; atoi(ptr=rdi) -> rax
atoi:
    push rbp
    mov rbp, rsp
    push rbx        ; Save callee-saved register
    xor rax, rax    ; Result
    xor rbx, rbx    ; Counter
loop_atoi:
    movzx rcx, byte [rdi + rbx]
    test rcx, rcx
    je end_atoi
    sub rcx, 48     ; ASCII to digit
    imul rax, 10
    add rax, rcx
    inc rbx
    jmp loop_atoi
end_atoi:
    pop rbx
    leave
    ret

; string(val=rdi, buf=rsi) -> rax (head), rdx (length)
string:
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, 7      ; Buffer offset
    test rdi, rdi   ; Handle 0 case
    jnz loop_string
    mov byte [rsi], '0'
    lea rax, [rsi]
    mov rdx, 1
    jmp end_string_done
loop_string:
    test rdi, rdi
    je end_string
    xor rdx, rdx
    mov rax, rdi
    mov rcx, 10
    idiv rcx
    mov rdi, rax
    add rdx, 48
    mov [rsi + rbx], dl
    dec rbx
    jmp loop_string
end_string:
    inc rbx
    lea rax, [rsi + rbx]
    mov rdx, 8
    sub rdx, rbx
end_string_done:
    mov [rax + rdx], byte 0xa
    inc rdx
    pop rbx
    leave
    ret

; read_until_space_or_endline(fd=rdi, buf=rsi)
read_until_space_or_endline:
    push rbp
    mov rbp, rsp
    push rbx
    mov rbx, rsi    ; Save buffer pointer
loop_read:
    mov rdx, 1
    call read
    movzx rcx, byte [space]
    cmp [rsi], cl
    je end_read
    movzx rcx, byte [endline]
    cmp [rsi], cl
    je end_read
    inc rsi
    jmp loop_read
end_read:
    mov [rsi], byte 0
    pop rbx
    leave
    ret

display_menu:
    push rbp
    mov rbp, rsp
    mov rdi, 1      ; stdout
    lea rsi, [menu]
    mov rdx, 39
    call write
    mov rdi, 1
    lea rsi, [add_menu]
    mov rdx, 7
    call write
    mov rdi, 1
    lea rsi, [sub_menu]
    mov rdx, 12
    call write
    mov rdi, 1
    lea rsi, [mul_menu]
    mov rdx, 12
    call write
    mov rdi, 1
    lea rsi, [div_menu]
    mov rdx, 10
    call write
    mov rdi, 1
    lea rsi, [choice_menu]
    mov rdx, 14
    call write
    leave
    ret

read_operand:
    push rbp
    mov rbp, rsp
    mov rdi, 1
    lea rsi, [op1_menu]
    mov rdx, 33
    call write
    mov rdi, 0      ; stdin
    lea rsi, [operand1]
    call read_until_space_or_endline
    lea rdi, [operand1]
    call atoi
    mov [operand1], rax
    mov rdi, 1
    lea rsi, [op2_menu]
    mov rdx, 34
    call write
    mov rdi, 0
    lea rsi, [operand2]
    call read_until_space_or_endline
    lea rdi, [operand2]
    call atoi
    mov [operand2], rax
    leave
    ret

do_add:
    push rbp
    mov rbp, rsp
    mov rax, [operand1]
    add rax, [operand2]
    mov [ans], rax
    leave
    ret

do_sub:
    push rbp
    mov rbp, rsp
    mov rax, [operand1]
    sub rax, [operand2]
    mov [ans], rax
    leave
    ret

do_mul:
    push rbp
    mov rbp, rsp
    mov rax, [operand1]
    imul rax, [operand2]  ; imul for signed multiplication
    mov [ans], rax
    leave
    ret

do_div:
    push rbp
    mov rbp, rsp
    mov rax, [operand1]
    cqo               ; Sign-extend rax into rdx:rax for division
    idiv qword [operand2]  ; Signed division
    mov [ans], rax
    leave
    ret

print_ans:
    push rbp
    mov rbp, rsp
    mov rdi, 1
    lea rsi, [ans_menu]
    mov rdx, 12
    call write
    mov rdi, [ans]
    lea rsi, [ans]
    call string
    mov rdi, 1
    mov rsi, rax
    call write
    mov rdi, 1
    lea rsi, [endline]
    mov rdx, 1
    call write
    leave
    ret

_start:
    call display_menu
    mov rdi, 0
    lea rsi, [choice]
    call read_until_space_or_endline

    call read_operand

    movzx rax, byte [choice]
    cmp rax, '1'
    je do_add_call
    cmp rax, '2'
    je do_sub_call
    cmp rax, '3'
    je do_mul_call
    cmp rax, '4'
    je do_div_call
    jmp finish       ; Invalid choice, just finish

do_add_call:
    call do_add
    jmp finish
do_sub_call:
    call do_sub
    jmp finish
do_mul_call:
    call do_mul
    jmp finish
do_div_call:
    call do_div

finish:
    call print_ans
    mov rax, 60      ; syscall: exit
    xor rdi, rdi     ; status 0
    syscall
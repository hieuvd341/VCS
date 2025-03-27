section .bss
    arr resq 100
    n resq 1
    maxx resq 1

section .data
    endline db 0xa
    space db 0x20

section .text
    global _start

read:
    push rbp
    mov rbp, rsp
    xor rax, rax
    syscall
    leave
    ret

write:
    push rbp
    mov rbp, rsp
    mov rax, 1
    syscall
    leave
    ret

atoi:
    push rbp
    mov rbp, rsp
    mov r10, 0
    xor rax, rax
loop_atoi:
    movzx r9, BYTE[rdi + r10]
    test r9, r9
    je end_atoi
    sub r9, 48
    imul rax, 10
    add rax, r9
    inc r10
    jmp loop_atoi
end_atoi:
    leave
    ret

string:
    push rbp
    mov rbp, rsp
    mov r9, 15
loop_string:
    test rdi, rdi
    je end_string
    xor rdx, rdx
    mov rax, rdi
    mov r10, 10
    idiv r10
    mov rdi, rax
    add rdx, 48
    mov BYTE [rsi + r9], dl
    dec r9
    jmp loop_string
end_string:
    inc r9
    lea rax, [rsi + r9]
    mov r10, 16
    sub r10, r9
    mov rdx, r10
    mov BYTE [rax + rdx], 0xa
    inc rdx
    leave
    ret

read_until_space_or_endline:
    push rbp
    mov rbp, rsp
loop_read:
    mov rdx, 1
    call read
    mov r10b, BYTE [space]
    cmp BYTE [rsi], r10b
    je end_read
    mov r10b, BYTE [endline]
    cmp BYTE [rsi], r10b
    je end_read
    inc rsi
    jmp loop_read
end_read:
    mov BYTE [rsi], 0
    leave
    ret

_start:
    mov rdi, 0
    lea rsi, [n]
    call read_until_space_or_endline
    lea rdi, [n]
    call atoi
    mov QWORD [n], rax
    xor r9, r9
loop_read_arr:
    cmp r9b, BYTE [n]
    je end_read_arr
    xor rdi, rdi
    movzx r10, r9b
    imul r10, 0x8
    lea rsi, [arr + r10]
    push r9
    push r10
    call read_until_space_or_endline
    pop r10
    lea rdi, [arr + r10]
    push r10
    call atoi
    pop r10
    pop r9
    mov QWORD [arr + r10], rax
    cmp rax, QWORD [maxx]
    jg update_maxx
    inc r9b
    jmp loop_read_arr
update_maxx:
    mov QWORD [maxx], rax
    inc r9b
    jmp loop_read_arr
end_read_arr:
    mov rdi, QWORD [maxx]
    lea rsi, [maxx]
    call string
    xor rdi, rdi
    mov rsi, rax
    call write
    mov rdi, 0
    mov rax, 0x3c
    syscall
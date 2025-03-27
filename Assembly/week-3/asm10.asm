section .bss
    arr resq 100
    n resq 1
    summ_odd resq 1
    summ_even resq 1

section .data
    endline db 0xa
    space db 0x20
    string_odd db "Sum of odd numbers: "
    string_even db "Sum of even numbers: "

section .text
    global _start

; read(fd=rdi, buf=rsi, cnt=rdx)
read:
    push rbp
    mov rbp, rsp
    xor rax, rax        ; syscall: read
    syscall
    leave
    ret

; write(fd=rdi, buf=rsi, cnt=rdx)
write:
    push rbp
    mov rbp, rsp
    mov rax, 1          ; syscall: write
    syscall
    leave
    ret

; atoi(ptr=rdi) -> rax
atoi:
    push rbp
    mov rbp, rsp
    push rbx            ; Save callee-saved register
    xor rax, rax        ; Result
    xor rbx, rbx        ; Counter
loop_atoi:
    movzx rcx, byte [rdi + rbx]
    test rcx, rcx
    je end_atoi
    sub rcx, 48         ; ASCII to digit
    imul rax, 10
    add rax, rcx
    inc rbx
    jmp loop_atoi
end_atoi:
    pop rbx
    leave
    ret

; string(val=rdi, buf=rsi) -> rax (head of string), rdx (length)
string:
    push rbp
    mov rbp, rsp
    push rbx            ; Save callee-saved register
    mov rbx, 7          ; Buffer offset
loop_string:
    test rdi, rdi
    je end_string
    xor rdx, rdx
    mov rax, rdi
    mov rcx, 10
    idiv rcx            ; rax = quotient, rdx = remainder
    mov rdi, rax
    add rdx, 48         ; Digit to ASCII
    mov [rsi + rbx], dl
    dec rbx
    jmp loop_string
end_string:
    inc rbx
    lea rax, [rsi + rbx] ; Head of string
    mov rdx, 8
    sub rdx, rbx        ; Length of string
    mov [rax + rdx], byte 0xa ; Append newline
    inc rdx             ; Include newline in length
    pop rbx
    leave
    ret

; read_until_space_or_endline(fd=rdi, buf=rsi)
read_until_space_or_endline:
    push rbp
    mov rbp, rsp
    push rbx            ; Save callee-saved register
    mov rbx, rsi        ; Save original buffer pointer
loop_read:
    mov rdx, 1          ; Read 1 byte
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
    mov [rsi], byte 0   ; Null terminate
    pop rbx
    leave
    ret

_start:
    ; Read n
    mov rdi, 0          ; stdin
    lea rsi, [n]
    call read_until_space_or_endline
    lea rdi, [n]
    call atoi
    mov [n], rax

    ; Read array and compute sums
    xor rbx, rbx        ; Counter (callee-saved)
loop_read_arr:
    cmp bl, [n]
    je end_read_arr
    mov rdi, 0          ; stdin
    movzx rcx, bl
    shl rcx, 3          ; rcx = rbx * 8
    lea rsi, [arr + rcx]
    call read_until_space_or_endline
    lea rdi, [arr + rcx]
    call atoi
    mov [arr + rcx], rax
    mov rcx, rax
    and rcx, 1          ; Check if odd
    jnz update_odd
update_even:
    add [summ_even], rax
    jmp continue
update_odd:
    add [summ_odd], rax
continue:
    inc bl
    jmp loop_read_arr
end_read_arr:

    ; Print "Sum of odd numbers: "
    mov rdi, 1          ; stdout
    lea rsi, [string_odd]
    mov rdx, 20
    call write

    ; Print sum_odd
    mov rdi, [summ_odd]
    lea rsi, [summ_odd]
    call string
	
    mov rdi, 1          ; stdout
    mov rsi, rax
    call write

    ; Print newline
    mov rdi, 1
    lea rsi, [endline]
    mov rdx, 1
    call write

    ; Print "Sum of even numbers: "
    mov rdi, 1
    lea rsi, [string_even]
    mov rdx, 21
    call write

    ; Print sum_even
    mov rdi, [summ_even]
    lea rsi, [summ_even]
    call string
    mov rdi, 1
    mov rsi, rax
    call write

    ; Print newline
    mov rdi, 1
    lea rsi, [endline]
    mov rdx, 1
    call write

    ; Exit
    mov rax, 60         ; syscall: exit
    xor rdi, rdi        ; status 0
    syscall
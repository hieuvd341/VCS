section .bss
    S resb 100
    C resb 10
    positions resb 1000
    count resq 1
    reverse_string_count resb 100
    string_count resb 100
    tmp resb 10
    reverse_tmp resb 10   
section .data
    msg1 db "Enter S: ", 0
    msg2 db "Enter C: ", 0
    newline db 10
    space db " "

section .text
    global _start

_start:
    ; Print msg1 
    mov rax , 1
    mov rdi , 1
    mov rsi , msg1
    mov rdx , 9
    syscall

    ; Read S
    mov rax , 0
    mov rdi , 0
    mov rsi , S
    mov rdx , 100
    syscall

    ; null terminate S
    mov byte [S + rax - 1], 0



    ; Print msg2
    mov rax , 1
    mov rdi , 1
    mov rsi , msg2
    mov rdx , 9
    syscall

    ; Read C
    mov rax , 0
    mov rdi , 0
    mov rsi , C
    mov rdx , 10
    syscall

    ; null terminate C
    mov byte [C + rax - 1], 0

    ; set up registers
    xor rcx , rcx                               ; count = 0
    xor rdi , rdi                               
    call find_positions

    ; Print count
    mov rdi , qword [count]
    mov r8 , reverse_string_count
    call int_to_string
    
    mov rdx , rax
    mov rdi , 1
    mov rax , 1
    mov rsi , string_count
    syscall

    mov rax , 1
    mov rdi , 1
    mov rsi , newline
    mov rdx , 1
    syscall 
    ; print positions
    call print_positions 
    ; exit
    mov rax , 60
    mov rdi , 0
    syscall 
    ret

find_positions:
    mov al , [S + rdi]
    cmp al , 0
    je end
    push rdi
    xor rsi , rsi

inner_loop:
    mov al , [S + rdi]
    inc rdi

    mov bl , [C + rsi]
    inc rsi
    cmp bl , 0
    je found

    cmp al , bl
    je inner_loop
    pop rdi
    inc rdi
    jmp find_positions

found:
    inc rcx
    pop rdi
    ; store position
    mov qword [positions + 8 * rcx - 8], rdi
    
    inc rdi
    jmp find_positions

end:
    ; store count
    mov qword [count], rcx
    ret 

; int store in rdi
; rsi store the length of string
; r8 store the reverse_buffer
int_to_string:
    mov rax , rdi
    xor rsi , rsi
    cmp rdi , 0
    je rdi_zero
int_to_string_loop:
    cmp rax , 0
    je int_to_string_end
    mov rdx , 0
    mov rcx , 10
    div rcx
    add rdx , '0'
    mov byte [r8 + rsi], dl
    inc rsi
    jmp int_to_string_loop


int_to_string_end:
    mov rdi , reverse_string_count
    mov rcx , string_count
    call reverse_string
    ret

rdi_zero:
    add rdi , 0x30
    mov byte [r8 + rsi] , dil
    ret

; reverse the string
; rsi store the length of the string
; rdi store the reverse_buffer
; rcx store the buffer
; return the length of the buffer
reverse_string:
    xor rdx , rdx
reverse_string_loop:    
    mov al , byte [rdi + rsi - 1] 
    cmp al , 0
    jz reverse_string_done
    mov byte [rcx + rdx] , al
    inc rdx
    dec rsi
    jmp reverse_string_loop
reverse_string_done:
    mov rax , rdx
    ret 

print_positions:
    xor r9 , r9
print_positions_loop:
    mov r10 , qword [positions + 8 * r9]
    cmp r9 , [count]
    je print_positions_done
    
    cmp r10 , 10
    jge two_chars

    mov rsi , 1
    mov r8 , tmp
    mov rdi , r10
    call int_to_string
    mov rax , 1
    mov rdi , 1
    mov rsi , tmp
    mov rdx , 1
    syscall
  
    mov rax , 1
    mov rdi , 1
    mov rsi , space
    mov rdx , 1
    syscall
    inc r9
    jmp print_positions_loop

two_chars:
    mov rdi , r10
    mov rsi , 2
    mov r8, tmp
    call int_to_string
    
    mov rsi , 2
    mov rdi , tmp
    mov rcx , reverse_tmp
    call reverse_string 
 
    mov rax , 1
    mov rdi , 1
    mov rsi , reverse_tmp
    mov rdx , 2
    syscall
    
    mov rax , 1
    mov rdi , 1
    mov rsi , space
    mov rdx , 1
    syscall

    inc r9
    jmp print_positions_loop
    
print_positions_done:
    mov rax , 1
    mov rdi , 1
    mov rsi , newline
    mov rdx , 1
    syscall
    ret

section .data

section .bss

	msg resb 33
section .text
	global _start

_start:
	; read
	mov rax , 0
	mov rdi , 0
	mov rsi , msg
	mov rdx , 32
	syscall

	; insert null byte
	mov byte [rsi + rax] , 0
	; write
	mov rdx , rax
	mov rax , 1
	mov rdi , 1
	mov rsi , msg
	syscall
	
	; exit
	mov rax , 60
	mov rdi , 0
	syscall 

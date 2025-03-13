section .bss
	number1 resb 12
	number2 resb 12
	reverse_result resb 12
	result resb 12
section .data
	msg1 db "Input the first number: "
	msg2 db "Input the second number: "
	msg3 db "Result: "
	error_message db "Invalid number!", 10

section .text
	global _start

_start:
	; write msg1
	mov rax , 1
	mov rdi , 1
	mov rsi , msg1
	mov rdx , 24
	syscall

	; input number1
	mov rax , 0
	mov rdi , 0
	mov rsi , number1
	mov rdx , 11
	syscall
	
	; null byte terminated
	mov byte [rsi + rax] , 0

	mov rcx , 0
	mov rdi , 0
	; string to int
	call string_to_int

	mov r8, rax


	; write msg2
	mov rax , 1
	mov rdi , 1
	mov rsi , msg2
	mov rdx , 25
	syscall

	; input number2
	mov rax , 0
	mov rdi , 0
	mov rsi , number2
	mov rdx , 11
	syscall

	; null byte terminated
	mov byte [rsi + rax] , 0


	mov rcx , 0
	mov rdi , 0
	; string to int
	call string_to_int

	mov rdi , rax
	add rdi , r8

	call int_to_string

	; write msg3
	mov rax , 1
	mov rdi , 1
	mov rsi , msg3
	mov rdx , 8
	syscall

	; write result
	mov rax , 1
	mov rdi , 1
	mov rsi , result
	mov rdx , r9
	syscall

	; exit
	mov rax , 60
	mov rdi , 0
	syscall


string_to_int:
	movzx rdx , byte [rsi + rax -1]
	cmp rdx , 10
	jne string_to_int_loop
	sub rax , 1

string_to_int_loop:
	cmp rdi , rax
	je string_to_int_done
	
	movzx rdx , byte [rsi + rdi]
	cmp rdx , 0x30
	jb error_message_log
	
	cmp rdx , 0x39
	jg error_message_log
	
	sub rdx , 0x30
	
	; store to rcx
	imul rcx , 10
	add rcx , rdx
	
	add rdi , 1
	jmp string_to_int_loop

error_message_log:
	mov rax , 1
	mov rdi , 1
	mov rsi , error_message
	mov rdx , 16
	syscall

	; exit
	mov rax , 60
	mov rdi , 0
	syscall 	
	
string_to_int_done:
	mov rax , rcx
	ret	


	
int_to_string:
	mov r8 , 0									; store length
	mov rax , rdi
	mov rsi , 0
int_to_string_loop:
	cmp rax , 0
	je int_to_string_done
	
	mov rdx , 0
	mov rcx , 10
	div rcx 
	
	; Quotient stored in rax
	; remainder stored in rdx

	add rdx , 0x30
	mov byte [reverse_result + rsi] , dl
	add r8 , 1
	add rsi , 1

	jmp int_to_string_loop


int_to_string_done:
	call reverse_string
	ret	


reverse_string:
	mov r9 , 0
reverse_string_loop:
	cmp r8 , 0
	je reverse_string_done
	

	movzx rdi , byte [reverse_result + r8 - 1]
	mov byte [result + r9] , dil
	add r9 , 1
	sub r8 , 1
	jmp reverse_string_loop

reverse_string_done:
	ret
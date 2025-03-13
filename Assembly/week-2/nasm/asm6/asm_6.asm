section .bss
	input_str resb 256
	result resb 256
section .data
	msg1 db "Input the string you want to reverse: "
section .text
	global _start

_start:
	mov rax , 1
	mov rdi , 1
	mov rsi , msg1
	mov rdx , 38
	syscall

	mov rax , 0
	mov rdi , 0 
	mov rsi , input_str
	mov rdx , 256
	syscall	
	
	mov rdi , rax
	mov rsi , input_str
	mov rdx , result
	call reverse_string
	
	
	; print result
	mov rdx , rax
	mov rax , 1
	mov rdi , 1
	mov rsi , result
	syscall

	; exit
	mov rax , 60
	mov rdi , 0
	syscall

reverse_string:
	xor rcx , rcx
reverse_string_loop:
	mov al , byte [rsi + rdi - 1]
	cmp al , 0
	je reverse_string_done
	mov byte [rdx + rcx] , al
	inc rcx
	dec rdi
	jmp reverse_string_loop


reverse_string_done:
	mov rax , rcx
	ret	

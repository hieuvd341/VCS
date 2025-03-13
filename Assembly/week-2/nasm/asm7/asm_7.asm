section .bss
	N resb 4
	reverse_result resb 100
	result resb 100	
section .data
	msg db "Input N: "
	newline db 10

section .text
	global _start

_start:
	mov rax , 1
	mov rdi , 1
	mov rsi , msg
	mov rdx , 9
	syscall

	mov rax , 0
	mov rdi , 0
	mov rsi , N
	mov rdx , 4
	syscall

	mov rdi , N
	mov rsi , rax
	call string_to_int
	
	mov rdi , rax
	call fibonacci
	
	; convert result to string
	mov rdi , rax
	mov rsi , reverse_result
	mov rdx , result
	call int_to_string
	
	; print the result
	mov rdx , rax
	mov rax , 1
	mov rdi , 1
	mov rsi , result
	syscall
	
	; print newline
	mov rax , 1
	mov rdi , 1
	mov rsi , newline
	mov rdx , 1
	syscall
	
	; exit
	mov rax , 60
	mov rdi , 0
	syscall

string_to_int:
	dec rsi
	xor rax , rax 
	xor rdx , rdx
	xor rbx , rbx
string_to_int_loop:
	mov bl , byte [rdi + rdx]
	cmp bl , 0xa
	je string_to_int_done
	inc rdx
	imul rax , 10
	sub rbx , 0x30
	add rax , rbx
	jmp string_to_int_loop

string_to_int_done:
	ret

; n stored in rdi
fibonacci:
	cmp rdi , 1
	je ret1

	cmp rdi , 2
	je ret1

	mov rsi , 2
	mov rax , 1
	mov rbx , 1
fibonacci_loop:
	cmp rsi , rdi 
	je fibonacci_done
	mov rcx , rbx
	add rbx , rax
	mov rax , rcx
	inc rsi
	jmp fibonacci_loop

fibonacci_done:
	mov rax , rbx
	ret
	
ret1:
	mov rax , 1
	ret


; rdi store integer number
; rsi store the reverse buffer
; rdx store the reverse buffer
int_to_string:
	push rdx
	mov rax , rdi
	xor r8 , r8
	cmp rdi , 0 
	je return_zero
	
int_to_string_loop:
	cmp rax , 0
	je int_to_string_end
	mov rdx , 0
	mov rcx , 10
	div rcx
	add rdx , '0'
	mov byte [rsi + r8]  , dl
	inc r8
	jmp int_to_string_loop

int_to_string_end:
	mov rax , r8
	; reverse the string
	mov rdi , rsi
	mov rsi , rax
	pop rdx
	call reverse_string
	ret
return_zero:
	add rdi , 0x30
	mov byte [r8 + rsi] , dil
	inc r8
	mov rax , r8
	ret			

; rdi store the buffer
; rsi store the length of string
; rdx store the reverse buffer
reverse_string:
	xor r8 , r8
reverse_string_loop:
	mov al , byte [rdi + rsi - 1]
	cmp rsi , 0
	je reverse_string_done
	dec rsi
	mov byte [rdx + r8] , al
	inc r8
	jmp reverse_string_loop

reverse_string_done:
	mov rax , r8
	ret
		

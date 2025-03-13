section .bss
	num1 resb 100
	num2 resb 100
	len1 resb 8
	len2 resb 8
	result resb 100
	reverse_result resb 100
section .data
	msg1 db "Input the first number: "
	msg2 db "Input the second number: "
	msg3 db "Result: "
	newline db 0x0A
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
	mov rsi , num1
	mov rdx , 100
	syscall
	
	mov byte [rsi + rax - 1] , 0
	; write msg2
	mov rax , 1
	mov rdi , 1
	mov rsi , msg2
	mov rdx , 25
	syscall

	; input number2
	mov rax , 0
	mov rdi , 0
	mov rsi , num2
	mov rdx , 100
	syscall
	mov byte [rsi + rax - 1] , 0

	; strlen of num1 
	mov rdi , num1
	call strlen
	mov qword [len1] , rax
	
	; strlen of num2 
	mov rdi , num2
	call strlen
	mov qword [len2] , rax

	; add big number
	mov rdi , num1
	mov rsi , num2
	mov rcx , qword [len1]
	mov rdx , qword [len2]
	call add_big_num
	
	; reverse the result
	mov rdi , rax
	mov rsi , result
	mov rdx , reverse_result
	call reverse_string
	
	push rax

	; write msg3
	mov rax , 1
	mov rdi , 1
	mov rsi , msg3
	mov rdx , 8
	syscall

	; write result
	pop rax
	mov rdx , rax
	mov rax , 1
	mov rdi , 1
	mov rsi , reverse_result
	syscall

	; print newline	
	mov rax , 1
	mov rdi , 1
	mov rsi , newline
	mov rdx , 1
	syscall

	; exit
	mov rdi , 0
	mov rax , 60
	syscall

; rdi store the string
strlen:
	xor rcx , rcx
strlen_loop:
	mov al , byte [rdi + rcx]
	cmp al , 0
	je strlen_done
	inc rcx 
	jmp strlen_loop
	
strlen_done:
	mov rax , rcx	
	ret
	
; rdi store num1
; rsi store num2	
; rcx store len1
; rdx store len2
add_big_num:
	xor rax , rax
	xor rbx , rbx
	xor r9 , r9			; counter
	xor r10, r10
add_big_num_loop:
	mov al , byte [rdi + rcx -1]
	cmp al , 0
	je num1_done

	mov bl , byte [rsi + rdx - 1]
	cmp bl , 0
	je num2_done
	
	sub al , 0x30
	sub bl , 0x30
	add al , bl
	add al , r10b
	mov r8 , 10

	push rdx
	xor rdx , rdx
	div r8
	
	add rdx , '0'
	mov r10 , rax
	mov byte [result + r9] , dl
	inc r9
	pop rdx
	dec rdx 
	dec rcx
	jmp add_big_num_loop		
		
num1_done:
num1_done_loop:
	mov al , byte [rsi + rdx -1]
	cmp al , 0
	je done
	sub al , 0x30
	add al , r10b
	mov r8 , 10
	push rdx
	xor rdx , rdx
	div r8
	add rdx , '0'
	mov r10 , rax
	mov byte [result + r9] , dl
	inc r9
	pop rdx
	dec rdx
	jmp num1_done_loop

num2_done:
num2_done_loop:
	mov al , byte [rdi + rcx - 1]
	cmp al , 0
	je done
	sub al , 0x30
	add al , r10b
	mov r8, 10
	xor rdx , rdx
	div r8
	add rdx , '0'
	mov r10 , rax
	mov byte [result + r9] , dl
	inc r9
	dec rcx
	jmp num2_done_loop
done:	
	; check if r10 is not 0
	cmp r10 , 0
	je done2
	; add r10 to result
	add r10 , '0'
	mov byte [result + r9] , r10b
	inc r9
done2:
    mov rax , r9	
	ret	

; rdi store the length of string
; rsi store the string
; rdx store the result
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
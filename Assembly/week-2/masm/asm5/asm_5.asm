option casemap:none
extrn printf: proc
extrn scanf: proc
extrn strlen: proc
extrn fgets: proc
extrn gets: proc

includelib msvcrt.lib
includelib vcruntime.lib
includelib ucrt.lib
includelib legacy_stdio_definitions.lib

.data
	format_in db "%100s", 0
	format_int db "%d", 10, 0
	format_char db "%c", 0
	format_positions db "%d ", 0
	newline db 10, 0
	space db ' '

	

.data?
	lenC dq 0
	count dq 0
	S db 101 dup(0)
	C db 11 dup(0)
	positions dq 20 dup(?)

.code
main proc
	sub rsp , 40h					; stack alignment

	; input S
	lea rcx , S
	call gets

	; input C
	lea rcx , format_in
	lea rdx , C
	call scanf

	; calculate length of C
	lea rcx , C
	call strlen
	mov [lenC] , rax

	; init value
	xor rdi , rdi					; i = 0
	xor r8 , r8					; counter = 0
	

main_loop:	
	lea rsi , C
	mov rdx , [lenC]

	mov al , byte ptr [rdi + S]
	cmp al , 0
	je done

	push rdi						; store i

check_substring:
	mov bl , byte ptr [rsi]
	cmp bl , 0
	je found

	mov al , byte ptr [rdi + S]
	cmp bl , al
	jne not_found

	inc rdi
	inc rsi
	dec rdx
	jnz check_substring
	


found:
	inc r8							; increase counter
	pop rdi							; restore position
	mov rax , r8 
	dec rax
	mov qword ptr [positions + rax * 8] , rdi
	inc rdi
	jmp main_loop

not_found:
	pop rdi							; restore position
	inc rdi
	jmp main_loop

done:
	mov rbx , r8					; rbx store counter
									; becasuse r8 will be changed after "test" instruction
	; print count
	mov rdx , r8
	lea rcx , format_int
	call printf

	test rbx , rbx
	jz exit_main

	xor rdi , rdi

print_positions:
	cmp rdi , rbx
	je exit_main

	mov rdx , [positions + rdi * 8]
	lea rcx , format_positions
 	call printf

	inc rdi
	jmp print_positions




exit_main:
	lea rcx , newline
	call printf

	add rsp , 40h
	ret
main endp

end
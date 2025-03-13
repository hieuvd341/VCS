option casemap: none
extrn printf: proc
extrn scanf: proc
extrn strlen: proc
extrn exit: proc

includelib msvcrt.lib
includelib vcruntime.lib
includelib ucrt.lib
includelib legacy_stdio_definitions.lib

.data
	invalid_len_message db "Invalid length!", 10, 0
	fmt_in db "%20s", 0
	fmt_out db "%s", 0
	num1 db 21 dup(0)
	num2 db 21 dup(0)
	num1Len dq 0
	num2Len dq 0
	result db 21 dup(0)
	reverse_result db 21 dup(0)

.code

reverse_string proc
	lea rcx , result
	call strlen

	xor rdi , rdi
reverse_string_loop:
	test rax , rax
	jz done

	mov bl , byte ptr [result + rax - 1]
	mov byte ptr [reverse_result + rdi] , bl
	dec rax 
	inc rdi
	jmp reverse_string_loop

done: 
	ret



reverse_string endp

; rcx stored num1 address
; rdx stored num2 address
add_big_num proc
	; rdi stored num1 length
	lea rcx , num1
	call strlen
	mov rdi , rax
	cmp rdi , 20
	ja invalid_length
	mov qword ptr [num1Len] , rdi

	; rsi stored num2 length
	lea rcx , num2
	call strlen
	mov rsi , rax
	cmp rsi , 20
	ja invalid_length

	mov qword ptr [num2Len] , rsi
	
	xor rcx , rcx									; remainder 
	xor rax , rax									
	xor rbx , rbx
	xor rsi , rsi									; counter

loop_add:
	; take the last character of num1
	mov rdi , qword ptr [num1Len]
	cmp rdi , 0
	je done_num1

	sub rdi , 1
	mov qword ptr [num1Len] , rdi

	mov al , byte ptr [rdi + num1]
	sub al , 30h

	; take the last character of num2
	mov rdi , qword ptr [num2Len]
	cmp rdi , 0
	je done_num2

	sub rdi , 1
	mov qword ptr [num2Len] , rdi
	mov bl , byte ptr [rdi + num2]
	sub bl , 30h

	add al , bl
	add al , cl
	mov ebx , 10
	xor edx , edx
	div ebx

	mov ecx , eax
	add dl , 30h
	mov byte ptr [rsi + result] , dl
	inc rsi
	jmp loop_add

done_num2:
	; restore
	mov rdi , qword ptr [num1Len]
	inc rdi
	mov qword ptr [num1Len] , rdi
done_num2_loop:
	mov rdi , qword ptr [num1Len]
	cmp rdi , 0
	je done

	sub rdi , 1
	mov qword ptr [num1Len] , rdi

	mov al , byte ptr [rdi + num1]

	sub al , 30h
	add al , cl
	mov ebx , 10
	xor edx , edx
	div ebx

	mov ecx , eax
	add dl , 30h
	mov byte ptr [rsi + result] , dl
	inc rsi
	jmp done_num2_loop

done_num1:
	mov rdi , qword ptr [num2Len]
	cmp rdi , 0
	je done

	sub rdi , 1
	mov qword ptr [num2Len] , rdi
	mov al , byte ptr [rdi + num2]
	sub al , 30h

	add al , cl

	mov ebx , 10
	xor edx , edx
	div ebx

	mov ecx , eax
	add dl , 30h
	mov byte ptr [rsi + result] , dl
	inc rsi
	jmp done_num1

done:
	cmp cl , 0
	je finish_add
	add cl , 30h
	mov byte ptr [rsi + result] , cl

finish_add:
	call reverse_string
	ret

invalid_length:
	lea rcx , invalid_len_message
	call printf

	mov rcx , 0
	call exit

add_big_num endp

main proc
	sub rsp , 40h

	; input num1
	lea rcx , fmt_in
	lea rdx , num1
	call scanf

	; input num2
	lea rcx , fmt_in
	lea rdx , num2
	call scanf

	lea rcx , num1
	lea rdx , num2
	call add_big_num

	lea rcx , fmt_out
	lea rdx , reverse_result
	call printf

	add rsp , 40h
	ret
main endp
end
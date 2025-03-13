option casemap: none
extrn printf: proc
extrn scanf: proc
extrn strlen: proc

includelib msvcrt.lib
includelib vcruntime.lib
includelib ucrt.lib
includelib legacy_stdio_definitions.lib

.data
	fmt_s db "%256s", 0
	fmt_print db "%s" , 0

.data?
	input_str db 256 dup (?)
	reverse_str db 256 dup(?)

.code
reverseString proc
	lea rcx , input_str
	call strlen

	mov rdi , rax
	xor rsi , rsi

reverseString_loop:
	
	test rdi , rdi
	jz reverseString_done

	mov al , byte ptr [input_str + rdi - 1]
	mov byte ptr [reverse_str + rsi] , al

	dec rdi 
	inc rsi

	jmp reverseString_loop

reverseString_done:
	mov byte ptr [reverse_str + rsi] , 0
	ret
reverseString endp

main proc
	sub rsp , 40h

	lea rcx , fmt_s
	lea rdx , input_str
	call scanf

	lea rcx , input_str
	call reverseString
	
	lea rcx , fmt_print
	lea rdx , reverse_str
	call printf

	add rsp , 40h
	ret

main endp
end



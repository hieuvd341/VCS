option casemap:none

extrn printf:proc
extrn scanf:proc

includelib msvcrt.lib
includelib vcruntime.lib
includelib ucrt.lib
includelib legacy_stdio_definitions.lib

.data
	fmt db "%32s", 0
	fmt2 db "%s", 0
.data?
	buffer db 100 dup(0)

.code
main proc
	sub rsp , 40h

	lea rcx , fmt
	lea rdx , buffer
	call scanf

	lea rdi , buffer
main_loop:
	mov al , byte ptr[rdi]
	cmp al , 0
	je done

	cmp al , 'a'
	jb main_skip

	cmp al , 'z'
	ja main_skip

	sub byte ptr [rdi], 32
main_skip:
	inc rdi
	jmp main_loop

done:
	lea rcx , fmt2
	lea rdx , buffer
	call printf

	add rsp , 40h
	ret 
main endp
end
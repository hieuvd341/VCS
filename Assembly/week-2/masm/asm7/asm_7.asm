option casemap: none
extrn printf: proc
extrn scanf: proc
extrn strlen: proc

includelib msvcrt.lib
includelib vcruntime.lib
includelib ucrt.lib
includelib legacy_stdio_definitions.lib

.data
	fmt_int db "%d" , 0
	num1 db 100 dup(0)
	num2 db 100 dup(0)

.data?
	N dd , 0


.code

fibonacci proc
	mov rax , 1
	mov rbx , 1

	cmp rcx , 1
	je done
	cmp rcx , 2
	je done

	mov rdi , 2
fibonacci_loop:
	cmp rdi , rcx
	je done
	
	mov rdx , rax
	mov rax , rbx
	add rbx , rdx
	
	inc rdi
	jmp fibonacci_loop
	
done:
	mov rax , rbx
	ret 
fibonacci endp

main proc
	sub rsp , 40h

	lea rcx , fmt_int
	lea rdx , N
	call scanf

	
	mov ecx , [N]
	cmp ecx , 0
	je end_main

	cmp ecx , 45
	ja end_main

	call fibonacci

	lea rcx , fmt_int
	mov rdx , rax
	call printf

end_main:
	add rsp , 40h
	ret
main endp
end
extrn printf: proc
includelib msvcrt.lib
includelib vcruntime.lib
includelib ucrt.lib
includelib legacy_stdio_definitions.lib

.data
	message db "Hello, world", 10, 0
	fmt db "%s", 0

.code
main proc
	sub rsp , 40h
	lea rcx , fmt
	lea rdx , message
	call printf
	add rsp , 40h
	ret
main endp

end
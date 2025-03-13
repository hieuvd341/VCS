; Definition of the data segment
section .data
	msg db "Hello, world!", 10
; Definition of the text segment
section .text

	; mark the `_start` symbol as global so that is it visible to the linker
	global _start
; Entry point
_start:
	mov rax , 1	; write syscall
	mov rdi , 1	; stdout	
	mov rsi , msg	; buffer
	mov rdx , 14	; count
	syscall
	
	mov rax , 60	; exit syscall
	mov rdi , 0	; error code
	syscall

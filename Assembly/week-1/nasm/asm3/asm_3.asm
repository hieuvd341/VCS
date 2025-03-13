section .bss
    msg resb 33   ; Reserve 33 bytes for input

section .text
    global _start

_start:
    	; Read user input
	mov rax, 0       ; syscall: sys_read
    	mov rdi, 0       ; file descriptor: stdin
    	mov rsi, msg     ; buffer to store input
    	mov rdx, 32      ; max bytes to read
    	syscall

    	; Null terminate input 
    	mov byte [rsi + rax], 0  
	
    	mov rcx, 0       ; Counter
    	call upperCase   ; Convert lowercase to uppercase
   
	; write
	mov rax , 1
	mov rdi , 1
	mov rsi , msg
	mov rdx , 32
	syscall 

	; exit
	mov rax , 60
	mov rdi , 0
	syscall
	ret
upperCase:
upperCase_loop:
    	cmp rcx, rax
	je upperCase_done  ; If reached end of input, return
	
    	movzx rdi, byte [rsi + rcx]  ; Load byte into rdi with zero extension

    	cmp rdi, 0x61    ; Check if character >= 'a'
    	jb upperCase_next

    	cmp rdi, 0x7A    ; Check if character <= 'z'
    	jg upperCase_next

    	sub dil, 32      ; Convert lowercase to uppercase
    	mov byte [rsi + rcx], dil  ; Store modified character back

upperCase_next:
    	add rcx, 1
    	jmp upperCase_loop

upperCase_done:
    	ret


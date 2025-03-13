option casemap:none

extrn printf:PROC
extrn scanf:PROC   

includelib msvcrt.lib
includelib vcruntime.lib
includelib ucrt.lib
includelib legacy_stdio_definitions.lib

.data
    format_in db "%u %u", 0
    format_out db "Tong hai so la: %u", 10, 0
    
.data?
    num1 dd 0
    num2 dd 0    

.code
main PROC
    sub rsp , 20h             

    lea rcx , format_in
    lea rdx , num1
    lea r8 , num2
    call scanf

    mov eax , [num1]
    add eax , [num2]

    lea rcx , format_out
    mov edx, eax
    call printf

    add rsp , 20h             
    ret

main ENDP
END

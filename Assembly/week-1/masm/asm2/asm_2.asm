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
    buffer db 32 dup(0) 
.code
main proc
    sub rsp , 40h 
    lea rcx, fmt
    lea rdx, buffer 
    call scanf 
    lea rcx, fmt2
    lea rdx, buffer
    call printf
    add rsp , 40h
    ret
main endp

end

.386
.model flat, stdcall
option casemap:none

; --- Include standard MASM32 files ---
include C:\masm32\include\windows.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\user32.inc

includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\user32.lib

;------------------------------------------------------------------------------
; Define any missing constants if your windows.inc doesn't already have them
; (If windows.inc already defines these, you can remove the lines below)
;------------------------------------------------------------------------------

ID_EDIT_INPUT    equ 1000
ID_EDIT_OUTPUT   equ 1001
hInstance_offset equ 14h


SW_SHOWDEFAULT   equ 10

; Common icon/cursor constants (usually in windows.inc)
IDI_APPLICATION  equ 32512
IDC_ARROW        equ 32512
COLOR_BTNFACE    equ 15

;------------------------------------------------------------------------------
; Data
;------------------------------------------------------------------------------
.data
AppName     db  "MASM32 Text Reverse",0
ClassName   db  "TextReverseClass",0
EditInitTxt db  0                  ; Initial text (empty)
ReverseBuf  db  256 dup (?)           ; Buffer for original text

; We'll store the HINSTANCE globally so WndProc can use it
ghInstance  dd  ?

;------------------------------------------------------------------------------
; Uninitialized data
;------------------------------------------------------------------------------
.data?
wc      WNDCLASSEX <>
msg     MSG        <>
hMain   dd        ?
szEdit  db  5 dup (?)  ; Will hold "EDIT",0

;------------------------------------------------------------------------------
; Prototypes
;------------------------------------------------------------------------------
WndProc proto :DWORD,:DWORD,:DWORD,:DWORD
reverse_string proto :DWORD, :DWORD

;------------------------------------------------------------------------------
; reverse_string:
;   - pSrc  = pointer to source string (null-terminated)
;   - pDest = pointer to destination buffer
;------------------------------------------------------------------------------
.code
reverse_string proc uses esi edi pSrc:DWORD, pDest:DWORD
    mov esi, pSrc
    mov edi, pDest

    ; Find length of source string
    xor eax, eax
calc_len:
    cmp byte ptr [esi+eax], 0
    je  len_found
    inc eax
    jmp calc_len

len_found:
    ; EAX = length (not counting null terminator)
    mov ecx, eax      ; ECX = length
    dec ecx           ; index of last char
    xor ebx, ebx      ; EBX = forward index

rev_loop:
    cmp ebx, eax
    jge done
    mov dl, [esi+ecx] ; get character from the end
    mov [edi+ebx], dl
    dec ecx
    inc ebx
    jmp rev_loop

done:
    ; Terminate the destination string
    mov byte ptr [edi+ebx], 0
    ret
reverse_string endp

;------------------------------------------------------------------------------
; WndProc: Window procedure
;------------------------------------------------------------------------------
WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    LOCAL hEditInput:DWORD
    LOCAL hEditOutput:DWORD

    .IF uMsg == WM_CREATE

        ; Create Edit #1 (input)
        invoke CreateWindowEx, \
               0, \
               ADDR szEdit, \
               ADDR EditInitTxt, \
               WS_CHILD or WS_VISIBLE or WS_BORDER or ES_AUTOHSCROLL, \
               10, 10, 300, 25, \
               hWnd, \
               ID_EDIT_INPUT, \
               ghInstance, \
               0

        ; Create Edit #2 (output, read-only)
        invoke CreateWindowEx, \
               0, \
               ADDR szEdit, \
               ADDR EditInitTxt, \
               WS_CHILD or WS_VISIBLE or WS_BORDER or ES_AUTOHSCROLL or ES_READONLY, \
               10, 50, 300, 25, \
               hWnd, \
               ID_EDIT_OUTPUT, \
               ghInstance, \
               0

        xor eax, eax
        ret

    .ELSEIF uMsg == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh   ; low word = control ID
        .IF eax == ID_EDIT_INPUT
            ; high word = notification code
            mov eax, wParam
            shr eax, 16
            .IF eax == EN_CHANGE
                ; Retrieve text from input, reverse it, display in output

                ; 1) Get handle to input Edit
                invoke GetDlgItem, hWnd, ID_EDIT_INPUT
                mov hEditInput, eax

                ; 2) Get length (+1 for null terminator)
                invoke GetWindowTextLength, hEditInput
                inc eax
                push eax  ; keep length on stack if needed

                ; 3) Get text into ReverseBuf
                invoke GetWindowText, hEditInput, ADDR ReverseBuf, eax

                ; 4) Allocate local buffer on stack for reversed text
                sub esp, 256
                mov edi, esp

                ; 5) reverse_string( ReverseBuf, local_stack_buffer )
                push edi
                push OFFSET ReverseBuf
                call reverse_string

                ; 6) Set reversed text in output Edit
                invoke GetDlgItem, hWnd, ID_EDIT_OUTPUT
                mov hEditOutput, eax

                push edi
                push hEditOutput
                call SetWindowText

                ; 7) Restore stack
                add esp, 256
            .ENDIF
        .ENDIF
        xor eax, eax
        ret

    .ELSEIF uMsg == WM_DESTROY
        invoke PostQuitMessage, 0
        xor eax, eax
        ret

    .ELSE
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
    .ENDIF

WndProc endp

;------------------------------------------------------------------------------
; WinMain: entry point for a 32-bit Windows GUI program
;------------------------------------------------------------------------------
WinMain proc
    LOCAL hInst:DWORD

    ; 1) Get instance handle
    invoke GetModuleHandle, 0
    mov hInst, eax
    mov ghInstance, eax        ; store globally so WndProc can use it

    ; 2) Copy "EDIT" string into szEdit
    mov byte ptr [szEdit], 'E'
    mov byte ptr [szEdit+1], 'D'
    mov byte ptr [szEdit+2], 'I'
    mov byte ptr [szEdit+3], 'T'
    mov byte ptr [szEdit+4], 0

    ; 3) Fill in WNDCLASSEX
    mov wc.cbSize, SIZEOF WNDCLASSEX
    mov wc.style, 0
    mov wc.lpfnWndProc, OFFSET WndProc
    mov wc.cbClsExtra, 0
    mov wc.cbWndExtra, 0
    mov eax, hInst
    mov dword ptr [wc+hInstance_offset], eax



    invoke LoadIcon, 0, IDI_APPLICATION
    mov wc.hIcon, eax

    invoke LoadCursor, 0, IDC_ARROW
    mov wc.hCursor, eax

    ; Use a standard background color
    mov wc.hbrBackground, COLOR_BTNFACE+1

    mov wc.lpszMenuName, 0
    mov wc.lpszClassName, OFFSET ClassName
    mov wc.hIconSm, 0

    ; 4) Register the window class
    invoke RegisterClassEx, ADDR wc

    ; 5) Create the main window
    invoke CreateWindowEx, \
           0, \
           ADDR ClassName, \
           ADDR AppName, \
           WS_OVERLAPPEDWINDOW, \
           200, 200, 350, 150, \
           0, \
           0, \
           hInst, \
           0
    mov hMain, eax

    ; 6) Show and update
    invoke ShowWindow, hMain, SW_SHOWDEFAULT
    invoke UpdateWindow, hMain

    ; 7) Message loop
MsgLoop:
    invoke GetMessage, ADDR msg, 0, 0, 0
    cmp eax, 0
    je  EndLoop

    invoke TranslateMessage, ADDR msg
    invoke DispatchMessage, ADDR msg
    jmp MsgLoop

EndLoop:
    mov eax, msg.wParam
    ret
WinMain endp

;------------------------------------------------------------------------------
; Program entry point
;------------------------------------------------------------------------------
start:
    invoke WinMain
    invoke ExitProcess, eax
end start

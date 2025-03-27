option casemap:none

includelib msvcrt.lib
includelib vcruntime.lib
includelib ucrt.lib
includelib legacy_stdio_definitions.lib


extrn MessageBoxW:proc
extrn ExitProcess:proc
extrn RegisterClassA:proc
extrn DefWindowProcW:proc
extrn PostQuitMessage:proc
extrn CreateSolidBrush:proc
extrn AdjustWindowRect:proc
extrn CreateWindowExA:proc
extrn ShowWindow:proc
extrn UpdateWindow:proc
extrn TranslateMessage:proc
extrn GetMessageA:proc
extrn DispatchMessageA:proc
extrn time:proc
extrn srand:proc
extrn GetModuleHandleA: proc
extrn GetStartupInfoA: proc
extrn DefWindowProcA: proc
extrn GetClientRect: proc
extrn rand: proc
extrn cos: proc
extrn sin : proc
extrn BeginPaint: proc
extrn EndPaint: proc
extrn SetTimer: proc
extrn KillTimer: proc
extrn SelectObject: proc
extrn CreatePen: proc
extrn Ellipse: proc
extrn DeleteObject: proc
extrn InvalidateRect: proc

; define some constants
COLOR_WINDOW equ 5
WS_OVERLAPPED equ 0h
WS_CAPTION equ 00C00000h
WS_SYSMENU equ 00080000h
WS_THICKFRAME equ 00040000h
WS_MINIMIZEBOX equ 00020000h
WS_MAXIMIZEBOX equ 00010000h
WS_OVERLAPPEDWINDOW equ 0cf0000h
CW_USEDEFAULT equ 80000000h
SW_SHOWDEFAULT equ 0ah
WM_CREATE equ 01h
WM_PAINT equ 0Fh
WM_TIMER equ 113h
WM_SIZE equ 05h
PS_SOLID equ 0
WM_DESTROY equ 02h
BALL_RADIUS equ 20h
BALL_SPEED equ 05h
BALL_TIMER_ID equ 01h
VX equ 5
VY equ 6

BALL STRUCT
    x DWORD ?
    y DWORD ?
    vx DWORD ?
    vy DWORD ?
BALL ENDS

.data
CLASS_NAME db "BouncingBallWindow", 0
title_name db "Bouncing Ball", 0
angles DWORD 45 , 135 , 225 , 315
RADIAN   dq 1

.data?
hwnd QWORD ?
hInstance QWORD ?
hPrevInstance QWORD ?
lpCmdLine QWORD ?
nCmdShow DWORD ?
uMsg DWORD ?
lParam QWORD ?
wParam QWORD ?
angle DWORD ?
ball BALL <>
radians dq ? 

.code
WinMain PROC
    ; retrieve the instance handle
    sub rsp, 28h
    xor rcx , rcx
    call GetModuleHandleA
    mov [hInstance] , rax
    add rsp, 28h

    mov [nCmdShow] , SW_SHOWDEFAULT
    ; WNDCLASS wc = {};
    ; wc store at rsp - 48h
    sub rsp , 48h

    ; wc.lpfnWndProc = WindowProc;
    lea rax , WindowProc
    mov qword ptr [rsp + 8] , rax

    ; wc.hInstance = hInstance;
    mov rax , [hInstance]
    mov qword ptr [rsp + 18h] , rax

    ; wc.lpszClassName = CLASS_NAME;
    lea rax , CLASS_NAME
    mov qword ptr [rsp + 40h] , rax

    ; wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
    mov rax , COLOR_WINDOW
    inc rax
    mov qword ptr [rsp + 30h] , rax

    ; RegisterClassA(&wc);
    sub rsp , 20h
    lea rax , [rsp + 20h]
    mov rcx , rax
    ; calling convention
    call RegisterClassA
    add rsp , 20h

    ; RECT windowRect = { 0, 0, 500, 500 };

    sub rsp , 10h
    lea rax , [rsp]
    mov rdi , rax
    xor ecx , ecx
    mov dword ptr [rdi] , ecx
    mov dword ptr [rdi + 4] , ecx
    mov dword ptr [rdi + 8] , 500
    mov dword ptr [rdi + 0ch] , 500

    ; AdjustWindowRect(&windowRect, WS_OVERLAPPEDWINDOW, FALSE);
    sub rsp , 20h                                               ; calling convention
    lea rax , [rsp + 20h]
    mov rcx , rax
    mov rdx , WS_OVERLAPPEDWINDOW
    xor r8 , r8
    call AdjustWindowRect
    add rsp , 20h

    ; hwnd = CreateWindowExA(0, CLASS_NAME, L"Bouncing Ball", WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, windowRect.right - windowRect.left, windowRect.bottom - windowRect.top, NULL, NULL, hInstance, NULL);
    sub rsp , 60h
    xor rcx , rcx
    lea rdx , CLASS_NAME
    lea r8 , title_name
    mov r9 , WS_OVERLAPPEDWINDOW                                    ; WS_OVERLAPPEDWINDOW
    mov dword ptr [rsp + 20h] , CW_USEDEFAULT                       ; CW_USEDEFAULT
    mov dword ptr [rsp + 28h] , CW_USEDEFAULT                       ; CW_USEDEFAULT

    mov eax , dword ptr [rsp + 60h + 8]
    sub eax , dword ptr [rsp + 60h]
    mov dword ptr [rsp + 30h] , eax                                 ; windowRect.right - windowRect.left

    mov eax , dword ptr [rsp + 60h + 0ch]
    sub eax , dword ptr [rsp + 60h + 4]
    mov dword ptr [rsp + 38h] , eax                                 ; windowRect.bottom - windowRect.top

    xor rax , rax
    mov qword ptr [rsp + 40h] , rax
    mov qword ptr [rsp + 48h] , rax
    mov qword ptr [rsp + 58h] , rax
    mov rax , [hInstance]
    mov qword ptr [rsp + 50h] , rax
    xor rax , rax
    call CreateWindowExA
    mov qword ptr [hwnd] , rax
    add rsp , 60h


    cmp qword ptr [hwnd] , 0
    je L1

    ; ShowWindow(hwnd, nCmdShow);
    sub rsp , 20h
    mov rcx , qword ptr [hwnd]
    mov edx , [nCmdShow]
    call ShowWindow
    add rsp , 20h

    ; UpdateWindow(hwnd);
    sub rsp , 20h
    mov rcx , qword ptr [hwnd]
    call UpdateWindow
    add rsp , 20h

    ; SetTimer(hwnd, BALL_TIMER_ID, 30, NULL);
    sub rsp, 28h
    mov rcx, qword ptr [hwnd]
    mov rdx, BALL_TIMER_ID
    mov r8, 30
    xor r9, r9
    call SetTimer
    add rsp, 28h

    ; MSG msg;
    sub rsp , 30h

L2:
    ; GetMessageA(&msg, NULL, 0, 0)
    sub rsp , 20h
    lea rax , [rsp]
    mov rcx , rax
    xor rdx , rdx
    xor r8 , r8
    xor r9 , r9
    call GetMessageA
    add rsp , 20h
    cmp eax , 0
    je L1
    ; TranslateMessage(&msg);
    sub rsp , 20h
    lea rax , [rsp]
    mov rcx , rax
    call TranslateMessage
    add rsp , 20h

    ; DispatchMessageA(&msg);
    sub rsp , 20h
    lea rax , [rsp]
    mov rcx , rax
    call DispatchMessageA
    add rsp , 20h
    jmp L2

L1:
    ; ExitProcess(0);
    sub rsp , 20h
    xor rcx , rcx
    call ExitProcess
    add rsp , 20h
    ret


WinMain ENDP

WindowProc PROC
    ; get uMsg
    mov [uMsg] , edx
    mov [lParam] , r9
    mov [hwnd] , rcx
    mov [wParam] , r8
    sub rsp, 10h

    cmp [uMsg], WM_CREATE
    je create_tag

    cmp [uMsg], WM_PAINT
    je paint_tag

    cmp [uMsg], WM_DESTROY
    je destroy_tag

    cmp [uMsg], WM_SIZE
    je size_tag

    cmp [uMsg], WM_TIMER
    je timer_tag
    ;cmp [uMsg] , WM_GETMINMAXINFO
    ;je minmax_tag
    jmp default_tag

create_tag:

    ;GetClientRect(hwnd, &clientRect);
    sub rsp, 28h
    mov rcx, qword ptr [hwnd]
    lea rdx, [rsp + 28h]
    call GetClientRect   
    add rsp, 28h

    ;InitializeBall(clientRect);
    sub rsp, 28h
    lea rcx, [rsp + 28h]
    call InitializeBall
    add rsp, 28h
    
    

    add rsp , 10h
    ret
minmax_tag:
    add rsp , 10h
    ret
paint_tag:
    ; PAINTSTRUCT ps
    sub rsp , 40h
    ; HDC hdc = BeginPaint(hwnd, &ps);
    sub rsp, 20h
    mov rcx, qword ptr [hwnd]
    lea rdx, [rsp + 20h]
    call BeginPaint
    add rsp, 20h

    sub rsp , 08h
    mov qword ptr [rsp] , rax
    ; HBRUSH redBrush = CreateSolidBrush(RGB(255, 0, 0));
    sub rsp , 20h
    mov rcx , 0ffh
    call CreateSolidBrush
    add rsp , 20h

    sub rsp , 08h
    mov qword ptr [rsp] , rax

    ; HBRUSH oldBrush = (HBRUSH)SelectObject(hdc, redBrush);
    sub rsp , 20h
    mov rcx , qword ptr [rsp + 20h + 8h]
    mov rdx , qword ptr [rsp + 20h]
    call SelectObject
    add rsp , 20h

    sub rsp , 08h
    mov qword ptr [rsp] , rax

    ; HPEN blackPen = CreatePen(PS_SOLID, 2, RGB(0, 0, 0));
    sub rsp , 20h
    xor r8, r8
    mov rdx , 2
    mov rcx , PS_SOLID
    call CreatePen
    add rsp , 20h

    sub rsp , 08h
    mov qword ptr [rsp] , rax

    ; HPEN oldPen = (HPEN)SelectObject(hdc, blackPen);
    sub rsp , 20h
    mov rcx , qword ptr [rsp + 20h + 18h]
    mov rdx , qword ptr [rsp + 20h]
    call SelectObject
    add rsp , 20h

    sub rsp , 08h
    mov qword ptr [rsp] , rax

    ; Ellipse(hdc, ball.x - BALL_RADIUS, ball.y - BALL_RADIUS, ball.x + BALL_RADIUS, ball.y + BALL_RADIUS);
    sub rsp , 28h
    mov rcx , qword ptr [rsp + 28h + 20h]

    xor rdx , rdx
    mov edx , dword ptr [ball.x]
    sub rdx , BALL_RADIUS

    xor r8 , r8
    mov r8d , dword ptr [ball.y]
    sub r8d , BALL_RADIUS

    xor r9 , r9
    mov r9d , dword ptr [ball.x]
    add r9d , BALL_RADIUS

    xor rax , rax
    mov eax , dword ptr [ball.y]
    add eax , BALL_RADIUS
    mov dword ptr [rsp + 20h] , eax

    call Ellipse
    add rsp , 28h

    ; SelectObject(hdc, oldBrush);
    sub rsp , 20h
    mov rcx , qword ptr [rsp + 20h + 20h]
    mov rdx , qword ptr [rsp + 20h + 10h]
    call SelectObject
    add rsp , 20h

    ; SelectObject(hdc, oldPen);
    sub rsp , 20h
    mov rcx , qword ptr [rsp + 20h + 20h]
    mov rdx , qword ptr [rsp + 20h + 0h]
    call SelectObject
    add rsp , 20h

    ; DeleteObject(redBrush);
    sub rsp , 20h
    mov rcx , qword ptr [rsp + 20h + 18h]
    call DeleteObject
    add rsp , 20h

    ; DeleteObject(blackPen);
    sub rsp , 20h
    mov rcx , qword ptr [rsp + 20h + 08h]
    call DeleteObject
    add rsp , 20h

    ; EndPaint(hwnd, &ps);
    sub rsp , 20h
    mov rcx , qword ptr [hwnd]
    lea rdx , [rsp + 20h + 28h]
    call EndPaint
    add rsp , 20h

    add rsp , 68h
    add rsp, 10h
    ret
destroy_tag:
    ; KillTimer(hwnd, BALL_TIMER_ID);
    sub rsp, 20h
    mov rcx , qword ptr [hwnd]
    mov rdx , BALL_TIMER_ID
    call KillTimer
    add rsp, 20h

    ; PostQuitMessage(0);
    sub rsp, 20h
    xor rcx , rcx
    call PostQuitMessage
    add rsp, 20h

    add rsp , 10h
    ret

size_tag:
    ; GetClientRect(hwnd, &clientRect);
    sub rsp, 28h
    mov rcx, qword ptr [hwnd]
    lea rdx, [rsp + 28h]
    call GetClientRect
    add rsp, 28h

    add rsp, 10h
    ret
timer_tag:
    sub rsp , 28h
    mov rcx , qword ptr [hwnd]
    lea rdx , [rsp + 28h]
    call moveBall
    add rsp , 28h

    ; InvalidateRect(hwnd, NULL, TRUE);
    sub rsp , 20h
    mov rcx , qword ptr [hwnd]
    xor rdx , rdx
    mov r8 , 1
    call InvalidateRect
    add rsp , 20h

    add rsp, 10h
    ret
    
default_tag:
    ; call DefWindowProcA(hwnd, uMsg, wParam, lParam);
    sub rsp , 28h
    mov rcx, qword ptr [hwnd]
    xor rdx , rdx
    mov r8, [wParam]
    mov edx, [uMsg]
    mov r9 , [lParam]
    call DefWindowProcA
    add rsp , 28h
    add rsp, 10h
    ret
WindowProc ENDP


; void InitializeBall(RECT clientRect)
InitializeBall PROC

    mov dword ptr [ball.x], 250
    mov dword ptr [ball.y], 250

    mov dword ptr [ball.vx], VX
    mov dword ptr [ball.vy], VY
    

    ret
InitializeBall ENDP

; void MoveBall(HWND hwnd, RECT clientRect)
moveBall PROC
    ; ball.x += ball.vx
    xor rax , rax
    mov eax , dword ptr [ball.x]
    add eax , dword ptr [ball.vx]
    mov dword ptr [ball.x] , eax

    ; ball.y += ball.vy
    xor rax , rax
    mov eax , dword ptr [ball.y]
    add eax , dword ptr [ball.vy]
    mov dword ptr [ball.y] , eax

    ; width = clientRect.right - clientRect.left
    sub rsp , 08h
    mov rax , rcx
    mov edi , dword ptr [rax + 8]
    sub edi , dword ptr [rax + 0]
    mov dword ptr [rsp], edi

    ; height = clientRect.bottom - clientRect.top
    mov edi , dword ptr [rax + 0ch]
    sub edi , dword ptr [rax + 4]
    mov dword ptr [rsp + 4], edi

    ; if (ball.x < BALL_RADIUS || ball.x > width - BALL_RADIUS) ball.vx = -ball.vx
    mov eax , dword ptr [ball.x]
    cmp eax , BALL_RADIUS
    jl flip_vx
    mov ecx , dword ptr [rsp]
    sub ecx , BALL_RADIUS
    cmp eax , ecx
    jg flip_vx
    jmp check_y

flip_vx:
    mov eax , dword ptr [ball.vx]
    neg eax
    mov dword ptr [ball.vx], eax

check_y:
    ; if (ball.y < BALL_RADIUS || ball.y > height - BALL_RADIUS) ball.vy = -ball.vy
    mov eax , dword ptr [ball.y]
    cmp eax , BALL_RADIUS
    jl flip_vy
    mov ecx , dword ptr [rsp + 4]
    sub ecx , BALL_RADIUS
    cmp eax , ecx
    jg flip_vy
    jmp end_move

flip_vy:
    mov eax , dword ptr [ball.vy]
    neg eax
    mov dword ptr [ball.vy], eax

end_move:
    add rsp , 08h
    ret
moveBall ENDP
END



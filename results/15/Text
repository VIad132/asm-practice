section .data
    fact_msg db "fact = "
    fact_msg_len equ $ - fact_msg
    calls_msg db "calls = "
    calls_msg_len equ $ - calls_msg
    newline db 10

section .bss
    ; memory
    input resb 32
    outbuf resb 16
    calls resd 1

section .text
    global _start

_start:
    ; I/O
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 32
    int 0x80

    ; parse
    mov esi, input
    xor eax, eax
    xor ebx, ebx

parse_loop:
    ; loops
    mov bl, [esi]
    cmp bl, '0'
    jb parse_done
    cmp bl, '9'
    ja parse_done
    imul eax, eax, 10
    sub bl, '0'
    add eax, ebx
    inc esi
    jmp parse_loop

parse_done:
    ; logic
    cmp eax, 12
    jbe input_ok
    mov eax, 12

input_ok:
    ; memory
    mov dword [calls], 0

    ; math
    call fact
    mov edi, eax

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, fact_msg
    mov edx, fact_msg_len
    int 0x80

    mov eax, edi
    call print_uint
    call print_newline

    mov eax, 4
    mov ebx, 1
    mov ecx, calls_msg
    mov edx, calls_msg_len
    int 0x80

    mov eax, [calls]
    call print_uint
    call print_newline

    mov eax, 1
    xor ebx, ebx
    int 0x80

fact:
    ; memory
    push ebp
    mov ebp, esp
    push ebx

    ; logic
    inc dword [calls]
    cmp eax, 1
    jbe fact_base

    ; math
    mov ebx, eax
    dec eax
    call fact
    imul eax, ebx
    jmp fact_done

fact_base:
    ; math
    mov eax, 1

fact_done:
    ; memory
    pop ebx
    mov esp, ebp
    pop ebp
    ret

print_uint:
    ; memory
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push esi

    ; logic
    mov esi, outbuf + 15
    mov byte [esi], 0
    mov ebx, 10
    cmp eax, 0
    jne print_digits
    dec esi
    mov byte [esi], '0'
    jmp print_write

print_digits:
    ; loops
    xor edx, edx
    div ebx
    add dl, '0'
    dec esi
    mov [esi], dl
    cmp eax, 0
    jne print_digits

print_write:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, esi
    mov edx, outbuf + 15
    sub edx, esi
    int 0x80

    ; memory
    pop esi
    pop edx
    pop ecx
    pop ebx
    mov esp, ebp
    pop ebp
    ret

print_newline:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret

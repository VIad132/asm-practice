section .bss
    ; memory
    input_buf resb 16
    line_buf  resb 80
    height    resd 1

section .text
    global _start

_start:
    ; I/O
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 16
    int 0x80

    ; parse
    mov esi, input_buf
    xor eax, eax

parse_loop:
    mov bl, [esi]
    cmp bl, '0'
    jb parse_done
    cmp bl, '9'
    ja parse_done
    imul eax, eax, 10
    sub bl, '0'
    movzx ebx, bl
    add eax, ebx
    inc esi
    jmp parse_loop

parse_done:
    ; math
    cmp eax, 1
    jae min_checked
    mov eax, 5

min_checked:
    cmp eax, 25
    jbe max_checked
    mov eax, 25

max_checked:
    mov [height], eax

    ; logic
    xor edi, edi

row_loop:
    mov eax, [height]
    cmp edi, eax
    jae exit_program

    ; math
    mov ebx, [height]
    dec ebx
    sub ebx, edi
    lea edx, [edi * 2 + 1]

    ; memory
    mov esi, line_buf

    ; loops
    mov ecx, ebx
spaces_loop:
    test ecx, ecx
    jz stars_start
    mov byte [esi], ' '
    inc esi
    dec ecx
    jmp spaces_loop

stars_start:
    mov ecx, edx
stars_loop:
    test ecx, ecx
    jz line_ready
        mov byte [esi], '*'
    inc esi
    dec ecx
    jmp stars_loop

line_ready:
    mov byte [esi], 10

    ; math
    mov eax, ebx
    add eax, edx
    inc eax

    ; I/O
    push eax
    push line_buf
    call print_line
    add esp, 8

    inc edi
    jmp row_loop

exit_program:
    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_line:
    push ebp
    mov ebp, esp

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, [ebp + 8]
    mov edx, [ebp + 12]
    int 0x80

    pop ebp
    ret

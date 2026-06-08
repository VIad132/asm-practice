section .data
    ; memory: constants and static text for output
    seed        dd 123456789
    n_value     dd 0
    ten         dd 10
    msg_colon   db ": "
    msg_lparen  db " ("
    msg_rparen  db ")", 10
    hash_char   db "#"
    newline     db 10

section .bss
    ; memory: input buffer, frequency array and decimal conversion buffer
    input_buf   resb 32
    freq        resd 10
    dec_buf     resb 12

section .text
    global _start

_start:
    ; I/O: read n from stdin
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 32
    int 0x80

    ; parse: convert decimal digits to integer
    mov esi, input_buf
    mov ecx, eax
    xor edi, edi

parse_loop:
    cmp ecx, 0
    je parse_done
    movzx eax, byte [esi]
    cmp al, '0'
    jb parse_done
    cmp al, '9'
        ja parse_done
    imul edi, edi, 10
    sub eax, '0'
    add edi, eax
    inc esi
    dec ecx
    jmp parse_loop

parse_done:
    ; logic: clamp n to the required range 100..1000
    cmp edi, 100
    jge check_upper
    mov edi, 100

check_upper:
    cmp edi, 1000
    jle save_n
    mov edi, 1000

save_n:
    mov [n_value], edi

    ; loops: generate n values and count frequencies
    mov ecx, [n_value]
    mov ebp, [seed]

generate_loop:
    cmp ecx, 0
    je print_histogram

    ; math: LCG x = (1103515245*x + 12345) mod 2^31
    imul ebp, ebp, 1103515245
    add ebp, 12345
    and ebp, 0x7fffffff

    ; math: bucket = x mod 10
    mov eax, ebp
    xor edx, edx
    div dword [ten]
    inc dword [freq + edx * 4]
        dec ecx
    jmp generate_loop

print_histogram:
    ; loops: print 10 histogram rows
    xor esi, esi

row_loop:
    cmp esi, 10
    je exit_program

    ; I/O: print row number and separator
    mov eax, esi
    add al, '0'
    mov [dec_buf], al
    mov eax, 4
    mov ebx, 1
    mov ecx, dec_buf
    mov edx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_colon
    mov edx, 2
    int 0x80

    ; loops: print one # per counted element
    mov edi, [freq + esi * 4]

hash_loop:
    cmp edi, 0
    je print_count
    mov eax, 4
    mov ebx, 1
    mov ecx, hash_char
    mov edx, 1
    int 0x80
    dec edi
    jmp hash_loop

    print_count:
    ; I/O: print decimal count in parentheses
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_lparen
    mov edx, 2
    int 0x80

    mov eax, [freq + esi * 4]
    call print_uint

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_rparen
    mov edx, 2
    int 0x80

    inc esi
    jmp row_loop

exit_program:
    ; I/O: exit(0)
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_uint:
    ; math: convert unsigned integer in eax to decimal text
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov ebx, 10
    lea edi, [dec_buf + 11]
    xor ecx, ecx

convert_loop:
    xor edx, edx
       div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    inc ecx
    cmp eax, 0
    jne convert_loop

    ; I/O: write converted decimal text
    mov eax, 4
    mov ebx, 1
    mov edx, ecx
    mov ecx, edi
    int 0x80

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

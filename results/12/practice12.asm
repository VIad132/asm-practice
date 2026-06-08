section .data
    nl db 10

section .bss
    ; memory: buffers in .bss
    input_buf resb 1
    text_buf  resb 201
    pat_buf   resb 51
    num_buf   resb 16

    text_len  resd 1
    pat_len   resd 1
    first_pos resd 1
    count     resd 1

section .text
    global _start

_start:
    ; I/O: read text line
    mov edi, text_buf
    mov ecx, 200
    call read_line

    ; I/O: read pattern line
    mov edi, pat_buf
    mov ecx, 50
    call read_line

    ; math: calculate lengths with own strlen
    mov esi, text_buf
    call strlen
    mov [text_len], eax

    mov esi, pat_buf
    call strlen
    mov [pat_len], eax

    ; logic: prepare default results
    mov dword [first_pos], -1
        mov dword [count], 0

    cmp dword [pat_len], 0
    je empty_pattern

    mov eax, [pat_len]
    cmp eax, [text_len]
    ja print_result

    xor ebx, ebx

search_loop:
    ; loops: stop when position is greater than text_len - pat_len
    mov eax, [text_len]
    sub eax, [pat_len]
    cmp ebx, eax
    ja print_result

    xor ecx, ecx

compare_loop:
    ; loops: naive nested comparison
    cmp ecx, [pat_len]
    je found_match

    mov al, [text_buf + ebx + ecx]
    cmp al, [pat_buf + ecx]
    jne no_match

    inc ecx
    jmp compare_loop

found_match:
    ; logic: count non-overlapping match
    cmp dword [first_pos], -1
    jne first_saved
    mov [first_pos], ebx

first_saved:
    inc dword [count]
        add ebx, [pat_len]
    jmp search_loop

no_match:
    inc ebx
    jmp search_loop

empty_pattern:
    ; logic: empty pattern case
    mov dword [first_pos], 0
    mov dword [count], 0

print_result:
    ; I/O: print first position and count
    mov eax, [first_pos]
    call print_int
    call print_nl

    mov eax, [count]
    call print_int
    call print_nl

    mov eax, 1
    xor ebx, ebx
    int 0x80

read_line:
    ; I/O: read one line using sys_read
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp

    ; parse: copy at most ECX bytes to EDI
    mov ebp, ecx
    xor esi, esi

    .read_loop:
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 1
    int 0x80

    cmp eax, 0
    jle .finish

    mov al, [input_buf]
    cmp al, 10
    je .finish
    cmp al, 13
    je .read_loop

    cmp esi, ebp
    jae .read_loop

    ; memory: store character in buffer
    mov [edi], al
    inc edi
    inc esi
    jmp .read_loop

.finish:
    mov byte [edi], 0

    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

strlen:
    ; memory: own strlen
    push esi
        xor eax, eax

.len_loop:
    cmp byte [esi + eax], 0
    je .len_done
    inc eax
    jmp .len_loop

.len_done:
    pop esi
    ret

print_nl:
    ; I/O: write newline
    mov eax, 4
    mov ebx, 1
    mov ecx, nl
    mov edx, 1
    int 0x80
    ret

print_int:
    ; math: convert signed integer to decimal
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov esi, num_buf + 15
    mov byte [esi], 0
    mov ebx, 10
    xor ecx, ecx

    cmp eax, 0
    jne .check_sign

    dec esi
    mov byte [esi], '0'
    inc ecx
        jmp .write_number

.check_sign:
    cmp eax, 0
    jge .digits

    neg eax
    mov edx, 1
    jmp .digits_start

.digits:
    xor edx, edx

.digits_start:
    push edx

.digit_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec esi
    mov [esi], dl
    inc ecx
    cmp eax, 0
    jne .digit_loop

    pop edx
    cmp edx, 0
    je .write_number

    dec esi
    mov byte [esi], '-'
    inc ecx

.write_number:
    mov eax, 4
    mov ebx, 1
    mov edx, ecx
    mov ecx, esi
    int 0x80

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

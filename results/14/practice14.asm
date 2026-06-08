section .data
    msg_before db 'Array before sorting:', 10
    msg_before_len equ $ - msg_before
    msg_after db 'Array after sorting:', 10
    msg_after_len equ $ - msg_after
    msg_median db 'Median:', 10
    msg_median_len equ $ - msg_median
    space db ' '
    newline db 10

section .bss
    ; memory: input buffer, array of dd values, and decimal output buffer
    input_buf resb 4096
    n_value resd 1
    numbers resd 100
    out_buf resb 16

section .text
    global _start

_start:
    ; I/O: read all input from stdin
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 4096
    int 0x80

    mov esi, input_buf

    ; parse: first integer is n
    call parse_int
    mov [n_value], eax

    ; loops: read n integers into the dd array
    xor edi, edi
.read_numbers:
    cmp edi, [n_value]
    jge .print_before
    call parse_int
    mov [numbers + edi * 4], eax
    inc edi
    jmp .read_numbers

.print_before:
    mov ecx, msg_before
    mov edx, msg_before_len
    call write_buf
    call print_array

    ; logic: selection sort in ascending order
    call selection_sort

    mov ecx, msg_after
    mov edx, msg_after_len
    call write_buf
    call print_array

    mov ecx, msg_median
    mov edx, msg_median_len
    call write_buf

    ; math: lower median index is (n - 1) / 2
    mov eax, [n_value]
    dec eax
    shr eax, 1
    mov eax, [numbers + eax * 4]
    call print_int
    call print_newline

    mov eax, 1
    xor ebx, ebx
    int 0x80

write_buf:
    ; I/O: write ecx buffer with edx length to stdout
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

print_newline:
    mov ecx, newline
    mov edx, 1
    call write_buf
    ret

print_space:
    mov ecx, space
    mov edx, 1
    call write_buf
    ret

parse_int:
    ; parse: skip whitespace, then parse optional sign and decimal digits
    push ebx
    push ecx
    push edx
    push edi

.skip_ws:
    mov bl, [esi]
    cmp bl, ' '
    je .next_ws
    cmp bl, 10
    je .next_ws
    cmp bl, 13
    je .next_ws
    cmp bl, 9
    jne .check_sign
.next_ws:
    inc esi
    jmp .skip_ws

.check_sign:
    mov edi, 1
    cmp byte [esi], '-'
    jne .parse_digits
    mov edi, -1
    inc esi

.parse_digits:
    xor eax, eax
.digit_loop:
    mov bl, [esi]
    cmp bl, '0'
    jl .digits_done
    cmp bl, '9'
    jg .digits_done
    imul eax, eax, 10
    movzx ebx, bl
    sub ebx, '0'
    add eax, ebx
    inc esi
    jmp .digit_loop

.digits_done:
    cmp edi, 1
    je .parse_done
    neg eax
.parse_done:
    pop edi
    pop edx
    pop ecx
    pop ebx
    ret

print_int:
    ; I/O: print signed integer from eax
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov edi, out_buf + 15
    mov ebx, 10
    xor esi, esi

    cmp eax, 0
    jne .check_negative
    dec edi
    mov byte [edi], '0'
    jmp .emit_number

.check_negative:
    jge .convert_digits
    mov esi, 1
    neg eax

.convert_digits:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .convert_digits

    cmp esi, 0
    je .emit_number
    dec edi
    mov byte [edi], '-'

.emit_number:
    mov ecx, edi
    mov edx, out_buf + 15
    sub edx, edi
    call write_buf

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

print_array:
    ; loops: print n dd values separated by spaces
    push eax
    push ecx
    push edi

    xor edi, edi
.array_loop:
    cmp edi, [n_value]
    jge .array_done
    mov eax, [numbers + edi * 4]
    call print_int
    inc edi
    cmp edi, [n_value]
    jge .array_loop
    call print_space
    jmp .array_loop

.array_done:
    call print_newline
    pop edi
    pop ecx
    pop eax
    ret

selection_sort:
    ; loops: nested i/j loops for selection sort
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    xor esi, esi
.outer_loop:
    mov eax, [n_value]
    dec eax
    cmp esi, eax
    jge .sort_done

    ; logic: min_index starts at i
    mov edi, esi
    mov ebx, esi
    inc ebx

.inner_loop:
    cmp ebx, [n_value]
    jge .maybe_swap
    mov eax, [numbers + ebx * 4]
    mov edx, [numbers + edi * 4]
    cmp eax, edx
    jge .next_j
    mov edi, ebx

.next_j:
    inc ebx
    jmp .inner_loop

.maybe_swap:
    cmp edi, esi
    je .next_i
    ; memory: exchange two dd elements numbers[i] and numbers[min_index]
    mov eax, [numbers + esi * 4]
    mov edx, [numbers + edi * 4]
    mov [numbers + esi * 4], edx
    mov [numbers + edi * 4], eax

.next_i:
    inc esi
    jmp .outer_loop

.sort_done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

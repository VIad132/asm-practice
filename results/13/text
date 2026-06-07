section .data
    msg_original db "Original array:", 10
    msg_original_len equ $ - msg_original

    msg_reversed db "Reversed array:", 10
    msg_reversed_len equ $ - msg_reversed

    msg_yes db "PALINDROME: YES", 10
    msg_yes_len equ $ - msg_yes

    msg_no db "PALINDROME: NO", 10
    msg_no_len equ $ - msg_no

    msg_invalid db "INVALID INPUT", 10
    msg_invalid_len equ $ - msg_invalid

    space db " "
    newline db 10

section .bss
    input_buf resb 4096
    array resd 200
    copy_buf resd 200
    rev_buf resd 200
    out_buf resb 16
    n_value resd 1
    read_len resd 1
    input_pos resd 1
    palindrome resd 1

section .text
    global _start

_start:
    ; I/O: read all input from stdin
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 4096
    int 0x80
    
    cmp eax, 0
    jle invalid_input
    mov [read_len], eax
    mov dword [input_pos], 0

    ; parse: first number is n
    call parse_int
    cmp edx, 0
    je invalid_input
    cmp eax, 5
    jl invalid_input
    cmp eax, 200
    jg invalid_input
    mov [n_value], eax

    ; parse: read n array elements
    xor edi, edi
    
read_array_loop:
    ; loops: fill source array with parsed dword values
    cmp edi, [n_value]
    jge array_read_done
    call parse_int
    cmp edx, 0
    je invalid_input
    mov [array + edi * 4], eax
    inc edi
    jmp read_array_loop

array_read_done:
    ; memory: copy source array to an additional buffer
    cld
    mov esi, array
    mov edi, copy_buf
    mov ecx, [n_value]
    rep movsd

    ; math: build reversed array with indexed addressing
    xor edi, edi
        ; loops: rev_buf[i] = copy_buf[n - 1 - i]
    cmp edi, [n_value]
    jge reverse_done
    mov ebx, [n_value]
    dec ebx
    sub ebx, edi
    mov eax, [copy_buf + ebx * 4]
    mov [rev_buf + edi * 4], eax
    inc edi
    jmp reverse_loop

reverse_done:
    ; logic: compare element pairs to decide if array is palindrome
    mov dword [palindrome], 1
    xor esi, esi
    mov edi, [n_value]
    dec edi
palindrome_loop:
    ; loops: stop after indices meet or cross
    cmp esi, edi
    jge print_result
    mov eax, [copy_buf + esi * 4]
    mov ebx, [copy_buf + edi * 4]
    cmp eax, ebx
    je palindrome_pair_ok
    mov dword [palindrome], 0
    jmp print_result

palindrome_pair_ok:
    inc esi
    dec edi
    jmp palindrome_loop

print_result:
    ; I/O: print original array, reversed array, and palindrome result
    mov ecx, msg_original
    mov edx, msg_original_len
    call write_buf
    mov esi, copy_buf
    call print_array
    mov ecx, msg_reversed
    mov edx, msg_reversed_len
    call write_buf
    mov esi, rev_buf
    call print_array

    cmp dword [palindrome], 1
    jne print_no
    mov ecx, msg_yes
    mov edx, msg_yes_len
    call write_buf
    jmp exit_ok

print_no:
    mov ecx, msg_no
    mov edx, msg_no_len
    call write_buf
    jmp exit_ok

invalid_input:
    ; I/O: report malformed or out-of-range input
    mov ecx, msg_invalid
    mov edx, msg_invalid_len
    call write_buf

exit_ok:
    mov eax, 1
    xor ebx, ebx
    int 0x80

write_buf:
    ; I/O: write ecx buffer of edx bytes
    push eax
    push ebx
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop ebx
    pop eax
    ret

    parse_int:
    ; parse: returns eax=value, edx=1 if found, edx=0 otherwise
    push ebx
    push ecx
    push esi
    push edi

    mov esi, [input_pos]

skip_spaces:
    cmp esi, [read_len]
    jge parse_fail
    mov bl, [input_buf + esi]
    cmp bl, ' '
    je skip_one
    cmp bl, 10
    je skip_one
    cmp bl, 13
    je skip_one
    cmp bl, 9
    je skip_one
    jmp sign_check

skip_one:
    inc esi
    jmp skip_spaces

sign_check:
    xor edi, edi
    cmp bl, '-'
    jne digit_start
    mov edi, 1
    inc esi

digit_start:
    xor eax, eax
    xor ecx, ecx

digit_loop:
    cmp esi, [read_len]
    jge digit_done
    mov bl, [input_buf + esi]
    cmp bl, '0'
    jl digit_done
    cmp bl, '9'
    jg digit_done
    imul eax, eax, 10
    movzx ebx, bl
    sub ebx, '0'
    add eax, ebx
    inc esi
    inc ecx
    jmp digit_loop

digit_done:
    cmp ecx, 0
    je parse_fail
    cmp edi, 0
    je parse_success
    neg eax

parse_success:
    mov [input_pos], esi
    mov edx, 1
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret

parse_fail:
    mov [input_pos], esi
    xor eax, eax
    xor edx, edx
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret

    print_array:
    ; I/O: print n signed integers from dword array at esi
    push eax
    push ebx
    push ecx
    push edx
    push edi

    xor edi, edi

print_array_loop:
    ; loops: print element and separator
    cmp edi, [n_value]
    jge print_array_newline
    mov eax, [esi + edi * 4]
    call print_int
    inc edi
    cmp edi, [n_value]
    jge print_array_loop
    mov ecx, space
    mov edx, 1
    call write_buf
    jmp print_array_loop

print_array_newline:
    mov ecx, newline
    mov edx, 1
    call write_buf

    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

print_int:
    ; I/O: print signed integer in eax
    push eax
    push ebx
        push ecx
    push edx
    push esi
    push edi

    mov edi, out_buf
    add edi, 15
    mov byte [edi], 0
    mov ebx, 10
    xor esi, esi

    cmp eax, 0
    jne print_int_sign
    dec edi
    mov byte [edi], '0'
    jmp print_int_write

print_int_sign:
    cmp eax, 0
    jge print_int_digits
    mov esi, 1
    neg eax

print_int_digits:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    cmp eax, 0
    jne print_int_digits
    cmp esi, 0
    je print_int_write
    dec edi
    mov byte [edi], '-'

print_int_write:
    mov ecx, edi
    mov edx, out_buf
    add edx, 15
    sub edx, edi
    call write_buf

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

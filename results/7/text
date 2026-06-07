section .data
    prompt db "Enter n (5..50): ", 0
    prompt_len equ $ - prompt

    msg_arr db "Array: ", 0
    msg_arr_len equ $ - msg_arr

    msg_min db 10, "Min: ", 0
    msg_min_len equ $ - msg_min

    msg_max db 10, "Max: ", 0
    msg_max_len equ $ - msg_max

    space db " "
    newline db 10

section .bss
    outbuf resb 16
    array resd 50       
    input resb 16
    n resd 1

section .text
    global _start

_start:

; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 16
    int 0x80
    ; parse
    mov esi, input
    xor eax, eax

parse_loop:
    mov bl, [esi]
    cmp bl, 10
    je parse_done

    sub bl, '0'
    movzx ebx, bl    

    imul eax, eax, 10
    add eax, ebx

    inc esi
    jmp parse_loop

parse_done:
    mov [n], eax

; logic (check bounds)
    cmp eax, 5
    jl exit
    cmp eax, 50
    jg exit

; loops + math + memory
    xor ecx, ecx        ; i = 0

fill_loop:
    mov eax, ecx

    ; a[i] = i*i - 3*i + 5
    mov ebx, ecx
    imul eax, eax       ; i*i
    mov edx, ecx
    imul edx, 3         ; 3*i
    sub eax, edx
    add eax, 5
        mov [array + ecx*4], eax

    inc ecx
    cmp ecx, [n]
    jl fill_loop

; print array
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_arr
    mov edx, msg_arr_len
    int 0x80

    xor ecx, ecx

print_loop:
    push ecx

    mov eax, [array + ecx*4]
    call print_number

    pop ecx

    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

    inc ecx
    cmp ecx, [n]
    jl print_loop

; find min/max
    mov eax, [array]
    mov ebx, eax        ; min
    mov edx, eax        ; max

    xor esi, esi        ; min index
    xor edi, edi        ; max index

    mov ecx, 1

find_loop:
    mov eax, [array + ecx*4]

    cmp eax, ebx
    jge check_max
    mov ebx, eax
    mov esi, ecx

check_max:
    cmp eax, edx
    jle next_i
    mov edx, eax
    mov edi, ecx

next_i:
    inc ecx
    cmp ecx, [n]
    jl find_loop

; print min
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_min
    mov edx, msg_min_len
    int 0x80

    mov eax, ebx
    call print_number

    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

    mov eax, esi
    call print_number

    ; print max
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_max
    mov edx, msg_max_len
    int 0x80

    mov eax, edx
    call print_number

    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

    mov eax, edi
    call print_number

; exit
exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; print_number
print_number:
    push eax
    push ebx
    push ecx
    push edx

    mov ecx, outbuf + 15
    mov byte [ecx], 0

    mov ebx, 10

convert_loop:
    dec ecx
    xor edx, edx
        div ebx
    add dl, '0'
    mov [ecx], dl
    test eax, eax
    jnz convert_loop

    mov edx, outbuf + 15
    sub edx, ecx

    mov eax, 4
    mov ebx, 1
    int 0x80

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

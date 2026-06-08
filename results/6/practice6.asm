section .data
    ; I/O
    prompt_a db "Enter a: ", 0
    prompt_b db "Enter b: ", 0

    signed_lt db "SIGNED: a < b", 10, 0
    signed_eq db "SIGNED: a = b", 10, 0
    signed_gt db "SIGNED: a > b", 10, 0

    unsigned_lt db "UNSIGNED: a < b", 10, 0
    unsigned_eq db "UNSIGNED: a = b", 10, 0
    unsigned_gt db "UNSIGNED: a > b", 10, 0

    max_s db "max_signed: ", 0
    max_u db "max_unsigned: ", 0
    newline db 10, 0

section .bss
    ; MEMORY
    input resb 32
    a resd 1
    b resd 1

section .text
    global _start

; UTILS

print:
    ; ecx = string
    push eax
    push ebx
    push edx

    mov edx, 0
.count:
    cmp byte [ecx+edx], 0
    je .done
    inc edx
    jmp .countsection .data
    ; I/O
    prompt_a db "Enter a: ", 0
    prompt_b db "Enter b: ", 0

    signed_lt db "SIGNED: a < b", 10, 0
    signed_eq db "SIGNED: a = b", 10, 0
    signed_gt db "SIGNED: a > b", 10, 0

    unsigned_lt db "UNSIGNED: a < b", 10, 0
    unsigned_eq db "UNSIGNED: a = b", 10, 0
    unsigned_gt db "UNSIGNED: a > b", 10, 0

    max_s db "max_signed: ", 0
    max_u db "max_unsigned: ", 0
    newline db 10, 0

section .bss
    ; MEMORY
    input resb 32
    a resd 1
    b resd 1

section .text
    global _start

; UTILS

print:
    ; ecx = string
    push eax
    push ebx
    push edx

    mov edx, 0
.count:
    cmp byte [ecx+edx], 0
    je .done
    inc edx
    jmp .count
    .done:
    mov eax, 4
    mov ebx, 1
    int 0x80

    pop edx
    pop ebx
    pop eax
    ret

read_line:
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 32
    int 0x80
    ret

atoi:
    ; PARSE
    ; result -> eax
    mov esi, input
    xor eax, eax
    xor ebx, ebx
    mov bl, 10

    xor ecx, ecx ; sign = 0

    cmp byte [esi], '-'
    jne .parse
    inc esi
    mov ecx, 1

.parse:
    xor eax, eax
.loop:
    cmp byte [esi], 10
    je .done
    cmp byte [esi], 0
    je .done
        imul eax, ebx
    mov dl, [esi]
    sub dl, '0'
    add eax, edx

    inc esi
    jmp .loop

.done:
    cmp ecx, 1
    jne .ret
    neg eax
.ret:
    ret

print_int:
    ; OUTPUT
    ; eax = number
    push eax
    push ebx
    push ecx
    push edx

    mov ecx, input + 31
    mov byte [ecx], 0

    mov ebx, 10
    cmp eax, 0
    jge .loop

    neg eax
    mov byte [input], '-'
    mov esi, input
    jmp .loop

.loop:
    dec ecx
    xor edx, edx
    div ebx
    add dl, '0'
        mov [ecx], dl
    test eax, eax
    jnz .loop

    mov eax, 4
    mov ebx, 1
    mov edx, input+31
    sub edx, ecx
    mov eax, 4
    mov ebx, 1
    mov edx, input+31
    sub edx, ecx
    mov ecx, ecx
    int 0x80

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; LOGIC

cmp_signed:
    ; SIGNED
    mov eax, [a]
    mov ebx, [b]

    cmp eax, ebx
    jl .lt
    jg .gt

    mov ecx, signed_eq
    call print
    ret

.lt:
    mov ecx, signed_lt
    call print
    ret
    .gt:
    mov ecx, signed_gt
    call print
    ret

cmp_unsigned:
    ; UNSIGNED
    mov eax, [a]
    mov ebx, [b]

    cmp eax, ebx
    jb .lt
    ja .gt

    mov ecx, unsigned_eq
    call print
    ret

.lt:
    mov ecx, unsigned_lt
    call print
    ret

.gt:
    mov ecx, unsigned_gt
    call print
    ret

max_signed:
    ; MATH
    mov eax, [a]
    mov ebx, [b]

    cmp eax, ebx
    jge .done
    mov eax, ebx

.done:
    ret

max_unsigned:
    mov eax, [a]
    mov ebx, [b]

    cmp eax, ebx
    jae .done
    mov eax, ebx

.done:
    ret

; MAIN

_start:

    ; read a
    mov ecx, prompt_a
    call print
    call read_line
    call atoi
    mov [a], eax

    ; read b
    mov ecx, prompt_b
    call print
    call read_line
    call atoi
    mov [b], eax

    ; comparisons
    call cmp_signed
    call cmp_unsigned

    ; max signed
    mov ecx, max_s
    call print
    call max_signed
    call print_int

    mov ecx, newline
        call print

    ; max unsigned
    mov ecx, max_u
    call print
    call max_unsigned
    call print_int

    mov ecx, newline
    call print

    ; exit
    mov eax, 1
    xor ebx, ebx
    int 0x80

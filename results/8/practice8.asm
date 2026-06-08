section .data
    newline db 10
    space db ' '
    minus db '-'
    one db '1'

section .bss
    buffer resb 1024        
    arr resd 100           
    indices resd 100    
    n resd 1
    target resd 1
    count resd 1

section .text
    global _start

_start:

; I/O
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 1024
    int 0x80

; parse
    mov esi, buffer

    call read_int
    mov [n], eax

    cmp eax, 10
    jl end_program
    cmp eax, 100
    jg end_program

    mov ecx, eax
    xor edi, edi
read_array:
    cmp edi, ecx
    jge read_target

    call read_int
    mov [arr + edi*4], eax
    inc edi
    jmp read_array

read_target:
    call read_int
    mov [target], eax

; logic
    mov ecx, [n]
    xor edi, edi
    mov dword [count], 0
    mov ebx, -1
    
search_loop:
    cmp edi, ecx
    jge after_search

    mov eax, [arr + edi*4]
    cmp eax, [target]
    jne next

    cmp ebx, -1
    jne skip_first
    mov ebx, edi

skip_first:
    mov eax, [count]
    mov [indices + eax*4], edi
    inc dword [count]

next:
    inc edi
        jmp search_loop

after_search:

; output

; 1. перший індекс
    cmp ebx, -1
    jne print_first

    mov eax, 4
    mov ebx, 1
    mov ecx, minus
    mov edx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, one
    mov edx, 1
    int 0x80
    jmp after_first

print_first:
    mov eax, ebx
    call print_int

after_first:
    call print_newline

; 2. кількість
    mov eax, [count]
    call print_int
    call print_newline

; 3. індекси
    mov edx, [count]
    cmp edx, 0
    je end_program
        xor edi, edi

print_indices:
    cmp edi, edx
    jge done_indices

    mov eax, [indices + edi*4]
    push edx
    call print_int
    pop edx

    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

    inc edi
    jmp print_indices

done_indices:
    call print_newline

; exit
end_program:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; functions

; read_int
read_int:
    xor eax, eax
    xor ebx, ebx

.skip_spaces:
    mov bl, [esi]
    cmp bl, ' '
    je .next_char
        cmp bl, 10
    je .next_char
    jmp .read

.next_char:
    inc esi
    jmp .skip_spaces

.read:
    xor eax, eax

.loop:
    mov bl, [esi]
    cmp bl, '0'
    jl .done
    cmp bl, '9'
    jg .done

    imul eax, eax, 10
    sub bl, '0'
    add eax, ebx

    inc esi
    jmp .loop

.done:
    ret

; print_int
print_int:
    mov ecx, buffer + 1023
    mov byte [ecx], 0
    dec ecx

    cmp eax, 0
    jne .convert

    mov byte [ecx], '0'
    jmp .print

.convert:
    mov ebx, 10

.loop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [ecx], dl
    dec ecx
    cmp eax, 0
    jne .loop

    inc ecx

.print:
    mov eax, 4
    mov ebx, 1
    mov edx, buffer + 1023
    sub edx, ecx
    mov esi, ecx
    mov ecx, esi
    int 0x80
    ret

; print_newline
print_newline:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret

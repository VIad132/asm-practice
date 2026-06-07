section .data
; memory
newline db 10
ten dd 10

section .bss
; memory
input resb 32
num resd 1
sum resd 1
len resd 1
buffer resb 32

section .text
global _start

_start:

; I/O
; read input
mov eax, 3          
mov ebx, 0          
mov ecx, input
mov edx, 32
int 0x80

; parse
; atoi
mov esi, input
xor eax, eax        

atoi_loop:
mov bl, [esi]
cmp bl, 10          
je atoi_done
cmp bl, 0
je atoi_done

sub bl, '0'
imul eax, eax, 10
add eax, ebx

inc esi
jmp atoi_loop

atoi_done:
mov [num], eax

; logic
mov eax, [num]
mov [sum], dword 0
mov [len], dword 0

; loops
digit_loop:
cmp eax, 0
je done_digits

; math
xor edx, edx
mov ecx, 10
div ecx          

add [sum], edx
inc dword [len]

jmp digit_loop

done_digits:

; I/O
; print sumDigits
mov eax, [sum]
call itoa

mov eax, 4
mov ebx, 1
mov ecx, buffer
mov edx, eax
int 0x80
mov eax, 4
mov ebx, 1
mov ecx, newline
mov edx, 1
int 0x80

; print len
mov eax, [len]
call itoa

mov eax, 4
mov ebx, 1
mov ecx, buffer
mov edx, eax
int 0x80

mov eax, 4
mov ebx, 1
mov ecx, newline
mov edx, 1
int 0x80

; exit
mov eax, 1
xor ebx, ebx
int 0x80


; parse
; itoa: eax -> string
itoa:
    mov edi, buffer
    add edi, 31
    mov byte [edi], 0

    mov ecx, 10

convert_loop:
    xor edx, edx
    div ecx
    
    add dl, '0'
    dec edi
    mov [edi], dl

    test eax, eax
    jnz convert_loop

    mov ecx, buffer
    add ecx, 31
    sub ecx, edi

    mov esi, edi
    mov edi, buffer

copy_loop:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    loop copy_loop

    mov eax, ecx
    ret

section .data
; memory
newline db 10

section .bss
; memory
input_buffer resb 32
output_buffer resb 32

section .text
global _start

_start:

; I/O
; read string from stdin
mov eax, 3       
mov ebx, 0       
mov ecx, input_buffer
mov edx, 32
int 0x80

; parse
; convert string to integer
mov esi, input_buffer
xor eax, eax        

parse_loop:

; logic
mov bl, [esi]
cmp bl, 10          
je parse_done

cmp bl, 0
je parse_done

; math
sub bl, '0'         
mov ecx, 10
mul ecx            
add eax, ebx       

; loops
inc esi
jmp parse_loop

parse_done:

; store result in AX
mov ax, ax

; convert number -> string
mov eax, eax
mov edi, output_buffer
add edi, 31
mov byte [edi], 0

convert_loop:

; math
xor edx, edx
mov ebx, 10
div ebx            

add dl, '0'

; memory
dec edi
mov [edi], dl

; logic
cmp eax, 0
jne convert_loop

; I/O
; print result
mov eax, 4         
mov ebx, 1         
mov ecx, edi
mov edx, output_buffer + 31
sub edx, edi
int 0x80

; print newline
mov eax, 4
mov ebx, 1
mov ecx, newline
mov edx, 1
int 0x80

; exit
mov eax, 1
xor ebx, ebx
int 0x80

section .data

; I/O

msgInput        db "Enter x: "
lenInput        equ $-msgInput

msgBinary       db 10,"Binary (32 bits): "
lenBinary       equ $-msgBinary

msgPop          db 10,"Popcount: "
lenPop          equ $-msgPop

msgResult       db 10,"Modified value: "
lenResult       equ $-msgResult

newline         db 10

; bit positions
p               equ 3
q               equ 7
r               equ 5

section .bss

; memory

inputBuffer     resb 64
binaryBuffer    resb 40
numBuffer       resb 16

x               resd 1

section .text
global _start

_start:

; I/O
; print prompt

    mov eax,4
    mov ebx,1
    mov ecx,msgInput
    mov edx,lenInput
    int 0x80

; I/O
; read string

    mov eax,3
    mov ebx,0
    mov ecx,inputBuffer
    mov edx,64
    int 0x80

; parse
; string -> integer

    mov esi,inputBuffer
    xor eax,eax

parse_loop:

    mov bl,[esi]

    cmp bl,10
    je parse_done

    cmp bl,13
    je parse_done

    cmp bl,0
    je parse_done

    sub bl,'0'

    imul eax,eax,10
    movzx ebx,bl
    add eax,ebx

    inc esi
    jmp parse_loop

parse_done:

    mov [x],eax

; I/O
; print binary title

    mov eax,4
    mov ebx,1
    mov ecx,msgBinary
    mov edx,lenBinary
    int 0x80

; loops + logic
; print 32 bits grouped by 4

    mov eax,[x]
    mov edi,binaryBuffer

    mov ecx,32

binary_loop:

    mov edx,eax
    shr edx,31
    add dl,'0'

    mov [edi],dl
    inc edi

    shl eax,1

    mov ebx,ecx
    dec ebx

    cmp ebx,0
    je no_space

    test ebx,3
    jnz no_space

    mov byte [edi],' '
    inc edi

no_space:

    loop binary_loop

    mov byte [edi],10
    inc edi

    mov eax,4
    mov ebx,1
    mov ecx,binaryBuffer
    mov edx,edi
    sub edx,binaryBuffer
    int 0x80

; math + logic
; popcount via shr and and 1

    mov eax,[x]
    xor ebx,ebx
    mov ecx,32

count_loop:

    mov edx,eax
    and edx,1
    add ebx,edx

    shr eax,1

    loop count_loop

; print popcount title

    mov eax,4
    mov ebx,1
    mov ecx,msgPop
    mov edx,lenPop
    int 0x80

; print popcount value

    mov eax,ebx
    call print_uint

; newline

    mov eax,4
    mov ebx,1
    mov ecx,newline
    mov edx,1
    int 0x80

; logic
; set bits p,q and clear bit r

    mov eax,[x]

    mov edx,1
    shl edx,p
    or eax,edx

    mov edx,1
    shl edx,q
    or eax,edx

    mov edx,1
    shl edx,r
    not edx
    and eax,edx

    mov [x],eax
    
; I/O
; print result title

    mov eax,4
    mov ebx,1
    mov ecx,msgResult
    mov edx,lenResult
    int 0x80

; print modified value

    mov eax,[x]
    call print_uint

; newline

    mov eax,4
    mov ebx,1
    mov ecx,newline
    mov edx,1
    int 0x80

; exit

    mov eax,1
    xor ebx,ebx
    int 0x80

; print_uint
; EAX = unsigned integer

print_uint:

    mov edi,numBuffer+15
    mov byte [edi],0

    cmp eax,0
    jne convert_number

    dec edi
    mov byte [edi],'0'
    jmp print_number

convert_number:

    mov ebx,10

convert_loop:

    xor edx,edx
    div ebx

    add dl,'0'

    dec edi
    mov [edi],dl

    test eax,eax
    jnz convert_loop

print_number:

    mov esi,edi

length_loop:

    cmp byte [esi],0
    je length_done

    inc esi
    jmp length_loop

length_done:

    mov edx,esi
    sub edx,edi

    mov eax,4
    mov ebx,1
    mov ecx,edi
    int 0x80

    ret

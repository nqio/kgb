
org 0x7E00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov ax, 0x4F02
    mov bx, 0x11F | 0x4000
    int 0x10

    mov ax, 0x4F01
    mov cx, 0x11F
    mov di, mode_info
    int 0x10
    
    

    mov eax, [mode_info + 0x28]
    mov [lfb_addr], eax

    movzx eax, word [mode_info + 0x10]
    mov [lfb_pitch], eax 

    lgdt [gdt_desc]

    mov eax, cr0
    or  eax, 1
    mov cr0, eax

    jmp CODE_SEL:pm_start

bits 32

pm_start:
    mov ax, DATA_SEL
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    mov esi, [lfb_addr]


    mov eax, cr0
    and eax, 0xFFFB 
    or  eax, 0x2 
    mov cr0, eax

    mov eax, cr4
    or  eax, 0x600
    mov cr4, eax






section .data

align 4
lfb_addr: dd 0
lfb_pitch: dd 0
zero: dd 0
NULL: dd 0
KEYS dd 128 dup(0)

mode_info: times 256 db 0

align 8
gdt:
    dq 0x0000000000000000
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF

gdt_desc:
    dw gdt_end - gdt - 1
    dd gdt
gdt_end:

CODE_SEL equ 0x08
DATA_SEL equ 0x10

section .text

section .text

line:
@alias(x1, eax)
@alias(y1, ebx)
@alias(x2, ecx)
@alias(y2, edx)

push ebp
mov ebp, esp

sub @y2, @y1
imul @y2, 2
@alias(m_new, @y2)

@alias(slope_error_new, edi)
mov @slope_error_new, @m_new
sub @m_new, @x2
add @m_new, @x1

push @x1
@alias(to_sub_from_SEN, [ebp - 4])
mov dword @to_sub_from_SEN, @x2
sub dword @to_sub_from_SEN, @x1 
push @slope_error_new
mov @slope_error_new, 2
imul dword @to_sub_from_SEN, @slope_error_new
pop @slope_error_new
add esp, 4

@alias(y, @y1) ; y1 initialized in y
@alias(x, @x1) ; x1 initialized in x

line_loop:
cmp @x, @x2
jg line_loop_exit

; draw pixel here

add @slope_error_new, @m_new
cmp @slope_error_new, 0
jl line_error_exit

line_error:
inc @y
sub @slope_error_new, dword @to_sub_from_SEN

line_error_exit:

inc @x
jmp line_loop

line_loop_exit:

mov ebp, [ebp] ; move the original ebp back into itself
mov esp, ebp ; move original esp back into itself
ret

section .text

rect:
push eax ; 12
push ebx ; 8
push ecx ; 4
push edx ; 0

mov esi, [lfb_addr]  
mov edx, [lfb_pitch]  

mov eax, [esp + 8]
mov ebx, [esp]
sub ebx, eax
imul eax, edx
add esi, eax

row_loop_rect:
mov edi, esi
mov eax, [esp + 12]
mov ecx, [esp + 4]
sub ecx, eax 
imul eax, 3              
add edi, eax         

pixel_loop_rect:
mov byte [edi], 0x00
mov byte [edi+1], 0x00
mov byte [edi+2], 0xFF 
add edi, 3
dec ecx
jnz pixel_loop_rect

add esi, edx        
dec ebx
jnz row_loop_rect
ret


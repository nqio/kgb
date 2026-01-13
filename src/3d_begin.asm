pusha

line:
mov eax, 0 ; x1
mov ebx, 0 ; y1
mov ecx, 80 ; x2
mov edx, 80 ; y2

mov edi, edx
sub edx, ebx
mov esi, ecx
sub esi, eax

push eax
push edx
mov eax, edi
cdq
idiv esi
mov edi, eax
pop edx
pop eax

mov esi, ebx
push ecx
mov ecx, edi
imul ecx, eax
sub esi, ecx ; integer y-intercept in esi
pop ecx

; rectangle should be from x1 -> x1 + 1
; y1 -> y1 + (y1 * slope + y-int)

push eax ; 20 x1
push ebx ; 16 y1
push ecx ; 12 x2
push edx ; 8 y2
push edi ; 4 slope
push esi ; 0 y-int

mov esi, [lfb_addr]  
mov edx, [lfb_pitch]  

line_loop:
mov eax, [esp + 16] ; y1
mov ebx, [esp + 20] ; x1
imul ebx, [esp + 4]
add ebx, [esp] ; now y2
mov [esp + 16], ebx

sub ebx, eax
imul eax, edx
add esi, eax

row_loop:
mov edi, esi
mov eax, [esp + 20]
cmp eax, [esp + 12]
jge line_done

mov ecx, eax
inc ecx
mov [esp + 20], ecx

sub ecx, eax
imul eax, 3
add edi, eax

pixel_loop:
mov byte [edi], 0x00
mov byte [edi + 1], 0x00
mov byte [edi + 2], 0xFF
add edi, 3
dec ecx
jnz pixel_loop

add esi, edx
dec ebx
jnz row_loop

line_done:
hlt

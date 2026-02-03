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

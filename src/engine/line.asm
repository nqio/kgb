section .text

line:
@alias(x1, eax)
@alias(y1, ebx)
@alias(x2, ecx)
@alias(y2, edx)

sub @y2, @y1
imul @y2, 2
@alias(m_new, edx)

@alias(slope_error_new, edi)
mov @slope_error_new, @m_new
sub @m_new, @x2
add @m_new, @x1

push @x1
@alias(x1, [esp])
@alias(y, ebx)
@alias(x, eax)

mov @x, @x1


ret

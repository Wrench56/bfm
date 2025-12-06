BITS 64
org 0x400000

%include "elfhdr.inc"

_start:
    mov             eax, 60
    xor             edi, edi
    syscall

_end:

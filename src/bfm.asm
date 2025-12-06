BITS 64
org 0x400000

%include "elfhdr.inc"

%define TAPE_SIZE     30000

_start:
    ; Program pointer (argv[1])
    mov     rbx, [rsp + 16]
    dec     rbx

    ; Reserve tape space on stack
    sub     rsp, TAPE_SIZE

    ; Clear out stack
    xor     eax, eax
    mov     rdi, rsp
    mov     rcx, TAPE_SIZE
    rep     stosb

    ; Tape pointer
    mov     rbp, rsp

.mainloop:
    inc     rbx
    mov     dil, byte [rbx]
    test    dil, dil
    je      .exit

    cmp     dil, '+'
    je      .increment
    cmp     dil, '-'
    je      .decrement
    cmp     dil, '>'
    je      .inccp
    cmp     dil, '<'
    je      .deccp
    cmp     dil, '['
    je      .jumpf
    cmp     dil, ']'
    je      .jumpb
    cmp     dil, '.'
    je      .output
    cmp     dil, ','
    je      .input

    jmp     .mainloop

.increment:
    inc     byte [rbp]
    jmp     .mainloop

.decrement:
    dec     byte [rbp]
    jmp     .mainloop

.inccp:
    inc     rbp
    jmp     .mainloop

.deccp:
    dec     rbp
    jmp     .mainloop

.jumpf:
    cmp     byte [rbp], 0
    jne     .mainloop

    mov     ecx, 1
.jumpf_search:
    inc     rbx

    mov     al, byte [rbx]
    cmp     al, '['
    je      .jumpf_inc_depth
    cmp     al, ']'
    je      .jumpf_dec_depth
    jmp     .jumpf_search

.jumpf_inc_depth:
    inc     ecx
    jmp     .jumpf_search

.jumpf_dec_depth:
    dec     ecx
    jnz     .jumpf_search
    jmp     .mainloop

.jumpb:
    cmp     byte [rbp], 0
    je      .mainloop

    mov     ecx, 1

.jumpb_search:
    dec     rbx
    mov     al, byte [rbx]
    cmp     al, ']'
    je      .jumpb_inc_depth
    cmp     al, '['
    je      .jumpb_dec_depth
    jmp     .jumpb_search

.jumpb_inc_depth:
    inc     ecx
    jmp     .jumpb_search

.jumpb_dec_depth:
    dec     ecx
    jnz     .jumpb_search
    jmp     .mainloop

.output:
    mov     eax, 1
    mov     edi, 1
    mov     edx, 1
    mov     rsi, rbp
    syscall
    jmp     .mainloop

.input:
    mov     eax, 0
    xor     edi, edi
    mov     rsi, rbp
    mov     edx, 1
    syscall
    jmp     .mainloop

; End program
.exit:
    mov     eax, 60
    xor     edi, edi
    syscall

_end:

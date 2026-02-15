BITS 64
org 0x400000

%include "elfhdr.inc"

%define TAPE_SIZE 30000

_start:
    ; Program pointer (argv[1])
    mov     rbx, [rsp + 16]

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
    mov     dil, byte [rbx]
    test    dil, dil
    je      .exit

    sub     dil, '+'
    jz      .increment
    dec     dil ; ','
    jz      .input
    dec     dil ; '-'
    jz      .decrement
    dec     dil ; '.'
    jz      .output
    sub     dil, 14 ; '<'
    jz      .deccp
    sub     dil, 2 ; '>'
    jz      .inccp
    sub     dil, 29 ; '['
    jz      .jumpf
    sub     dil, 2 ; ']'
    jz      .jumpb

.next:
    inc     rbx
    jmp     .mainloop

.increment:
    inc     byte [rbp]
    jmp     .next

.decrement:
    dec     byte [rbp]
    jmp     .next

.inccp:
    inc     rbp
    jmp     .next

.deccp:
    dec     rbp
    jmp     .next

.jumpf:
    cmp     byte [rbp], 0
    jne     .next

    xor     ecx, ecx
    inc     ecx
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
    jmp     .next

.jumpb:
    cmp     byte [rbp], 0
    je      .next

    xor     ecx, ecx
    inc     ecx
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
    jmp     .next

.output:
    xor     eax, eax
    inc     eax
    mov     edi, eax
    mov     edx, eax
    mov     rsi, rbp
    syscall
    jmp     .next

.input:
    xor     eax, eax
    xor     edi, edi
    mov     rsi, rbp
    cdq
    inc     edx
    syscall
    jmp     .next

; End program
.exit:
    mov     eax, 60
    xor     edi, edi
    syscall

_end:

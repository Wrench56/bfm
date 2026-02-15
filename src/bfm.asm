BITS 64
org 0x400000

%include "elfhdr.inc"

%define TAPE_SIZE 30000

_exit:
    mov     eax, 60
    xor     edi, edi
    syscall

_output:
    xor     eax, eax
    inc     eax
    mov     edi, eax
    mov     edx, eax
    push    rsi
    mov     rsi, rbp
    syscall
    pop     rsi
    jmp     _start.mainloop

_input:
    xor     eax, eax
    xor     edi, edi
    push    rsi
    mov     rsi, rbp
    cdq
    inc     edx
    syscall
    pop     rsi
    jmp     _start.mainloop

_start:
    ; Program pointer (argv[1])
    mov     rsi, [rsp + 16]

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
    lodsb
    test    al, al
    je      _exit

    sub     al, '+'
    jz      .increment
    dec     al ; ','
    jz      _input
    dec     al ; '-'
    jz      .decrement
    dec     al ; '.'
    jz      _output
    sub     al, 14 ; '<'
    jz      .deccp
    sub     al, 2 ; '>'
    jz      .inccp
    sub     al, 29 ; '['
    jz      .jumpf
    sub     al, 2 ; ']'
    jz      .jumpb

.next:
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
    lodsb
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
    dec     rsi
.jumpb_search:
    dec     rsi
    mov     al, [rsi]
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

_end:

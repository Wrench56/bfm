elfhdr:
    db 0x7F, "ELF"           ; e_ident[0..3] = 0x7F 'E' 'L' 'F'
    db 2                     ; EI_CLASS = ELFCLASS64
    db 1                     ; EI_DATA = little endian
    db 1                     ; EI_VERSION = 1
    db 0                     ; EI_OSABI = System V
    db 0                     ; EI_ABIVERSION
    times 7 db 0             ; EI_PAD

    dw 2                     ; e_type = ET_EXEC
    dw 0x3E                  ; e_machine = EM_X86_64
    dd 1                     ; e_version = EV_CURRENT
    dq _start                ; e_entry
    dq programhdr - $$       ; e_phoff
    dq 0                     ; e_shoff
    dd 0                     ; e_flags
    dw 64                    ; e_ehsize
    dw 56                    ; e_phentsize
    dw 1                     ; e_phnum
    dw 0                     ; e_shentsize
    dw 0                     ; e_shnum
    dw 0                     ; e_shstrndx

programhdr:
    dd 1                     ; p_type = PT_LOAD
    dd 7                     ; p_flags = PF_X | PF_R | PF_W
    dq 0                     ; p_offset = 0
    dq $$                    ; p_vaddr = 0x400000
    dq $$                    ; p_paddr = 0x400000
    dq _end - $$             ; p_filesz
    dq _end - $$ + TAPE_SIZE ; p_memsz
    dq 0x200000              ; p_align

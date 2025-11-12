; ============================================================================
; FILE: src/gdt.asm
; ============================================================================
; Global Descriptor Table setup

BITS 32

global gdt_install
global gdt_flush

section .data

; GDT structure
gdt_start:
    ; Null descriptor
    dq 0x0000000000000000

gdt_code:
    ; Code segment descriptor
    dw 0xFFFF       ; Limit (bits 0-15)
    dw 0x0000       ; Base (bits 0-15)
    db 0x00         ; Base (bits 16-23)
    db 10011010b    ; Access: present, ring 0, code, executable, readable
    db 11001111b    ; Granularity: 4K pages, 32-bit
    db 0x00         ; Base (bits 24-31)

gdt_data:
    ; Data segment descriptor
    dw 0xFFFF       ; Limit (bits 0-15)
    dw 0x0000       ; Base (bits 0-15)
    db 0x00         ; Base (bits 16-23)
    db 10010010b    ; Access: present, ring 0, data, writable
    db 11001111b    ; Granularity: 4K pages, 32-bit
    db 0x00         ; Base (bits 24-31)

gdt_end:

; GDT descriptor
gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Size
    dd gdt_start                 ; Offset

; Segment selectors (offset into GDT)
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

section .text

gdt_install:
    lgdt [gdt_descriptor]
    jmp CODE_SEG:.flush
.flush:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    ret

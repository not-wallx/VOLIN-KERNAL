; ============================================================================
; FILE: src/idt.asm
; ============================================================================
; Interrupt Descriptor Table setup

BITS 32

global idt_install
global idt_load

section .bss
idt_entries:
    resb 256 * 8  ; 256 IDT entries, 8 bytes each

section .data
idt_ptr:
    dw 256 * 8 - 1      ; Size of IDT
    dd idt_entries      ; Address of IDT

section .text

; Set an IDT gate
; Parameters: EAX = index, EBX = handler address, CL = flags
idt_set_gate:
    push edx
    
    ; Calculate entry address: idt_entries + (index * 8)
    mov edx, 8
    mul edx
    add eax, idt_entries
    
    ; Lower 16 bits of handler address
    mov word [eax], bx
    
    ; Segment selector (code segment)
    mov word [eax + 2], 0x08
    
    ; Reserved byte
    mov byte [eax + 4], 0
    
    ; Flags
    mov byte [eax + 5], cl
    
    ; Upper 16 bits of handler address
    shr ebx, 16
    mov word [eax + 6], bx
    
    pop edx
    ret

idt_install:
    ; Clear all IDT entries
    mov ecx, 256 * 8
    mov edi, idt_entries
    xor al, al
    rep stosb
    ret

idt_load:
    lidt [idt_ptr]
    ret

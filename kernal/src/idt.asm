BITS 32

global idt_install
global idt_load

section .bss
idt_entries:
    resb 256 * 8  

section .data
idt_ptr:
    dw 256 * 8 - 1     
    dd idt_entries     

section .text

idt_set_gate:
    push edx

    mov edx, 8
    mul edx
    add eax, idt_entries
    
    mov word [eax], bx
    
    mov word [eax + 2], 0x08
    
    mov byte [eax + 4], 0
    
    mov byte [eax + 5], cl
    
    shr ebx, 16
    mov word [eax + 6], bx
    
    pop edx
    ret

idt_install:
    mov ecx, 256 * 8
    mov edi, idt_entries
    xor al, al
    rep stosb
    ret

idt_load:
    lidt [idt_ptr]
    ret

BITS 32

extern gdt_install
extern idt_install
extern isr_install
extern irq_install
extern vga_init
extern vga_print
extern keyboard_install

global _start
global kernel_main

section .bss
align 16
stack_bottom:
    resb 16384  
stack_top:

section .text

_start:
    mov esp, stack_top

    cli

    call kernel_main

    cli
.hang:
    hlt
    jmp .hang

kernel_main:
    call gdt_install
    
    call idt_install
    
    call isr_install
    
    call irq_install
    
    call vga_init
    
    call keyboard_install
    
    sti
    
    push welcome_msg
    call vga_print
    add esp, 4
    
    push info_msg
    call vga_print
    add esp, 4

.loop:
    hlt
    jmp .loop

section .data
welcome_msg db 'Welcome to VOLIN 32-bit v1.0', 0x0A, 0
info_msg db 'Type on your keyboard - ISRs and IRQs are active!', 0x0A, 0x0A, 0

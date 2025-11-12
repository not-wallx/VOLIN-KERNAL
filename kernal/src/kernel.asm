; ============================================================================
; FILE: src/kernel.asm
; ============================================================================
; Kernel entry point and main initialization

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
    resb 16384  ; 16KB stack
stack_top:

section .text

_start:
    ; Setup stack pointer
    mov esp, stack_top
    
    ; Clear interrupt flag until we setup IDT
    cli
    
    ; Call kernel main
    call kernel_main
    
    ; Hang if kernel returns
    cli
.hang:
    hlt
    jmp .hang

kernel_main:
    ; Initialize GDT
    call gdt_install
    
    ; Initialize IDT
    call idt_install
    
    ; Install ISRs (CPU exceptions)
    call isr_install
    
    ; Install IRQs (hardware interrupts)
    call irq_install
    
    ; Initialize VGA text mode
    call vga_init
    
    ; Install keyboard driver
    call keyboard_install
    
    ; Enable interrupts
    sti
    
    ; Print welcome message
    push welcome_msg
    call vga_print
    add esp, 4
    
    push info_msg
    call vga_print
    add esp, 4
    
    ; Main kernel loop - just halt and wait for interrupts
.loop:
    hlt
    jmp .loop

section .data
welcome_msg db 'Welcome to 32-bit Protected Mode Kernel v1.0', 0x0A, 0
info_msg db 'Type on your keyboard - ISRs and IRQs are active!', 0x0A, 0x0A, 0

BITS 32

extern idt_set_gate
extern keyboard_handler

global irq_install

PIC1_COMMAND    equ 0x20
PIC1_DATA       equ 0x21
PIC2_COMMAND    equ 0xA0
PIC2_DATA       equ 0xA1

PIC_EOI         equ 0x20
ICW1_INIT       equ 0x11
ICW4_8086       equ 0x01

%macro IRQ 2
global irq%1
irq%1:
    cli
    push byte 0
    push byte %2
    jmp irq_common
%endmacro


IRQ 0, 32       
IRQ 1, 33      
IRQ 2, 34     
IRQ 3, 35     
IRQ 4, 36       
IRQ 5, 37      
IRQ 6, 38      
IRQ 7, 39      
IRQ 8, 40      
IRQ 9, 41      
IRQ 10, 42    
IRQ 11, 43    
IRQ 12, 44    
IRQ 13, 45    
IRQ 14, 46    
IRQ 15, 47    

section .text

irq_common:
    pusha

    push ds
    push es
    push fs
    push gs

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov eax, [esp + 32 + 4]
    sub eax, 32

    cmp eax, 1
    je .keyboard
    jmp .eoi
    
.keyboard:
    call keyboard_handler
    jmp .eoi
    
.eoi:
    mov eax, [esp + 32 + 4]
    cmp eax, 40
    jl .pic1
    
    mov al, PIC_EOI
    out PIC2_COMMAND, al
    
.pic1:
    mov al, PIC_EOI
    out PIC1_COMMAND, al

    pop gs
    pop fs
    pop es
    pop ds

    popa
    
    add esp, 8
    
    iret

pic_remap:
   
    in al, PIC1_DATA
    mov bl, al
    in al, PIC2_DATA
    mov bh, al

    mov al, ICW1_INIT
    out PIC1_COMMAND, al
    out PIC2_COMMAND, al

    mov al, 32
    out PIC1_DATA, al
    mov al, 40
    out PIC2_DATA, al
    
    mov al, 4
    out PIC1_DATA, al
    
    mov al, 2
    out PIC2_DATA, al
    
    mov al, ICW4_8086
    out PIC1_DATA, al
    out PIC2_DATA, al
    
    mov al, bl
    out PIC1_DATA, al
    mov al, bh
    out PIC2_DATA, al
    
    ret

irq_install:
    call pic_remap

    mov cl, 0x8E
    
    mov eax, 32
    mov ebx, irq0
    call idt_set_gate
    
    mov eax, 33
    mov ebx, irq1
    call idt_set_gate
    
    mov eax, 34
    mov ebx, irq2
    call idt_set_gate
    
    mov eax, 35
    mov ebx, irq3
    call idt_set_gate
    
    mov eax, 36
    mov ebx, irq4
    call idt_set_gate
    
    mov eax, 37
    mov ebx, irq5
    call idt_set_gate
    
    mov eax, 38
    mov ebx, irq6
    call idt_set_gate
    
    mov eax, 39
    mov ebx, irq7
    call idt_set_gate
    
    mov eax, 40
    mov ebx, irq8
    call idt_set_gate
    
    mov eax, 41
    mov ebx, irq9
    call idt_set_gate
    
    mov eax, 42
    mov ebx, irq10
    call idt_set_gate
    
    mov eax, 43
    mov ebx, irq11
    call idt_set_gate
    
    mov eax, 44
    mov ebx, irq12
    call idt_set_gate
    
    mov eax, 45
    mov ebx, irq13
    call idt_set_gate
    
    mov eax, 46
    mov ebx, irq14
    call idt_set_gate
    
    mov eax, 47
    mov ebx, irq15
    call idt_set_gate
    
    ret

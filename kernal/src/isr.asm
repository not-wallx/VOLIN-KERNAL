BITS 32

extern idt_set_gate
extern idt_load
extern vga_print_hex

global isr_install

%macro ISR_ERR 1
global isr%1
isr%1:
    cli
    push byte %1
    jmp isr_common
%endmacro

%macro ISR_NOERR 1
global isr%1
isr%1:
    cli
    push byte 0     
    push byte %1
    jmp isr_common
%endmacro


ISR_NOERR 0    
ISR_NOERR 1     
ISR_NOERR 2  
ISR_NOERR 3    
ISR_NOERR 4     
ISR_NOERR 5     
ISR_NOERR 6    
ISR_NOERR 7   
ISR_ERR   8   
ISR_NOERR 9    
ISR_ERR   10  
ISR_ERR   11   
ISR_ERR   12  
ISR_ERR   13  
ISR_ERR   14  
ISR_NOERR 15  
ISR_NOERR 16  
ISR_ERR   17  
ISR_NOERR 18  
ISR_NOERR 19  
ISR_NOERR 20  
ISR_NOERR 21  
ISR_NOERR 22   
ISR_NOERR 23    
ISR_NOERR 24    
ISR_NOERR 25   
ISR_NOERR 26   
ISR_NOERR 27  
ISR_NOERR 28   
ISR_NOERR 29    
ISR_ERR   30    
ISR_NOERR 31   

section .data
exception_msgs:
    dd msg_0, msg_1, msg_2, msg_3, msg_4, msg_5, msg_6, msg_7
    dd msg_8, msg_9, msg_10, msg_11, msg_12, msg_13, msg_14, msg_15
    dd msg_16, msg_17, msg_18, msg_19, msg_20, msg_21, msg_22, msg_23
    dd msg_24, msg_25, msg_26, msg_27, msg_28, msg_29, msg_30, msg_31

msg_0 db 'Exception 0: Divide by Zero', 0
msg_1 db 'Exception 1: Debug', 0
msg_2 db 'Exception 2: NMI', 0
msg_3 db 'Exception 3: Breakpoint', 0
msg_4 db 'Exception 4: Overflow', 0
msg_5 db 'Exception 5: Bound Range Exceeded', 0
msg_6 db 'Exception 6: Invalid Opcode', 0
msg_7 db 'Exception 7: Device Not Available', 0
msg_8 db 'Exception 8: Double Fault', 0
msg_9 db 'Exception 9: Coprocessor Segment Overrun', 0
msg_10 db 'Exception 10: Invalid TSS', 0
msg_11 db 'Exception 11: Segment Not Present', 0
msg_12 db 'Exception 12: Stack-Segment Fault', 0
msg_13 db 'Exception 13: General Protection Fault', 0
msg_14 db 'Exception 14: Page Fault', 0
msg_15 db 'Exception 15: Reserved', 0
msg_16 db 'Exception 16: x87 FPU Error', 0
msg_17 db 'Exception 17: Alignment Check', 0
msg_18 db 'Exception 18: Machine Check', 0
msg_19 db 'Exception 19: SIMD Exception', 0
msg_20 db 'Exception 20: Virtualization Exception', 0
msg_21 db 'Exception 21: Reserved', 0
msg_22 db 'Exception 22: Reserved', 0
msg_23 db 'Exception 23: Reserved', 0
msg_24 db 'Exception 24: Reserved', 0
msg_25 db 'Exception 25: Reserved', 0
msg_26 db 'Exception 26: Reserved', 0
msg_27 db 'Exception 27: Reserved', 0
msg_28 db 'Exception 28: Reserved', 0
msg_29 db 'Exception 29: Reserved', 0
msg_30 db 'Exception 30: Security Exception', 0
msg_31 db 'Exception 31: Reserved', 0

section .text


isr_common:
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

    cmp eax, 31
    ja .done
    
    mov ebx, [exception_msgs + eax * 4]
    push ebx
    extern vga_print
    call vga_print
    add esp, 4
    
.done:
    pop gs
    pop fs
    pop es
    pop ds

    popa

    add esp, 8

    iret

isr_install:

    mov cl, 0x8E 
    
    xor eax, eax
    mov ebx, isr0
    call idt_set_gate
    
    mov eax, 1
    mov ebx, isr1
    call idt_set_gate
    
    mov eax, 2
    mov ebx, isr2
    call idt_set_gate
    
    mov eax, 3
    mov ebx, isr3
    call idt_set_gate
    
    mov eax, 4
    mov ebx, isr4
    call idt_set_gate
    
    mov eax, 5
    mov ebx, isr5
    call idt_set_gate
    
    mov eax, 6
    mov ebx, isr6
    call idt_set_gate
    
    mov eax, 7
    mov ebx, isr7
    call idt_set_gate
    
    mov eax, 8
    mov ebx, isr8
    call idt_set_gate
    
    mov eax, 9
    mov ebx, isr9
    call idt_set_gate
    
    mov eax, 10
    mov ebx, isr10
    call idt_set_gate
    
    mov eax, 11
    mov ebx, isr11
    call idt_set_gate
    
    mov eax, 12
    mov ebx, isr12
    call idt_set_gate
    
    mov eax, 13
    mov ebx, isr13
    call idt_set_gate
    
    mov eax, 14
    mov ebx, isr14
    call idt_set_gate
    
    mov eax, 15
    mov ebx, isr15
    call idt_set_gate
    
    mov eax, 16
    mov ebx, isr16
    call idt_set_gate
    
    mov eax, 17
    mov ebx, isr17
    call idt_set_gate
    
    mov eax, 18
    mov ebx, isr18
    call idt_set_gate
    
    mov eax, 19
    mov ebx, isr19
    call idt_set_gate
    
    mov eax, 20
    mov ebx, isr20
    call idt_set_gate
    
    mov eax, 21
    mov ebx, isr21
    call idt_set_gate
    
    mov eax, 22
    mov ebx, isr22
    call idt_set_gate
    
    mov eax, 23
    mov ebx, isr23
    call idt_set_gate
    
    mov eax, 24
    mov ebx, isr24
    call idt_set_gate
    
    mov eax, 25
    mov ebx, isr25
    call idt_set_gate
    
    mov eax, 26
    mov ebx, isr26
    call idt_set_gate
    
    mov eax, 27
    mov ebx, isr27
    call idt_set_gate
    
    mov eax, 28
    mov ebx, isr28
    call idt_set_gate
    
    mov eax, 29
    mov ebx, isr29
    call idt_set_gate
    
    mov eax, 30
    mov ebx, isr30
    call idt_set_gate
    
    mov eax, 31
    mov ebx, isr31
    call idt_set_gate
    
    call idt_load
    
    ret

BITS 32

global gdt_install
global gdt_flush

section .data

gdt_start:
    dq 0x0000000000000000

gdt_code:
    dw 0xFFFF      
    dw 0x0000     
    db 0x00       
    db 10011010b   
    db 11001111b   
    db 0x00         

gdt_data:
    dw 0xFFFF       
    dw 0x0000      
    db 0x00        
    db 10010010b   
    db 11001111b   
    db 0x00        

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  
    dd gdt_start                 

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

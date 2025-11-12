; ============================================================================
; FILE: src/io.asm
; ============================================================================
; Port I/O functions

BITS 32

global inb
global outb

section .text

; Read byte from port
; Parameter: port number on stack
; Returns: AL = byte read
inb:
    mov dx, [esp + 4]
    in al, dx
    ret

; Write byte to port
; Parameters: port number, byte value on stack
outb:
    mov dx, [esp + 4]
    mov al, [esp + 8]
    out dx, al
    ret

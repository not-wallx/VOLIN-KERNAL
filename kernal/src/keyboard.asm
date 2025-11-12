; ============================================================================
; FILE: src/keyboard.asm
; ============================================================================
; PS/2 Keyboard driver with scan code translation

BITS 32

global keyboard_install
global keyboard_handler

extern vga_putc
extern inb

section .data

; US QWERTY keyboard layout (scan code set 1)
keyboard_map:
    db 0, 27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 8
    db 9, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 13
    db 0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '`'
    db 0, '\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0
    db '*', 0, ' '

keyboard_map_shift:
    db 0, 27, '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', 8
    db 9, 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', 13
    db 0, 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '"', '~'
    db 0, '|', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?', 0
    db '*', 0, ' '

; Keyboard state
shift_pressed   db 0
ctrl_pressed    db 0
alt_pressed     db 0
caps_lock       db 0

section .text

keyboard_install:
    ; Enable keyboard interrupts (unmask IRQ1)
    in al, 0x21
    and al, 0xFD        ; Clear bit 1
    out 0x21, al
    ret

keyboard_handler:
    push eax
    push ebx
    
    ; Read scan code from keyboard data port (0x60)
    in al, 0x60
    
    ; Check for key release (high bit set)
    test al, 0x80
    jnz .key_released
    
    ; Key pressed - handle special keys
    cmp al, 0x2A        ; Left shift
    je .shift_down
    cmp al, 0x36        ; Right shift
    je .shift_down
    cmp al, 0x1D        ; Ctrl
    je .ctrl_down
    cmp al, 0x38        ; Alt
    je .alt_down
    
    ; Translate scan code to ASCII
    movzx ebx, al
    cmp ebx, 58         ; Check if within map range
    jge .done
    
    ; Check if shift is pressed
    cmp byte [shift_pressed], 0
    jne .use_shift
    
    ; Normal key
    mov al, [keyboard_map + ebx]
    jmp .print_char
    
.use_shift:
    mov al, [keyboard_map_shift + ebx]
    jmp .print_char
    
.print_char:
    test al, al
    jz .done
    
    ; Print character
    movzx eax, al
    push eax
    call vga_putc
    add esp, 4
    jmp .done
    
.shift_down:
    mov byte [shift_pressed], 1
    jmp .done
    
.ctrl_down:
    mov byte [ctrl_pressed], 1
    jmp .done
    
.alt_down:
    mov byte [alt_pressed], 1
    jmp .done
    
.key_released:
    ; Clear high bit to get scan code
    and al, 0x7F
    
    ; Check which key was released
    cmp al, 0x2A        ; Left shift
    je .shift_up
    cmp al, 0x36        ; Right shift
    je .shift_up
    cmp al, 0x1D        ; Ctrl
    je .ctrl_up
    cmp al, 0x38        ; Alt
    je .alt_up
    jmp .done
    
.shift_up:
    mov byte [shift_pressed], 0
    jmp .done
    
.ctrl_up:
    mov byte [ctrl_pressed], 0
    jmp .done
    
.alt_up:
    mov byte [alt_pressed], 0
    
.done:
    pop ebx
    pop eax
    ret

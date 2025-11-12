; ============================================================================
; FILE: src/vga.asm
; ============================================================================
; VGA text mode driver (80x25, color)

BITS 32

global vga_init
global vga_print
global vga_putc
global vga_clear
global vga_set_color

section .data
vga_buffer      dd 0xB8000
vga_width       dd 80
vga_height      dd 25
vga_row         dd 0
vga_col         dd 0
vga_color       db 0x0F     ; White on black

section .text

vga_init:
    ; Clear screen and reset cursor
    call vga_clear
    mov dword [vga_row], 0
    mov dword [vga_col], 0
    ret

vga_clear:
    mov edi, [vga_buffer]
    mov ecx, 80 * 25
    mov ax, 0x0F20      ; Space with white on black
.loop:
    mov [edi], ax
    add edi, 2
    loop .loop
    ret

vga_set_color:
    mov al, [esp + 4]
    mov [vga_color], al
    ret

; Put character at current cursor position
; Parameter: character on stack
vga_putc:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    
    mov al, [ebp + 8]   ; Get character
    
    ; Handle special characters
    cmp al, 0x0A        ; Newline
    je .newline
    cmp al, 0x08        ; Backspace
    je .backspace
    jmp .putchar
    
.newline:
    mov dword [vga_col], 0
    inc dword [vga_row]
    jmp .scroll_check
    
.backspace:
    cmp dword [vga_col], 0
    je .done
    dec dword [vga_col]
    
    ; Calculate position and put space
    mov eax, [vga_row]
    mov ebx, [vga_width]
    mul ebx
    add eax, [vga_col]
    mov edi, [vga_buffer]
    lea edi, [edi + eax * 2]
    mov ah, [vga_color]
    mov al, ' '
    mov [edi], ax
    jmp .done
    
.putchar:
    ; Calculate position: (row * width + col) * 2
    mov eax, [vga_row]
    mov ebx, [vga_width]
    mul ebx
    add eax, [vga_col]
    
    ; Write character to video memory
    mov edi, [vga_buffer]
    lea edi, [edi + eax * 2]
    mov ah, [vga_color]
    mov [edi], ax
    
    ; Move cursor forward
    inc dword [vga_col]
    mov eax, [vga_col]
    cmp eax, [vga_width]
    jl .scroll_check
    
    ; Wrap to next line
    mov dword [vga_col], 0
    inc dword [vga_row]
    
.scroll_check:
    ; Check if we need to scroll
    mov eax, [vga_row]
    cmp eax, [vga_height]
    jl .done
    
    ; Scroll up
    call vga_scroll
    dec dword [vga_row]
    
.done:
    pop esi
    pop ebx
    pop ebp
    ret

vga_scroll:
    ; Copy each line up one row
    mov esi, [vga_buffer]
    add esi, 160        ; Skip first line
    mov edi, [vga_buffer]
    mov ecx, 80 * 24    ; 24 lines
    rep movsw
    
    ; Clear last line
    mov edi, [vga_buffer]
    add edi, 80 * 24 * 2
    mov ecx, 80
    mov ax, 0x0F20
.clear_loop:
    mov [edi], ax
    add edi, 2
    loop .clear_loop
    
    ret

; Print null-terminated string
; Parameter: string address on stack
vga_print:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    
    mov esi, [ebp + 8]  ; Get string address
    
.loop:
    lodsb               ; Load byte from [ESI] into AL
    test al, al         ; Check for null terminator
    jz .done
    
    push eax
    call vga_putc
    add esp, 4
    
    jmp .loop
    
.done:
    pop esi
    pop ebx
    pop ebp
    ret

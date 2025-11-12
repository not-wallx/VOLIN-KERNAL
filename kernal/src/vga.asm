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
vga_color       db 0x0F     

section .text

vga_init:
    call vga_clear
    mov dword [vga_row], 0
    mov dword [vga_col], 0
    ret

vga_clear:
    mov edi, [vga_buffer]
    mov ecx, 80 * 25
    mov ax, 0x0F20    
.loop:
    mov [edi], ax
    add edi, 2
    loop .loop
    ret

vga_set_color:
    mov al, [esp + 4]
    mov [vga_color], al
    ret

vga_putc:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    
    mov al, [ebp + 8]  

    cmp al, 0x0A       
    je .newline
    cmp al, 0x08        
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
    
    mov eax, [vga_row]
    mov ebx, [vga_width]
    mul ebx
    add eax, [vga_col]
    
    mov edi, [vga_buffer]
    lea edi, [edi + eax * 2]
    mov ah, [vga_color]
    mov [edi], ax
    
    inc dword [vga_col]
    mov eax, [vga_col]
    cmp eax, [vga_width]
    jl .scroll_check
    

    mov dword [vga_col], 0
    inc dword [vga_row]
    
.scroll_check:
    mov eax, [vga_row]
    cmp eax, [vga_height]
    jl .done
    
    call vga_scroll
    dec dword [vga_row]
    
.done:
    pop esi
    pop ebx
    pop ebp
    ret

vga_scroll:
    mov esi, [vga_buffer]
    add esi, 160       
    mov edi, [vga_buffer]
    mov ecx, 80 * 24   
    rep movsw
    
    mov edi, [vga_buffer]
    add edi, 80 * 24 * 2
    mov ecx, 80
    mov ax, 0x0F20
.clear_loop:
    mov [edi], ax
    add edi, 2
    loop .clear_loop
    
    ret


vga_print:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    
    mov esi, [ebp + 8] 
    
.loop:
    lodsb            
    test al, al      
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

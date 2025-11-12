BITS 32

global mem_init
global kmalloc
global mem_get_used

section .data
heap_start      dd 0x01000000  
heap_current    dd 0x01000000  
heap_end        dd 0x02000000 

section .text

mem_init:
    mov eax, [heap_start]
    mov [heap_current], eax
    ret


kmalloc:
    push ebp
    mov ebp, esp
    push ebx
    
    mov ebx, [ebp + 8]
    
    add ebx, 3
    and ebx, 0xFFFFFFFC
    
    mov eax, [heap_current]
    add eax, ebx
    cmp eax, [heap_end]
    jg .out_of_memory
    
    mov eax, [heap_current]
    add [heap_current], ebx
    
    jmp .done
    
.out_of_memory:
    xor eax, eax        
    
.done:
    pop ebx
    pop ebp
    ret



mem_get_used:
    mov eax, [heap_current]
    sub eax, [heap_start]
    ret

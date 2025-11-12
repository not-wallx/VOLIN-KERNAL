; ============================================================================
; FILE: src/mem.asm
; ============================================================================
; Simple bump allocator for heap memory management

BITS 32

global mem_init
global kmalloc
global mem_get_used

section .data
heap_start      dd 0x01000000   ; Heap starts at 16MB
heap_current    dd 0x01000000   ; Current allocation pointer
heap_end        dd 0x02000000   ; Heap ends at 32MB (16MB available)

section .text

; Initialize memory allocator
mem_init:
    ; Reset heap pointer to start
    mov eax, [heap_start]
    mov [heap_current], eax
    ret

; Allocate memory (simple bump allocator)
; Parameter: size in bytes (on stack)
; Returns: EAX = pointer to allocated memory (or 0 if failed)
kmalloc:
    push ebp
    mov ebp, esp
    push ebx
    
    ; Get requested size
    mov ebx, [ebp + 8]
    
    ; Align size to 4-byte boundary
    add ebx, 3
    and ebx, 0xFFFFFFFC
    
    ; Check if we have enough space
    mov eax, [heap_current]
    add eax, ebx
    cmp eax, [heap_end]
    jg .out_of_memory
    
    ; Allocate memory
    mov eax, [heap_current]
    add [heap_current], ebx
    
    jmp .done
    
.out_of_memory:
    xor eax, eax        ; Return NULL
    
.done:
    pop ebx
    pop ebp
    ret

; Get amount of heap memory used
; Returns: EAX = bytes used
mem_get_used:
    mov eax, [heap_current]
    sub eax, [heap_start]
    ret

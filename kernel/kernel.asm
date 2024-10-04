; 32-bit protected mode code
BITS 32

global _start
extern kernel_main

%define CODE_SEG 0x08
%define DATA_SEG 0x10

_start:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    mov ebp, 0x0200000        ; Set up stack
    mov esp, ebp
    
    ; Clear the screen
    mov ecx, 80 * 25        ; 80 columns * 25 rows
    mov edi, 0xb8000
    mov ax, 0x0720          ; White on black space
    rep stosw
    
    mov esi, msg_pm
    call print_string_pm

   ; Remap the master PIC
    mov al, 00010001b
    out 0x20, al           ; Send the command to the master PIC

    mov al, 0x20           ; Interrupt 0x20 is the starting point of the master PIC interrupt
    out 0x21, al           ; Send the command to the master PIC

    mov al, 00000100b      ; Tell Master PIC that there is a slave PIC at IRQ2
    out 0x21, al           ; Send the command to the master PIC

    mov al, 0000001b       ; Put the master PIC in 8086 mode
    out 0x21, al           ; Send the command to the master PIC

    ;End of PIC remapping
    
    call kernel_main

    jmp $                   ; Hang

print_string_pm:
    pusha
    mov edx, 0xb8000 + 160  ; Start on the second line
.loop:
    lodsb
    test al, al
    je .done
    mov ah, 0x0F            ; White on black
    mov [edx], ax
    add edx, 2
    jmp .loop
.done:
    popa
    ret

msg_pm: db "Now in 32-bit Protected Mode!", 0


times 512 - ($ - $$) db 0

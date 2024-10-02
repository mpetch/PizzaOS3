ORG 0x7C00
BITS 16


_start:
    jmp short start
    nop

times 33 db 0 ; Dummy bios parameter block

start:
    cli             ; Disable interrupts while setting up
    xor ax, ax
    mov ds, ax      ; Set Data Segment to 0x7C0
    mov es, ax      ; Set Extra Segment to 0x7C0
    mov ss, ax      ; Set Stack Segment to 0
    mov sp, 0x7C00  ; Set Stack Pointer to 0x7C00 (standard boot sector load address)
    sti             ; Re-enable interrupts

    mov si, msg_real_mode    ; Load message address into SI register
    call print_string_real_mode  ; Call the print_string function


    call enable_a20         ; Enable A20 line
    call load_gdt           ; Load GDT

    cli                     ; Disable interrupts for mode switch
    mov eax, cr0            ; Switch to protected mode
    or eax, 1
    mov cr0, eax
    
    jmp CODE_SEG:init_pm    ; Far jump to 32-bit code


; Function to print a string in real mode
print_string_real_mode:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string_real_mode
.done:
    ret

; Enable A20 line using the keyboard controller
enable_a20:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

; GDT
gdt_start:
    dq 0x0000000000000000   ; Null descriptor
gdt_code:
    dw 0xFFFF               ; Limit (bits 0-15)
    dw 0x0000               ; Base (bits 0-15)
    db 0x00                 ; Base (bits 16-23)
    db 10011010b            ; Access byte
    db 11001111b            ; Flags and Limit (bits 16-19)
    db 0x00                 ; Base (bits 24-31)
gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Size of GDT
    dd gdt_start                ; Start address of GDT

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; Load GDT
load_gdt:
    lgdt [gdt_descriptor]
    ret

; 32-bit protected mode code
BITS 32
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    mov ebp, 0x90000        ; Set up stack
    mov esp, ebp
    
    ; Clear the screen
    mov ecx, 80 * 25        ; 80 columns * 25 rows
    mov edi, 0xb8000
    mov ax, 0x0720          ; White on black space
    rep stosw
    
    mov esi, msg_pm
    call print_string_pm
    
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

; Define the message to print
msg_real_mode: db "Now in 16-bit Real Mode!", 13, 10, 0
msg_pm: db "Now in 32-bit Protected Mode!", 0

; Pad the boot sector to 510 bytes and add boot signature
times 510 - ($ - $$) db 0
dw 0xAA55


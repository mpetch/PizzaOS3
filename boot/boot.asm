ORG 0
BITS 16


_start:
    jmp short start
    nop

times 33 db 0 ; Dummy bios parameter block

; Start with a far jump to set CS correctly
start:
    jmp 0x7C0:main  ; SETS CS TO 0x7C0

main:
    ; Disable interrupts while setting up
    cli

    ; Set up segment registers
    mov ax, 0x7C0
    mov ds, ax      ; Set Data Segment to 0x7C0
    mov es, ax      ; Set Extra Segment to 0x7C0
    xor ax, ax
    mov ss, ax      ; Set Stack Segment to 0
    mov sp, 0x7C00  ; Set Stack Pointer to 0x7C00 (standard boot sector load address)

    ; Re-enable interrupts
    sti

    ; Continue with the main code
    mov si, message    ; Load message address into SI register
    call print_string  ; Call the print_string function
    jmp $              ; Infinite loop (hang)

; Define the message to print
message: db 'Hello, World!', 0

; Function to print a null-terminated string
print_string:
    mov bx, 0          ; Page number (0) in BH, color in BL (if graphics mode)
    
.loop:
    lodsb              ; Load byte at SI into AL and increment SI
    cmp al, 0          ; Check if it's the null terminator
    je .done           ; If so, we're done
    call print_char    ; Otherwise, print the character
    jmp .loop          ; Continue with next character

.done:
    ret

; Function to print a single character
print_char:
    mov ah, 0eh        ; BIOS teletype output
    int 0x10           ; Call BIOS interrupt
    ret

; Pad the boot sector to 510 bytes and add boot signature
times 510 - ($ - $$) db 0
dw 0xAA55


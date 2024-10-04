ORG 0x7C00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

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
    jmp $

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

; Load GDT
load_gdt:
    lgdt [gdt_descriptor]
    ret

; Define the message to print
msg_real_mode: db "Now in 16-bit Real Mode!", 13, 10, 0

BITS 32
init_pm:
    mov ax, DATA_SEG    ; Load data segment selector
    mov ds, ax          ; Set DS register
    mov es, ax          ; Set ES register
    mov fs, ax          ; Set FS register
    mov gs, ax          ; Set GS register
    mov ss, ax          ; Set SS register
    mov esp, 0x7C00   ; Set stack pointer (example address)

    mov eax, 1          ; 0 is the boot sector, 1 is the first sector of the kernel
    mov ecx, 100        ; 100 (Total sectors to read) sectors to read
    mov edi, 0x0100000  ; Load the kernel at 0x100000
    call ata_lba_read
    jmp CODE_SEG:0x0100000

ata_lba_read:
    mov ebx, eax        ; Backup the LBA

    ; Send the highest 8 bits of the LBA to the hard disk controller
    shr eax, 24
    or al, 0xE0        ; Selects the master drive
    mov dx, 0x1F6
    out dx, al
    ; Finished sending the highest 8 bits of the LBA

    ; Send the total sectors to read to the hard disk controller
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al
    ; Finished sending the total sectors to read

    ; Send more bits of the LBA
    mov eax, ebx        ; Restore the LBA
    mov dx, 0x1F3       ; Port to send the LBA
    out dx, al
    ; Finished sending more  bits of the LBA

    ; Send the more bits of the LBA
    mov eax, ebx        ; Restore the LBA
    mov dx, 0x1F4       ; Port to send the LBA
    shr eax, 8
    out dx, al
    ; Finished sending more bits of the LBA
    
    ; Send the highest 16 bits of the LBA
    mov eax, ebx        ; Restore the LBA
    mov dx, 0x1F5       ; Port to send the LBA
    shr eax, 16
    out dx, al
    ; Finished sending the highest 16 bits of the LBA   

    mov dx, 0x1F7       ; Command port
    mov al, 0x20         ; Read with retry
    out dx, al

    ; Read all sectors into memory
.next_sector:
    push ecx

    ; checking if we need to READ
.try_again:
    mov dx, 0x1F7
    in al, dx
    test al, 8
    jz .try_again

   ; read 256 words at a time
   mov ecx, 256
   mov dx, 0x1F0
   rep insw
   pop ecx
   loop .next_sector
   ret
    

; Pad the boot sector to 510 bytes and add boot signature
times 510 - ($ - $$) db 0
dw 0xAA55


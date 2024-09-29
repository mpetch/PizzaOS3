ORG 0x7C00
BITS 16

message: db 'Hello, World!', 0

start:
    mov si, message
    call print_string
    jmp $

print_string:
    mov bx, 0
.loop:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp .loop

.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10
    ret

times 510 - ($ - $$) db 0
dw 0xAA55


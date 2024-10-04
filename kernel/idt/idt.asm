section .asm

extern int21h_handler
extern no_interrupt_handler

global idt_load
global int21h
global enable_interrupts
global disable_interrupts
global no_interrupt


enable_interrupts:
    sti
    ret

disable_interrupts:
    cli
    ret

idt_load:
    push ebp
    mov ebp , esp

    mov eax , [ebp + 8]
    lidt [eax]

    pop ebp
    ret 

int21h:
    cli
    pushad      ; Pushes the content of all the GPRs onto the stack
    call int21h_handler
    popad       ; Pops the content of all the GPRs off the stack
    sti
    iret        ; pops 5 things off the stack: CS, EIP, EFLAGS, SS, and ESP 


no_interrupt:
    cli
    pushad
    call no_interrupt_handler
    popad
    sti
    iret
ENTRY(_start)

SECTIONS
{
    . = 1M;
    .text : ALIGN(4096) { *(.text) }
    .data : ALIGN(4096) { *(.data) }
    .bss : ALIGN(4096) { 
        *(COMMON)
        *(.bss) 
    }
    .rodata : ALIGN(4096) { *(.rodata) }
    .asm : ALIGN(4096) { *(.asm) }
} 

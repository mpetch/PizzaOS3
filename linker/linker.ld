ENTRY(_start)
OUTPUT_FORMAT(binary)

SECTIONS
{
    . = 1M;
    .text : { *(.text) }
    .data : { *(.data) }
    .bss : { 
        *(COMMON)
        *(.bss) 
    }
    .rodata : { *(.rodata) }
}
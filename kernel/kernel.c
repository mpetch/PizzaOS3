#include "kernel.h"
#include <stdint.h>
#include <stddef.h>
#include "idt/idt.h"
#include "io/io.h"
#include "memory/heap/kheap.h"
#include "memory/paging/paging.h"

uint16_t* video_mem = 0;
uint16_t terminal_row = 0;
uint16_t terminal_col = 0;
static struct paging_4gb_chunk* kernel_chunk = 0;


// ACTUALLY MAKES THE CHAR
uint16_t terminal_make_char (char c , char color){
    return (color<< 8) | c; // x89 is little endian , thus in memory char followed by color will be stored.
}

// DOES NOT KEEP TRACK OF CURSOR POSITION
void terminal_putchar(uint16_t x , uint16_t y , char c , char color){
    const size_t index = y * VGA_WIDTH + x;
    video_mem[index] = terminal_make_char(c, color);
}

//KEEPS TRACK OF CURSOR POSITION
void terminal_writechar(char c , char color){
    if (c == '\n'){
        terminal_col = 0;
        terminal_row ++;
    }
    else{  
        terminal_putchar(terminal_col , terminal_row , c , color);
        if (++terminal_col == VGA_WIDTH){
            terminal_col = 0;
            terminal_row ++;
        }
    }
}

// INITIALIZES TERMINAL
void terminal_initialize(void) {
    terminal_row = 0;
    terminal_col = 0;

    video_mem = (uint16_t*)(0xB8000);

    for (size_t y = 0; y < VGA_HEIGHT; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            terminal_putchar(x, y, ' ', 0);
        }
    }
}

// CALCULATES LENGTH OF STRING
size_t strlen(const char* str){
    size_t len = 0;
    while (str[len])
        len++;
    return len;
}

// PRINTS STRING TO TERMINAL
void print(const char* str){
    size_t len = strlen(str);
    for (size_t i = 0; i < len; i++)
        terminal_writechar(str[i], 15);
}



// MAIN FUNCTION (CALLED BY KERNEL.ASM)
void kernel_main() {
    terminal_initialize();
    print("Hello World \n This is my os \n");
    
    kheap_init();

    print("Initializing IDT...\n");
    idt_init();
    print("IDT initialized.\n");


    // void* ptr1 = kmalloc(50);
    // void* ptr2 = kmalloc(5000);
    // void* ptr3 = kmalloc(5600);
    // if(ptr1){}
    // kfree(ptr1);
    // void* ptr4 = kmalloc(50);
    // if (ptr2 || ptr3 || ptr4){

    // }
// gdb
// add-symbol-file ./build/kernelfull.o 0x100000
// target remote | qemu-system-i386 -hda ./bin/os.bin -S -gdb stdio
// break kernel.c : 90
//continue

        // Setup paging
    kernel_chunk = paging_new_4gb(PAGING_IS_WRITEABLE | PAGING_IS_PRESENT | PAGING_ACCESS_FROM_ALL);

     // Switch to kernel paging chunk
    paging_switch(paging_4gb_chunk_get_directory(kernel_chunk));
    // Enable paging
    enable_paging();

    print("Enabling interrupts...\n");
    enable_interrupts();
    print("Interrupts enabled.\n");

    print("Kernel initialization complete.\n");

}
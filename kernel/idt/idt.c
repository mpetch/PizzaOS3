#include "idt.h"
#include "../config.h"
#include "../memory/memory.h"
#include "../kernel.h"

// Define the variables here
struct idt_desc idt_descriptors[256];
struct idtr_desc idtr_descriptor;

extern void idt_load(struct idtr_desc* ptr);

void idt_zero(){
    print("Divide by zero error\n");
}

void idt_Set(int interrupt_no , void* addr){
    struct idt_desc* desc = &idt_descriptors[interrupt_no];
    desc->offset_1 = (uint32_t)addr & 0x0000FFFF;
    desc->selector = KERNEL_CODE_SEGMENT;
    desc->zero = 0x00;
    desc->type_attr = 0xEE;
    desc->offset_2 = (uint32_t)addr >> 16;
} 

void idt_init(){
    memset(idt_descriptors , 0 , sizeof(idt_descriptors));
    idtr_descriptor.limit = sizeof(idt_descriptors) - 1;
    idtr_descriptor.base = (uint32_t)idt_descriptors; 

    idt_Set(0 , idt_zero);

    // Load the idt
    idt_load(&idtr_descriptor);
}

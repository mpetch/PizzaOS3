FILES = ./build/kernel.asm.o ./build/kernel.o
INCLUDES = -I./kernel/
FLAGS = -g -ffreestanding -falign-jumps -falign-loops -falign-functions -falign-labels -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0	 -Iinc

all: ./bin/boot.bin ./bin/kernel.bin 
	rm -rf ./bin/os.bin
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin 
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin

./bin/boot.bin: ./boot/boot.asm
	nasm -f bin -o ./bin/boot.bin ./boot/boot.asm

#linker is to link all the object files into a single binary file
./bin/kernel.bin: $(FILES)
	i686-elf-ld -g -relocatable $(FILES) -o ./build/kernelfull.o 
	i686-elf-gcc $(FLAGS) -T ./linker/linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./build/kernelfull.o

./build/kernel.asm.o: ./kernel/kernel.asm
	nasm -f elf32 -g -o ./build/kernel.asm.o ./kernel/kernel.asm

./build/kernel.o: ./kernel/kernel.c
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c -o ./build/kernel.o ./kernel/kernel.c

clean:
	rm -rf ./bin/*.bin
	rm -rf ./build/*.o
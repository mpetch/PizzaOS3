FILES = ./build/kernel.asm.o ./build/kernel.o ./build/idt/idt.asm.o ./build/idt/idt.o ./build/memory/memory.o ./build/io/io.asm.o ./build/memory/heap/heap.o ./build/memory/heap/kheap.o ./build/memory/paging/paging.o ./build/memory/paging/paging.asm.o  ./build/disk/disk.o ./build/fs/pparser.o ./build/string/string.o ./build/disk/streamer.o
INCLUDES = -I./kernel/
FLAGS = -g -ffreestanding -falign-jumps -falign-loops -falign-functions -falign-labels -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0	 -Iinc

all: ./bin/boot.bin ./bin/kernel.bin 
	rm -rf ./bin/os.bin
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin 
	dd if=/dev/zero bs=1048576 count=16 >> ./bin/os.bin
	sudo mount -t vfat ./bin/os.bin /mnt/d
	# Copy a file over
	sudo cp ./hello.txt /mnt/d
	sudo umount /mnt/d

./bin/boot.bin: ./boot/boot.asm
	nasm -f bin -o ./bin/boot.bin ./boot/boot.asm

#linker is to link all the object files into a single binary file
./bin/kernel.bin: $(FILES)
	i686-elf-ld -g -relocatable $(FILES) -o ./build/kernelfull.o 
	i686-elf-gcc $(FLAGS) -T ./linker/linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./build/kernelfull.o

./build/kernel.asm.o: ./kernel/kernel.asm
	nasm -f elf32 -g -o ./build/kernel.asm.o ./kernel/kernel.asm

./build/idt/idt.asm.o: ./kernel/idt/idt.asm
	nasm -f elf -g -o ./build/idt/idt.asm.o ./kernel/idt/idt.asm

./build/idt/idt.o: ./kernel/idt/idt.c
	i686-elf-gcc $(INCLUDES) -I./kernel/idt $(FLAGS) -std=gnu99 -c -o ./build/idt/idt.o ./kernel/idt/idt.c

./build/memory/memory.o: ./kernel/memory/memory.c
	i686-elf-gcc $(INCLUDES) -I./kernel/memory $(FLAGS) -std=gnu99 -c -o ./build/memory/memory.o ./kernel/memory/memory.c

./build/kernel.o: ./kernel/kernel.c
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c -o ./build/kernel.o ./kernel/kernel.c

./build/io/io.asm.o: ./kernel/io/io.asm
	nasm -f elf -g -o ./build/io/io.asm.o ./kernel/io/io.asm

./build/memory/heap/heap.o: ./kernel/memory/heap/heap.c
	i686-elf-gcc $(INCLUDES) -I./kernel/memory/heap $(FLAGS) -std=gnu99 -c -o ./build/memory/heap/heap.o ./kernel/memory/heap/heap.c

./build/memory/heap/kheap.o: ./kernel/memory/heap/kheap.c
	i686-elf-gcc $(INCLUDES) -I./kernel/memory/heap $(FLAGS) -std=gnu99 -c -o ./build/memory/heap/kheap.o ./kernel/memory/heap/kheap.c

./build/memory/paging/paging.o: ./kernel/memory/paging/paging.c
	i686-elf-gcc $(INCLUDES) -I./kernel/memory/paging $(FLAGS) -std=gnu99 -c -o ./build/memory/paging/paging.o ./kernel/memory/paging/paging.c

./build/memory/paging/paging.asm.o: ./kernel/memory/paging/paging.asm
	nasm -f elf -g -o ./build/memory/paging/paging.asm.o ./kernel/memory/paging/paging.asm

./build/disk/disk.o: ./kernel/disk/disk.c
		i686-elf-gcc $(INCLUDES) -I./kernel/disk $(FLAGS) -std=gnu99 -c -o ./build/disk/disk.o ./kernel/disk/disk.c

./build/fs/pparser.o: ./kernel/fs/pparser.c
	i686-elf-gcc $(INCLUDES) -I./kernel/fs $(FLAGS) -std=gnu99 -c -o ./build/fs/pparser.o ./kernel/fs/pparser.c

./build/disk/streamer.o: ./kernel/disk/streamer.c
	i686-elf-gcc $(INCLUDES) -I./kernel/disk $(FLAGS) -std=gnu99 -c -o ./build/disk/streamer.o ./kernel/disk/streamer.c

./build/string/string.o: ./kernel/string/string.c
	i686-elf-gcc $(INCLUDES) -I./kernel/string $(FLAGS) -std=gnu99 -c -o ./build/string/string.o ./kernel/string/string.c

clean:
	rm -rf ./bin/*.bin
	rm -rf ./build/*.o
	rm -rf ./build/idt/*.o
	rm -rf ./build/io/*.o
	rm -rf ./build/memory/*.o
	rm -rf ./build/memory/heap/*.o
	rm -rf ./build/memory/paging/*.o
	rm -rf ./build/disk/*.o
	rm -rf ./build/string/*.o

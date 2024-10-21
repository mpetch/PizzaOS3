FILES = ./build/kernel.asm.o ./build/kernel.o ./build/idt/idt.asm.o ./build/idt/idt.o ./build/memory/memory.o ./build/io/io.asm.o ./build/gdt/gdt.o ./build/gdt/gdt.asm.o ./build/memory/heap/heap.o ./build/memory/heap/kheap.o ./build/memory/paging/paging.o ./build/memory/paging/paging.asm.o  ./build/disk/disk.o ./build/fs/pparser.o ./build/string/string.o ./build/disk/streamer.o ./build/fs/file.o ./build/fs/fat/fat16.o
INCLUDES = -I./kernel/
FLAGS = -g -ffreestanding -falign-jumps -falign-loops -falign-functions -falign-labels -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc -fno-pic

all: createdirs ./bin/boot.bin ./bin/kernel.bin
	rm -rf ./bin/os.bin
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=1048576 count=16 >> ./bin/os.bin
	sudo mount -t vfat ./bin/os.bin mnt
	# Copy a file over
	sudo cp ./hello.txt mnt
	sudo umount mnt

./bin/boot.bin: ./boot/boot.asm
	nasm -f bin -o ./bin/boot.bin ./boot/boot.asm

#Link all the object files into a single ELF file
./bin/kernel.elf: $(FILES)
	i686-elf-gcc -T ./linker/linker.ld -o $@ -nostdlib -no-pie $^

./bin/kernel.bin: ./bin/kernel.elf
	i686-elf-objcopy -O binary $< $@

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

./build/fs/file.o: ./kernel/fs/file.c
	i686-elf-gcc $(INCLUDES) -I./kernel/fs $(FLAGS) -std=gnu99 -c ./kernel/fs/file.c -o ./build/fs/file.o

./build/fs/fat/fat16.o: ./kernel/fs/fat/fat16.c
	i686-elf-gcc $(INCLUDES) -I./kernel/fat/fs -I./kernel/fat $(FLAGS) -std=gnu99 -c ./kernel/fs/fat/fat16.c -o ./build/fs/fat/fat16.o

./build/gdt/gdt.o: ./kernel/gdt/gdt.c
	i686-elf-gcc $(INCLUDES) -I./kernel/gdt $(FLAGS) -std=gnu99 -c ./kernel/gdt/gdt.c -o ./build/gdt/gdt.o

./build/gdt/gdt.asm.o: ./kernel/gdt/gdt.asm
	nasm -f elf -g ./kernel/gdt/gdt.asm -o ./build/gdt/gdt.asm.o

createdirs:
	mkdir -p ./mnt/
	mkdir -p ./bin/
	mkdir -p ./build/
	mkdir -p ./build/idt/
	mkdir -p ./build/io/
	mkdir -p ./build/memory/
	mkdir -p ./build/memory/heap
	mkdir -p ./build/memory/paging
	mkdir -p ./build/disk
	mkdir -p ./build/string
	mkdir -p ./build/fs
	mkdir -p ./build/fs/fat
	mkdir -p ./build/gdt

clean:
	rm -rf ./bin/*.bin
	rm -rf ./bin/*.elf
	rm -rf ./build/*.o
	rm -rf ./build/idt/*.o
	rm -rf ./build/io/*.o
	rm -rf ./build/memory/*.o
	rm -rf ./build/memory/heap/*.o
	rm -rf ./build/memory/paging/*.o
	rm -rf ./build/disk/*.o
	rm -rf ./build/string/*.o
	rm -rf ./build/fs/*.o
	rm -rf ./build/fs/fat/*.o
	rm -rf ./build/gdt/*.o
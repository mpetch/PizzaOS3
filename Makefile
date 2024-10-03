FILES = ./build/kernel.asm.o

all: ./bin/boot.bin $(FILES)
	rm -rf ./bin/os.bin
	dd if=./bin/boot.bin of=./bin/os.bin

./bin/boot.bin: ./boot/boot.asm
	nasm -f bin -o ./bin/boot.bin ./boot/boot.asm

./build/kernel.asm.o: ./kernel/kernel.asm
	nasm -f elf32 -g -o ./build/kernel.asm.o ./kernel/kernel.asm

clean:
	rm -f ./bin/*.bin
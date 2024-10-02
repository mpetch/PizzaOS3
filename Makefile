all:
	nasm -f bin -o ./bin/boot.bin boot/boot.asm
	qemu-system-x86_64 -fda ./bin/boot.bin

clean:
	rm -f ./bin/*.bin
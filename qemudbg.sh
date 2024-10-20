qemu-system-i386 -hda bin/os.bin -S -s &
QEMU_PID=$!

gdb bin/kernel.elf \
        -ex 'target remote localhost:1234' \
        -ex 'layout src' \
        -ex 'layout regs' \
        -ex 'break kernel_main' \
        -ex 'continue'

ps --pid $QEMU_PID > /dev/null
if [ "$?" -eq 0 ]; then
    kill -9 $QEMU_PID
fi

stty sane


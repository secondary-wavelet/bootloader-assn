all: loader.bin kernel.bin disk.img

loader.bin: loader.asm
	nasm -f bin loader.asm -o loader.bin

kernel.bin: kernel.asm
	nasm -f bin kernel.asm -o kernel.bin

disk.img: loader.bin kernel.bin
	dd if=/dev/zero of=disk.img bs=512 count=2880 status=none
	dd if=loader.bin of=disk.img bs=512 count=1 conv=notrunc status=none
	dd if=kernel.bin of=disk.img bs=512 count=1 seek=1 conv=notrunc status=none

run: disk.img
	qemu-system-i386 -hda disk.img

clean:
	rm -f loader.bin kernel.bin disk.img

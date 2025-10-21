all: Build/loader.bin Build/kernel.bin Build/disk.img

Build/loader.bin: Code/loader.s | Build
	nasm -f bin Code/loader.s -o Build/loader.bin

Build/kernel.bin: Code/kernel.s | Build
	nasm -f bin Code/kernel.s -o Build/kernel.bin

Build:
	mkdir -p Build

Build/disk.img: Build/loader.bin Build/kernel.bin
	dd if=/dev/zero of=Build/disk.img bs=512 count=2880 status=none
	dd if=Build/loader.bin of=Build/disk.img bs=512 count=1 conv=notrunc status=none
	dd if=Build/kernel.bin of=Build/disk.img bs=512 count=1 seek=1 conv=notrunc status=none

run: Build/disk.img
	qemu-system-i386 -hda Build/disk.img

clean:
	rm -f Build/loader.bin Build/kernel.bin Build/disk.img

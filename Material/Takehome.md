# Takehome

This take home assignment requires you to implement a _minimal x86 bootloader_ that loads a tiny "hello world" kernel from the next disk sector and jumps to it in QEMU.

The implementation uses **16‑bit real mode**, with a **512‑byte boot sector** and a single **512‑byte kernel payload**.

## Prerequisites

You will need the following tools:

* **nasm** — The Netwide Assembler to assemble your bootloader and kernel.
* **qemu-system-x86** — The QEMU emulator to boot and test your disk image.
* **dd** — A tool to write your bootloader and kernel binaries into specific sectors on a disk image.

***

## Overview of the Assignment

You are tasked to build two components to be used together on a bootable disk image:

### 1. `loader.s` (Bootloader)

* Must be a **512-byte flat binary** suitable as a boot sector with the **boot signature `0xAA55`** in the last two bytes.
* Runs in **16-bit real mode**, the CPU mode immediately after power-on or reset.
* Sets up **segment registers** and a **stack** to prepare for further operations.
* Prints a small boot banner using the BIOS text output service (`INT 0x10`, function `AH=0x0E`) — this lets you see that your bootloader is running.
* Uses the **BIOS interrupt `INT 0x13` (Extensions read, AH=0x42)** to read the second sector (LBA 1) into a chosen memory address (usually a safe place like `0x1000` physical).
* Preserves the boot drive number in the **DL** register, as the BIOS provides it when jumping to the bootloader.
* On successful read, transfers control to the loaded kernel with a **far jump** (`jmp` segment:offset) to the chosen memory address.
* On failure, prints a simple error message and halts execution to avoid undefined behavior.

### 2. `kernel.s` (Hello Kernel)

* Also a **512-byte flat binary** designed to be loaded at the same memory address used by the bootloader.
* Runs in **16-bit real mode**.
* Prints `"Hello from kernel!"` to the screen via BIOS teletype output (`INT 0x10`, AH=0x0E).
* Halts by entering an infinite loop (e.g., `jmp $`).

***

## Technical Details and Important Concepts

### Boot drive number

* When the BIOS loads your bootloader into memory at address 0x7c00 and transfers control to it, it places the "boot drive number" in the DL register.
* This drive number identifies the physical device the BIOS booted from, for example:
  * 0x00 for first floppy
  * 0x80 for first hard disk
  * 0x81 for second hard disk, etc.
* Disk read functions via INT 0x13 expect the drive number in DL to specify which device to read from.

### BIOS Interrupts Used

* **`INT 0x10` - Video Services**
  * Used for text output.
  * Function `AH = 0x0E` is “Teletype Output”: prints the character in `AL` on the screen and advances cursor.
  * Can print strings by calling this repeatedly for each character.
* **`INT 0x13` - Disk Services (Extended Read)**
  * The traditional hard disk access interrupt.
  * The extended read function (`AH=0x42`) supports reading sectors via the **LBA (Logical Block Addressing)** method, which allows direct addressing of sectors regardless of disk geometry.
  * This is crucial because CHS addressing (older method) is limited and deprecated.
  * Requires passing a 16-byte Disk Address Packet (DAP) describing the read parameters (buffer address, sector count, starting LBA).

### Disk Address Packet (DAP) Format (for `INT 0x13` / AH=0x42)

| Offset | Size (Bytes) | Description                         |
| ------ | ------------ | ----------------------------------- |
| 0      | 1            | Size of packet (must be 16)         |
| 1      | 1            | Reserved (0)                        |
| 2      | 2            | Number of sectors to read           |
| 4      | 4            | Pointer to buffer (segment:offset)  |
| 8      | 8            | 64-bit starting LBA (sector number) |

Note: Because of real-mode segmentation, pointers must be carefully specified.

### Segment Setup & Stack

* Real mode uses segmented addressing — you must set `DS`, `ES`, `SS`, and `CS` appropriately.
* The stack pointer `SP` should point to a safe, unused memory region to avoid overwriting bootloader or kernel code while pushing/popping data.
* A common choice is to set the stack near the top of low memory (e.g., `0x7c00` or `0x7e00` area for bootloader, or `0xf000` segment).

### Memory Layout & Load Address

* The bootloader code loads the kernel at a physical address like `0x1000` (segment `0x0000`, offset `0x1000`).
* This address should be safe from overwriting the bootloader and BIOS data.
* Both bootloader and kernel must agree on the load address for control transfer.

***

## Building and Testing

1.  **Assemble the bootloader and kernel** using `nasm`:

    ```
    nasm -f bin loader.s -o loader.bin
    nasm -f bin kernel.s -o kernel.bin
    ```
2.  **Create a disk image** (e.g., floppy image of 1440KB):

    ```
    dd if=/dev/zero of=disk.img bs=512 count=2880
    ```
3.  **Write the bootloader and kernel binaries** to appropriate sectors:

    ```
    dd if=loader.bin of=disk.img conv=notrunc bs=512 count=1 seek=0
    dd if=kernel.bin of=disk.img conv=notrunc bs=512 count=1 seek=1
    ```
4.  **Run with QEMU**:

    ```
    qemu-system-i386 -fda disk.img
    ```

You should see the bootloader banner, then `"Hello from kernel!"`.

***

## Extra Recommendations

* Carefully preserve all registers according to calling conventions when calling BIOS interrupts.
* When reading from the disk, check the carry flag after the `INT 0x13` call to detect errors.
* Use infinite loops (e.g., `jmp $`) to halt the system on errors or when your program finishes.

***

## Deliverables

* `loader.s` and `kernel.s` assembly files.
* A **build script or Makefile** automating build steps and disk image creation.
* A screenshot or screen recording showing the output in QEMU.

***

## Optional Extensions

* Extend the bootloader to load multiple sectors continuously to support larger kernels.

***

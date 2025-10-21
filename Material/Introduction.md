# Introduction

## 1. What is a Bootloader?

When a computer is powered on, the CPU does not _immediately_ run an operating system. Instead, it executes a small piece of firmware stored on the motherboard (BIOS or UEFI). This firmware initializes hardware and then looks for a **bootable device** containing a special piece of code: the **bootloader**.

The bootloader has one simple job:\
**Load the operating system kernel into memory and transfer execution to it.**

***

## 2. Boot Process from Hardware Perspective

### (i) Power ON:

* When the power button is pressed, the CPU starts executing instructions from a fixed address mapped to the motherboard firmware chip (BIOS/UEFI ROM).

### (ii) POST (Power-On Self-Test):

* The firmware performs POST, a set of diagnostics that checks the status and integrity of core hardware: CPU, RAM, keyboard, basic display, and storage devices. Any critical problem halts the boot process and often produces a beep code or error message.

### (iii) Firmware Initialisation and Operation:

* BIOS/UEFI loads its settings from non-volatile memory (usually CMOS).
* Boot Device Selection:
  * Consults the stored boot priority list (user-configurable in BIOS/UEFI setup).
  * Sequentially checks each device for bootability (like HDD/SSD, USB, CD/DVD).

### (iv) Bootloader Handoff

* For BIOS: Reads the first sector (MBR) of each device in priority order, looking for the boot signature (0xAA55). If found, loads the 512 bytes at address 0x7c00 and jumps to its code—the bootloader
* For UEFI: Loads the bootloader from the EFI System Partition (ESP) on a GPT disk, as an executable file (e.g., bootx64.efi), and transfers control to it.

### BIOS / UEFI

* **BIOS (Basic Input/Output System)**:
  * Stored in non-volatile memory (flash/ROM chip on the motherboard).
  * Runs in **16-bit real mode** immediately after power-on.
  * Performs the **Power-On Self Test (POST)** to check memory, CPU, keyboard, and other devices.
  * Scans configured boot devices to find valid boot sectors.
* **UEFI (Unified Extensible Firmware Interface)**:
  * Modern replacement for BIOS.
  * Provides a richer environment (32/64-bit support, FAT32 boot partitions).
  * Still responsible for finding and executing a bootloader from disk.

***

### Disk Layout: MBR vs GPT

A bootloader typically resides in the **first sector** of a storage device.

* **Master Boot Record (MBR)**:
  * First 512 bytes of a disk.
  * Contains:
    * **Bootloader code** (usually the first stage).
    * **Partition table** (locations of partitions on disk).
    * **Boot signature (`0xAA55`)** at offset 510–511.
  * Limitations:
    * Supports only **four primary partitions**.
    * Maximum disk size: **2 TB**.
* **GUID Partition Table (GPT)**:
  * Modern replacement for MBR.
  * Allows **many partitions**.
  * Stores partitioning information in multiple locations for redundancy.
  * Still maintains a **protective MBR** for compatibility.

***

## 3. Two-Stage Booting Process

Because a disk sector is only **512 bytes**, a full loader cannot fit into one sector. Hence, many systems split bootloading into two stages.

* **Stage 1**:
  * BIOS loads the first 512 bytes (the boot sector) into memory at `0x7c00` and jumps to it.
  * This code sets up basic segments and possibly prints messages.
  * It then loads the **second stage** bootloader.
* **Stage 2**:
  * More complex code that can parse partition tables and file systems.
  * Loads the actual kernel (e.g., ELF file) into memory.
  * Jumps to the kernel entry point.

***

## 4. Why 16-bit Real Mode?

* BIOS starts the CPU in **16-bit real mode**, a legacy of the original Intel 8086 processor.
* Characteristics:
  * Only 1 MB addressable memory space.
  * Segmented memory model (CS:IP pairing).
  * Direct access to BIOS interrupts (for disk, display, keyboard I/O).
* Transition to **32-bit protected mode** or **64-bit long mode** comes later, when the kernel takes control.

This context is important, because the Pintos bootloader (like many real-mode loaders) runs in **16-bit mode** and uses BIOS interrupts to interact with disks and screens.

***

## 5. The Pintos Bootloader

Pintos includes its own simple bootloader defined in `loader.s`. Here is what it does:

### Execution Flow

1. **BIOS loads boot sector**:
   * BIOS looks at Disk 0, loads sector 0 (512 bytes) to `0x7c00–0x7e00`.
   * Jumps to the code at `0x7c00`.
2. **Segment setup**:
   * Initializes data and stack segments.
   * Prepares a small stack (`~60 KB`).
3. **Serial initialization**:
   * Configures serial port to print messages without relying on VGA.
4. **Disk scanning (MBR parsing)**:
   * Reads the Master Boot Record (sector 0).
   * Verifies MBR signature (`0xAA55`).
   * Checks partition table entries:
     * Looks for partitions of **type `0x20` (Pintos kernel partition)**.
     * Ensures partition is bootable (`0x80` flag).
5. **Kernel loading**:
   * If found, reads kernel sectors into memory starting at `0x20000`.
   * Pintos kernel size is capped at **512 KB**.
   * Prints `"."` after every 16 sectors as progress.
6. **ELF entry point extraction**:
   * Bootloader reads the ELF header of `kernel.bin`.
   * Extracts the start address and prepares a far jump.
7. **Control transfer**:
   * Executes `ljmp` to the kernel entry point.
   * Kernel takes over (executes `start.S`).

***

## 6. Key Learning Outcomes

By the end of this lab, you should understand:

* The role of a bootloader in bridging BIOS/UEFI and the kernel.
* How MBR/GPT defines partition layouts.
* How real-mode limitations impact bootloader design.
* How Pintos’ bootloader mirrors real-world loaders.
* How a bootloader loads and passes execution control to a kernel.

***

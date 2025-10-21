; load program from disk to 0x7C00, to be read and executed
    ORG 0x7C00


setup: ; set up segment registers and stack
    XOR AX, AX
    MOV DS, AX
    MOV ES, AX

    MOV AX, 0x9000
    MOV SS, AX
    MOV SP, 0xFFFF ; 

main: 
; saves DX (DL) for future use
    PUSH DX
; 10 *s followed by a newline
    MOV AL, 42
    MOV CX, 10
    CALL putnc

    MOV SI, newline
    CALL puts

; bootloader status
    MOV SI, bootup
    CALL puts

; 10 *s followed by a newline
    MOV AL, 42
    MOV CX, 10
    CALL putnc

    MOV SI, newline
    CALL puts

; Attempts to load the kernel from the next sector into memory location 0x10000.
; If it succeeds, jumps to that location and start executing kernel code.
; If it fails, prints an error string.
    POP DX
    MOV SI, dap
    MOV AH, 0x42
    INT 0x13
    JC read_failed

    JMP 0x1000:0x0000

read_failed:
    MOV SI, badread
    CALL puts

; inf loop to halt the program
    JMP $

puts: ; prints the length-preceded string starting at [SI]
    MOV CL, [SI]
    XOR CH, CH
    INC SI
.loop:
    LODSB
    MOV AH, 0x0E
    INT 0x10
    LOOP .loop

    RET

putnc: ; prints the ascii character [AL] to the screen, [CX] times
    PUSH CX
.loop:
    MOV AH, 0x0E
    INT 0x10
    LOOP .loop

    POP CX
    RET

data:
    bootup DB 32, "The bootloader is starting up!", 0x0D, 0x0A
    badread DB 19, "Kernel not found!", 0x0D, 0x0A
    newline DB 2, 0x0D, 0x0A
dap:                ; reads disk sector 
    DB 0x10         ; size of DAP
    DB 0            ; reserved
    DW 1            ; number of sectors to be read
    DW 0x0000       ; memory buffer: offset address
    DW 0x1000       ; memory buffer: segment address
    DQ 1            ; logical block address (index) of the sector to be read


; padding and adding boot sector signature
    TIMES 510 - ($-$$) DB 0
    DW 0xAA55  
    
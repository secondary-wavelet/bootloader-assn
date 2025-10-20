; load program from disk to 0x7C00, to be read and executed
    ORG 0x7C00

setup: ; set up segment registers and stack
    ; MOV AX, 0x7C00
    XOR AX, AX
    MOV DS, AX
    MOV ES, AX

    MOV AX, 0x9000
    MOV SS, AX
    MOV SP, 0xFFFF ; 

main: 
    MOV AL, 42
    MOV CX, 10
    CALL putnc

    MOV SI, newline
    CALL puts

    MOV SI, bootup
    CALL puts

    MOV AL, 42
    MOV CX, 10
    CALL putnc

    MOV SI, newline
    CALL puts

    MOV AH, 0x42
    

; inf loop to halt the program
    JMP $

puts: ; prints the length-preceded string starting at [SI]
    MOV CL, [SI]
    XOR CH, CH
    INC SI
.loop:
    ; MOV AH, 0x00
    ; INT 0x16
    LODSB
    MOV AH, 0x0E
    INT 0x10
    LOOP .loop

    RET

putnc: ; prints the ascii character [AL] to the screen, [CX] times
    PUSH CX
.loop:
    ; PUSH AX
    MOV AH, 0x0E
    INT 0x10
    ; POP AX
    LOOP .loop

    POP CX
    RET

data:
    bootup DB 32, "The bootloader is starting up!", 0x0D, 0x0A
    newline DB 2, 0x0D, 0x0A

; padding and adding boot sector signature
    TIMES 510 - ($-$$) DB 0
    DW 0xAA55  
    
; load program from disk to 0x7C00, to be read and executed
    ORG 0x7C00

; setup segment registers and stack
    XOR AX, AX
    MOV DS, AX
    MOV SS, AX
    MOV SP, 0xF000 ; 60KB stack

; simple program that prints five asterisks to the screen
    MOV CX, 5
looping:
    MOV AH, 0x0E
    MOV AL, 42
    INT 0x10
    LOOP looping

; inf loop to halt the program
    JMP $

; padding and adding boot sector signature
    TIMES 510 - ($-$$) DB 0
    DW 0xAA55
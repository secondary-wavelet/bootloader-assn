setup: ; set up segment registers and stack
    MOV AX, 0x1000
    MOV DS, AX
    MOV ES, AX

    MOV AX, 0x1700
    MOV SS, AX
    MOV SP, 0xFFFF ; 

    MOV SI, hellostr
    CALL puts

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

data:
    hellostr DB 20, "Hello from kernel!", 0x0D, 0x0A
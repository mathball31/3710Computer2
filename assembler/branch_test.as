MOV_IMM 0x8 r6
CMPI 0x1 r6
JMP_REL 7 r14 NE
    //#r6 == 1, SNES is up
    SUBI 80 r7
    //'1'
    MOV_IMM 0x0200 r11
    MOV_IMM 0x302d r12
    STOR r11 r12
//#r6 != 1
CMPI 0x2 r6
JMP_REL 7 r14 NE
    //#r6 == 2, SNES is down
    ADDI 80 r7
    //'2'
    MOV_IMM 0x0300 r11
    MOV_IMM 0x302e r12
    STOR r11 r12
//#r6 != 2
CMPI 0x4 r6
JMP_REL 7 r14 NE
    //#r6 == 4, SNES is left
    SUBI 1 r7
    //'4'
    MOV_IMM 0x0500 r11
    MOV_IMM 0x302f r12
    STOR r11 r12
//#r6 != 4
CMPI 0x8 r6
JMP_REL 7 r14 NE
    //#r6 == 8, SNES is right
    ADDI 1 r7
    //'8'
    MOV_IMM 0x0900 r11
    MOV_IMM 0x3030 r12
    STOR r11 r12
print_addr

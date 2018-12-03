//Snakeeeeeeee
/*

Start of code: 0x000


End of code:

Start of Frame_buffer:
End of Frame_buffer:

Start of Glyphs:
End of Gylphs:

Start of snakes:
End of snakes:


End of memory: 0xFFF


Size of screen: 60x80

Size of board: 59x80


Register Conventions:
NOTE: even regs SNES_0, odd regs SNES_1
r0: SNES_0
r1: SNES_1
    0: B
    1: Y
    2: Select
    3: Start
    4: Up
    5: Down
    6: Left
    7: Right
    8: A
    9: X
   10: L
   11: R

r2: snake_0_head
r3: snake_1_head
    [11:0] ptr to head_location
    [13:12] direction
        NOTE: 13: up/down vs left/right
        00: up
        01: down
        10: left
        11: right

r4: snake_0_tail
r5: snake_1_tail
    [12:0] offset from board_start


r14: JMP_IMM/JMP_REL
r15: JAL/Return


*/


//Start/Init
//TODO jump to Main loop
JMP_IMM 0x100 r14 UC 



//#Main loop
@100
//read controllers
SNES 0 r0
//move
    //TODO get head_location

    //r12 is snake head_location
    MOV_IMM 0x0FFF r12
    AND r2 r12
    LOAD r12 r12

    //read snake location and direction

    // snake_0_head.vertical
    MOV_IMM 0x2000 r6
    AND r2 r6
    CMPI 0 r6
    //#jmp if snake is moving horizontally
    JMP_REL 23 r14 NE
    //#vertical
        // snes.left
        MOV_IMM 0x0040 r6
        AND r0 r6
        CMPI 0 r6
        //#jmp if snes not left
        JMP_REL 5 r14 EQ
            //#snes is left
            SUBI 1 r12
            JMP_IMM 0x132 r14 UC
        //#snes is not left
        // snes.right
        MOV_IMM 0x0050 r6
        AND r0 r6
        CMPI 0 r6
        //#jmp if snes not right
        JMP_IMM 0x132 r14 EQ
            //#snes is right
            ADDI 1 r12
            JMP_IMM 0x132 r14 UC


        //#snes is not right
    //#horizontal
        // snes.up
        MOV_IMM 0x0010
        AND r0 r6
        //#jmp if snes not up
        JMP_REL 5 r14 EQ
            //#snes is up
            //TODO pixel
            SUBI 80 r12
            JMP_IMM 0x132 r14 UC
        //#snes is not up
        // snes.down
        MOV_IMM 0x0020 r6
        AND r0 r6
        //#jmp if snes not down
        JMP_IMM 0x132 r14 UC
            //#snes is down
            ADDI 80 r12
            JMP_IMM 0x132 r14 UC
        //#snes is not down

//end of move ifs
//TODO main_loop + 32
@132


//Increment snake_0_head ptr
ADDI 1 r2
//TODO check if wraps snake buffer
//#write snake location r12
STOR r12 r2




//check overlap

//loop
JMP_IMM 0x100 r14 UC


//Snake buffer
@200

//Snakeeeeeeee
/*

Start of code: 0x000


End of code:

Start of Frame_buffer:  0xF000
End of Frame_buffer:    0xF960

Start of Glyphs:
End of Gylphs:

Start of snakes:
End of snakes:


End of memory: 0xFFFF


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
    [11:0] offset from frame_buffer to head_location
    [12] is high byte vs low byte of addr word
    [14:13] direction
        NOTE: 14: up/down vs left/right
        00: up
        01: down
        10: left
        11: right

r4: snake_0_tail
r5: snake_1_tail
    [12:0] offset from board_start


r14: JMP_IMM/JMP_REL
r15: JAL/Return

Structs lol
glyph {
    [8:7] direction to next snake piece in frame_buffer
        NOTE: 13: up/down vs left/right
        00: up
        01: down
        10: left
        11: right
    [6:0] offset in glyph table
        if [6:4] == 3'b111
            glyph is part of game
            [3:0] game piece
                000: wall
                001: food
                010: head_0
                011: head_1
                100: tail_0
                101: tail_1
                110: body_0
                111: body_1
        else
            glyph is text etc
}
        

*/


//Start/Init
//TODO jump to Main loop
JMP_IMM 0x1000 r14 UC 

//#void update_head(r6(snake_dir), r7(SNES_dir), r8(head_ptr), r9(head_byte))
/*
    writes body segment at head_ptr with pointer to new head
    moves head_ptr
    write new head at head_ptr
*/
@100




//#Main loop
@1000
//read controllers
SNES 0 r0
//move

    

//#put snake_dir in r6
    MOV_IMM 0x0600 r6
    AND r2 r6
    LRSHI 13 r6
    MOVI 0x01 r9
    LSH r6 r9
    MOV r9 r6
//r6 is snake_dir
//#put snes_dir in r7
    MOVI 0xF0 r7
    AND r0 r7
    LRSHI 4 r7
//r7 is snes_dir
//#put head_ptr in r8
    MOV_IMM 0x0FFF r8
    AND r2 r8
    MOV_IMM 0xF000 r14
    ADD r14 r8
//r8 is head_ptr
//#put head_byte in r9
    MOV_IMM 0x1000 r9
    AND r2 r9
    LRSHI 12 r9
//r9 is head_byte
//#call 
//#update_head(r6(snake_dir), r7(SNES_dir), r8(head_ptr), r9(head_byte))
JAL_IMM 0x0100 r14
    

    /*
    MOV_IMM 0x0FFF r12
    MOV_IMM 0x1000 r13
    //r12 is offset part of r2 (snake_head)
    AND r2 r12
    MOV_IMM 0xF000 r14
    //r12 is address to head
    ADD r14 r12
    //r12 is word holding snake head
    LOAD r12 r12
    //r13 is snake head_byte
    AND r2 r13

    CMPI 0 r13
    //jmp high byte
    JMP_REL 5 r14 NE
    //head is in low byte
        //r12 is snake head
        ANDI 0xFF r12
        JMP_REL 2 r14 UC
    //head is in high byte
        //r12 is snake head
        LRSHI 8 r12
    //end jmp


    

    //read snake location and direction

    //TODO make head point to new head location
    // snake_0_head.vertical
    MOV_IMM 0x4000 r6
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
            SUBI 1 r2
            //set head_glyph_direction
            XOR
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
*/


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

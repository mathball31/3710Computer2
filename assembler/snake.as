//#---------Start/Init---------
//Initialize head_0 starting location and direction
MOV_IMM 0x61F4 r2
/*
MOV_IMM 0xFE00 r6
MOV_IMM 0x30FA r7
STOR r6 r7
STOP
*/

//#r2 has head_0 initial value
//#---------End Start/Init---------
JMP_IMM 0x1000 r14 UC 

//#void set_glyph(r6(dir), r7(glyph_ptr), r8(glyph_byte), r9(glyph_num))
/*
    Sets the glyph at [glyph_ptr].glyph_byte to {dir, glyph_num}
*/
@100
//put glyph_word in r10
LOAD r10 r7
//#glyph_word is in r10
//put low_byte of head_word in r11
MOV_IMM 0x00FF r11
AND r10 r11
//#low_byte is in r11
//put high_byte of head_word in r12
MOV_IMM 0xFF00 r12
AND r10 r12
//#high_byte is in r12
//set direction and glyph number of glyph
//put glyph in r6
LLSHI 6 r6
OR r9 r6
//#r6 has glyph
//calculate glyph_word, put in r6
CMPI 1 r8
// handle high vs low byte
JMP_REL 7 r14 NE
    //glyph is in low_byte
    MOVI 0xFF r8
    AND r8 r6
    OR r12 r6
    JMP_REL 3 r14 UC
//glyph is in high_byte
    LLSHI 8 r6
    OR r11 r6
//#r6 has glyph_word
//write glyph_word
STOR r6 r7
//#return
JMP r15 UC



//#r6(2_bit_dir) 4bit_to_2bit(r6(4_bit_dir))
/*
    Takes a direction in 4 bit form
    returns a direction in 2 bit form
*/
@200
MOV r6 r7
ANDI 8 r7
CMPI 0 r7
JMP_REL 3 r14 EQ
    //#move right
    MOVI 0x03 r6
    JMP r15 UC
MOV r6 r7
ANDI 4 r7
CMPI 0 r7
JMP_REL 3 r14 EQ
    //#move left
    MOVI 0x02 r6
    JMP r15 UC
MOV r6 r7
ANDI 2 r7
CMPI 0 r7
JMP_REL 3 r14 EQ
    //#move Down
    MOVI 0x01 r6
    JMP r15 UC
MOV r6 r7
ANDI 1 r7
CMPI 0 r7
JMP_REL 3 r14 EQ
    //#move up
    MOVI 0x00 r6
    JMP r15 UC
JMP r15 UC

/*
CMPI 0x1 r6
JMP_REL 3 r14 NE
    //#r6 == 1
    MOVI 0x00 r6
    JMP r15 UC
//#r6 != 1
CMPI 0x2 r6
JMP_REL 3 r14 NE
    //#r6 == 2
    MOVI 0x01 r6
    JMP r15 UC
//#r6 != 2
CMPI 0x4 r6
JMP_REL 3 r14 NE
    //#r6 == 4
    MOVI 0x10 r6
    JMP r15 UC
//#r6 != 4
CMPI 0x8 r6
JMP_REL 2 r14 NE
    //#r6 == 8
    MOVI 0x11 r6
//#return
*/
JMP r15 UC


//#r7(new_head) update_head(r6(dir), r7(head_copy))
/*
    gets a new value of the head given a copy of the old one and the direction to move
    */
@300
//MOVI 1 r8
//AND r6 r8
//#r8 is low bit
//LRSHI 1 r6
//#r6 is high bit
//MOV r8 r9
//OR r6 r9
/*
//#r9 is r6 || r8
CMPI 0 r9
JMP_REL 8 r14 NE
    //#!r6 && !r8, SNES is up
    //'0'
    MOV_IMM 0x0100 r9
    MOV_IMM 0x3040 r10
    STOR r9 r10
    SUBI 80 r7
    JMP r15 UC
//#r6 != 0
MOV r8 r9

MOV r6 r9
XORI 1 r9
AND r8 r9
//#r9 is !r6 && r8
CMPI 0 r9
JMP_REL 8 r14 EQ
    //#!r6 && r8, SNES is down
    //'1'
    MOV_IMM 0x0200 r9
    MOV_IMM 0x3040 r10
    STOR r9 r10
    ADDI 80 r7
    JMP r15 UC
//#r6 != 1
MOV r8 r9
XORI 1 r9
AND r6 r9
//#r9 is r6 && !r8
CMPI 0 r9
JMP_REL 7 r14 EQ
    //#r6 && !r8, SNES is left

    //'2'
    MOV_IMM 0x0300 r9
    MOV_IMM 0x3040 r10
    STOR r9 r10
    SUBI 1 r7
    JMP r15 UC
//#r6 != 2
MOV r8 r9
AND r6 r9
//r9 has r6 && r8
CMPI 0 r9
JMP_REL 8 r14 EQ
    //#r6&&r8, SNES is right
    //'3'
    MOV_IMM 0x0400 r9
    MOV_IMM 0x3040 r10
    STOR r9 r10
    ADDI 1 r7
    JMP r15 UC
    */
CMPI 0x00 r6
JMP_REL 8 r14 NE
    //#r6 == 0, SNES is up
    //'0'
    MOV_IMM 0x0100 r9
    MOV_IMM 0x3040 r10
    STOR r9 r10
    SUBI 80 r7
    JMP r15 UC
//#r6 != 0
CMPI 0x01 r6
JMP_REL 8 r14 NE
    //#r6 == 1, SNES is down
    //'1'
    MOV_IMM 0x0200 r9
    MOV_IMM 0x3040 r10
    STOR r9 r10
    ADDI 80 r7
    JMP r15 UC
//#r6 != 1
CMPI 0x02 r6
JMP_REL 8 r14 NE
    //#r6 == 2, SNES is left
    //'2'
    MOV_IMM 0x0300 r9
    MOV_IMM 0x3040 r10
    STOR r9 r10
    SUBI 1 r7
    JMP r15 UC
//#r6 != 2
CMPI 0x03 r6
JMP_REL 8 r14 NE
    //#r6 == 3, SNES is right
    //'3'
    MOV_IMM 0x0400 r9
    MOV_IMM 0x3040 r10
    STOR r9 r10
    ADDI 1 r7
    JMP r15 UC
//#r6 != 8, something is wrong
//'A'
MOV_IMM 0x0B00 r9
MOV_IMM 0x3035 r10
STOR r9 r10
JMP r15 UC

//#r6(2bit new_dir) get_dir(r6(2bit snes_dir), r7(2bit snake_dir))
/*
    returns the direction of snake after a button press
    */
@400
MOVI 2 r8
AND r7 r8
//#r8 is orientation bit of snake
MOVI 2 r9
AND r6 r9
//#r9 is orientation bit of snes
CMP r8 r9
JMP_REL 2 r14 NE
    //#r8 == r9
    // return snake direction
    MOV r7 r6
//#r8 != r9
//return snes direction
//r6 already has snes direction
//#return
JMP r15 UC






//#---------Main loop---------
@1000
//read controllers
SNES 0 r0
//#r0 has SNES_0

//if snes0 has direction input, call function
MOV_IMM 0x00F0 r6
AND r0 r6
LRSHI 4 r6
CMPI 0 r6
JMP_REL 17 r14 EQ
    //r6 != 0
    //#call
    //#r6(2_bit_dir) 4bit_to_2bit(r6(4_bit_dir))
    JAL_IMM 0x200 r14
    //#r6 has 2bit snes dir
    //put 2bit snake_dir in r7
    MOV_IMM 0x6000 r7
    AND r2 r7
    LRSHI 13 r7
    //#r7 has 2bit snake_dir
    //#call
    //#r6(2bit new_dir) get_dir(r6(2bit snes_dir), r7(2bit snake_dir))
    JAL_IMM 0x400 r14
    //#r6 has 2bit new_snake_dir
    MOV_IMM 0x9FFF r7
    AND r2 r7
    //put dir in correct spot for r2
    LLSHI 13 r6
    OR r6 r7
    MOV r7 r2
    //#r2 has new direction
    //r6 == 0

    

//#-----Write Body-----
//put snake_dir in r6
MOV_IMM 0x6000 r6
AND r2 r6
LRSHI 13 r6
//#r6(dir) is snake_dir
//put head_ptr in r7
MOV_IMM 0x1FFE r7
AND r2 r7
LRSHI 1 r7
//Frame buffer start
MOV_IMM 0x3000 r14
ADD r14 r7
//#r7(glyph_ptr) is head_ptr
//put head_byte in r8
MOV_IMM 0x0001 r8
AND r2 r8
//#r8(glyph_byte) is head_byte
//put glyph.body_0 in r9
MOV_IMM 0x3E r9
//#r9(glyph_num) is glyph.body_0
//#call 
//#set_glyph(r6(dir), r7(glyph_ptr), r8(glyph_byte), r9(glyph_num))
JAL_IMM 0x0100 r14
//#check that set_glyph returns
//'1'
MOV_IMM 0x0200 r10
MOV_IMM 0x302a r11
STOR r10 r11
//#-----End Write Body-----
    
print_addr
//#-----Update head_ptr-----
//put snake_dir in r6
MOV_IMM 0x6000 r6
AND r2 r6
MOV r6 r8
//#r8 has snake_dir
LRSHI 13 r6
//#r6 has 2_bit snake_dir
//put offset into r7
MOV_IMM 0x1FFF r7
AND r2 r7
//#r7 has a copy of r2
//#call
//#r7(new_head location) update_head(r6(dir), r7(head_copy))
JAL_IMM 0x300 r14
//update r2
MOV_IMM 0x1FFF r9
AND r9 r7
OR r8 r7
MOV r7 r2
//#r2 has a new value
//#-----End Update head_ptr-----


//#-----Write Head-----
//put snes_dir in r6
MOV_IMM 0x6000 r6
AND r2 r6
LRSHI 13 r6
//#r6(dir) is 2bit snake_dir
//put head_ptr in r7
MOV_IMM 0x1FFE r7
AND r2 r7
LRSHI 1 r7
//Frame buffer start
MOV_IMM 0x3000 r14
ADD r14 r7
//#r7(glyph_ptr) is head_ptr
//put head_byte in r8
MOV_IMM 0x0001 r8
AND r2 r8
//#r8(glyph_byte) is head_byte
//put glyph.body_0 in r9
MOV_IMM 0x3A r9
//#r9(glyph_num) is glyph.body_0
//#call 
//#set_glyph(r6(dir), r7(glyph_ptr), r8(glyph_byte), r9(glyph_num))
JAL_IMM 0x0100 r14
//#check that set_glyph returns
//'1'
MOV_IMM 0x0300 r6
MOV_IMM 0x302b r7
STOR r6 r7
//#-----End Write Head-----
//check overlap

//#Busy wait
MOVI 0 r6
MOV_IMM 37900 r7
ADDI 1 r6
NOP
CMP r7 r6
JMP_REL -3 r14 LT


//#---------End Main Loop---------
JMP_IMM 0x1000 r14 UC


@3000
//#-----Frame_Buffer start-----
INIT
0000
0100
0200
0300
0400
0500
0600
0700
0800
0900
0a00
0b00
0c00
0d00
0e00
0f00
1000
1100
1200
1300
1400
1500
1600
1700
END


//#-----Frame_Buffer end-----
@3960

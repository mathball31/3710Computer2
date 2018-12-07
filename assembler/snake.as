//#---------Start/Init---------
//Initialize head_0 starting location and direction
MOV_IMM 0x61F4 r2

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

//#init tail_0
MOV_IMM 0x01F4 r4

//#wait until input
SNES 0 r0
CMPI 0 r0
JMP_REL -2 r14 EQ

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
//TODO
JMP_REL 25 r14 NE
    //glyph is in low_byte
    //check r11
    MOVI 0x38 r10
    AND r11 r10
    XORI 0x38 r10
    //#r10 has !game_glyph
    CMPI 0 r10
    JMP_REL 6 r14 NE
        //overlapped
        //TODO
        MOV_IMM 0x1 r13
        JMP_REL 3 r14 UC
    //no overlap
    MOV_IMM 0x0 r13

    MOVI 0xC0 r10
    AND r11 r10
    LRSHI 2 r10
    //#r10 has dir for tail
    //put byte direction in r13 for tail
    OR r10 r13

    MOVI 0xFF r8
    AND r8 r6
    OR r12 r6
    JMP_REL 24 r14 UC
//glyph is in high_byte
    //check r12
    MOVI 0x38 r10
    MOV r12 r14
    LRSHI 8 r14
    AND r14 r10
    XORI 0x38 r10
    //#r10 has !game_glyph
    CMPI 0 r10
    JMP_REL 6 r14 NE
        //overlapped
        //TODO
        MOV_IMM 0x1 r13
        JMP_REL 3 r14 UC
    //no overlap
    MOV_IMM 0x0 r13

    MOV_IMM 0xC000 r10
    AND r12 r10
    LRSHI 10 r10
    //#r10 has dir for tail
    //put byte direction in r13 for tail
    OR r10 r13

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
JMP r15 UC


//#r7(new_head) update_ptr(r6(dir), r7(head_copy))
/*
    gets a new value of the head given a copy of the old one and the direction to move
    */
@300
CMPI 0x00 r6
JMP_REL 3 r14 NE
    //#r6 == 0, SNES is up
    SUBI 80 r7
    JMP r15 UC
//#r6 != 0
CMPI 0x01 r6
JMP_REL 3 r14 NE
    //#r6 == 1, SNES is down
    ADDI 80 r7
    JMP r15 UC
//#r6 != 1
CMPI 0x02 r6
JMP_REL 3 r14 NE
    //#r6 == 2, SNES is left
    SUBI 1 r7
    JMP r15 UC
//#r6 != 2
CMPI 0x03 r6
JMP_REL 3 r14 NE
    //#r6 == 3, SNES is right
    ADDI 1 r7
    JMP r15 UC
//#r6 != 8, something is wrong
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

//-----Set Direction-----
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
//#-----End Set Direction-----

    

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
//#-----End Write Body-----

//save direction
//MOV_IMM 0x3F00 r14
//STOR r13 r14
    
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
//#r7(new_head location) update_ptr(r6(dir), r7(head_copy))
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
//#-----End Write Head-----

//#-----Overlap-----

MOVI 0x3 r6
AND r6 r13
CMPI 0 r13
JMP_REL 2 r14 EQ
    //overlap
    STOP

//#-----End Overlap-----
//#-----Get tail dir-----
MOV_IMM 0x1FFE r6
AND r4 r6
LRSHI 1 r6
MOV_IMM 0x3000 r14
ADD r14 r6
//#r6 has tail glyph_ptr
MOVI 0x01 r7
AND r4 r7
//#r7 has glyph_byte
LOAD r8 r6
//#r8 has glyph_word
CMPI 0 r7
JMP_REL 8 r14 NE
    //#in high byte
    MOV_IMM 0xC000 r9
    AND r8 r9
    LRSHI 14 r9
    //r9 has tail direction
    JMP_REL 4 r14 UC
//#in low byte
    MOVI 0xC0 r9
    AND r8 r9
    LRSHI 6 r9

MOV_IMM 0x3F00 r14
STOR r9 r14
//#-----End Get tail dir-----

//#-----Write Tail-----
MOV_IMM 0x0 r6
//#r6 has dir (0)
MOV_IMM 0x9FFE r7
AND r4 r7
LRSHI 1 r7
MOV_IMM 0x3000 r14
ADD r14 r7
//#r7 has tail_ptr
MOVI 1 r8
AND r4 r8
//#r8 has tail_byte
MOVI 0x00 r9
//r9 is empty space glyph
//#call
//#set_glyph(r6(dir), r7(glyph_ptr), r8(glyph_byt), r9(glyph_num))
JAL_IMM 0x100 r14
//#-----End Write Tail-----

//#-----Update Tail-----

MOV_IMM 0x3F00 r14
LOAD r6 r14
//#r6 has dir for tail
MOV r4 r7

//#call
//#r7(new_head location) update_ptr(r6(dir), r7(head_copy))
JAL_IMM 0x300 r14 
MOV r7 r4

//#-----End Update Tail-----


//#Busy wait
MOVI 0 r6
MOV_IMM 37900 r7
ADDI 1 r6
NOP
NOP
NOP
NOP
CMP r7 r6
JMP_REL -6 r14 LT


//#---------End Main Loop---------
JMP_IMM 0x1000 r14 UC


@3000
//#-----Frame_Buffer start-----
INIT
//initial head_0
0000

// one row is roughly 28 addresses - skip a row for looks
@3028
0000
3e00

// starting a wall
@3078
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3800

@30c7
0038
3800

// add 28 for each consecutive line
@30ef
0038
3800

@3117
0038
3800

@313f
0038
3800

@3167
0038
3800

@318f
0038
3800

@31b7
0038
3800

@31df
0038
3800

@3207
0038
3800

@322f
0038
3800

@3257
0038
3800

@327f
0038
3800

@32a7
0038
3800

@32cf
0038
3800

@32f7
0038
3800

@331f
0038
3800

@3347
0038
3800

@336f
0038
3800

@3397
0038
3800

@33bf
0038
3800

@33e7
0038
3800

@340f
0038
3800

@3437
0038
3800

@345f
0038
3800

@3487
0038
3800

@34af
0038
3800

@34d7
0038
3800

@34ff
0038
3800

@3527
0038
3800

@354f
0038
3800

@3577
0038
3800

@359f
0038
3800

@35c7
0038
3800

@35ef
0038
3800

@3527
0038
3800

@354f
0038
3800

@3577
0038
3800

@359f
0038
3800

@35c7
0038
3800

@35ef
0038
3800

@3617
0038
3800

@363f
0038
3800

@3667
0038
3800

@368f
0038
3800

@36b7
0038
3800

@36df
0038
3800

@3707
0038
3800

@372f
0038
3800

@3757
0038
3800

@377f
0038
3800

@37a7
0038
3800

@37cf
0038
3800

@37f7
0038
3800

@381f
0038
3800

@3847
0038
3800

@386f
0038
3800

@3897
0038
3800

@38bf
0038
3800

@38e7
0038
3800

@390f
0038
3800

@3937
0038
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838
3838



END


//#-----Frame_Buffer end-----
@3960

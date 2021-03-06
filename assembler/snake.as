//#---------Start/Init---------
//Initialize head_0 starting location and direction
MOV_IMM 0x6974 r2
MOV_IMM 0x499C r3

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

//put head1_ptr in r7
MOV_IMM 0x1FFE r7
AND r3 r7
LRSHI 1 r7
//Frame buffer start
MOV_IMM 0x3000 r14
ADD r14 r7
//#r7(glyph_ptr) is head1_ptr
//put head_byte in r8
MOV_IMM 0x0001 r8
AND r3 r8
//#r8(glyph_byte) is head_byte
//put glyph.body_0 in r9
MOV_IMM 0x3B r9
//#r9(glyph_num) is glyph.body_0
//#call 
//#set_glyph(r6(dir), r7(glyph_ptr), r8(glyph_byte), r9(glyph_num))
JAL_IMM 0x0100 r14

//#init tail_0
MOV_IMM 0x0974 r4
//#init tail_1
MOV_IMM 0x099C r5

//#wait until start
SNES 0 r0
CMPI 8 r0
JMP_REL 6 r14 EQ
SNES 1 r1
CMPI 8 r1
JMP_REL -7 r14 NE

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
JMP_IMM 0x12f r14 NE
    //glyph is in low_byte
    //check r11 for overlap
    MOVI 0x3F r10
    AND r11 r10
    //#r10 has !game_glyph
    CMPI 0x39 r10
    JMP_REL 6 r14 NE
        //food
        MOV_IMM 0x2 r13
        JMP_REL 14 r14 UC
    ANDI 0x38 r10
    XORI 0x38 r10
    CMPI 0 r10
    JMP_REL 6 r14 NE
        //overlapped non-food
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
    //was 24
    JMP_IMM 0x150 r14 UC
    print_addr
//glyph is in high_byte
    //check r12 for overlap
    MOVI 0x3F r10
    MOV r12 r14
    LRSHI 8 r14
    AND r14 r10
    //#r10 has !game_glyph
    CMPI 0x39 r10
    JMP_REL 6 r14 NE
        //food
        MOV_IMM 0x2 r13
        JMP_REL 14 r14 UC
    ANDI 0x38 r10
    XORI 0x38 r10
    CMPI 0 r10
    JMP_REL 6 r14 NE
        //overlapped non-food
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
    print_addr
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

//# void reset_screen()
@500
//wait for start
SNES 0 r0
CMPI 8 r0
JMP_REL 6 r14 EQ
SNES 1 r1
CMPI 8 r1
JMP_REL -7 r14 NE


//wait until no button presses
SNES 0 r0
SNES 1 r1
OR r1 r0
CMPI 0 r0
JMP_REL -4 r14 NE


MOV_IMM 0x2000 r6
MOV_IMM 0x3000 r7
MOV_IMM 0x2960 r8
ADDI 1 r6
ADDI 1 r7
LOAD r9 r6
STOR r9 r7
CMP r6 r8
JMP_REL -5 r14 LT
//#return
JMP r15 UC


//# void busy_wait()
@600
//#Busy wait
MOVI 0 r6
MOV_IMM 39900 r7
ADDI 1 r6
NOP
NOP
NOP
NOP
NOP
CMP r7 r6
JMP_REL -7 r14 LT

MOVI 0 r6
MOV_IMM 39900 r7
ADDI 1 r6
NOP
NOP
NOP
NOP
NOP
CMP r7 r6
JMP_REL -7 r14 LT

//#return
JMP r15 UC




//#---------Main loop---------
@1000
//#---------Snake 0---------
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
MOVI 0x1 r7
AND r13 r7
CMPI 0 r7
//TODO
JMP_REL 28 r14 EQ
    MOV_IMM 0x3044 r7
    MOVI 0 r8
    MOVI 0x21 r9
    //#set_glyph(r6(dir), r7(glyph_ptr), r8(glyph_byte), r9(glyph_num))
    JAL_IMM 0x0100 r14

    MOV_IMM 0x3045 r7
    MOVI 0 r8
    MOVI 0x13 r9
    //#set_glyph(r6(dir), r7(glyph_ptr), r8(glyph_byte), r9(glyph_num))
    JAL_IMM 0x0100 r14

    MOV_IMM 0x3046 r7
    MOVI 0 r8
    MOVI 0x18 r9
    //#set_glyph(r6(dir), r7(glyph_ptr), r8(glyph_byte), r9(glyph_num))
    JAL_IMM 0x0100 r14
    //# void reset_screen()
    //#call 
    JAL_IMM 0x500 r14
    JMP_IMM 0x0 r14 UC

MOVI 0x2 r7
AND r13 r7
CMPI 0 r13
//skip tail if we ate food
//TODO
JMP_IMM 0x10AD r14 NE


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
    //r9 has tail direction

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
JMP_IMM 0x10d1 r14 UC
print_addr
//TODO jmp past update food
//#-----Update Food-----
MOV_IMM 0x3F01 r14
LOAD r12 r14
//update counter
ADDI 1 r12
//#r12 has food counter
//get a glyph pointer 
LOAD r6 r12
CMPI 0 r6 
//retry if result == 0
JMP_REL -3 r14 EQ
//Check that the memory address is in frame buffer
MOV_IMM 0x0FFE r7
AND r6 r7
LRSHI 1 r7
//#r7 has an offset from frame_buffer
MOV_IMM 0x0840 r8
CMP r7 r8
//jump to start & get a new num if r7 > r8 (maybe)
JMP_REL -12 r14 HI
//TODO

MOV_IMM 0x3140 r14
ADD r14 r7
//#r7 has food_ptr
//check that word doesn't have any overlap
LOAD r10 r7
//#r10 has food_destination_word
CMPI 0 r10
//retry if word has a glyph in it already
JMP_REL -21 r14 NE

MOVI 1 r8
AND r6 r8
//#r8 has food_byte
MOVI 0x39 r9
//#r9 has food_num

//#store counter
MOV_IMM 0x3F01 r14
STOR r12 r14

//#call
//#set_glyph(r6(dir), r7(glyph_ptr), r8(glyph_byt), r9(glyph_num))
JAL_IMM 0x100 r14
//#r7 has glyph_ptr





//#-----End Update Food-----
//#---------End Snake 0---------
print_addr

//#---------Snake 1---------
//read controllers
SNES 1 r1
//#r1 has SNES_1

//-----Set Direction-----
//if snes0 has direction input, call function
MOV_IMM 0x00F0 r6
AND r1 r6
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
    AND r3 r7
    LRSHI 13 r7
    //#r7 has 2bit snake_dir
    //#call
    //#r6(2bit new_dir) get_dir(r6(2bit snes_dir), r7(2bit snake_dir))
    JAL_IMM 0x400 r14
    //#r6 has 2bit new_snake_dir
    MOV_IMM 0x9FFF r7
    AND r3 r7
    //put dir in correct spot for r3
    LLSHI 13 r6
    OR r6 r7
    MOV r7 r3
    //#r3 has new direction
    //r6 == 0
//#-----End Set Direction-----

    

//#-----Write Body-----
//put snake_dir in r6
MOV_IMM 0x6000 r6
AND r3 r6
LRSHI 13 r6
//#r6(dir) is snake_dir
//put head_ptr in r7
MOV_IMM 0x1FFE r7
AND r3 r7
LRSHI 1 r7
//Frame buffer start
MOV_IMM 0x3000 r14
ADD r14 r7
//#r7(glyph_ptr) is head_ptr
//put head_byte in r8
MOV_IMM 0x0001 r8
AND r3 r8
//#r8(glyph_byte) is head_byte
//put glyph.body_1 in r9
MOV_IMM 0x3F r9
//#r9(glyph_num) is glyph.body_0
//#call 
//#set_glyph(r6(dir), r7(glyph_ptr), r8(glyph_byte), r9(glyph_num))
JAL_IMM 0x0100 r14
//#-----End Write Body-----

print_addr
//#-----Update head_ptr-----
//put snake_dir in r6
MOV_IMM 0x6000 r6
AND r3 r6
MOV r6 r8
//#r8 has snake_dir
LRSHI 13 r6
//#r6 has 2_bit snake_dir
//put offset into r7
MOV_IMM 0x1FFF r7
AND r3 r7
//#r7 has a copy of r3
//#call
//#r7(new_head location) update_ptr(r6(dir), r7(head_copy))
JAL_IMM 0x300 r14
//update r3
MOV_IMM 0x1FFF r9
AND r9 r7
OR r8 r7
MOV r7 r3
//#r3 has a new value
//#-----End Update head_ptr-----

//#-----Write Head-----
//put snes_dir in r6
MOV_IMM 0x6000 r6
AND r3 r6
LRSHI 13 r6
//#r6(dir) is 2bit snake_dir
//put head_ptr in r7
MOV_IMM 0x1FFE r7
AND r3 r7
LRSHI 1 r7
//Frame buffer start
MOV_IMM 0x3000 r14
ADD r14 r7
//#r7(glyph_ptr) is head_ptr
//put head_byte in r8
MOV_IMM 0x0001 r8
AND r3 r8
//#r8(glyph_byte) is head_byte
//put glyph.head_1 in r9
MOV_IMM 0x3B r9
//#r9(glyph_num) is glyph.head_1
//#call 
//#set_glyph(r6(dir), r7(glyph_ptr), r8(glyph_byte), r9(glyph_num))
JAL_IMM 0x0100 r14
//#-----End Write Head-----

//#-----Overlap-----

MOVI 0x3 r6
AND r6 r13
MOVI 0x1 r7
AND r13 r7
CMPI 0 r7
JMP_REL 28 r14 EQ
    MOV_IMM 0x302f r7
    MOVI 0 r8
    MOVI 0x21 r9
    //#set_glyph(r6(dir), r7(glyph_ptr), r8(glyph_byte), r9(glyph_num))
    JAL_IMM 0x0100 r14

    MOV_IMM 0x3030 r7
    MOVI 0 r8
    MOVI 0x13 r9
    //#set_glyph(r6(dir), r7(glyph_ptr), r8(glyph_byte), r9(glyph_num))
    JAL_IMM 0x0100 r14

    MOV_IMM 0x3031 r7
    MOVI 0 r8
    MOVI 0x18 r9
    //#set_glyph(r6(dir), r7(glyph_ptr), r8(glyph_byte), r9(glyph_num))
    JAL_IMM 0x0100 r14
    //# void reset_screen()
    //#call 
    JAL_IMM 0x500 r14
    JMP_IMM 0x0 r14 UC

MOVI 0x2 r7
AND r13 r7
CMPI 0 r13
//skip tail if we ate food
//TODO
JMP_IMM 0x117e r14 NE


//#-----End Overlap-----
//#-----Get tail dir-----
MOV_IMM 0x1FFE r6
AND r5 r6
LRSHI 1 r6
MOV_IMM 0x3000 r14
ADD r14 r6
//#r6 has tail glyph_ptr
MOVI 0x01 r7
AND r5 r7
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
    //r9 has tail direction

MOV_IMM 0x3F00 r14
STOR r9 r14
//#-----End Get tail dir-----

//#-----Write Tail-----
MOV_IMM 0x0 r6
//#r6 has dir (0)
MOV_IMM 0x9FFE r7
AND r5 r7
LRSHI 1 r7
MOV_IMM 0x3000 r14
ADD r14 r7
//#r7 has tail_ptr
MOVI 1 r8
AND r5 r8
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
MOV r5 r7

//#call
//#r7(new_head location) update_ptr(r6(dir), r7(head_copy))
JAL_IMM 0x300 r14 
MOV r7 r5

//#-----End Update Tail-----
JMP_IMM 0x11a2 r14 UC
print_addr
//TODO jmp past update food
//#-----Update Food-----
MOV_IMM 0x3F01 r14
LOAD r12 r14
//update counter
ADDI 1 r12
//#r12 has food counter
//get a glyph pointer 
LOAD r6 r12
CMPI 0 r6 
//retry if result == 0
JMP_REL -3 r14 EQ
//Check that the memory address is in frame buffer
MOV_IMM 0x0FFE r7
AND r6 r7
LRSHI 1 r7
//#r7 has an offset from frame_buffer
MOV_IMM 0x0840 r8
CMP r7 r8
//jump to start & get a new num if r7 > r8 (maybe)
JMP_REL -12 r14 HI
//TODO

MOV_IMM 0x3140 r14
ADD r14 r7
//#r7 has food_ptr
//check that word doesn't have any overlap
LOAD r10 r7
//#r10 has food_destination_word
CMPI 0 r10
//retry if word has a glyph in it already
JMP_REL -21 r14 NE

MOVI 1 r8
AND r6 r8
//#r8 has food_byte
MOVI 0x39 r9
//#r9 has food_num

//#store counter
MOV_IMM 0x3F01 r14
STOR r12 r14

//#call
//#set_glyph(r6(dir), r7(glyph_ptr), r8(glyph_byt), r9(glyph_num))
JAL_IMM 0x100 r14
//#r7 has glyph_ptr





//#-----End Update Food-----
print_addr
//#---------End Snake 1---------

//#Busy wait
MOVI 0 r6
MOV_IMM 39900 r7
ADDI 1 r6
NOP
NOP
NOP
NOP
NOP
CMP r7 r6
JMP_REL -7 r14 LT

MOVI 0 r6
MOV_IMM 39900 r7
ADDI 1 r6
NOP
NOP
NOP
NOP
NOP
CMP r7 r6
JMP_REL -7 r14 LT


//#---------End Main Loop---------
JMP_IMM 0x1000 r14 UC


@2000
//-----Frame_Buffer copy start-----
INIT

// one row is roughly 28 addresses - skip a row for looks
@2028
001a
0016
000b
0023
000b
003e

@2038
001d
0018
000b
0015
000f
0026

@2048
001a
0016
000b
0023
000b
003f

// starting a wall
@2078
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

@20c7
0038
3800

// add 28 for each consecutive line
@20ef
0038
3800

@2117
0038
3800

@213f
0038
3800

@2167
0038
3800

@218f
0038
3800

@219a
0039

@21b7
0038
3800

@21df
0038
3800

@2207
0038
3800

@222f
0038
3800

@2257
0038
3800

@227f
0038
3800

@22a7
0038
3800

@22cf
0038
3800

@22f7
0038
3800

@231f
0038
3800

@2322
0039

@2347
0038
3800

@236f
0038
3800

@2397
0038
3800

@23bf
0038
3800

@23db
0039

@23e7
0038
3800

@240f
0038
3800

@2430
0039

@2437
0038
3800

@245f
0038
3800

@2487
0038
3800

@24af
0038
3800

@24d7
0038
3800

@24ff
0038
3800

@2527
0038
3800

@254f
0038
3800

@2577
0038
3800

@258a
0039

@259f
0038
3800

@25c7
0038
3800

@25ef
0038
3800

@2527
0038
3800

@254f
0038
3800

@2577
0038
3800

@259f
0038
3800

@25c7
0038
3800

@25ef
0038
3800

@2617
0038
3800

@263f
0038
3800

@2667
0038
3800

@268f
0038
3800

@26b7
0038
3800

@26df
0038
3800

@2707
0038
3800

@272f
0038
3800

@2757
0038
3800

@277f
0038
3800

@27a7
0038
3800

@27cf
0038
3800

@27f0
0039

@27f7
0038
3800

@2710
0039

@281f
0038
3800

@2847
0038
3800

@286f
0038
3800

@2897
0038
3800

@28aa
0039

@28bf
0038
3800

@28e7
0038
3800

@290f
0038
3800

@2937
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

//-----Frame_Buffer copy end-----


@3000
//-----Frame_Buffer start-----
INIT

// one row is roughly 28 addresses - skip a row for looks
@3028
001a
0016
000b
0023
000b
003e

@3038
001d
0018
000b
0015
000f
0026

@3048
001a
0016
000b
0023
000b
003f

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

@319a
0039

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

@3322
0039

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

@33db
0039

@33e7
0038
3800

@340f
0038
3800

@3430
0039

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

@358a
0039

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

@37f0
0039

@37f7
0038
3800

@3710
0039

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

@38aa
0039

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

//-----Frame_Buffer end-----



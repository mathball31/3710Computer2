//Start/Init
//TODO jump to Main loop
JMP_IMM 0x1000 r14 UC 

//#void set_glyph(r6(dir), r7(glyph_ptr), r8(glyph_byte), r9(glyph_num))
/*
    Sets the glyph at [glyph_ptr].glyph_byte to {dir, glyph_num}
*/
@100
//put glyph_word in r10
LOAD r10 r7
//#head_word is in r10
//put low_byte of head_word in r11
MOVI 0xFF r11
AND r10 r11
//#low_byte is in r11
//put high_byte of head_word in r12
MOV_IMM 0xFF00 r12
AND r10 r12
//#high_byte is in r12
//set direction and glyph number of glyph
//put glyph in r6
LLSHI 6 r6
ADD r9 r6
//#r6 has glyph
//calculate glyph_word, put in r6
CMPI 0 r8
JMP_REL 5 r14 NE
    //glyph is in low_byte
    ADD r12 r6
    JMP_REL 3 r14 UC
//glyph is in high_byte
    LLSHI 8 r6
    ADD r11 r6
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
CMPI 0x1 r6
JMP_REL 5 r14 NE
    //r6 == 1
    MOVI 0x00 r6
    JMP_IMM 0x21d r14 UC
//r6 != 1
CMPI 0x2 r6
JMP_REL 5 r14 NE
    //r6 == 2
    MOVI 0x01 r6
    JMP_IMM 0x21d r14 UC
//r6 != 2
CMPI 0x4 r6
JMP_REL 5 r14 NE
    //r6 == 4
    MOVI 0x10 r6
    JMP_IMM 0x21d r14 UC
//r6 != 4
CMPI 0x8 r6
JMP_REL 5 r14 NE
    //r6 == 8
    MOVI 0x11 r6
@21d
//#return
JMP r15 UC





//#---------Main loop---------
@1000
//read controllers
SNES 0 r0
//#r0 has SNES_0
//move
/*
    done: writes body segment at head_ptr with pointer to new head
    moves head_ptr
    write new head at head_ptr
*/
    

//#-----Write Body-----
//put snes_dir in r6
MOVI 0xF0 r6
AND r0 r6
LRSHI 4 r6
//#call
//#r6(2_bit_dir) 4bit_to_2bit(r6(4_bit_dir))
JAL_IMM 0x0200 r14
//#r6(dir) is snes_dir
//put head_ptr in r7
MOV_IMM 0x0FFF r7
AND r2 r7
MOV_IMM 0xF000 r14
ADD r14 r7
//#r7(glyph_ptr) is head_ptr
//put head_byte in r8
MOV_IMM 0x1000 r8
AND r2 r8
LRSHI 12 r8
//#r8(glyph_byte) is head_byte
//put glyph.body_0 in r9
MOV_IMM 0x3E r9
//#r9(glyph_num) is glyph.body_0
//#call 
//#set_glyph(r6(dir), r7(glyph_ptr), r8(glyph_byte), r9(glyph_num))
JAL_IMM 0x0100 r14
//#-----End Write Body-----
    
@1016
//#-----Update head_ptr-----
//put snes_dir in r6
MOVI 0xF0 r6
AND r0 r6
LRSHI 4 r6
//#r6 has snes_dir
//move head_ptr
CMPI 0x1 r6
JMP_REL 5 r14 NE
    //r6 == 1, SNES is up
    SUBI 80 r2
    JMP_IMM 0x1036 r14 UC
//r6 != 1
CMPI 0x2 r6
JMP_REL 5 r14 NE
    //r6 == 2, SNES is down
    ADDI 80 r2
    JMP_IMM 0x1036 r14 UC
//r6 != 2
CMPI 0x4 r6
JMP_REL 5 r14 NE
    //r6 == 4, SNES is left
    SUBI 1 r2
    JMP_IMM 0x1036 r14 UC
//r6 != 4
CMPI 0x8 r6
JMP_REL 5 r14 NE
    //r6 == 8, SNES is right
    ADDI 1 r2
//#-----End Update head_ptr-----

@1036
//#-----Write Head-----
//put snes_dir in r6
MOVI 0xF0 r6
AND r0 r6
LRSHI 4 r6
//#call
//#r6(2_bit_dir) 4bit_to_2bit(r6(4_bit_dir))
JAL_IMM 0x0200 r14
//#r6(dir) is snes_dir
//put head_ptr in r7
MOV_IMM 0x0FFF r7
AND r2 r7
MOV_IMM 0xF000 r14
ADD r14 r7
//#r7(glyph_ptr) is head_ptr
//put head_byte in r8
MOV_IMM 0x1000 r8
AND r2 r8
LRSHI 12 r8
//#r8(glyph_byte) is head_byte
//put glyph.head_0 in r9
MOV_IMM 0x3a r9
//#r9(glyph_num) is glyph.body_0
//#call
//#set_glyph(r6(dir), r7(glyph_ptr), r8(glyph_byte), r9(glyph_num))
JAL_IMM 0x0100 r14
//#-----End Write Head-----
//check overlap

//#---------End Main Loop---------
JMP_IMM 0x1000 r14 UC


@F000
//#-----Frame_Buffer start-----
//#initial head_0
@F05A
INIT
    FA00
END

//#-----Frame_Buffer end-----
@F960
/*//Here we will place the glyphs into memory, commented out for now
@what address do we put here?
INIT
// encode black space: 000000
0000
0000
0000
0000
//encode 0: 000001
3C66
C7CB
D3E3
663C
//ecode 1:  000010
1838
1818
1818
1818
//encode 2:  000011
3C66
0306
0C18
307E
//  3:  000100
3C66
031E
0366
3C00
//  4:  000101
0C1C
3C6C
CCFF
0C0C
// 5:  000110
FFC0
C07C
0603
C67C
// 6:  000111
0C18
307C
C6C3
663C
// 7:  001000
FFC3
061F
0C18
3060
// 8:  001001
7EC3
C37E
C3C3
C37E
// 9:  001010
7EC3
C37E
0303
633E
// A:  001011
183C
66C3
FFC3
C3C3
// B:  001100
FEC3
C3FE
C3C3
C3FE
// C:  001101
3E63
C0C0
C0C0
633E
// D:  001110
FCC6
C3C3
C3C3
C6FC
// E:  001111
FFC0
C0C0
FEC0
C0FF
// F:  010000
FFC0
C0C0
FEC0
C0C0
// G: 010001
3E63
C3C0
C0CF
663C
// H: 010010
C3C3
C3C3
FFC3
C3C3
// I: 010011
FF18
1818
1818
18FF
// J: 010100
FF0C
0C0C
0CCC
6C38
// K: 010101
C3C6
CCD8
F0D8
CCC6
// L: 010110
C0C0
C0C0
C0C0
C0FF
// M: 010111
C3E7
FFDB
C3C3
C3C3
// N: 011000
C3C3
E3F3
DBCF
C7C3
// O: 011001
3C66
C3C3
C3C3
663C
// P: 011010
FCC6
C3C6
FCC0
C0C0
// Q: 011011
3C66
C3C3
663C
0C07
// R: 011100
FCC6
C3FE
F0D8
CCC7
// S: 011101
7EC3
C030
0C03
663E
// T: 011110
FF18
1818
1818
1818
// U: 011111
C3C3
C3C3
C3C3
663C
// V: 100000
C3C3
C3C3
C366
3C18
// W: 100001
C3C3
C3C3
C3DB
FF66
// X: 100010
C3C3
663C
183C
66C3
// Y: 100011
C3C3
663C
1818
1818
// Z: 100100
FF06
0C18
3060
C0FF
// -: 100101
0000
0000
3C00
0000
// !: 100110
1818
1818
1818
0018
//... skip some codes

// Wall(Magenta):  111000
FFFF
FFFF
FFFF
FFFF
FFFF
// Food(red): 111001
007E
7E7E
7E7E
7E00
// Head_0(Green): 111010
FFFF
FFE7
E7FF
FFFF
// Head_1(Blue): 111011
FFFF
FFE7
E7FF
FFFF
// Tail_0(Green): 111100
FFFF
FFFF
FFFF
FFFF
// Tail_1(Blue): 111101
FFFF
FFFF
FFFF
FFFF
// Body_0(Green): 111110
FFFF
FFFF
FFFF
FFFF
// Body_1(Blue): 111111
FFFF
FFFF
FFFF
FFFF
END
*/

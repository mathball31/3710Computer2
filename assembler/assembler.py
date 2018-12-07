SREC_OUTPUT     = True
#SREC_OUTPUT     = False
'''
3710 Assembler
(Mostly) Follows the CR16 manual on ISA.pdf (linked on the course)

Usage: 
    python assembler.py path/to/input_file /path/to/output_file

    takes an input file written in our homebrew (mostly) CR16 assembly
    and outputs a file in machine code for our CPU.

    Any output after the first two lines indicates an error, 
    but the file will still likely compile.
    *** PLEASE RESOLVE ERRORS OR YOU WILL BE SAD***

If there is any output except "name of source file" and "name of dest f

Commands take the following possible forms:
    COMMAND         //Additional info
        EXAMPLE
    IMM val dst     //val must fit in a single byte. can be signed or unsigned
        ADDI 100 r0
        CMPI -45 r5
        LUI 33 r13
    INS src dst     //src and dst takes form r0, r1 etc up through r15
        SUB r1 r5
        AND r0 r15
        LSH r1 r0
    JAL lnk dst     //JAL can take one or two arguments
        JAL r1 r9
    JAL dst         //set lnk to r15
        JAL r10
    JMP reg cond    //possible conditions in jmp_cond
        JMP r1 EQ
    SHIFTI val dst  //val must fit in 4 bits. Is unsigned
        LLSHI 4 r8
    SNES cont dst   //cont must be '0' or '1'
        SNES 0 r3

    INIT            //starts memory block must be paired with END
    1234            // inside of memory block, data is copied over directly with 
    1233            // ***no error checking***
    1233
    END             //Ends memory block

    // aslkfae      //comment
    /*              //block comment *NOTE* must start line
    aklsdfajw

    aefa
    */              //end block comment *NOTE* must end line

Immediates should be able to be entered as decimal or hex (prefixed with 0x)

Available commands are in imm_ins, r_to_r_ins, and shift_ins
helpful macros are in macro_ins
    All macros (except NOP) consist of two words with an underscore, (e.g. JMP_IMM)
    No other instructions have an underscore

    You should almost never (if ever) use JMP, MOVI, LUI, or JAL.
    Instead use the macros JMP_IMM JMP_REL, MOV_IMM, and JAL_IMM
    It will make your life easier.

    The macros have helpful error checking to help prevent you from 
    shooting yourself in the foot. 
    The raw instructions have not checks to see if addresses are in the valid range,
    so it is on YOU as the programmer to ensure that all LOAD, STOR, JMP, and JAL isntructions
    only access/jump to valid locations. Please use the macros if at all possible

***MACROS -- NOT DEFINED IN ISA***
JMP_REL offset reg cond
    - jumps on {cond} to {current address + offset}, using {reg}
    - NOTE: will overwrite {reg}
    - assembles into MOVI, LUI, JMP
    JMP_REL 10 r12 UC
    JMP_REL -7 r4 EQ

JMP_IMM addr reg con
    - same as JMP_REL, except using an absolute address instead of an offset
    - addr must fit in two bytes, and jump to a valid code location
JAL_IMM addr reg [lnk]
    - same as JMP_IMM, but JAL
    - lnk defaults to r15 if none specified
    - addr must fit in two bytes, and jump to a valid code location
MOV_IMM val reg
    - similar to MOVI, but allows full byte values
    - equivalent to 
        MOVI val(lower byte) reg
        LUI val(upper byte) reg
    - val must fit in two bytes

***Assembler specific instructions***
    These have no effect on the code
print_addr
    - prints the line number and memory address at the given line to the console

'''
import sys, traceback

#TODO
PROGRAM_START   = int(0x0000)
PROGRAM_END     = int(0x2000)
ADDR_END        = int(0x3FFF)




#not defined in ISA, defined in block comment above
macro_ins = {
    "JMP_REL":      "0",
    "JMP_IMM":      "1",
    "JAL_IMM":      "2",
    "MOV_IMM":      "3",
    "NOP":          "6",
    "STOP":         "7"
}

imm_ins = {
    "R_TO_R":       "0", #not an instruction
    "ANDI":         "1",
    "ORI":          "2",
    "XORI":         "3",
    "JMP_LD_STR":   "4", #not an instruction
    "ADDI":         "5",
    "ADDUI":        "6",
    "ADDCI":        "7",
    "SHIFT":        "8", #not an instruction
    "SUBI":         "9",
    "SUBCI":        "a",
    "CMPI":         "b",
    "MOVI":         "d",
    "MULI":         "e",
    "LUI":          "f"
}


r_to_r_ins = {
    "AND":  "1",
    "OR":   "2",
    "XOR":  "3",
    "ADD":  "5",
    "ADDU": "6",
    "ADDC": "7",
    "SUB":  "9",
    "CMP":  "b",
    "MOV":  "d",
    "MUL":  "e"
}

shift_ins = {
    "LLSHI":    "0",
    "LRSHI":    "1",
    "ALSHI":    "2",
    "ARSHI":    "3",
    "LSH":      "4",
    "ASH":      "a"
}

#TODO implement SNES
jmp_ld_str_ins = {
    "LOAD": "0",
    "STOR": "4",
    "JAL":  "8",
    "JMP":  "c",
    "SNES": "f"     #Custom for our cpu, not in ISA
}

jmp_cond = {
    "EQ":   "0",    #Equal
    "NE":   "1",    #Not Equal
    "CS":   "2",    #Carry Set
    "CC":   "3",    #Carry Clear
    "HI":   "4",    #Higher than
    "LS":   "5",    #Lower than/same
    "GT":   "6",    #Greater than
    "LE":   "7",    #Less than/equal
    "FS":   "8",    #Flag set
    "FC":   "9",    #Flag clear
    "LO":   "a",    #Lower than
    "HS":   "b",    #higher than/same
    "LT":   "c",    #Less than
    "GE":   "d",    #Greater than/equal
    "UC":   "e",    #unconditional
    "NJ":   "f"     #never
}

line_num = 0
# *** ONLY CHANGE THIS WITH set_memory_addr ***
memory_addr = 0

#print an error message with line number
def error(msg):
    print("ERROR: line " + str(line_num) + ": " + msg)

#safely set memory_addr
def set_memory_addr(val):
    global memory_addr 
    memory_addr = val
    if memory_addr > ADDR_END:
        error("Memory location too big: " + str(memory_addr))

#accepts a register (e.g. r13) and return number in hex (e.g. d)
def reg_to_hex(reg):
    if not reg.startswith("r"):
        error("malformed register: " + reg)
    ret = hex(int(reg.replace('r', ''))).replace("0x", '')
    if len(ret) > 1:
        error("register is too big")
        return "-"
    return ret

# takes a 1 byte immediate and converts to 1 hex character
def imm_to_hex(ins):
    imm = ""
    if ins.startswith("0x"):
        imm = ins.replace("0x", '')
    else:
        val = int(ins)
        if val > 255:
            error("immediate is larger than 1 byte")
        imm_hex = hex((val + (1 << 8)) % (1 << 8))
        imm = imm_hex.replace("0x", '')
    ret = ""
    if len(imm) == 1:
        return "0" + imm
    elif len(imm) == 2:
        return imm
    else:
        error("imm_to_hex error, " + str(len(imm)) + "chars")
        return "--"

# takes a 2 byte immediate and converts to 4 hex characters
def int_to_hex(val):
    if val > 65535:
        error("immediate is larger than 2 bytes")
    imm_hex = hex((val + (1 << 16)) % (1 << 16))
    imm = imm_hex.replace("0x", '')
    while len(imm) < 4:
        imm = "0" + imm
    if len(imm) == 4:
        return imm
    else:
        error("int_to_hex error, " + str(len(imm)) + "chars")
        return "----"



# parses a standard (NOT macro)) instruction
def parse_ins(line):
    code = list("____\n") 
    tokens = line.split()

    if len(tokens) < 2 or len(tokens) > 3:
        error("wrong number of tokens")
    elif tokens[0] in r_to_r_ins:
        #ins
        code[0] = imm_ins["R_TO_R"]
        #dest
        code[1] = reg_to_hex(tokens[2])
        #ins low
        code[2] = r_to_r_ins[tokens[0]]
        #src
        code[3] = reg_to_hex(tokens[1])
    elif tokens[0] in jmp_ld_str_ins:
        code[0] = imm_ins["JMP_LD_STR"]
        if tokens[0] == "JMP":
            #cond
            code[1] = jmp_cond[tokens[2]]
            #src
            code[3] = reg_to_hex(tokens[1])
        elif tokens[0] == "JAL" and len(tokens) == 2:
            #link
            code[1] = "f"
            #src
            code[3] = reg_to_hex(tokens[1])
        #TODO
        elif tokens[0] == "SNES":
            code[1] = reg_to_hex(tokens[2])
            if tokens[1] != "0" and tokens[1] != "1":
                error("invalid snes controller: " + tokens[1])
            code[3] = tokens[1]
        else:
            #dest
            code[1] = reg_to_hex(tokens[1])
            #src
            code[3] = reg_to_hex(tokens[2])
        #ins low
        code[2] = jmp_ld_str_ins[tokens[0]]

    elif tokens[0] in imm_ins:
        code[0] = imm_ins[tokens[0]]
        code[1] = reg_to_hex(tokens[2])
        imm = imm_to_hex(tokens[1])
        code[2] = imm[0]
        code[3] = imm[1]
    elif tokens[0] in shift_ins:
        code[0] = imm_ins["SHIFT"]
        code[1] = reg_to_hex(tokens[2])
        code[2] = shift_ins[tokens[0]]
        if tokens[0] == "LSH" or tokens[0] == "ASH":
            code[3] = reg_to_hex(tokens[1])
        else:
            code[3] = imm_to_hex(tokens[1])[1]
    else:
        error("parse_ins error")

    return "".join(code)

source_filename = sys.argv[1]
dest_filename = sys.argv[2]
source_file = open(source_filename, "r")
dest_file = open(dest_filename, "w")

def write_ins(ins):
    if SREC_OUTPUT:
        dest_file.write(ins[0] + ins[1] + '\n')
        dest_file.write(ins[2] + ins[3] + '\n')
    else:
        dest_file.write(ins)
    set_memory_addr(memory_addr + 1)

print("name of source file: " + source_file.name)
print("name of dest file: " + dest_file.name)


memory_block = False
block_comment = 0
if SREC_OUTPUT:
    dest_file.write("\n");
for line in source_file:
    try: 
        line_num += 1
        tokens = line.split()

        #empty line
        if len(tokens) == 0:
            continue
        #comments
        if line.strip().startswith("/*"):
            block_comment += 1
            continue

        elif line.strip().startswith("*/"):
            block_comment -= 1
            if block_comment < 0:
                error("unmatched */")
            continue

        elif block_comment > 0:
            continue

        elif line.strip().startswith("//#"):
            if not SREC_OUTPUT:
                dest_file.write(line.replace("#", "").lstrip())
            continue

        elif line.strip().startswith("//"):
            continue

        elif line.strip().startswith("@"):
            set_memory_addr(int(line.replace('@', ''), 16))
            if SREC_OUTPUT:
                dest_file.write("$A" + int_to_hex(memory_addr*2) + ",\n")
            else:
                dest_file.write(line)
            continue

        elif line.strip().startswith("print_addr"):
            print("Line number: " + str(line_num) + " Memory Address: " + hex(memory_addr))
            continue

        elif line.startswith("INIT"):
            if memory_block:
                error("unmatched INIT")
            memory_block = True
            continue

        elif line.startswith("END"):
            if not memory_block:
                error("unmatched END")
            memory_block = False
            continue

        elif memory_block:
            write_ins(line)
            continue


        #first token
        elif tokens[0] in macro_ins:
            if tokens[0] == "JMP_REL":
                dest = tokens[1]
                reg = tokens[2]
                cond = tokens[3]

                #calculate address
                offset = 0
                if dest.startswith("0x"):
                    offset = int(dest, 16)
                else:
                    offset = int(dest)
                addr_val = memory_addr + offset
                if offset > 0:
                    addr_val += 2
                if addr_val < PROGRAM_START or addr_val > PROGRAM_END:
                    error("invalid jump location: " + hex(addr_val))
                addr = int_to_hex(addr_val)
                #MOVI
                write_ins(parse_ins("MOVI 0x" + addr[2] + addr[3] + " " + reg))
                #LUI
                write_ins(parse_ins("LUI 0x" + addr[0] + addr[1] + " " + reg))
                #JMP
                write_ins(parse_ins("JMP " + reg + " " + cond))

            elif tokens[0] == "JMP_IMM":
                dest = tokens[1]
                reg = tokens[2]
                cond = tokens[3]
                if dest.startswith("0x"):
                    dest = int(dest, 16)
                else:
                    dest = int(dest)

                addr = int_to_hex(dest)
                #MOVI
                write_ins(parse_ins("MOVI 0x" + addr[2] + addr[3] + " " + reg))
                #LUI
                write_ins(parse_ins("LUI 0x" + addr[0] + addr[1] + " " + reg))
                #JMP
                write_ins(parse_ins("JMP " + reg + " " + cond))

            elif tokens[0] == "JAL_IMM":
                dest = tokens[1]
                if dest.startswith("0x"):
                    dest = int(dest, 16)
                else:
                    dest = int(dest)
                reg = tokens[2]
                link = "r15"
                if len(tokens) == 4:
                    link = tokens[3]

                addr = int_to_hex(dest)

                #MOVI
                write_ins(parse_ins("MOVI 0x" + addr[2] + addr[3] + " " + reg))
                #LUI
                write_ins(parse_ins("LUI 0x" + addr[0] + addr[1] + " " + reg))
                #JAL
                write_ins(parse_ins("JAL " + link + " " + reg))

            elif tokens[0] == "MOV_IMM":
                val = tokens[1]
                reg = tokens[2]
                if val.startswith("0x"):
                    val = int(val, 16)
                else:
                    val = int(val)

                hex_val = int_to_hex(val)
                #MOVI
                write_ins(parse_ins("MOVI 0x" + hex_val[2] + hex_val[3] + " " + reg))
                #LUI
                write_ins(parse_ins("LUI 0x" + hex_val[0] + hex_val[1] + " " + reg))
                
                
            elif tokens[0] == "NOP":
                write_ins(parse_ins("OR r0 r0"))
            elif tokens[0] == "STOP":
                write_ins("0000\n")

        #normal instruction
        else:
            write_ins(parse_ins(line))
    except Exception as exc:
        error("python exception:")
        traceback.print_exc()
        write_ins("----\n")

if SREC_OUTPUT:
    dest_file.write('');
if memory_block:
    error("unmatched INIT")

if block_comment > 0:
    error("unmatched /*")


source_file.close()
dest_file.close()

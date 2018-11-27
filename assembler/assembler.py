'''
3710 Assembler
(Mostly) Follows the CR16 manual on ISA.pdf (linked on the course)

Commands take the following possible forms:
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
    Should probably use REL_JMP or JMP_IMM instead of JMP in almost all cases.
    It will make your life easier.

***MACROS -- NOT DEFINED IN ISA***
REL_JMP offset reg cond
    - jumps on {cond} to {current address + offset}, using {reg}
    - NOTE: will overwrite {reg}
    - assembles into MOVI, LUI, JMP
    REL_JMP 10 r12 UC
    REL_JMP -7 r4 EQ

JMP_IMM addr reg con
    - same as REL_JMP, except using an absolute address instead of an offset
'''
import sys

#TODO
PROGRAM_START   = int(0x0000)
PROGRAM_END     = int(0x1000)



#TODO add JMP
macro_ins = {
    "REL_JMP":  "0",
    "JMP_IMM":  "1",
    "NOP":      "2"
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

jmp_ld_str_ins = {
    "LOAD": "0",
    "STOR": "4",
    "JAL":  "8",
    "JMP":  "c"
}

jmp_cond = {
    "EQ":   "0",
    "NE":   "1",
    "CS":   "2",
    "CC":   "3",
    "HI":   "4",
    "LS":   "5",
    "GT":   "6",
    "LE":   "7",
    "FS":   "8",
    "FC":   "9",
    "LO":   "a",
    "hs":   "b",
    "LT":   "c",
    "GE":   "d",
    "UC":   "e",
    "NJ":   "f"
}

line_num = 0
memory_addr = 0

def error(msg):
    print("line " + str(line_num) + ": " + msg)


#accepts a register (e.g. r13) and return number in hex (e.g. d)
def reg_to_hex(reg):
    ret = hex(int(reg.replace('r', ''))).replace("0x", '')
    if len(ret) > 1:
        error("register is too big")
        return "-"
    return ret

def imm_to_hex(ins):
    imm = ""
    if ins.startswith("0x"):
        imm = ins.replace("0x", '')
    else:
        val = int(ins)
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

def int_to_hex(val):
    imm_hex = hex((val + (1 << 16)) % (1 << 16))
    imm = imm_hex.replace("0x", '')
    ret = ""
    while len(imm) < 4:
        imm = "0" + imm
    if len(imm) == 4:
        return imm
    else:
        error("int_to_hex error, " + str(len(imm)) + "chars")
        return "----"



def parse_ins(line):
    code = list("____\n") 
    tokens = line.split()

    if len(tokens) < 2 or len(tokens) > 3:
        error("wrong number of tokens")
    elif tokens[0] in r_to_r_ins:
        print("r_to_r")
        #ins
        code[0] = imm_ins["R_TO_R"]
        #dest
        code[1] = reg_to_hex(tokens[2])
        #ins low
        code[2] = r_to_r_ins[tokens[0]]
        #src
        code[3] = reg_to_hex(tokens[1])
    elif tokens[0] in jmp_ld_str_ins:
        print("jmp_ld_str")
        code[0] = imm_ins["JMP_LD_STR"]
        if tokens[0] == "JMP":
            print("jmp")
            #cond
            code[1] = jmp_cond[tokens[2]]
        elif tokens[0] == "JAL" and len(tokens) == 2:
            #link
            code[1] = "f"
        else:
            #dest
            code[1] = reg_to_hex(tokens[2])
        #ins low
        code[2] = jmp_ld_str_ins[tokens[0]]
        #src
        code[3] = reg_to_hex(tokens[1])

    elif tokens[0] in imm_ins:
        print("imm")
        code[0] = imm_ins[tokens[0]]
        code[1] = reg_to_hex(tokens[2])
        imm = imm_to_hex(tokens[1])
        code[2] = imm[0]
        code[3] = imm[1]
    elif tokens[0] in shift_ins:
        print("shift")
        code[0] = imm_ins["SHIFT"]
        code[1] = reg_to_hex(tokens[2])
        code[2] = shift_ins[tokens[0]]
        if tokens[0] == "LSH" or tokens[0] == "ASH":
            code[3] = reg_to_hex(tokens[1])
        else:
            code[3] = imm_to_hex(tokens[1])[1]
    else:
        print("line " + line_num + ": error")

    return "".join(code)

source_filename = sys.argv[1]
dest_filename = sys.argv[2]
source_file = open(source_filename, "r")
dest_file = open(dest_filename, "w")

def write_ins(ins):
    dest_file.write(ins)
    global memory_addr
    memory_addr += 1

print("name of source file: " + source_file.name)
print("name of dest file: " + dest_file.name)


memory_block = False
block_comment = 0
for line in source_file:
    line_num += 1
    tokens = line.split()

    #comments
    if line.startswith("/*"):
        block_comment += 1
        continue

    elif line.startswith("*/"):
        block_comment -= 1
        if block_comment < 0:
            error("unmatched */")
        continue

    elif block_comment > 0:
        continue

    elif line.startswith("//"):
        continue

    elif line.startswith("@"):
        memory_addr = int(line.replace('@', ''), 16)
        print("location: " + hex(memory_addr))
        dest_file.write(line)
        continue

    elif line == "INIT\n":
        if memory_block:
            error("unmatched INIT")
        memory_block = True
        continue

    elif line == "END\n":
        if not memory_block:
            error("unmatched END")
        memory_block = False
        continue

    elif memory_block:
        dest_file.write(line)
        continue


    #first token
    elif tokens[0] in macro_ins:
        if tokens[0] == "REL_JMP":
            print(hex(memory_addr))
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
            
        elif tokens[0] == "NOP":
            write_ins(parse_ins("OR r0 r0"))

    else:
        write_ins(parse_ins(line))

if memory_block:
    error("unmatched INIT")

if block_comment > 0:
    error("unmatched /*")


source_file.close()
dest_file.close()

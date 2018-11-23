import sys
from enum import Enum

class ins_type(Enum):
    r_to_r= 0
    ld_str= 1
    jmp= 2
    imm= 3

op_code = {
    "AND": "1",
    "OR": "2",
    "XOR": "3",
    "NOT": "4",
    "ADD": "5",
    "ADDU": "6",
    "ADDC": "7",
    "ADDCU": "8",
    "SUB": "9",
    "CMP": "b",
    "CMPU": "f",
    "MOV": "d"
}

def get_ins_type(ins):
    if ins.endswith("I"):
        return ins_type.imm
    elif ins == "LOAD" or ins == "STOR":
        return ins_type.ld_str
    elif ins == "JMP":
        return ins_type.jmp
    else:
        return ins_type.r_to_r

#accepts a register (e.g. r13) and return number in hex (e.g. d)
def reg_to_hex(reg):
    return hex(int(reg.replace('r', ''))).replace("0x", '')

source_filename = sys.argv[1]
dest_filename = sys.argv[2]
source_file = open(source_filename, "r")
dest_file = open(dest_filename, "w")

print("name of source file: " + source_file.name)
print("name of dest file: " + dest_file.name)



for line in source_file:
    code = list("____\n") 
    tokens = line.split()

    #first token
    mnemonic = get_ins_type(tokens[0])
    #set code[0], maybe code[2]

    if mnemonic is ins_type.r_to_r:
        #do stuff
        print("r_to_r")
        #set ins high
        code[0] = "0"
        #set dest
        code[1] = reg_to_hex(tokens[2])
        #set ins low
        code[2] = op_code[tokens[0]]
        #set src
        code[3] = reg_to_hex(tokens[1])
    elif mnemonic is ins_type.ld_str:
        print("ld_str")
        #set ins high
        code[0] = "4"
        #set dest
        code[1] = reg_to_hex(tokens[2])
        #set ins low
        if tokens[0] == "LOAD":
            code[2] = "0"
        elif tokens[0] == "STOR":
            code[2] = "4"
        #set src
        code[3] = reg_to_hex(tokens[1])

    elif mnemonic is ins_type.jmp:
        print("jmp")
        #do other stuff
    elif mnemonic is ins_type.imm:
        print("imm")
        code[0] = op_code[tokens[0].replace('I', '')]
        code[1] = reg_to_hex(tokens[2])
        imm = hex(int(tokens[1]).replace("0x", '')
        if len(imm) == 1:
            code[2] = "0"
            code[3] = imm
        elif len(imm) == 2:
            code[2] = imm[0]
            code[3] = imm[1]


    dest_file.write("".join(code))


source_file.close()
dest_file.close()

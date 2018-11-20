import sys
from enum import Enum

class ins_type(Enum):
    r_to_r= 0
    ld_str= 1
    jmp= 2
    imm= 3

def get_ins_type(ins):
    if ins.endswith("I"):
        return ins_type.imm
    elif ins == "LOAD" or ins == "STOR":
        return ins_type.ld_str
    elif ins == "JMP":
        return ins_type.jmp
    else:
        return ins_type.r_to_r

source_filename = sys.argv[1]
dest_filename = sys.argv[2]
source_file = open(source_filename, "r")
dest_file = open(dest_filename, "w")

print("name of source file " + source_file.name)
print("name of dest file " + dest_file.name)



for line in source_file:
    code = list("1234\n") 
    tokens = line.split()

    #first token
    mnemonic = get_ins_type(tokens[0])
    #set code[0], maybe code[2]

    #second token
    if mnemonic is ins_type.r_to_r or mnemonic is ins_type.ld_str:
        #do stuff
        #set dest
        code[1] = hex(int(tokens[2].replace('r', ''))).replace("0x", '')
        #set src
        code[3] = hex(int(tokens[1].replace('r', ''))).replace("0x", '')
    elif mnemonic is ins_type.jmp:
        #do other stuff
        print("jmp")
    elif mnemonic is ins_type.imm:
        #do even more stuff
        print("imm")

    #third token

    dest_file.write("".join(code))


source_file.close()
dest_file.close()

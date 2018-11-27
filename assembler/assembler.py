import sys



imm_ins = {
    "R_TO_R":       "0",
    "ANDI":         "1",
    "ORI":          "2",
    "XORI":         "3",
    "JMP_LD_STR":   "4",
    "ADDI":         "5",
    "ADDUI":        "6",
    "ADDCI":        "7",
    "SHIFT":        "8",
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



line_num = 1
#accepts a register (e.g. r13) and return number in hex (e.g. d)
def reg_to_hex(reg):
    ret = hex(int(reg.replace('r', ''))).replace("0x", '')
    if len(ret) > 1:
        print("line " + str(line_num) + ": register is too big")
        return "-"
    return ret

#TODO handle negative
def imm_to_hex(ins):
    val = int(ins)
    imm_hex = hex((val + (1 << 8)) % (1 << 8))
    #imm = hex(int(ins) + (1 << 8)) % (1 << 8)) ).replace("0x", '')
    imm = imm_hex.replace("0x", '')
    ret = ""
    if len(imm) == 1:
        return "0" + str(imm)
    elif len(imm) == 2:
        return imm
    else:
        print("line " + line_num + ": error")
        return "--"


source_filename = sys.argv[1]
dest_filename = sys.argv[2]
source_file = open(source_filename, "r")
dest_file = open(dest_filename, "w")

print("name of source file: " + source_file.name)
print("name of dest file: " + dest_file.name)



for line in source_file:
    code = list("____\n") 
    tokens = line.split()
    if len(tokens) < 2 or len(tokens) > 3:
        print("line " + str(line_num) + ": wrong number of tokens")
        dest_file.write("".join(code))
        line_num += 1
        continue


    #first token

    if tokens[0] in r_to_r_ins:
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


    dest_file.write("".join(code))
    line_num += 1


source_file.close()
dest_file.close()

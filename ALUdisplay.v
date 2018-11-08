`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    9/13/2018 
// Design Name: 
// Module Name:    ALUdisplay 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ALUdisplay(Aupper, Bupper, Opcode, Cin, Flags, Display);
input [3:0] Aupper, Bupper, Opcode;
input Cin;
output [4:0] Flags;
output [27:0] Display;

wire [15:0] C;

ALU alu ({Aupper, 12'b0}, {Bupper, 12'b0}, ~Opcode, Flags, Cin, C);

hexTo7Seg seg0(C[15:12], Display[27:21]);
hexTo7Seg seg1(C[11:8], Display[20:14]);
hexTo7Seg seg2(C[7:4], Display[13:7]);
hexTo7Seg seg3(C[3:0], Display[6:0]);

endmodule

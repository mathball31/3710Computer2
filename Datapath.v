`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:30:00 09/13/2018
// Design Name: 
// Module Name:    datapath
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
/*
This module handles the interactions between the ALU and register file.
*/
module Datapath(Cin, clk, reset, flags, alu_bus);
	
	input clk, Cin, reset;
	// add output
	
	output [4:0] flags;
	output [15:0] alu_bus;
	
	wire [15:0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15;
	wire [15:0] mux_A_out, mux_B_out;
	wire [15:0] reg_en;		// output of the Mux4to16 module, to be put into RegBank
	wire [15:0] opcode; // output of FSM
	// opcode: [15:12], [7:4] = operation code for ALU
	//				[11:8] = number for input A (dest)
	//				[3:0] = number for input B
	
	// Mux4to16 regEnable(opcode[11:8], reg_en);
	// new stuuuff
	
	wire pc_en, w_en_a, w_en_b, pc_sel, imm_sel, flag_en, alu_sel;  // Output from FSM
	wire [3:0] mux_A_sel, mux_B_sel;
	wire [15:0] data_b; // TODO these don't do anything; refer to mem declaration comments
	wire [9:0] addr_b; // TODO these don't do anything; refer to mem declaration comments
	wire [9:0] pc_out;
	wire pc_ld = 0; // TODO Depends on load instruction. Will come from FSM later
	wire [9:0] pc_mux_out = pc_sel ? pc_out : mux_A_out[9:0];	
	wire [15:0] mem_out_a, mem_out_b;
	wire [15:0] reg_input = alu_sel ? alu_bus : mem_out_a;
	
	RegBank regFile(clk, reset, reg_en, reg_input, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15);

	RegMux muxA(r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, mux_A_sel, mux_A_out);

	RegMux muxB(r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, mux_B_sel, mux_B_out);
	
	ALU alu(mux_A_out, mux_B_out, opcode, flags, Cin, alu_bus);
	
	ProgramCounter pc(clk, reset, pc_en, pc_ld, mux_A_out[9:0], pc_out);
	
	// Will fill in data_b and addr_b later for VGA (maybe?)
	// TODO mux_B_out may need to change to account for immediate instructions (refer to how ALU takes 
	// care of immediate instructions)
	Memory mem(mux_B_out, data_b, pc_mux_out, addr_b, w_en_a, w_en_b, clk, mem_out_a, mem_out_b);
	
	FSM fsm(clk, reset, mem_out_a, flags, opcode, mux_A_sel, mux_B_sel, alu_sel, pc_sel, 
		w_en_a, w_en_b, reg_en, flag_en, pc_en);
	

endmodule




/*
This module selects an output from an register depending on regNum
	out = r[regNum]
*/
module RegMux(r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, regNum, out);

	input [15:0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15;
	input [3:0] regNum;
	output reg [15:0] out;
	
	always @(regNum, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15)
	begin
		case (regNum)
			0: out = r0;
			1: out = r1;
			2: out = r2;
			3: out = r3;
			4: out = r4;
			5: out = r5;
			6: out = r6;
			7: out = r7;
			8: out = r8;
			9: out = r9;
			10: out = r10;
			11: out = r11;
			12: out = r12;
			13: out = r13;
			14: out = r14;
			15: out = r15;			
		
		endcase
	end

endmodule


module ProgramCounter(clk, reset, pc_en, pc_ld, pc_in, pc_out);
	input clk, reset, pc_en, pc_ld;
	input [9:0] pc_in;
	output reg [9:0] pc_out;
	
	always @ (posedge clk)
	begin
		if (pc_en)
		begin
			if (pc_ld)
			begin
				pc_out = pc_in;
			end
			else
			begin
				pc_out = pc_out + 1'b1;
			end
		end
		if (reset) 
		begin
			pc_out = 0;
		end
		else
		begin
			pc_out = pc_out;
		end
	end
endmodule

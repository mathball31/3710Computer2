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
module Datapath(clk, reset, Display);
	
	input clk, reset;
	wire [15:0] alu_bus;
	output [27:0] Display;
	
	wire [4:0] flags_in, flags_out;
	
	wire [15:0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15;
	wire [15:0] mux_A_out, mux_B_out;
	wire [15:0] reg_en;		// output of the Mux4to16 module, to be put into RegBank
	wire [15:0] opcode; // output of FSM
	// opcode: [15:12], [7:4] = operation code for ALU
	//				[11:8] = number for input A (dest)
	//				[3:0] = number for input B
	
	wire pc_en, w_en_a, w_en_b, pc_sel, imm_sel, flag_en, alu_sel, pc_ld;  // Output from FSM
	wire [3:0] mux_A_sel, mux_B_sel;
	wire [15:0] data_b; 
	wire [9:0] addr_b; 
	wire [9:0] pc_out;
	wire [9:0] pc_mux_out = pc_sel ? pc_out : mux_A_out[9:0];	
	wire [15:0] mem_out_a, mem_out_b;
	wire [15:0] reg_input = alu_sel ? alu_bus : mem_out_a;
	
	RegBank regFile(clk, !reset, reg_en, reg_input, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15);

	RegMux muxA(r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, mux_A_sel, mux_A_out);

	RegMux muxB(r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, mux_B_sel, mux_B_out);
	
	ALU alu(mux_A_out, mux_B_out, opcode, flags_out[3], flags_in, alu_bus);
	
	ProgramCounter pc(clk, !reset, pc_en, pc_ld, mux_A_out[9:0], pc_out);
	
	Flags flags(clk, !reset, flag_en, flags_in, flags_out);
	
	// TODO Will fill in data_b and addr_b later for VGA (maybe?)
	Memory mem(clk, w_en_a, w_en_b, mux_B_out, data_b, pc_mux_out, addr_b, mem_out_a, mem_out_b);
	
	FSM fsm(clk, !reset, mem_out_a, flags_out, pc_out, opcode, mux_A_sel, mux_B_sel, alu_sel, pc_sel, 
		w_en_a, w_en_b, reg_en, flag_en, pc_en, pc_ld);
		
	hexTo7Seg seg0(r0[15:12], Display[27:21]);
	hexTo7Seg seg1(r0[11:8], Display[20:14]);
	hexTo7Seg seg2(r0[7:4], Display[13:7]);
	hexTo7Seg seg3(r0[3:0], Display[6:0]);	
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


module Flags(clk, reset, flag_en, flags_in, flags_out);
	input clk, reset, flag_en;
	input [4:0] flags_in;
	output reg [4:0] flags_out;
	
	always @(posedge clk) 
	begin
		if (reset) flags_out = 5'bxxxxx;
		else if (flag_en) flags_out = flags_in;
	end
endmodule



module FSM #(parameter ADDR_WIDTH = 12)(clk, reset, mem_in, flags, pc_ins, snes_data, snes_data1, opcode, mux_A_sel, mux_B_sel, alu_sel, pc_sel, 
	mem_w_en_a, mem_w_en_b, reg_en, flag_en, pc_en, pc_ld);

	input clk, reset;
	input [15:0] mem_in;
	input [4:0] flags;
	input [ADDR_WIDTH-1:0] pc_ins;
	input [11:0] snes_data, snes_data1;
	output reg [15:0] opcode, reg_en;
	output reg [3:0] mux_A_sel, mux_B_sel;
	output reg pc_sel, mem_w_en_a, mem_w_en_b, flag_en, alu_sel, pc_en, pc_ld;
	
	wire [15:0] mux_out;
	reg [4:0] state;
	reg [15:0] instruction;
	reg [ADDR_WIDTH-1:0] old_pc;
	reg snes_num;
	
	parameter RESET		= 5'b00000;
	parameter FETCH_1 	= 5'b00001;
	parameter FETCH_2		= 5'b00010;
	parameter R_TYPE		= 5'b00011;
	parameter STORE_1		= 5'b00100;
	parameter STORE_2		= 5'b00101;
	parameter LOAD_1		= 5'b00110;
	parameter LOAD_2		= 5'b00111;
	parameter JUMP_1		= 5'b01000;
	parameter JUMP_2		= 5'b01001;
	parameter JAL_1		= 5'b01010;
	parameter JAL_2		= 5'b01011;
	parameter JAL_3		= 5'b01100;
	parameter SNES_1		= 5'b01101;
	parameter SNES_2		= 5'b01110;
	parameter SNES_3		= 5'b01111;
	parameter STOP			= 5'b10000;
	
	parameter EQUAL 		= 4'b0000; 	// Equal 						Z=1
	parameter NOT_EQ 		= 4'b0001; 	// Not Equal 					Z=0
	parameter GREAT_EQ	= 4'b1101; 	// Greater than or Equal 	N=1 or Z=1
	parameter CARRY_SET	= 4'b0010; 	// Carry Set 					C=1
	parameter CARRY_CL	= 4'b0011; 	// Carry Clear 				C=0
	parameter HIGHER		= 4'b0100; 	// Higher than 				L=1
	parameter LOW_SAME	= 4'b0101; 	// Lower than or Same as 	L=0
	parameter LOWER 		= 4'b1010; 	// Lower than 					L=0 and Z=0
	parameter HIGH_SAME	= 4'b1011; 	// Higher than or Same as 	L=1 or Z=1
	parameter GREATER		= 4'b0110; 	// Greater Than 				N=1
	parameter LESS_EQ		= 4'b0111; 	// Less than or Equal 		N=0
	parameter FLAG_SET	= 4'b1000; 	// Flag Set 					F=1
	parameter FLAG_CL		= 4'b1001; 	// Flag Clear 					F=0
	parameter LESS 		= 4'b1100; 	// Less Than 					N=0 and Z=0
	parameter UNCOND		= 4'b1110; 	// Unconditional 				1
	parameter NO_JUMP		= 4'b1111; 	// Never jump					0
	
	// Need these so they don't overwrite register
	parameter CMP 		= 4'b1011;
	parameter CMPI		= 4'b1011;

	
	parameter ZERO 	= 4;
	parameter CARRY 	= 3;
	parameter FLOW 	= 2;
	parameter NEG 		= 1;
	parameter LOW 		= 0;
	
	
	always @(posedge clk)
	begin
		if (reset)
		begin
			state = RESET;
		end
	
		case (state)
			
			// 0
			RESET:
			begin
				opcode 		= 16'bx;
				mux_A_sel 	= 4'bx;
				mux_B_sel 	= 4'bx;
				alu_sel 		= 1'b1;
				pc_sel 		= 1'b1;
				mem_w_en_a 	= 1'b0;
				mem_w_en_b 	= 1'b0;
				reg_en 		= 16'b0;
				flag_en		= 1'b0;
				pc_en 		= 1'b0;
				pc_ld			= 1'b0;

				if (reset) 
				begin
					state = RESET;
				end
				
				else 
				begin
					state = FETCH_1;
				end
			end
			
			// 1
			FETCH_1:
			begin			
				opcode 		= 16'b0;
				mux_A_sel 	= 4'bx;
				mux_B_sel	= 4'bx;
				alu_sel 		= 1'b1;
				pc_sel 		= 1'b1;
				mem_w_en_a 	= 1'b0;
				mem_w_en_b 	= 1'b0;
				reg_en 		= 16'b0;
				flag_en 		= 1'b0;
				pc_en 		= 1'b1;
				pc_ld			= 1'b0;
				instruction = 16'bx;
				state 		= FETCH_2;
			end
			
			// 2
			FETCH_2:
			begin
				pc_en 		= 1'b0;
				instruction = mem_in;

				if (instruction == 16'b0)
				begin
					state = STOP;
				end
				
				else if (instruction[15:12] != 4'b0100) 
				begin
					state = R_TYPE;
				end
				
				else if (instruction[15:12] == 4'b0100)
				begin
					case (instruction[7:4])
						4'b0000:
						begin
							state = LOAD_1;
						end
						4'b0100:
						begin
							state = STORE_1;
						end
						4'b1000:
						begin
							state = JAL_1;
						end
						4'b1100:
						begin
							state = JUMP_1;
						end
						4'b1111:
						begin
							state = SNES_1;
						end
					endcase
				end
			end
			
			// 3
			R_TYPE:
			begin
				opcode 		= instruction;
				mux_A_sel 	= instruction[11:8];	// Destination
				mux_B_sel 	= instruction[3:0];  	// Source
				flag_en		= 1'b1;
				
				// don't write to registers if instruction is CMP or CMPI
				if ((instruction[15:12] == 0 && instruction[7:4] == CMP) || (instruction[15:12] == CMPI))
				begin
					reg_en 	= 16'b0;		
				end
				
				else
				begin
					reg_en 	= mux_out;
				end
				
				state 		= FETCH_1;
			end
					
			// 4
			STORE_1:
			begin
				mux_A_sel 	= instruction[3:0]; //destination address
				mux_B_sel 	= instruction[11:8]; //source register
				pc_sel 		= 1'b0;
				mem_w_en_a 	= 1'b1;				
				state 		= STORE_2;
			end
			
			// 5
			STORE_2:
			begin
				pc_sel 		= 1'b1;
				mem_w_en_a 	= 1'b0;
				state 		= FETCH_1;
			end
			
			// 6
			LOAD_1:
			begin
				mux_A_sel 	= instruction[3:0]; //address
				pc_sel 		= 1'b0;
				reg_en 		= mux_out;
				state 		= LOAD_2;
			end
			
			// 7
			LOAD_2:
			begin
				alu_sel 		= 1'b0;
				pc_sel 		= 1'b1;
				state 		= FETCH_1;
			end
			
			// 8
			JUMP_1:
			begin		  
				case (instruction[11:8]) // condition = instruction[11:8]
					EQUAL:
						pc_ld = flags[ZERO];
						
					NOT_EQ:
						pc_ld = !flags[ZERO];
						
					GREAT_EQ:
						pc_ld = (flags[NEG] || flags[ZERO]);
						
					CARRY_SET:
						pc_ld = flags[CARRY];
						
					CARRY_CL:
						pc_ld = !flags[CARRY];
						
					HIGHER:
						pc_ld = flags[LOW];
						
					LOW_SAME:
						pc_ld = !flags[LOW];
						
					LOWER:
						pc_ld = (!flags[LOW] && !flags[ZERO]);
						
					HIGH_SAME:
						pc_ld = (flags[LOW] || flags[ZERO]);
						
					GREATER:
						pc_ld = flags[NEG];
						
					LESS_EQ:
						pc_ld = !flags[NEG];
						
					FLAG_SET:
						pc_ld = flags[FLOW];
						
					FLAG_CL:
						pc_ld = !flags[FLOW];
						
					LESS:
						pc_ld = (!flags[NEG] && !flags[ZERO]);
						
					UNCOND:
						pc_ld = 1'b1;
						
					NO_JUMP:
						pc_ld = 1'b0;
				endcase
				
				pc_en = pc_ld;
				mux_A_sel = instruction[3:0];
				state = JUMP_2;
			end
			 
			// 9
			JUMP_2:
			begin
				pc_ld = 1'b0;
				pc_en = 1'b0;
				state = FETCH_1;
			end
		
			// 10
			JAL_1:
			begin
				pc_ld = 1'b1;
				pc_en = 1'b1;
				mux_A_sel = instruction[3:0];
				
				old_pc = pc_ins;
				
				// Set low byte of register to low byte of pc
				// MOVI pc_ins[7:0] r[instruction[11:8]]
				instruction = {4'b1101, instruction[11:8], old_pc[7:0]};
				state = JAL_2;
			end
			
			// 11
			JAL_2:
			begin
				pc_ld 		= 1'b0;
				pc_en 		= 1'b0;
				opcode 		= instruction;
				mux_A_sel 	= instruction[11:8];	// Destination
				mux_B_sel 	= instruction[3:0];  	// Source
				reg_en 		= mux_out;
				state = JAL_3;
			end
			
			// 12
			JAL_3:
			begin
				// set high byte of register to high byte of pc
				// LUI pc_ins[9:8] r[instruction[11:8]]
				instruction = {4'b1111, instruction[11:8], {(16-ADDR_WIDTH){1'b0}}, old_pc[ADDR_WIDTH-1:8]};
				state = R_TYPE;
			end
			
			// 13
			SNES_1:
			begin
				// TODO select snes_data based on insruction[3:0]
				// MOVI button_data[7:0] r[instruction[11:8]]
				snes_num = instruction[0];
				if (snes_num)
				begin
					instruction = {4'b1101, instruction[11:8], snes_data1[7:0]};	
				end
				else
				begin
					instruction = {4'b1101, instruction[11:8], snes_data[7:0]};
				end
				state = SNES_2;
			end
			
			// 14
			SNES_2:
			begin
				opcode 		= instruction;
				mux_A_sel 	= instruction[11:8];	// Destination
				mux_B_sel 	= instruction[3:0];  	// Source
				reg_en 		= mux_out;	
				state = SNES_3;
			end
			
			// 15
			SNES_3:
			begin
				// LUI button_data[11:8] r[instruction[11:8]]
				if (snes_num)
				begin
					instruction = {4'b1111, instruction[11:8], 4'b0, snes_data1[11:8]};
				end
				else
				begin
					instruction = {4'b1111, instruction[11:8], 4'b0, snes_data[11:8]};
				end
				state = R_TYPE;
			end
			
			
			
			// 16
			STOP:
			begin
				opcode 		= 16'bx;
				mux_A_sel 	= 4'bx;
				mux_B_sel	= 4'bx;
				alu_sel 		= 1'b1;
				pc_sel 		= 1'b1;
				mem_w_en_a 	= 1'b0;
				mem_w_en_b 	= 1'b0;
				reg_en 		= 16'b0;
				flag_en 		= 1'b0;
				pc_en 		= 1'b0;
				pc_ld			= 1'b0;
				instruction = 16'bx;
				state = STOP;
			end
			
		endcase
	end	
	
	Mux4to16 regEnable(instruction[11:8], mux_out);
	
endmodule



module Mux4to16(s, decoder_out);

	input [3:0] s;
	output reg [15:0] decoder_out;
	
	always @ (s)
	begin
		case (s)
			4'h0 : decoder_out = 16'h0001;
			4'h1 : decoder_out = 16'h0002;
			4'h2 : decoder_out = 16'h0004;
			4'h3 : decoder_out = 16'h0008;
			4'h4 : decoder_out = 16'h0010;
			4'h5 : decoder_out = 16'h0020;
			4'h6 : decoder_out = 16'h0040;
			4'h7 : decoder_out = 16'h0080;
			4'h8 : decoder_out = 16'h0100;
			4'h9 : decoder_out = 16'h0200;
			4'hA : decoder_out = 16'h0400;
			4'hB : decoder_out = 16'h0800;
			4'hC : decoder_out = 16'h1000;
			4'hD : decoder_out = 16'h2000;
			4'hE : decoder_out = 16'h4000;
			4'hF : decoder_out = 16'h8000;
		endcase
	end
	
endmodule






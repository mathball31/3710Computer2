

module FSM(clk, reset, mem_in, flags, opcode, mux_A_sel, mux_B_sel, alu_sel, pc_sel, 
	mem_w_en_a, mem_w_en_b, reg_en, flag_en, pc_en);

	input clk, reset;
	input [15:0] mem_in;
	input [4:0] flags;
	output reg [15:0] opcode, reg_en;
	output reg [3:0] mux_A_sel, mux_B_sel;
	output reg pc_sel, mem_w_en_a, mem_w_en_b, flag_en, alu_sel, pc_en;
	
	wire [15:0] mux_out;
	reg [3:0] state;
	reg [15:0] instruction;
	
	parameter RESET		= 4'b0000;
	parameter FETCH_1 	= 4'b0001;
	parameter FETCH_2		= 4'b0010;
	parameter R_TYPE		= 4'b0011;
	parameter STORE_1		= 4'b0100;
	parameter STORE_2		= 4'b0101;
	parameter LOAD_1		= 4'b0110;
	parameter LOAD_2		= 4'b0111;
	parameter JUMP_1		= 4'b1000;
	parameter JUMP_2		= 4'b1001;
	
	
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
				reg_en 		= 16'bx;
				flag_en		= 1'b0;
				pc_en 		= 1'b0;

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
				opcode 		= 16'bx;
				mux_A_sel 	= 16'bx;
				mux_B_sel	= 16'bx;
				alu_sel 		= 1'b1;
				pc_sel 		= 1'b1;
				mem_w_en_a 	= 1'b0;
				mem_w_en_b 	= 1'b0;
				reg_en 		= 16'bx;
				flag_en 		= 1'b0;
				pc_en 		= 1'b1;
				instruction = 16'bx;
				state 		= FETCH_2;
			end
			
			// 2
			FETCH_2:
			begin
				pc_en 		= 1'b0;
				instruction = mem_in;

				if (instruction[15:12] != 4'b0100) 
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
						4'b1100:
						begin
							state = JUMP_1;
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
				reg_en 		= mux_out;				
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
				
			end
			 
			// 9
			JUMP_2:
			begin
				reg_en 		= 16'bx;
				opcode 		= 16'bx;
			end	
			
		endcase
	end	
	
	Mux4to16 regEnable(mem_in[11:8], mux_out);
	
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






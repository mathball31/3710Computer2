

module FSM(clk, reset, data, flags, opcode, mux_A_sel, mux_B_sel, pc_sel, imm_sel, 
	mem_w_en_a, mem_w_en_b, reg_en, flag_en, alu_sel, pc_en);

	input clk, reset;
	input [15:0] data;
	input [4:0] flags;
	output reg [15:0] opcode, reg_en;
	output reg [3:0] mux_A_sel, mux_B_sel;
	output reg pc_sel, imm_sel, mem_w_en_a, mem_w_en_b, flag_en, alu_sel, pc_en;
	
	wire [15:0] mux_out;
	reg [3:0] state;
	
  	parameter RESET		= 4'b0000;
	parameter FETCH 		= 4'b0001;
	parameter R_TYPE_1	= 4'b0010;
	parameter R_TYPE_2	= 4'b0011;
	parameter STORE_1		= 4'b0100;
	parameter STORE_2		= 4'b0101;
	parameter LOAD_1		= 4'b0110;
	parameter LOAD_2		= 4'b0111;
	parameter JUMP_1		= 4'b1000;
	parameter JUMP_2		= 4'b1001;
	
	
	//TODO sensitivity list
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
				//pc_en = 1'b0;
				flag_en = 1'b0;
				reg_en = 1'b0;
				mem_w_en_a = 1'b0;
				mem_w_en_b = 1'b0;
				alu_sel = 1'b1; // alu_sel = 1 means use alu_bus.
				pc_sel = 1'b1;
				opcode = 16'bx;
				reg_en = 16'bx;
				
				if (reset) 
				begin
					pc_en = 1'b0;
					state = RESET;
				end
				
				else 
				begin
					pc_en = 1'b1;  // TODO
					state = FETCH;
				end
			end
			
			// 1
			FETCH:
			begin
				pc_en = 1'b0;
				flag_en = 1'b0;
				reg_en = 1'b0;
				mem_w_en_a = 1'b0;
				mem_w_en_b = 1'b0;
				pc_sel = 1'b1;
				alu_sel = 1'b1;
				opcode = 16'bx;
				reg_en = 16'bx;
				
				if (data[15:12] != 4'b0100) 
				begin
					state = R_TYPE_1;
				end
				
				else if (data[15:12] == 4'b0100)
				begin
					case (data[7:4])
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
			
			// 2
			R_TYPE_1:
			begin
				opcode = data;
				mux_A_sel = data[11:8];	// Destination
				mux_B_sel = data[3:0];  	// Source
				
				reg_en = mux_out;
				alu_sel = 1'b1;
				pc_en = 0;
				
				state = R_TYPE_2;
			end
			
			// 3
			R_TYPE_2:
			begin
				reg_en = 16'bx;
				opcode = 16'bx;
				pc_en = 1'b1; // TODO
				state = FETCH;
			end
			
			// 4
			STORE_1:
			begin
				reg_en = 16'bx; // Don't write to a reg yet.
				opcode = 16'bx;
				pc_sel = 1'b0;
				pc_en = 1'b0;
			end
			
			// 5
			STORE_2:
			begin
				reg_en = 16'bx;
				opcode = 16'bx;
			end
			
			// 6
			LOAD_1:
			begin
				opcode = 16'bx;
				pc_en = 1'b0;
				pc_sel = 1'b0;
				mem_w_en_a = 1'b0;
				mem_w_en_b = 1'b0;
				// Destination register set by Mux4to16.
				mux_A_sel = data[3:0];  	// Address 
				reg_en = mux_out;

				
				state = LOAD_2;
			end
			
			// 7
			LOAD_2:
			begin
				opcode = 16'bx;
				pc_en = 1'b0;
				pc_sel = 1'b1;
				alu_sel = 1'b0; // alu_sel = 0 means use mem_out (data)
				state = R_TYPE_2;
			end
			
			// 8
			JUMP_1:
			begin
				reg_en = 16'bx;
				opcode = 16'bx;
			end
			 
			// 9
			JUMP_2:
			begin
				reg_en = 16'bx;
				opcode = 16'bx;
			end			
		endcase
	end
	

	
	
	Mux4to16 regEnable(data[11:8], mux_out);


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






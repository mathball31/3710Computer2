`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:54:08 08/30/2011 
// Design Name: 
// Module Name:    alu 
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
module ALU(dest, src, opcode, carry_in, flags, out);
	input [15:0] dest, src, opcode;
	input carry_in;

	output reg [4:0] flags;
	output reg [15:0] out;

	// flags
	parameter Z	= 4; // Zero
	parameter C	= 3; // Carry
	parameter F = 2; // overFlow
	parameter N	= 1; // Negative
	parameter L	= 0; // Low
	
	// opcode high
	parameter R_TO_R 		= 4'b0000;
	parameter ADDI 		= 4'b0101;
	parameter ADDUI		= 4'b0110;
	parameter ADDCI		= 4'b0111;
	parameter MULI			= 4'b1110;
	parameter SUBI			= 4'b1001;
	parameter SUBCI		= 4'b1010;
	parameter CMPI			= 4'b1011;
	parameter ANDI			= 4'b0001;
	parameter ORI			= 4'b0010;
	parameter XORI			= 4'b0011;
	parameter MOVI			= 4'b1101;
	parameter SHIFT		= 4'b1000;
	parameter LUI			= 4'b1111;
	
	// opcode low R_TO_R
	parameter ADD	= 4'b0101;
	parameter ADDU	= 4'b0110;
	parameter ADDC	= 4'b0111;
	parameter MUL	= 4'b1110;
	parameter SUB	= 4'b1001;
	parameter SUBC	= 4'b1010;
	parameter CMP	= 4'b1011;
	parameter AND	= 4'b0001;
	parameter OR	= 4'b0010;
	parameter XOR	= 4'b0011;
	parameter MOV	= 4'b1101;
	
	// opcode low SHIFT
	parameter LSH		= 4'b0100;
	parameter LLSHI	= 4'b0000;
	parameter LRSHI	= 4'b0001;
	parameter ASH		= 4'b0110;
	parameter ALSHI	= 4'b0010;
	parameter ARSHI	= 4'b0011;
	
	always @(dest, src, opcode, carry_in)
	begin
		out = 16'bx;
		flags = 5'bx;
		// check opcode high
		case (opcode[15:12])
			R_TO_R:
			begin
				// check opcode low
				case (opcode[7:4])	
					ADD:
					begin
						{flags[C], out} = dest + src;						
						flags[F] = ((~dest[15] & ~src[15] & out[15]) | (dest[15] & src[15] & ~out[15])); 
					end
					
					ADDU:
					begin
						out = dest + src;						
					end
						
					ADDC:
					begin
						{flags[C], out} = dest + src + carry_in;						
						flags[F] = ((~dest[15] & ~src[15] & out[15]) | (dest[15] & src[15] & ~out[15])); 
					end
					
					MUL:
					begin
						out = dest * src;
					end
					
					SUB:
					begin
						out = dest - src;
						flags[F] = ((~dest[15] & src[15] & out[15]) | (dest[15] & ~src[15] & ~out[15]));
						flags[C] = src > dest;
					end
					
					SUBC:
					begin
						out = dest - src - carry_in;
						flags[F] = ((~dest[15] & src[15] & out[15]) | (dest[15] & ~src[15] & ~out[15]));
						flags[C] = src > (dest - carry_in);
					end
					
					CMP:
					begin
						flags[L] = (src > dest);
						flags[N] = ($signed(src) > $signed(dest));
						flags[Z] = (src == dest);
						out = 16'b0;
					end

					AND:
					begin
						out = dest & src;
					end
						
					OR:
					begin
						out = dest | src;
					end
						
					XOR:
					begin
						out = dest ^ src;
					end
						
					MOV:
					begin
						out = src;
					end

					default:
					begin
						// when there is no opcode to use
						out = 16'bx;
					end
				endcase 
			end // R_TO_R
		
			ADDI:
			begin
				{flags[C], out} = dest + opcode[7:0];
				flags[F] = ((~dest[15] & ~opcode[7] & out[15]) | (dest[15] & opcode[7] & ~out[15])); 
			end
			
			ADDUI:
			begin
				out = dest + {8'b0, opcode[7:0]};
			end
				
			ADDCI:
			begin
				{flags[C], out} = dest + opcode[7:0] + carry_in;
				flags[F] = ((~dest[15] & ~opcode[7] & out[15]) | (dest[15] & opcode[7] & ~out[15])); 
			end
			
			MULI:
			begin
				out = dest * opcode[7:0];
			end
			
			SUBI:
			begin
				out = dest - opcode[7:0];
				flags[F] = ((~dest[15] & opcode[7] & out[15]) | (dest[15] & ~opcode[7] & ~out[15]));
				flags[C] = {{8{opcode[7]}}, opcode[7:0]} > dest;
			end
			
			SUBCI:
			begin
				out = dest - opcode[7:0] - carry_in;
				flags[F] = ((~dest[15] & opcode[7] & out[15]) | (dest[15] & ~opcode[7] & ~out[15]));
				flags[C] = {{8{opcode[7]}}, opcode[7:0]} > (dest - carry_in);
			end
			
			CMPI:
			begin
				flags[L] = ({8'b0, opcode[7:0]} > dest);
				flags[N] = ($signed({{8{opcode[7]}}, opcode[7:0]}) > $signed(dest));
				flags[Z] = ({{8{opcode[7]}}, opcode[7:0]} == dest);
				out = 16'b0;			
			end
			
			ANDI:
			begin
				out = {dest[15:8], (dest[7:0] & opcode[7:0])};
			end
			
			ORI:
			begin
				out = {dest[15:8], (dest[7:0] | opcode[7:0])};
			end
			
			XORI:
			begin
				out = {dest[15:8], (dest[7:0] ^ opcode[7:0])};
			end
			
			MOVI:
			begin
				out = {8'b0, opcode[7:0]};
			end
			
			SHIFT:
			begin
				// check opcode low
				case (opcode[7:4])
					// Logical shift
					LSH:
					begin
						//if negative
						if (src[4])
						begin
							out = dest >> (-src[4:0]);
						end
						else
						begin
							out = dest << src[4:0];
						end
					end
					
					// Logical Left Shift Immediate
					LLSHI:
					begin
						out = dest << opcode[3:0];
					end
					
					// Logical Right Shift Immediate
					LRSHI:
					begin
						out = dest >> opcode[3:0];
					end
					
					// Arithmetic Shift
					ASH:
					begin
						//if negative
						if (src[4])
						begin
							out = dest >>> (-src[4:0]);
						end
						else
						begin
							out = dest <<< src[4:0];
						end
					end
					
					// Arithmetic left Shift Immediate
					ALSHI:
					begin
						out = dest <<< opcode[3:0];
					end
					
					// Arithmetic Right Shift Immediate
					ARSHI:
					begin
						out = dest >>> opcode[3:0];
					end
					
					default:
					begin
						// when there is no opcode to use
						out = 16'bx;
					end	
				endcase 
			end // shift
			
			LUI:
			begin
				out = {opcode[7:0], dest[7:0]};
			end
				
			
			default:
				begin
					// when there is no opcode to use
					out = 16'bx;
				end
		endcase
	end

endmodule

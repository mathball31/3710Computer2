`timescale 1ns / 1ps
// Datapath wrapper

module DatapathTest; 
	
	reg Cin = 0;
	reg clk = 0;
	reg reset = 1;
	wire [4:0] flags;
	wire [15:0] alu_bus;	
	
	Datapath dp(Cin, clk, reset, flags, alu_bus);
	
	initial
	begin
		#5;
		reset = 1;
		#10
		reset = 0;
	end
	
	always
	begin
		clk = !clk;		
		#5;
	end

endmodule 
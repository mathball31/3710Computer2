`timescale 1ns / 1ps
// Datapath wrapper

module DatapathTest; 
	
	reg clk = 0;
	reg reset = 1;
	//wire [4:0] flags;
	//wire [15:0] alu_bus;
	wire [27:0] Display;
	
	Datapath dp(clk, reset, Display);
	
	initial
	begin
		#5;
		reset = 0;
		#10
		reset = 1;
	end
	
	always
	begin
		clk = !clk;		
		#5;
	end

endmodule 
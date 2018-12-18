`timescale 1ns / 1ps
// Datapath wrapper

module DatapathTest; 
	
	reg clk = 0;
	reg reset = 1;
	reg serial_data = 1;
	//wire [4:0] flags;
	//wire [15:0] alu_bus;
	wire snes_clk, data_latch, hSync, vSync, bright, slowClk;
	wire [7:0] rgb;
	
	Datapath dp(clk, reset, serial_data, snes_clk, data_latch, hSync, vSync, bright, rgb, slowClk);
	
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
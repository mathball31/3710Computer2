`timescale 1ns / 1ps

module SNES_test;

	reg clk = 0;
	reg reset = 0;
	wire serial_data, snes_clk, data_latch;
	//wire [11:0] button_data;
	wire [5:0] output_data;
	wire testLED;
	
	integer i;
	
	initial
	begin
		for (i = 0; i < 10000000; i = i+1)
		begin
			clk = ~clk;
			#10;
		end
	end
	
	//SNES_Control snes_control(clk, serial_data, snes_clk, data_latch, button_data, testLED);
	SNES_Wrapper snes_wrapper(clk, reset, serial_data, snes_clk, data_latch, output_data, testLED);


endmodule

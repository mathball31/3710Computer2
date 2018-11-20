// SNES Control

module SNES_Control(clk, serial_data,  snes_clk, data_latch, button_data);
	input clk, serial_data;
	output snes_clk, data_latch;
	output reg [11:0] button_data;
	reg counter = 1'b0;
	
	always @(posedge clk)
	begin
		counter = counter + 1'b1;
		
		
	end
	
endmodule

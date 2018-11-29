/// Wrapper to give SNES_Control a slower clock

module SNES_Wrapper(clk, reset, serial_data, snes_clk, data_latch, output_data);
	input clk, reset, serial_data;
	output snes_clk, data_latch;
	output reg [5:0] output_data;
	
	parameter B = 0;
	parameter UP = 4;
	parameter DOWN = 5;
	parameter LEFT = 6;
	parameter RIGHT = 7;
	parameter A = 8;
	
	wire [11:0] button_data;
	always @ (button_data)
	begin
		output_data[5] = button_data[A];
		output_data[4] = button_data[RIGHT];
		output_data[3] = button_data[LEFT];
		output_data[2] = button_data[DOWN];
		output_data[1] = button_data[UP];		
		output_data[0] = button_data[B];
	end
	
	wire clk_1200, locked;
	
	Clock_1200kHz clock_1200kHz(clk, reset, clk_1200, locked);
	
	SNES_Control snes_control(clk_1200, serial_data, snes_clk, data_latch, button_data);

endmodule

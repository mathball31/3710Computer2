// SNES Control

module SNES_Control(clk, reset, serial_data, snes_clk, data_latch, button_data);
	
		// Place holder for the number of clock ticks that corresponds to a 
	// data latch signal being sent out every 16.67 ms (about 60 Hz)
	// Corresponds to 20,000 clock ticks when clock speed is 1.2 MHz
	// 110_0101_1011_1110_1110
	parameter PULSE	= 16'b0100_1110_0010_0000;	
	// Place holder for 6 us; speed of snes_clk toggle
	// Corresponds to about 7 (7.2) clock ticks when clock speed is 1.2 MHz
	parameter SIXu		= 16'b0000_0000_0000_0111;	
	// Place holder for 12us; width of the data latch pulse
	// Corresponds to about 14 (14.4) clock ticks when clock speed is 1.2 MHz
	parameter TWELVEu	= 16'b0000_0000_0000_1110;
	
	
	input clk, reset, serial_data;
	output reg snes_clk, data_latch;
	output reg [11:0] button_data;
	
	reg [15:0] counter = PULSE;
	reg [15:0] temp_counter;
	reg [3:0] button_counter;
	reg latch_complete = 1'b0;
		

	
	

	// SNES controller button to clock pulse assignment
	parameter B			= 4'b0000; // 0
	parameter Y			= 4'b0001; // 1
	parameter SELECT	= 4'b0010; // 2
	parameter START	= 4'b0011; // 3
	parameter UP		= 4'b0100; // 4
	parameter DOWN		= 4'b0101; // 5
	parameter LEFT		= 4'b0110; // 6
	parameter RIGHT	= 4'b0111; // 7
	parameter A			= 4'b1000; // 8
	parameter X			= 4'b1001; // 9 
	parameter L			= 4'b1010; // 10
	parameter R			= 4'b1011; // 11
	
	always @(posedge clk)
	begin
		if (reset)
		begin
			counter = PULSE;
			temp_counter 	= counter;
			button_counter = 4'b1111;
			latch_complete = 1'b0;
			snes_clk 		= 1'b1;
			data_latch 		= 1'b0;
			button_data 	= 12'b0;
		end
		
		if (counter == PULSE)
		begin
			counter 			= 16'b0;
			temp_counter 	= counter;
			button_counter = 4'b1111;
			latch_complete = 1'b0;
			
			snes_clk 		= 1'b1;
			data_latch 		= 1'b1;
			
		end
		
		if ((counter - temp_counter) == TWELVEu)
		begin
			temp_counter 	= counter;
			latch_complete = 1'b1;
			
			data_latch 		= 1'b0;
		end
		
		else if ((counter - temp_counter) == SIXu && latch_complete)
		begin
			button_counter = button_counter + snes_clk;
			snes_clk 		= ~snes_clk;
			temp_counter 	= counter;
			
			if (~snes_clk)
				begin
				case (button_counter)
					B:
					begin
						button_data[B] 		= ~serial_data;
					end
					Y:
					begin
						button_data[Y] 		= ~serial_data;
					end
					SELECT:
					begin
						button_data[SELECT] 	= ~serial_data;
					end
					START:
					begin 
						button_data[START] 	= ~serial_data;
					end
					UP:
					begin
						button_data[UP] 		= ~serial_data;
					end
					DOWN:
					begin
						button_data[DOWN] 	= ~serial_data;
					end
					LEFT:
					begin
						button_data[LEFT] 	= !serial_data;
					end
					RIGHT:
					begin
						button_data[RIGHT] 	= ~serial_data;
					end
					A:
					begin
						button_data[A] 		= ~serial_data;
					end
					X:
					begin
						button_data[X] 		= ~serial_data;
					end
					L:
					begin
						button_data[L] 		= ~serial_data;
					end
					R:
					begin
						button_data[R] 		= ~serial_data;
					end
					4'b1111:
					begin
						temp_counter = 16'b0;
						latch_complete = 1'b0;
					end
				endcase
			end // if ~snes_clk
		end // else if for SIXu
		
		counter = counter + 16'b0000_0000_0000_0001;
	end // always block
	
endmodule

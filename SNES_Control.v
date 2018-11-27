// SNES Control

module SNES_Control(clk, serial_data, snes_clk, data_latch, button_data);
	input clk, serial_data;
	output reg snes_clk, data_latch;
	output reg [11:0] button_data;
	
	// TODO make wider (counter & temp_counter)
	reg [15:0] counter 			= 16'b0;
	reg [15:0] temp_counter 	= TWELVEu;
	reg [3:0] button_counter;
	
	// Place holder for the number of clock ticks that corresponds to a 
	// data latch signal being sent out every 16.67 ms (about 60 Hz)
	// TODO
	parameter PULSE	= 16;
	
	// Place holder for however fast snes_clk is supposed to be
	// TODO
	parameter SIXu		= 6;	
	// Place holder for how wide the data latch pulse is (12 us)
	// TODO
	parameter TWELVEu	= 12;

	// SNES controller button to clock pulse assignment
	parameter B			= 0;
	parameter Y			= 1;
	parameter SELECT	= 2;
	parameter START	= 3;
	parameter UP		= 4;
	parameter DOWN		= 5;
	parameter LEFT		= 6;
	parameter RIGHT	= 7;
	parameter A			= 8;
	parameter X			= 9;
	parameter L			= 10;
	parameter R			= 11;
	
	
	always @(posedge clk)
	begin
		counter = counter + 1'b1;
		
		if (counter == PULSE)
		begin
			data_latch 	= 1'b1;
			temp_counter = counter;
			snes_clk = 1'b1;
			button_counter = 4'b1111;
		end
		
		if ((counter - temp_counter) == TWELVEu)
		begin
			data_latch = 1'b0;
			temp_counter = counter;
		end
		
		else if ((counter - temp_counter) == SIXu)
		begin
			button_counter = button_counter + snes_clk;
			snes_clk 		= ~snes_clk;
			temp_counter 	= counter;
			
			if (~snes_clk)
				begin
				case (button_counter)
					B:
					begin
						button_data[B] = ~serial_data;
					end
					Y:
					begin
						button_data[Y] = ~serial_data;
					end
					SELECT:
					begin
						button_data[SELECT] = ~serial_data;
					end
					START:
					begin 
						button_data[START] = ~serial_data;
					end
					UP:
					begin
						button_data[UP] = ~serial_data;
					end
					DOWN:
					begin
						button_data[DOWN] = ~serial_data;
					end
					LEFT:
					begin
						button_data[LEFT] = !serial_data;
					end
					RIGHT:
					begin
						button_data[RIGHT] = ~serial_data;
					end
					A:
					begin
						button_data[A] = ~serial_data;
					end
					X:
					begin
						button_data[X] = ~serial_data;
					end
					L:
					begin
						button_data[L] = ~serial_data;
					end
					R:
					begin
						button_data[R] = ~serial_data;
					end
					4'b1111:
					begin
						counter = 1'b0;
						temp_counter = TWELVEu;
					end
				endcase
			end // if ~snes_clk
		end // else if for SIXu
	end // always block
	
endmodule

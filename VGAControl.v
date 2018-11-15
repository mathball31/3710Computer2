
/*	FPGA has a 50MHz clock and a 25MHz clock - recommended to us 25MHz clock

	VGA 640x480 @ 60Hz refresh and 40MHz pixel clock
	
	HSync
			Timing		Clocks
		A	3.8us			
		B	1.6us			
		C	25.4us		
		D	0.6us			
		E	31.4us		
		
	A = sync pulse length		B = back porch		C = active video time		D = front porch		E = scanline time
	To find the timing, multiply the timing with the pixel clock
	
	VSync
			Lines			Clocks
		A	2				
		B	33				
		C	480			
		C	10				
		F	525			
	
	A = sync pulse length		B = back porch		C = active video time		D = front porch		F = total frame time
	To find the clock cycles, multiply the lines with the total scanline time of the HSync
	
	Only cares about the HSync and VSync and the falling edge of those pulses
	This file should only be about timing - BitGen takes care of all the drawing.
*/
module VGAcontrol (
	input clock, clear,
	output reg hSync, vSync, bright,
	output reg [9:0] hCount, vCount);

	// hsync, vsync are asserted low - high rest of the time
	
	//	hcount, vcount are used by BitGen to keep track of where you are on the screen
	// best if counts are the counts of the pixels on the screen
	// hcount = (0, 639), vcount = (0, 479)
	
	// bright can be asserted high or low - used by BitGen to say whether or not to draw a pixel

endmodule

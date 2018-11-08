
/*	FPGA has a 50MHz clock and a 25MHz clock - we'll start with 50MHz

	SVGA 800x600 @ 60Hz refresh and 40MHz pixel clock - we may need a wrapper for this
		Check the stopwatch project from previous semester
	
	HSync
			Timing		Clocks
		A	3.2us			128
		B	2.2us			88
		C	20us			800
		D	2us			40
		E	26.4us		1056
		
	A = sync pulse length		B = back porch		C = active video time		D = front porch		E = scanline time
	To find the timing, multiply the timing with the pixel clock
	
	VSync
			Lines			Clocks
		A	4				4224
		B	23				24288
		C	600			633600
		C	1				1056
		F	628			663168
	
	A = sync pulse length		B = back porch		C = active video time		D = front porch		F = total frame time
	To find the clock cycles, multiply the lines with the total scanline time of the HSync
	
	Only cares about the HSync and VSync and the falling edge of those pulses
	This file should only be about timing - BitGen takes care of all the drawing.
*/
module VGAcontrol ();

	// hsync, vsync, hcount, vcount, bright (?)

endmodule

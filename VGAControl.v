
/*	FPGA has a 50MHz clock and a 25MHz clock - recommended to us 25MHz clock
	VGA 640x480 @ 60Hz refresh and 25MHz pixel clock
	
	HSync
			Timing		Clocks
		A	3.8us			95
		B	1.6us			40
		C	25.4us		640
		D	0.6us			15
		E	31.4us		785
		
	A = sync pulse length		B = back porch		C = active video time		D = front porch		E = scanline time
	To find the number of clock cycles, multiply the timing with the pixel clock
	
	VSync
			Lines			Clocks
		A	2				62.8
		B	33				1036.2
		C	480			15072
		D	10				314
		F	525			16485
	
	A = sync pulse length		B = back porch		C = active video time		D = front porch		F = total frame time
	To find the clock cycles, multiply the lines with the total scanline time of the HSync
*/
module VGAcontrol (
	input clock, clear,
	output reg hSync, vSync, bright,
	output reg [9:0] hCount, vCount);
	
	parameter HVID = 640;			// pixel width 
	parameter HPULSE = 95;			// sync pulse length
	parameter HBACK = 60;			// back porch length
	parameter HFRONT = 15;			// front port length
	parameter HMAX = 785;			// max length of horizontal pulse
	
	parameter VVID = 480;			// pixel height
	parameter VPUSLE = 63;			// sync pulse
	parameter VBACK = 1036;			// back porch
	parameter VFRONT = 314;			// front porch
	parameter VMAX = 16485;			// max length for vertical pulse
	
	wire hreset;
	wire vreset;
	
	// hsync, vsync are asserted low - high rest of the time <- active low
	// use nested if loops or separate always blocks
	always@ (posedge clock)
	begin
		if (hreset)
		begin
			// reset has been fired for horizontal sync
			hCount <= 0;
			
			if (vreset)
			begin
				vCount <= 0;
			end
			else 
			begin
				vCount <= vCount + 1;
			end
		end
		else
		begin
			// herest == 0
			hCount <= hCount + 1;
			vCount <= vCount;			// make sure vCount stays constant until reset has been fired
		end
	end
	
	assign hreset = (hCount == (HMAX - 1));		// MAX - 1 because we start counting from 0
	
	assign vreset = (vCount == (VMAX - 1));
	
	
	//	hcount, vcount are used by BitGen to keep track of where you are on the screen
	// best if counts are the counts of the pixels on the screen
	// hcount = (0, 639), vcount = (0, 479)
	
	// bright can be asserted high or low - used by BitGen to say whether or not to draw a pixel
	// this is enabled when the position is the active area of the screen

endmodule

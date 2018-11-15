
/*	FPGA has a 50MHz clock and a 25MHz clock - recommended to us 25MHz clock

	VGA 640x480 @ 60Hz refresh and 40MHz pixel clock
	
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
		C	10				314
		F	525			16485
	
	A = sync pulse length		B = back porch		C = active video time		D = front porch		F = total frame time
	To find the clock cycles, multiply the lines with the total scanline time of the HSync
*/
module VGAcontrol (
	input clock, clear,
	output reg hSync, vSync, bright,
	output reg [9:0] hCount, vCount);
	
	reg [7:0] h_sbpCount;			// sync and backporch pulse count for horizontal timing
	reg [7:0] v_sbpCount;			// sync and backporch pulse count for vertical timing
	
	// hsync, vsync are asserted low - high rest of the time
	always@(posedge clock)
	begin
		// when hCount = 640, hSync = 1
		//	when hSync = 1, hCount = 0, v_en = 1, count sync and back porch pulses
		 
		// count sync and backporch pulses first
		h_sbpCount <= h_sbpCount + 1;
		
		// when they hit 135 clock cycles, turn on hSync
		if(h_sbpCount >= 135)
		begin
			hSync <= 1;
		end
		else
		begin
			hSync <= 0;
		end

		// if hSync is on, then start counting hCount
		if(hSync)
		begin
			hCount <= hCount + 1;
		end
		else
		begin
			// if it's off, clear hCount, turn on v_en
			hCount <= 0;
			v_en <= 1;
		end		
	end
	
	
	//	hcount, vcount are used by BitGen to keep track of where you are on the screen
	// best if counts are the counts of the pixels on the screen
	// hcount = (0, 639), vcount = (0, 479)
	
	// bright can be asserted high or low - used by BitGen to say whether or not to draw a pixel
	// this is enabled when the position is the active area of the screen

endmodule

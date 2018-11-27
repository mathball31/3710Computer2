
/* Driver module of the VGA */
module VGA (
	input clk,
	output hSync, vSync, bright,
	output rgb
	);

	wire [9:0] hCount, vCount;
	
	VGAControl control (.clock(clk), .hSync(hSync), .vSync(vSync), .bright(bright), .hCount(hCount), .vCount(vCount));
	
	BitGen gen (.bright(bright), .pixelData(8'b0000_0000), .hCount(hCount), .vCount(vCount), .rgb(rgb));
	
endmodule


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
module VGAControl (
	input clock,
	output reg hSync, vSync, bright,
	output reg [9:0] hCount, vCount);
	
	//	hcount, vcount are used by BitGen to keep track of where you are on the screen
	// best if counts are the counts of the pixels on the screen
	// hcount = (0, 639), vcount = (0, 479)

	parameter HVID = 640;			// pixel width 
	parameter HPULSE = 95;			// sync pulse length
	parameter HBACK = 60;			// back porch length
	parameter HFRONT = 15;			// front port length
	parameter HMAX = 785;			// max length of horizontal pulse
	
	parameter VVID = 480;			// pixel height
	parameter VPULSE = 63;			// sync pulse
	parameter VBACK = 1036;			// back porch
	parameter VFRONT = 314;			// front porch
	parameter VMAX = 16485;			// max length for vertical pulse
	
	reg vBlank, hBlank;
	wire hReset, hSyncOn, hSyncOff, hOff;
	wire vReset, vSyncOn, vSyncOff, vOff;
	
	// hsync, vsync are asserted low - high rest of the time <- active low
	// use nested if loops or separate always blocks
	always@ (posedge clock)
	begin
		// a different way of using conditionals with a conditional operator!
		// syntax -> conditional ? true : false
		
		// if hReset == 0, hCount = 0; else hCount <= hCount + 1;
		hCount <= hReset ? 0 : hCount + 1;
		// statement of how hSync should behave
		// if hSyncOn == 1, hSync <= (fires). Else, if hSyncOff == 1, don't fire (hSync <= 1)
		// otherwise, retain it's previous state
		hSync <= hSyncOn ? 0 : hSyncOff ? 1 : hSync;
		// if hReset == 1, hBlank == 0. Else if hReset == 0, check if hOff == 1, hBlank == 1
		// which menas that the beam shouldn't be in use
		// otherwise retain previous state.
		hBlank <= hReset ? 0 : hOff ? 1 : hBlank;
		
		
		// if hReset == 0, if vReset == 0, vCount <= 0, else increment
		// else just keep vCount as it is -> horizontal beam hasn't reached the end
		vCount <= hReset ? (vReset ? 0 : vCount + 1) : vCount;
		// statement of how vSync should behave - almost exactly the same as hSync
		vSync <= vSyncOn ? 0 : vSyncOff ? 1 : vSync;
		vBlank <= vReset ? 0 : vOff ? 1 : vBlank;
		
		// bright can be asserted high or low - used by BitGen to say whether or not to draw a pixel
		// this is enabled when the position is in the active area of the screen
		// bright == 1 when vBlank == hBlank == 0 <- "blanking" is not on (the beam is on)
		bright <= !(vBlank && hBlank);
	end
	
	
	assign hReset = (hCount == (HMAX - 1));		// MAX - 1 because we start counting from 0
	// tells hsync when to fire, happens after the display has been shown, and front porch happens
	assign hSyncOn = (hCount == ((HVID + HFRONT) - 1));
	// turn off hsync
	assign hSyncOff = (hCount == (HPULSE - 1));
	// when the beam shouldn't be on for the horizontal sync, which is during pulse, back porch, and front porch
	assign hOff = (hCount == ((HPULSE + HBACK) - 1) || (hCount == ((HVID + HFRONT) - 1)));
	
	
	assign vReset = (vCount == (VMAX - 1));
	
	// telss vSync when to fire, happens after display has been shown and front porch happens
	assign vSyncOn = hReset & (vCount == ((VVID + VFRONT) - 1));
	assign vSyncOff = hReset & (vCount == (HPULSE - 1));
	assign vOff = hReset & (vCount == ((VPULSE + VBACK) - 1) || (vCount == ((VVID + VFRONT) - 1)));
	
endmodule

/*
	Is a combinational circuit
	Decides for each pixel what color should be on the screen
	
	Glyph graphics - break the screen into chunks
*/
module BitGen (
	input bright,
	input [7:0] pixelData,
	input [9:0] hCount, vCount,
	output reg [7:0] rgb);
	
	// First just dipslay vertical bars of each color:
	parameter BLACK = 8'b000_000_00;
	parameter BLUE = 8'b000_000_11;
	parameter GREEN = 8'b000_111_00; 
	parameter CYAN = 8'b000_111_11;
	parameter RED = 8'b111_000_00;
	parameter MAGENTA = 8'b111_000_11;
	parameter YELLOW = 8'b111_111_00;
	parameter WHITE = 8'b111_111_11; 
	
	
	 
	// there are 640 pixels in a row, and 480 in a column
	always@(*) // paint the bars
	begin
		if ((hCount >= 0) && (hCount <=80) || ~bright) 
			rgb = BLACK; // force black if not bright 
		else if ((hCount >= 81) && (hCount <= 160))
			rgb = BLUE;
		else if ((hCount >= 161) && (hCount <=240))
			rgb = GREEN;
		else if ((hCount >= 241) && (hCount <= 320))
			rgb = CYAN;
		else if ((hCount >= 321) && (hCount <= 400))
			rgb = RED;
		else if ((hCount >= 401) && (hCount <= 480))
			rgb = MAGENTA;
		else if ((hCount >= 481) && (hCount <= 560))
			rgb = YELLOW;
		else if ((hCount >= 561) && (hCount <= 640))
			rgb = WHITE;
		else
			rgb = BLACK;
	end
	
	/** glyph number is hCount and vCount minus the low three bits
	 * glyph bits are the low-order 4 bits in each of hCount and vCount
	 * Figure out which screen chunk you’re in, then reference the bits from the glyph memory 
	 *
	 * Use 16 pixels square for each block.  This results in a grid of 40 x 30.
	 * the glyphs will be stored somewhere in memory:  They should be:
	 *		* The letters A - Z plus a few special characters (dash)
	 *    * Green glyphs for green snake
	 *    * Blue glyphs for blue snake
	 *    * Red glyphs for food
	 *    * Black (default background color)
	 *
	 * A grid of 40 x 30 would require a memory block of 1200 bytes
	 * and a separate storage for 32 glyphs
	 *
	 * Check which block we are in (refer to the block of memory)
	 *
	 * Check where in the block (glyph) we are in (now refer to the glyph memory)
	 *
	 * Display the correct pixel of the glyph
	 **/

endmodule

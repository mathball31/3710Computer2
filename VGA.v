
/* Driver module of the VGA */
module VGA (
	input clk,
	output hSync, vSync, bright,
	output [7:0] rgb
	);

	wire [9:0] hCount, vCount;
	reg slowClk = 1'b0;
	
	always @ ( posedge clk)
	begin
		slowClk <= ~slowClk;
	end
	
	VGAControl control (slowClk, hSync, vSync, bright, hCount, vCount);
	
	BitGen gen (bright, 8'b0000_0000, hCount, vCount, rgb);
	
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

	parameter HPULSE = 95;			// sync pulse length
	parameter HBACK = 60;			// back porch length
	parameter HVID = 640;			// pixel width 
	parameter HFRONT = 15;			// front port length
	parameter HMAX = 810;			// max length of horizontal pulse
	
	parameter VPULSE = 63;			// sync pulse
	parameter VBACK = 1036;			// back porch
	parameter VVID = 480;			// pixel height
	parameter VFRONT = 314;			// front porch
	parameter VMAX = 1893;			// max length for vertical pulse
	
	wire vBlank, hBlank;
	wire hReset, hsOn, hsOff;
	wire vReset, vsOn, vsOff;
	
	// hsync, vsync are asserted low - high rest of the time <- active low
	always@ (posedge clock)
	begin
		// a different way of using conditionals with a conditional operator!
		// syntax -> conditional ? true : false
		
		// if hReset == 1, then hCount = 0; else hCount <= hCount + 1;
		hCount <= hReset ? 0 : hCount + 1;
		
		// hSync should fire when hsOn == 1; be off when hsOff == 1;
		// otherwise retain its previous state
		hSync <= hsOn ? 0 : hsOff ? 1 : hSync;
		
		
		// if hReset == 0, if vReset == 0, vCount <= 0, else increment
		// else just keep vCount as it is -> horizontal beam hasn't reached the end
		vCount <= hReset ? (vReset ? 0 : vCount + 1) : vCount;
		vSync <= vsOn ? 0 : vsOff ? 1 : vSync;
		
		// bright can be asserted high or low - used by BitGen to say whether or not to draw a pixel
		// this is enabled when the position is in the active area of the screen
		// bright == 1 when vBlank == hBlank == 0 <- "blanking" is not on (the beam is on)
		bright <= !(vBlank && hBlank);
	end
	
	
	// if hCount == MAX, hReset = 1; else, hReset = 0;
	// as soon as hCount hits MAX, then it has reached the end of the row, and is time to fire the rest
	assign hReset = (hCount == HMAX);
	
	// hsOn happens after the front porch has happened, which is the same as the max of the row
	assign hsOn = (hCount == HMAX);
	
	// after the pulse width, as it is the length of time it takes for the sync pulse to go through
	assign hsOff = (hCount == HPULSE);
	
	// turn off the beam when the beam is in either the front or back porches or pulse
	assign hBlank = (hCount > (HMAX - HFRONT) || hCount < (HPULSE + HBACK));
	
	
	// vSync is a lot like hSync, except it relies on hSync
	assign vReset = (vCount == VMAX);
	assign vsON = hReset & (vCount == VMAX);
	assign vsOff = hReset & (vCount == VPULSE);
	assign vBlank = hReset & (vCount > (VMAX - VFRONT) || vCount < (VPULSE + VBACK));	
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
	 *		* The letters A - Z plus a few special characters (dash, colon, exlamation point)
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
	 
	 /*pseudo code for glyphs
	 
	 hGlyphCount = hCount[9:4];
	 hInnerGlyphCount = hCount[3:0];
	 
	 vGlyphCount = vCount[9:4];
	 vInnerGlyphCount = vCount[3:0];
	 
	 GetGlyphFromWorld
	 
	 */
	 

endmodule

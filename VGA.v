
/* Driver module of the VGA */
module VGA (clk, clear, hSync, vSync, bright, rgb, slowClk);
	
	input clk, clear;
	output hSync, vSync;
	output [7:0] rgb;
	output bright;
	output reg slowClk = 0;

	wire [9:0] hCount;
	wire [9:0] vCount;
	
	always @ (posedge clk)
	begin
		slowClk <= ~slowClk;
	end
	
	VGAControl control (slowClk, clear, hSync, vSync, bright, hCount, vCount);
	
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
		E	31.4us		810
		
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
module VGAControl (clock, clear, hSync, vSync, bright, hCount, vCount);
	
	input clock, clear;
	output reg hSync, vSync, bright = 0;
	output reg [9:0] hCount = 10'b0;
	output reg [9:0] vCount = 10'b0;
	
	//	hcount, vcount are used by BitGen to keep track of where you are on the screen
	// best if counts are the counts of the pixels on the screen
	// hcount = (0, 639), vcount = (0, 479)

	parameter HPULSE = 96;			// sync pulse length
	parameter HBACK = 48;			// back porch length
	parameter HVID = 640;			// pixel width 
	parameter HFRONT = 16;			// front port length
	parameter HMAX = 800;			// max length of horizontal pulse
	
	parameter VPULSE = 2;			// sync pulse
	parameter VBACK = 29;			// back porch
	parameter VVID = 480;			// pixel height
	parameter VFRONT = 10;			// front porch
	parameter VMAX = 521;			// max length for vertical pulse
	
	reg vc_en = 0;
	
	// hsync, vsync are asserted low - high rest of the time <- active low
	always@ (posedge clock)
	begin
	
//		if(clear)
//		begin
//			hCount <= 10'b0;
//			vCount <= 10'b0;
//		end
//		else
//		begin
//			hCount <= hCount;
//			vCount <= vCount;
//		end
	
		if(hCount == HMAX)
		begin
			hCount <= 10'b0;
			vc_en <= 1;
		end
		else
		begin
			hCount <= hCount + 1'b1;
			vc_en <= 0;
		end
	
		if(vc_en)
		begin
			if(vCount == VMAX)
				vCount <= 10'b0;
			else
				vCount <= vCount + 1'b1;
		end
		
		if(hCount < 96)
			hSync <= 0;
		else
			hSync <= 1;
			
		if(vCount < 2)
			vSync <= 0;
		else
			vSync <= 1;
			
		if((hCount > 144) && (hCount < 784) && (vCount > 31) && (vCount < 511))
			bright <= 1;
		else
			bright <= 0;
		
	end
endmodule

/*
	Is a combinational circuit
	Decides for each pixel what color should be on the screen
	
	Glyph graphics - break the screen into chunks
*/
module BitGen (bright, pixelData, hCount, vCount, rgb);
	
	input bright;
	input [7:0] pixelData;
	input [9:0] hCount, vCount;
	output reg [7:0] rgb;
	
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
		if (bright)
		begin
			if ((hCount >= 155) && (hCount <=235)) 
				rgb = BLACK; 
			else if ((hCount >= 236) && (hCount <= 315))
				rgb = BLUE;
			else if ((hCount >= 316) && (hCount <= 395))
				rgb = GREEN;
			else if ((hCount >= 396) && (hCount <= 475))
				rgb = CYAN;
			else if ((hCount >= 476) && (hCount <= 555))
				rgb = RED;
			else if ((hCount >= 556) && (hCount <= 635))
				rgb = MAGENTA;
			else if ((hCount >= 636) && (hCount <= 715))
				rgb = YELLOW;
			else if ((hCount >= 716) && (hCount <= 795))
				rgb = WHITE;
			else
				rgb = BLACK;
		end
		
		else
			rgb = 8'b00000000;
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

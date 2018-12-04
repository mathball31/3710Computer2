
/* Driver module of the VGA */
module VGA (clk, clear, glyph, hSync, vSync, bright, rgb, slowClk, addr_out);
	
	input clk, clear;
	input [15:0] glyph;
	output addr_out;
	output hSync, vSync;
	output [7:0] rgb;
	output bright;
	output reg slowClk = 0;

	wire [9:0] hCount;
	wire [9:0] vCount;
	
	reg [15:0] addr_in;
	
	VGAControl control (slowClk, clear, hSync, vSync, bright, hCount, vCount);
		
	always @ (posedge clk)
	begin
		slowClk <= ~slowClk;
		
		// if hcount/vcount reach a specific spot on the screen, get a glyph
		if (hCount == 200 && vCount == 207)
			addr_in = 16'b0000_0000_0000_0100;
	end

	AddrGen ag(clk, hCount, vCount, addr_in, addr_out);
	BitGen gen (bright, glyph, hCount, vCount, rgb);

endmodule


module AddrGen(clk, x, y, addr_in, addr_out);
	input clk;
	input [9:0] x, y;
	input [15:0] addr_in;
	output reg [15:0] addr_out;
	
	parameter DEFAULT = 16'b0000_0000_0000_0010;
	
	reg nextBit = 0;
	integer count = 0;
	
	always @(posedge clk)
	begin
		if (y >= 200 && y <= 207)
		begin
			if (x >= 200 && x <= 207)
			begin
				// only move to the next address when nextBit = 1;
				if (nextBit)
					addr_out <= addr_in + count;
				else
					addr_out <= addr_out;
			end
			else
				addr_out <= DEFAULT;
		end
		else
			addr_out <= DEFAULT;
		
		nextBit <= ~nextBit;
		count <= count + 1;
	end
endmodule


/*
	Is a combinational circuit
	Decides for each pixel what color should be on the screen
	
	Glyph graphics - break the screen into chunks
*/
module BitGen (bright, glyph, hCount, vCount, rgb);
	
	input bright;
	input [15:0] glyph;
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
			if ((hCount >= 200 && hCount <= 207) ||
				 (vCount >= 200 && vCount <= 207))
				rgb = glyph[15:8];
			else if ((hCount >= 208 && hCount <= 215) ||
						(vCount >= 200 && vCount <= 207))
				rgb = glyph[7:0];
			else if ((hCount >= 216 && hCount <= 223) ||
						(vCount >= 200 && vCount <= 207))
				rgb = CYAN;
			else
				rgb = BLACK;
		end
		else
			rgb = 8'b00000000;
	end
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
	
		if(!clear)
		begin
			hCount <= 10'b0;
			vCount <= 10'b0;
		end
		else
		begin
			hCount <= hCount;
			vCount <= vCount;
		end
	
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

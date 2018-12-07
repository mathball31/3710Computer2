
/* Driver module of the VGA */
module VGA #(parameter ADDR_WIDTH=16) (clk, reset, mem_out, hSync, vSync, bright, rgb, slowClk, addr_out);
	
	input clk, reset;
	input [15:0] mem_out;
	output [ADDR_WIDTH-1:0] addr_out;
	output hSync, vSync;
	output [7:0] rgb;
	output bright;
	output reg slowClk = 0;

	wire [9:0] hCount;
	wire [9:0] vCount;
	wire [7:0] glyph_num;
	wire [2:0] glyph_x, glyph_y;
	
	// reg [15:0] addr_in;
	
	always @ (posedge clk)
	begin
		slowClk <= ~slowClk;
	end

	VGAControl control (slowClk, reset, hSync, vSync, bright, hCount, vCount);
		
	AddrGen #(.ADDR_WIDTH(ADDR_WIDTH)) ag(slowClk, reset, mem_out, hCount, vCount, addr_out, glyph_num, glyph_x, glyph_y);
	
	BitGen gen (bright, glyph_num, glyph_x, glyph_y, rgb);

endmodule


module AddrGen #(parameter ADDR_WIDTH=16) (clk, reset, mem_out, h_count, v_count, addr_out, glyph_num, glyph_x, glyph_y);
	input clk, reset;
	input [15:0] mem_out;
	input [9:0] h_count, v_count;
	output reg [ADDR_WIDTH-1:0] addr_out;
	output reg [7:0] glyph_num;
	output reg [2:0] glyph_x, glyph_y;
	
	// (0,0) on our display
	parameter HSTART = 8'b10010000;
	parameter VSTART = 5'b11111;
	parameter HEND = 784;
	parameter VEND = 511;
	parameter DEFAULT = 16'b00_0000_0000_0010;
	
	parameter FRAME_BUFFER_START 	= 14'b11_0000_0000_0000;
	parameter SCREEN_WIDTH 			= 6'b101000;
	
	reg [4:0] state = 0;
	
	reg [9:0] x, y;
	
	always @(posedge clk)
	begin
		if (reset)
		begin
			state = 5'b0;
		end
		
		// in between the display of the screen
		if ((h_count >= HSTART && h_count < HEND) &&
			 (v_count >= VSTART && v_count < VEND))
		begin
			case (state)
				0:
				begin
					x = h_count - HSTART;
					y = v_count - VSTART + 1;
					glyph_x = x[2:0];
					glyph_y = y[2:0];

					// read in the address from the frame buffer 
					addr_out = FRAME_BUFFER_START + (SCREEN_WIDTH * y[9:3]) + x[9:4];
					
					state = 1;
				end
				1:
				begin
					if (x[3] == 1'b0)
					begin
						glyph_num = mem_out[15:8];
					end
					else
					begin
						glyph_num = mem_out[7:0];
					end
					state = 0;
				end
			endcase
		end	
	end
endmodule


/*
	Decides for each pixel what color should be on the screen
	
	Glyph graphics - break the screen into chunks
*/
module BitGen (bright, glyph_num, x, y, rgb);
	input bright;
	input [7:0] glyph_num;
	input [2:0] x, y;
	output reg [7:0] rgb;
	
	reg [7:0] glyph_table[2**12-1:0];
	
	initial
	begin
		// TODO This file path needs to change for your personal laptop 
		//$readmemh("C:/Users/dirkl/3710Computer2/GlyphTable.txt", glyph_table);

		//$readmemh("C:/Users/sator/Documents/CS3710/3710Computer2/GlyphTest.txt", ram);

		//$readmemh("C:/Users/Michelle/Documents/GitHub/3710Computer2/14.txt", ram);
		$readmemh("C:/Users/samfa/OneDrive/Documents/GitHub/3710Computer2/GlyphTable.txt", glyph_table);
		
	end
	
	parameter BLACK = 8'b000_000_00;

	// there are 640 pixels in a row, and 480 in a column
	always@(*) // paint
	begin
		if (bright)
		begin
			rgb = glyph_table[{glyph_num[5:0], y, x}];
		end
		else
		begin
			rgb = BLACK;
		end

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
	
		if(clear)
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

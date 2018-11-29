module VGATest;
	
	reg clk;
	reg clear;
	
	wire hSync, vSync;
	wire [7:0] rgb;
	
	VGA uut(.clk(clk), .clear(clear), .hSync(hSync), .vSync(vSync), .rgb(rgb));

	initial
	begin
		clk =0;
		clear = 1;
		#10
		clear = 0;
	end
	
	always
	begin
		#5 clk = ~clk;		
	end

endmodule

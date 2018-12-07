// Quartus Prime Verilog Template
// True Dual Port RAM with single clock

module Memory
#(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=12)
(clk, we_a, we_b, data_a, data_b, addr_a, addr_b, q_a, q_b);

	input [(DATA_WIDTH-1):0] data_a, data_b;
	input [(ADDR_WIDTH-1):0] addr_a, addr_b;
	input we_a, we_b, clk;
	output reg [(DATA_WIDTH-1):0] q_a, q_b;

	// Declare the RAM variable
	// (* ram_init_file = "C:/Users/dirkl/3710Computer2/snake.mif" *)reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
	(* ram_init_file = "C:/Users/samfa/OneDrive/Documents/3710Computer2/snake.mif" *)reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	
	//only use for simulation
	initial
	begin
		// TODO This file path needs to change for your personal laptop 
		//$readmemh("C:/Users/dirkl/3710Computer2/assembler/snake.mem", ram);
		// $readmemh("C:/Users/sator/Documents/CS3710/3710Computer2/GlyphTest.txt", ram);
		// $readmemh("C:/Users/Michelle/Documents/GitHub/3710Computer2/GlyphTest.txt", ram);
		$readmemh("C:/Users/samfa/OneDrive/Documents/GitHub/3710Computer2/GlyphTest.txt", ram);
	end

	// Port A 
	always @ (posedge clk)
	begin
		if (we_a) 
		begin
			ram[addr_a] <= data_a;
			q_a <= data_a;
		end
		else 
		begin
			q_a <= ram[addr_a];
		end 
	end 

	// Port B 
	always @ (posedge clk)
	begin
		if(we_b)
		begin
			ram[addr_b] <= data_b;
			q_b <= data_b;
		end
		else 
		begin
			q_b <= ram[addr_b];
		end 
	end

endmodule

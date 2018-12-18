`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   9/6/2018
// Design Name:   mem Test
// Module Name:   
// Project Name:  ECE3700Project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created for module: mem
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created`
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module memTest;
	parameter DATA_WIDTH = 16;
	parameter ADDR_WIDTH = 10;
	reg [(DATA_WIDTH-1):0] data_a, data_b;
	reg [(ADDR_WIDTH-1):0] addr_a, addr_b;
	reg we_a, we_b, clk;
	wire [(DATA_WIDTH-1):0] out_a, out_b;
	
	reg [3:0] state;
	reg [(DATA_WIDTH-1):0] expected_out_a, expected_out_b;
	
	event terminate_sim;
	event checkResult_a;
	event checkResult_b;
	reg error;
	
	// Instantiate the Unit Under Test (UUT)
	Memory uut (
		data_a, data_b, addr_a, addr_b, we_a, we_b, clk, out_a, out_b
	);
	
	//check results
	always @(checkResult_a) 
	begin
		if (out_a !== expected_out_a)
		begin
			$display ("ERROR at time: %d, state: %d", $time, state);
			$display ("addr_a: 0x%h, 0b%b", addr_a, addr_a);
			$display ("Expected value a: %d, %b; Actual Value a: %d, %b, data_a: %d, %b", expected_out_a, expected_out_a, out_a, out_a, data_a, data_a);
			error = 1;
			#5 -> terminate_sim;
		end
	end
	
	//check results
	always @(checkResult_b) 
	begin
		if (out_b !== expected_out_b)
		begin
			$display ("ERROR at time: %d, state: %d", $time, state);
			$display ("addr_b: 0x%h, 0b%b", addr_b, addr_b);
			$display ("Expected value b: %d, %b; Actual Value b: %d, %b, data_b: %d, %b", expected_out_b, expected_out_b, out_b, out_b, data_b, data_b);
			error = 1;
			#5 -> terminate_sim;
		end
	end
	
		
	initial @(terminate_sim) 
	begin
		$display("Terminating simulation");
		if (error == 0)
		begin
			$display("Simulation Result: PASSED");
		end
		else begin
			$display("Simulation Result: FAILED");
		end
		#1 $finish;
	end
	
	integer i;

	initial
	begin
		clk =1 ;
		data_a = 0;
		data_b = 0;
		addr_a = 0;
		addr_b = 0;
		we_a = 0;
		we_b = 0;
		state = 0;
		
		#20
		
		#100
		$finish;
	
	end

always @(*)
begin
#5 clk <= ~clk;
end
	
	always @(posedge clk)
	begin
		
		case (state)
			/*
			0:
			begin
				we = 1;
				data = 16'b1;
				addr = 10'b0;
			end
			1:
			begin
				we = 0;
				addr = 10'b0;
			end
			2:
			begin
				expected_out =  16'b1;
				#5-> checkResult;
			end
			*/
			1:
			begin
				we_a = 1;
				we_b = 1;
				addr_a = 10'h000;
				addr_b = 10'h001;
				data_a = 16'hfefe;
				data_b = 16'hefef;
			end
			2:
			begin
				we_a = 0;
				we_b = 0;
				addr_a = 10'h000;
				addr_b = 10'h001;
				expected_out_a = 16'hdead;
				expected_out_b = 16'hbeaf;
				//#5 -> checkResult_a;
				//#5 -> checkResult_b;
			end
			3:
			begin
				we_a = 1;
				we_b = 1;
				addr_a = 10'h002;
				addr_b = 10'h002;
				data_a = 16'hbeaf;
				data_b = 16'hdead;
			
			end
			4:
			begin
				we_a = 0;
				we_b = 0;
			end
		endcase
		
		state = state + 4'b0001;
	end
	
      
endmodule


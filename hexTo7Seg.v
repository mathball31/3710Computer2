module hexTo7Seg(
    input  [3:0]hex_input,
    output reg [6:0]seven_seg_out
    );
	 
always @*
	case (hex_input)
		4'b0000 :      	//Hexadecimal 0
			//seven_seg_out = 7'b0111111;
			seven_seg_out = 7'b1000000;
		4'b0001 :    	//Hexadecimal 1
			//seven_seg_out = 7'b0000110  ;
			seven_seg_out = 7'b1111001  ;
		4'b0010 :  		// Hexadecimal 2
			//seven_seg_out = 7'b1011011 ; 
			seven_seg_out = 7'b0100100 ; 
		4'b0011 : 		// Hexadecimal 3
			//seven_seg_out = 7'b1001111 ;
			seven_seg_out = 7'b0110000 ;
		4'b0100 :		// Hexadecimal 4
			//seven_seg_out = 7'b1100110 ;
			seven_seg_out = 7'b0011001 ;
		4'b0101 :		// Hexadecimal 5
			//seven_seg_out = 7'b1101101 ;  
			seven_seg_out = 7'b0010010 ;  
		4'b0110 :		// Hexadecimal 6
			//seven_seg_out = 7'b1111101 ;
			seven_seg_out = 7'b0000010 ;
		4'b0111 :		// Hexadecimal 7
			//seven_seg_out = 7'b0000111;
			seven_seg_out = 7'b1111000;
		4'b1000 :     		 //Hexadecimal 8
			//seven_seg_out = 7'b1111111;
			seven_seg_out = 7'b0000000;
		4'b1001 :    		//Hexadecimal 9
			//seven_seg_out = 7'b1101111 ;
			seven_seg_out = 7'b0010000 ;
		4'b1010 :  		// Hexadecimal A
			//seven_seg_out = 7'b1110111 ; 
			seven_seg_out = 7'b0001000 ; 
		4'b1011 : 		// Hexadecimal B
			//seven_seg_out = 7'b1111100;
			seven_seg_out = 7'b0000011;
		4'b1100 :		// Hexadecimal C
			//seven_seg_out = 7'b0111001 ;
			seven_seg_out = 7'b1000110 ;
		4'b1101 :		// Hexadecimal D
			//seven_seg_out = 7'b1011110 ;
			seven_seg_out = 7'b0100001 ;
		4'b1110 :		// Hexadecimal E
			//seven_seg_out = 7'b1111001 ;
			seven_seg_out = 7'b0000110 ;
		4'b1111 :		// Hexadecimal F
			//seven_seg_out = 7'b1110001 ;
			seven_seg_out = 7'b0001110 ;
	endcase
 
endmodule

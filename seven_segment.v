module seven_segment (
	input [3:0] i,
	output reg[6:0]o
	);

	// HEX out - rewire DE1
	//  ---0---
	// |       |
	// 5       1
	// |       |
	//  ---6---
	// |       |
	// 4       2
	// |       |
	//  ---3---

	always @(*)
	begin
		case (i)	    // abcdefg
				4'b0000: o = 7'b1000000;
				4'b0001: o = 7'b1111001;
				4'b0010: o = 7'b0100100;
				4'b0011: o = 7'b0110000;
				4'b0100: o = 7'b0011001;
				4'b0101: o = 7'b0010010;
				4'b0110: o = 7'b0000010;
				4'b0111: o = 7'b1111000;
				4'b1000: o = 7'b0000000;
				4'b1001: o = 7'b0011000;
				4'b1010: o = 7'b0001000;
				4'b1011: o = 7'b0000011;
				4'b1100: o = 7'b1000110;
				4'b1101: o = 7'b0100001;
				4'b1110: o = 7'b0000110;
				4'b1111: o = 7'b0001110;
				default: o = 7'b0000000;
		endcase
	end
endmodule
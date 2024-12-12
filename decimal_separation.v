module decimal_separation(
	input clk,
	input rst,
	input [5:0] right_side,
	input [9:0] left_side,
	output [6:0] seg_0,
	output [6:0] seg_1,
	output [6:0] seg_2,
	output [6:0] seg_3,
	output [6:0] seg_4,
	output [6:0] seg_5
	);
	
	reg [3:0] thousands_i;
	reg [3:0] hundreds_i;
	reg [3:0] tens_i;
	reg [3:0] ones_i;
	reg [3:0] tens_f;
	reg [3:0] hundreds_f;
	
	
	/* *****LEFT SIDE***** */
	always @(*) begin
		thousands_i = (left_side / 1000) % 10;
		hundreds_i = (left_side / 100) % 10;
		tens_i = (left_side / 10) % 10; 
		ones_i = left_side % 10;
	end
	
	/* *****RIGHT SIDE***** */
	
	reg [2:0] S;
	reg [2:0] NS;
	
	reg [16:0] sum;
	reg [15:0] current_val1;
	reg [15:0] current_val2;
	reg [15:0] current_val3;
	reg [15:0] current_val4;
	reg [15:0] current_val5;
	reg [15:0] current_val6;
	
	parameter	START = 3'd0,
					INIT = 3'd1,
					CALC = 3'd3,
					SUM = 3'd4;
					
	always @(posedge clk or negedge rst) begin
		if (rst == 1'b0)
			S <= START;
		else
			S <= NS;
	end
	
	always @(*) begin
		case(S)
			START:
				NS = INIT;
			INIT:
				NS = CALC;
			CALC:
				NS = SUM;
			SUM:
				NS = CALC;
		endcase
	end
	
	always @(posedge clk or negedge rst) begin
		if(rst == 1'b0) begin
			sum <= 17'd0;
			current_val1 <= 16'd0;
			current_val2 <= 16'd0;
			current_val3 <= 16'd0;
			current_val4 <= 16'd0;
			current_val5 <= 16'd0;
			current_val6 <= 16'd0;
		end
		else begin
			case(S)
				INIT: begin
					sum <= 16'd0;
					current_val1 <= 16'd0;
					current_val2 <= 16'd0;
					current_val3 <= 16'd0;
					current_val4 <= 16'd0;
					current_val5 <= 16'd0;
					current_val6 <= 16'd0;
				end
				CALC: begin
					if (right_side[0] == 1'b1)
						current_val1 <= 16'd1563;
					else
						current_val1 <= 16'd0;
						
					if (right_side[1] == 1'b1)
						current_val2 <= 16'd3125;
					else
						current_val2 <= 16'd0;
						
					if (right_side[2] == 1'b1)
						current_val3 <= 16'd6250;
					else
						current_val3 <= 16'd0;
						
					if (right_side[3] == 1'b1)
						current_val4 <= 16'd12500;
					else
						current_val4 <= 16'd0;
						
					if (right_side[4] == 1'b1)
						current_val5 <= 16'd25000;
					else
						current_val5 <= 16'd0;
						
					if (right_side[5] == 1'b1)
						current_val6 <= 16'd50000;
					else
						current_val6 <= 16'd0;
				end
				SUM:
					sum <= current_val1 + current_val2 + current_val3 + current_val4 + current_val5 + current_val6;
			endcase
		end
	end
	
	always@(*) begin
		tens_f = (sum / 10000) % 10;
		hundreds_f = (sum / 1000) % 10; 
	end
	
	seven_segment segment_5(thousands_i, seg_5);
	seven_segment segment_4(hundreds_i, seg_4);
	seven_segment segment_3(tens_i, seg_3);
	seven_segment segment_2(ones_i, seg_2);
	seven_segment segment_1(tens_f, seg_1);
	seven_segment segment_0(hundreds_f, seg_0);
endmodule
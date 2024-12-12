module final_project (
	input CLOCK_50,
	input [3:0] KEY,
	input [9:0] SW,
	output [9:0] LEDR,
	output [6:0] HEX0,
	output [6:0] HEX1,	
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4
	);
	// setting my clock
	wire clk;
	assign clk = CLOCK_50;
	//assign clk = ~KEY[1];
	
	// setting my start signal
	wire start;
	assign start = ~KEY[3];
	
	// setting my rst signal
	wire rst;
	assign rst = KEY[2];
	
	// assigning LEDs
	assign LEDR[9] = done;
	
	
	// dimension of matrix
	wire [3:0] n;
	assign n = 3'd3;
	wire [3:0] p;
	assign p = 3'd3;
	wire [3:0] m;
	assign m = 3'd3;
	
	// memory address input variables (formula: address = (row * #col) + col
	
	reg [4:0] address_A;
	reg [4:0] address_B;
	reg [4:0] address_C;
	reg [4:0] input_address_C;
	wire [4:0] user_input_address_C;
	assign user_input_address_C = SW[4:0];
	
	assign LEDR[4:0] = SW[4:0];
	
	always @(*) begin
		address_A = (i * 3) + k;
		address_B = (k * 3) + j;
		address_C = (i * 3) + j;
	end
	
	// memory read or write
	reg rw_A;
	reg rw_B;
	reg rw_C;
	
	// for loop incrementing variables
	reg [3:0] i;
	reg [3:0] j;
	reg [3:0] k;
	
	// current values from matrices
	wire [15:0] a_from_mem;
	wire [15:0] b_from_mem;
	wire [15:0] c_ij; 
	wire [9:0] left_side;
	assign left_side = c_ij[15:6];
	wire [5:0] right_side;
	assign right_side = c_ij[5:0];
	
	// done signal
	reg done;
	
	// data input to memory declaration
	reg [15:0] data_input_A;
	reg [15:0] data_input_B;
	reg [15:0] sum;
	
	wire [31:0] product;
	assign product = a_from_mem * b_from_mem;
	
	wire [15:0] shifted_product;
	assign shifted_product = product[22:6];
	
	// defining S and NS
	reg [5:0] S;
	reg [5:0] NS;
	
	// debugging variables
	wire [3:0] current_state;
	
	parameter 	START = 6'd0,
					INIT = 6'd1,
					FOR_COND_1 = 6'd2,
					FOR_COND_2 = 6'd3,
					SUM_RST = 6'd4,
					FOR_COND_3 = 6'd5,
					ACCESS_A = 6'd6,
					ACCESS_B = 6'd7,
					SET_SUM = 6'd8,
					COUNT_K = 6'd9,
					RST_K = 6'd10,
					LOAD_C = 6'd11,
					COUNT_J = 6'd12,
					RST_J = 6'd13,
					COUNT_I = 6'd14,
					WAIT_1 = 6'd15,
					WAIT_2 = 6'd16,
					WAIT_3 = 6'd17,
					WRITE_OFF = 6'd18,
					DONE = 6'd19,
					VIEW = 6'd20;
					
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
				if (start == 1'b1)
					NS = FOR_COND_1;
				else
					NS = INIT;
			FOR_COND_1:
				if (i < n)
					NS = FOR_COND_2;
				else
					NS = DONE;
			FOR_COND_2:
				if (j < p)
					NS = SUM_RST;
				else 
					NS = RST_J;
			SUM_RST:
				NS = FOR_COND_3;
			FOR_COND_3:
				if (k < m)
					NS = ACCESS_A;
				else
					NS = RST_K;
			ACCESS_A:
				NS = WAIT_1;
			WAIT_1:
				NS = ACCESS_B;
			ACCESS_B:
				NS = WAIT_2;
			WAIT_2:
				NS = SET_SUM;
			SET_SUM:
				NS = COUNT_K;
			COUNT_K:
				NS = FOR_COND_3;
			RST_K:
				NS = LOAD_C;
			LOAD_C:
				NS = WAIT_3;
			WAIT_3:
				NS = WRITE_OFF;
			WRITE_OFF:
				NS = COUNT_J;
			COUNT_J:
				NS = FOR_COND_2;
			RST_J:
				NS = COUNT_I;
			COUNT_I:
				NS = FOR_COND_1;
			DONE:
				NS = VIEW;
			VIEW:
				NS = VIEW;
		endcase
	end
	
	always @(posedge clk or negedge rst) begin
		if (rst == 1'b0) begin
			i <= 4'd0;
			j <= 4'd0;
			k <= 4'd0;
			sum <= 16'd0;
			done <= 1'd0;
			rw_A <= 1'b0;
			rw_B <= 1'b0;
			rw_C <= 1'b0;
			input_address_C <= user_input_address_C;
		end
		else begin
			case(S)
				INIT: 
				begin
					i <= 4'd0;
					j <= 4'd0;
					k <= 4'd0;
					sum <= 16'd0;
					done <= 1'd0;
					rw_A <= 1'b0;
					rw_B <= 1'b0;
					rw_C <= 1'b0;
					input_address_C <= user_input_address_C;
				end
				SUM_RST:
					sum <= 16'd0;
				ACCESS_A:
					rw_A <= 1'b0;
				ACCESS_B:
					rw_B <= 1'b0;
				SET_SUM:
					sum <= sum + shifted_product;
				COUNT_K:
					k <= k + 1'd1;
				RST_K:
					k <= 4'd0;
				LOAD_C: begin
					rw_C <= 1'b1;
					input_address_C <= address_C;
				end
				WAIT_3:
					rw_C <= 1'b1;
				WRITE_OFF:
					rw_C <= 1'b0;
				COUNT_J:
					j <= j + 1'd1;
				RST_J:
					j <= 4'd0;
				COUNT_I:
					i <= i + 1'd1;
				DONE:
					done <= 1'd1;
				VIEW:
					input_address_C <= user_input_address_C;
			endcase
		end
	end
	
	// instantiating matrix_A:
	matrix_A A_instance(
		address_A,
		clk,
		data_input_a, 
		rw_A,
		a_from_mem
	);
	
	matrix_B B_instance(
		address_B, 
		clk,
		data_input_B,
		rw_B,
		b_from_mem
	);
	
	matrix_C C_instance(
		input_address_C, 
		clk,
		sum,
		rw_C,
		c_ij 
	);
	
	decimal_separation separation(
		clk,
		rst,
		right_side,
		left_side,
		HEX0,
		HEX1,
		HEX2,
		HEX3,
		HEX4
	);
	
endmodule
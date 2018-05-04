`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:27:45 05/18/2017 
// Design Name: 
// Module Name:    mult64x59 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: mult32bit mul(clk, a_word, b_word, mul_out);
// Revision 0.01 - File Created
// Additional Comments : 
//
//////////////////////////////////////////////////////////////////////////////////
module mult64x64(clk, rst, a, b, c, done);
input clk, rst;
input [63:0] a;
input [63:0] b;

output [127:0] c;
output done;


wire [31:0] b0, b1, b_word;
wire [31:0] a0, a1, a_word;
wire [32+32-1:0] mul_out;
reg [127:0] R;
reg [1:0] R_extra;
wire [64:0] addin, addout;
reg a_sel, b_sel, addin_sel, r_shift_en, r_en;
reg r_shift_en_d, r_shift_en_d1, r_shift_en_d2;
reg r_en_d, r_en_d1;
reg addin_sel_d, addin_sel_d1, addin_sel_d2;


assign {b1, b0} = b;
assign {a1, a0} = a;

assign a_word = (a_sel) ? a1 : a0;
assign b_word = (b_sel) ? b1 : b0;

hybrid_mul32x32 mul(clk, a_word, b_word, mul_out);
assign addin = (addin_sel_d2) ? {32'd0,R[127:94]} : R[127:62];
assign addout = addin + mul_out;


always @(posedge clk)
begin
	r_en_d <= r_en; r_en_d1<=r_en_d; 
	r_shift_en_d <= r_shift_en; r_shift_en_d1<=r_shift_en_d; r_shift_en_d2<=r_shift_en_d1;
	addin_sel_d<=addin_sel; addin_sel_d1<=addin_sel_d; addin_sel_d2<=addin_sel_d1;
end

always @(posedge clk)
begin
	if(rst)
		R<=0;
	else if(r_shift_en_d1)
		R<={addout, R[93:32]};
	else if(r_en_d1)
		R<={addout, R[61:0]};
	else
		R<=R;
end

always @(posedge clk)
begin
	if(rst)
		R_extra<=0;
	else if(r_shift_en_d1)
		R_extra<=R[31:30];
	else
		R_extra<=R_extra;
end


reg [2:0] state, nextstate;

always @(posedge clk)
begin
	if(rst)
		state <= 3'd0;
	else
		state <= nextstate;
end
		
always @(state)
begin
	case(state)
	3'd0: begin // R <-- a0*b0
				a_sel<=0; b_sel<=0; addin_sel<=0; r_shift_en<=0; r_en<=0;
			end

	3'd1: begin // R <-- a0*b1 + (R>>32)
				a_sel<=0; b_sel<=1; addin_sel<=1; r_shift_en<=0; r_en<=1;
			end
	3'd2: begin // R <-- a1*b0 + R
				a_sel<=1; b_sel<=0; addin_sel<=0; r_shift_en<=1; r_en<=0;
			end

	3'd3: begin // R <-- a1*b1 + (R>>32)
				a_sel<=1; b_sel<=1; addin_sel<=1; r_shift_en<=0; r_en<=1;
			end			
	3'd4: begin // Write enable for R
				a_sel<=1; b_sel<=1; addin_sel<=1; r_shift_en<=1; r_en<=0;
			end
	3'd5: begin 
				a_sel<=0; b_sel<=0; addin_sel<=0; r_shift_en<=0; r_en<=0;
			end
	3'd6: begin 
				a_sel<=0; b_sel<=0; addin_sel<=0; r_shift_en<=0; r_en<=0;
			end			
	3'd7: begin // R <-- R
				a_sel<=0; b_sel<=0; addin_sel<=0; r_shift_en<=0; r_en<=0;
			end
	default: begin // R <-- R
				a_sel<=0; b_sel<=0; addin_sel<=0; r_shift_en<=0; r_en<=0;
			end			
	endcase
end


always @(state)
begin
	case(state)
	3'd0: nextstate <= 3'd1;
	3'd1: nextstate <= 3'd2;	
	3'd2: nextstate <= 3'd3;
	3'd3: nextstate <= 3'd4;
	3'd4: nextstate <= 3'd5;
	3'd5: nextstate <= 3'd6;
	3'd6: nextstate <= 3'd7;	
	3'd7: nextstate <= 3'd7;
	default: nextstate <= 3'd0;
	endcase
end	

assign c = {R[125:0],R_extra};
assign done = (state==3'd7) ? 1'b1 : 1'b0;

endmodule	

/////////////////////////////////////////////////////////////////////////////////////

module add_65_by_123(clk, rst, clear_R, mode, a, b, c, result_word_ready);
input clk, rst;
input mode;		// this is 1 when many additions are performed in a pipeline. otherwise this is 0.
input clear_R;
input [64:0] a;
input [122:0] b;

output [64:0] c;
output reg result_word_ready;

wire [58:0] a0, a1, a_word;
wire [63:0] b0, b1, b_word;
wire [64:0] add_out;
reg carry;
reg ab_sel, carry_en, R_en;

reg [64:0] R;
reg [5:0] a_top_delayed;

always @(posedge clk)
a_top_delayed <= a[64:59];

assign {a1,a0} = {53'd0,a_top_delayed,a[58:0]};
assign b0 = {5'd0,b[58:0]};
assign b1 = b[122:59];

assign a_word = (ab_sel) ? a1 : a0;
assign b_word = (ab_sel) ? b1 : b0;

assign add_out = a_word + b_word + carry;

always @(posedge clk)
begin
	if(clear_R)
		R <= 65'd0;
	else if(R_en)
		R <= add_out;
	else
		R <= R;
end		

always @(posedge clk)
begin
	if(rst)
		carry <= 1'b0;
	else if(carry_en)
		carry <= add_out[59];
	else
		carry <= 1'b0;
end

reg [1:0] state, nextstate;

always @(posedge clk)
begin
	if(rst)
		state <= 2'd0;
	else
		state <= nextstate;
end

always @(state)
begin
	case(state)
	2'd0: begin // Idle
				ab_sel<=0; carry_en<=0; R_en<=0;
			end

	2'd1: begin // R<--a0 + b0; carry<-carry(a0+b0);
				ab_sel<=0; carry_en<=1; R_en<=1;
			end	
	2'd2: begin // R<--a1 + b1 + carry; 
				ab_sel<=1; carry_en<=0; R_en<=1;
			end	


	2'd3: begin // Idle
				ab_sel<=0; carry_en<=0; R_en<=0;
			end
			
	default: begin // Idle
				ab_sel<=0; carry_en<=0; R_en<=0;
			end
	endcase
end	

always @(state or mode)
begin
	case(state)
	2'd0: nextstate <= 2'd1;
	2'd1: nextstate <= 2'd2;	
	2'd2: begin
				if(mode)
					nextstate <= 2'd1;
				else
					nextstate <= 2'd3;
			end		
	2'd3: nextstate <= 2'd3;	
	default: nextstate <= 2'd0;	
	endcase
end	

assign c = R;

always @(posedge clk)
begin
	if(rst)
		result_word_ready <= 1'b0;
	else
		result_word_ready <= R_en;
end

endmodule




/////////////////////////////////////////////////////////////////////////////////////

module hybrid_mul32x32(clk, a, b, c);
input clk;
input [31:0] a;
input [31:0] b;
output [63:0] c;

wire [23:0] a_24;
wire [7:0] a_8;
wire [16:0] b_17;
wire [14:0] b_15;

assign {a_8, a_24} = a;
assign {b_15, b_17} = b;

wire [40:0] m1_out, m2_out;
wire [24:0] m3_out;
wire [22:0] m4_out;


dsp_mult24x17 m1(clk, a_24, b_17, m1_out);
dsp_mult24x17 m2(clk, a_24, {2'b0,b_15}, m2_out);

LUT_mul_8_by_17 m3(clk, a_8, b_17, m3_out);
LUT_mul_8_by_15 m4(clk, a_8, b_15, m4_out);

assign c = m1_out + {m2_out,17'd0} + {m3_out,24'd0} + {m4_out,41'd0};

endmodule


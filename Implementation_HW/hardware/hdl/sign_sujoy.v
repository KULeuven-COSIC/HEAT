
`timescale 1ns / 1ps

// Most significant 4*18-bits of qs = 2490078900537976070997

`define q0 18'd173798
`define q1 18'd256931
`define q2 18'd142413
`define q3 18'd258151
`define q_by2_0 18'd202278
`define q_by2_1 18'd129075

// Create Date:    10:37:12 09/19/2017
// Design Name:a
// Module Name:    sign_calculation

module sign_calculation(clk, rst, quotient, asp_msw, sign, done);
input clk, rst;
input [35:0] quotient;
input [18*4-1:0] asp_msw; //asp[179:144] Not really the MSB because we know they subtract to 0
output sign;
output done;


wire [17:0] quotient_word, q_word;
wire [35:0] mult_out;
reg quotient_word_sel, acc_sel;
reg [1:0] q_word_sel;
reg en_acc, rst_acc;

reg [4:0] state, nextstate;
reg [36:0] acc;
wire [36:0] addition_result, acc_word;

assign quotient_word = (quotient_word_sel) ? quotient[35:18] : quotient[17:0];
assign q_word = (q_word_sel==2'd0) ? `q0 : (q_word_sel==2'd1) ? `q1 : (q_word_sel==2'd2) ? `q2 : `q3;

mul18_18 mult18_18_DP(quotient_word, q_word, mult_out);

assign acc_word = (acc_sel) ? {18'd0,acc[36:18]} : acc;
assign addition_result = mult_out + acc_word;

always @(posedge clk)
begin
	if(rst_acc)
		acc <= 37'd0;
	else if(en_acc)
		acc <= addition_result;
	else
		acc <= acc;
end


wire [17:0] asp_msw_word;
wire [18:0] subtraction_result;
reg [1:0] asp_msw_word_sel;
reg carry, rst_carry, en_subtraction;
reg [17:0] sub;

assign asp_msw_word = (asp_msw_word_sel==2'd0) ? asp_msw[17:00] :
                     (asp_msw_word_sel==2'd1) ? asp_msw[35:18] :
							(asp_msw_word_sel==2'd2) ? asp_msw[53:36] : asp_msw[71:54];

assign subtraction_result = asp_msw_word - acc[17:0] - carry;

always @(posedge clk)
begin
	if(rst_carry)
		carry <= 1'b0;
	else if(en_subtraction)
		carry <= subtraction_result[18];
	else
		carry <= carry;
end

always @(posedge clk)
begin
	if(en_subtraction)
		sub <= subtraction_result[17:0];
	else
		sub <= sub;
end



reg carry2, rst_carry2, en_carry2;
wire [18:0] subtraction_result2;
wire [17:0] q_by2_word;	// most significant two words of q/2
reg q_by2_word_sel;

assign q_by2_word = (q_by2_word_sel) ? `q_by2_1 : `q_by2_0;
assign subtraction_result2 = q_by2_word - sub - carry2;

always @(posedge clk)
begin
	if(rst_carry2)
		carry2 <= 1'b0;
	else if(en_carry2)
		carry2 <= subtraction_result2[18];
	else
		carry2 <= carry2;
end


always @(posedge clk)
begin
	if(rst)
		state <= 5'd0;
	else
		state <= nextstate;
end

always @(state)
begin
	case(state)
	5'd0: begin	// RST state
				quotient_word_sel	<=1'b0; 
				q_word_sel			<=2'd0; 
				rst_acc				<=1'b1; 
				en_acc				<=1'b0; 
				acc_sel				<=1'b0;
				asp_msw_word_sel	<=2'd0; 
				rst_carry			<=1'b1; 
				en_subtraction		<=1'b0;
				rst_carry2			<=1'b1; 
				en_carry2			<=1'b0; 
				q_by2_word_sel		<=1'b0;
			end

	5'd1: begin	// acc<--acc+quo[0]*q[0]
				quotient_word_sel	<=1'b0; 
				q_word_sel			<=2'd0; 
				rst_acc				<=1'b0; 
				en_acc				<=1'b1; 
				acc_sel				<=1'b0;
				asp_msw_word_sel	<=2'd0; 
				rst_carry			<=1'b0; 
				en_subtraction		<=1'b0;
				rst_carry2			<=1'b0; 
				en_carry2			<=1'b0; 
				q_by2_word_sel		<=1'b0;
			end

	5'd2: begin	// acc<--acc[36:18] + quo[0]*q[1]; sub<--asp[0] - acc[17:0];
				quotient_word_sel	<=1'b0; 
				q_word_sel			<=2'd1; 
				rst_acc				<=1'b0; 
				en_acc				<=1'b1; 
				acc_sel				<=1'b1;
				asp_msw_word_sel	<=2'd0; 
				rst_carry			<=1'b0; 
				en_subtraction		<=1'b1;
				rst_carry2			<=1'b0; 
				en_carry2			<=1'b0; 
				q_by2_word_sel		<=1'b0;
			end
			
	5'd3: begin	// acc<--acc + quo[1]*q[0]
				quotient_word_sel	<=1'b1; 
				q_word_sel			<=2'd0; 
				rst_acc				<=1'b0; 
				en_acc				<=1'b1; 
				acc_sel				<=1'b0;
				asp_msw_word_sel	<=2'd0; 
				rst_carry			<=1'b0; 
				en_subtraction		<=1'b0;
				rst_carry2			<=1'b0; 
				en_carry2			<=1'b0; 
				q_by2_word_sel		<=1'b0;
			end

	5'd4: begin	// acc<--acc[36:18] + quo[0]*q[2]; sub<--asp[1] - acc[17:0] - carry;
				quotient_word_sel	<=1'b0; 
				q_word_sel			<=2'd2; 
				rst_acc				<=1'b0; 
				en_acc				<=1'b1; 
				acc_sel				<=1'b1;
				asp_msw_word_sel	<=2'd1; 
				rst_carry			<=1'b0; 
				en_subtraction		<=1'b1;
				rst_carry2			<=1'b0; 
				en_carry2			<=1'b0; 
				q_by2_word_sel		<=1'b0;
			end
			
	5'd5: begin	// acc<--acc + quo[1]*q[1]
				quotient_word_sel	<=1'b1; 
				q_word_sel			<=2'd1; 
				rst_acc				<=1'b0; 
				en_acc				<=1'b1; 
				acc_sel				<=1'b0;
				asp_msw_word_sel	<=2'd0; 
				rst_carry			<=1'b0; 
				en_subtraction		<=1'b0;
				rst_carry2			<=1'b0; 
				en_carry2			<=1'b0; 
				q_by2_word_sel		<=1'b0;
			end

	5'd6: begin	// acc<--acc[36:18] + quo[0]*q[3]; sub<--asp[2] - acc[17:0] - carry;
				quotient_word_sel	<=1'b0; 
				q_word_sel			<=2'd3; 
				rst_acc				<=1'b0; 
				en_acc				<=1'b1; 
				acc_sel				<=1'b1;
				asp_msw_word_sel	<=2'd2; 
				rst_carry			<=1'b0; 
				en_subtraction		<=1'b1;
				rst_carry2			<=1'b1; 
				en_carry2			<=1'b0; 
				q_by2_word_sel		<=1'b0;
			end
			
	5'd7: begin	// acc<--acc + quo[1]*q[2]; sub2<--q_by2[0] - sub;
				quotient_word_sel	<=1'b1; 
				q_word_sel			<=2'd2; 
				rst_acc				<=1'b0; 
				en_acc				<=1'b1; 
				acc_sel				<=1'b0;
				asp_msw_word_sel	<=2'd0; 
				rst_carry			<=1'b0; 
				en_subtraction		<=1'b0;
				rst_carry2			<=1'b0; 
				en_carry2			<=1'b1; 
				q_by2_word_sel		<=1'b0;
			end
			
	5'd8: begin	// sub<--asp[3] - acc[17:0] - carry;
				quotient_word_sel	<=1'b1; 
				q_word_sel			<=2'd2; 
				rst_acc				<=1'b0; 
				en_acc				<=1'b0; 
				acc_sel				<=1'b0;
				asp_msw_word_sel	<=2'd3; 
				rst_carry			<=1'b0; 
				en_subtraction		<=1'b1;
				rst_carry2			<=1'b0; 
				en_carry2			<=1'b0; 
				q_by2_word_sel		<=1'b0;
			end
			
	5'd9: begin	// sub2<--q_by2[1] - sub - carry2;
				quotient_word_sel	<=1'b0; 
				q_word_sel			<=2'd2; 
				rst_acc				<=1'b0; 
				en_acc				<=1'b0; 
				acc_sel				<=1'b0;
				asp_msw_word_sel	<=2'd0;
				rst_carry			<=1'b0; 
				en_subtraction		<=1'b0;
				rst_carry2			<=1'b0; 
				en_carry2			<=1'b1; 
				q_by2_word_sel		<=1'b1;
			end

	5'd10: begin	// RST state
				quotient_word_sel	<=1'b0; 
				q_word_sel			<=2'd0; 
				rst_acc				<=1'b1; 
				en_acc				<=1'b0; 
				acc_sel				<=1'b0;
				asp_msw_word_sel	<=2'd0; 
				rst_carry			<=1'b0; 
				en_subtraction		<=1'b0;
				rst_carry2			<=1'b0; 
				en_carry2			<=1'b0; 
				q_by2_word_sel		<=1'b0;
			end
			
	default: begin
				quotient_word_sel	<=1'b0; 
				q_word_sel			<=2'd0; 
				rst_acc				<=1'b1; 
				en_acc				<=1'b0; 
				acc_sel				<=1'b0;
				asp_msw_word_sel	<=2'd0; 
				rst_carry			<=1'b1; 
				en_subtraction		<=1'b0;
				rst_carry2			<=1'b0; 
				en_carry2			<=1'b0; 
				q_by2_word_sel		<=1'b0;
			end
	endcase
end

always @(state)
begin
	case(state)
	5'd0: nextstate <= 5'd1;
	5'd1: nextstate <= 5'd2;
	5'd2: nextstate <= 5'd3;
	5'd3: nextstate <= 5'd4;
	5'd4: nextstate <= 5'd5;
	5'd5: nextstate <= 5'd6;
	5'd6: nextstate <= 5'd7;
	5'd7: nextstate <= 5'd8;
	5'd8: nextstate <= 5'd9;
	5'd9: nextstate <= 5'd10;
	5'd10: nextstate <= 5'd10;
	default: nextstate <= 5'd0;
	endcase
end

assign sign = carry2;
assign done = (state==5'd10) ? 1'b1 : 1'b0;

endmodule

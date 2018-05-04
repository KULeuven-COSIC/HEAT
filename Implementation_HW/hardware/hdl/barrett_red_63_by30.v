`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: a
// Engineer: 
// 
// Create Date:    14:40:24 05/08/2017 
// Design Name: 
// Module Name:    barrett_red_60by30 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module barrett_red_63_by30mod(	clk,
										sel_60_63,
										a, 
										prime, 
										barrett_const, 
										only_multiply,
										ina1, 
										inb1, 
										ina2, 
										inb2, 
										ina3, 
										inb3,
										out1_r, 
										out2_r, 
										out3_r,		
										b); 
input clk;
input sel_60_63;
input [62:0] a;
input [29:0] prime;
input [33:0] barrett_const;
input only_multiply;						// is 0 for computing modular reduction
input [29:0] ina1, ina2, ina3;
input [30:0] inb1, inb2, inb3;
output reg [59:0] out1_r, out2_r, out3_r;
output reg [29:0] b;	// reduced op

//wire [29:0] a1, a2;
//assign {a2, a1} = a;

wire [31:0] a_32L;
wire [30:0] a_31H;
assign {a_31H, a_32L} = a;


wire [65:0] ma1, ma2;
wire [97:0] ma; //32 + 66

reg [29:0] prime_d1, prime_d2, prime_d3, prime_d4, prime_d5, prime_d6, prime_d7, prime_d8; 

always @(posedge clk)
begin
	prime_d1 <= prime; 
	prime_d2 <= prime_d1; 
	prime_d3 <= prime_d2; 
	prime_d4 <= prime_d3; 
	prime_d5 <= prime_d4; 
	prime_d6 <= prime_d5; 
	prime_d7 <= prime_d6; 
	prime_d8 <= prime_d7;
end

wire [33:0] hm_ina1;
wire [31:0] hm_inb1;
wire [33:0] hm_ina2;
wire [31:0] hm_inb2;
wire [33:0] hm_ina3;
wire [31:0] hm_inb3;

assign {hm_ina1, hm_inb1} = (only_multiply) ? {4'b0,ina1,1'b0,inb1} : {barrett_const,a_32L};
assign {hm_ina2, hm_inb2} = (only_multiply) ? {4'b0,ina2,1'b0,inb2} : {barrett_const,1'b0,a_31H};


hibrid_mul_34x32 im1(clk, hm_ina1, hm_inb1, ma1);
hibrid_mul_34x32 im2(clk, hm_ina2, hm_inb2, ma2);

wire [59:0] out1, out2, out3;

assign out1 = ma1[59:0];
assign out2 = ma2[59:0];

assign ma = {ma2,32'b0} + ma1;

wire [36:0] quotient_wire;
reg [36:0] quotient;

assign quotient_wire = ma[96:60];

always @(posedge clk)
	quotient <= quotient_wire;
	
wire [33:0] quotient_final;
assign quotient_final = (sel_60_63 == 0) ? {3'b0,quotient[30:0]} : {quotient[36:3]};

wire [65:0] quotient_times_n_wire;
reg [63:0] quotient_times_n;

assign {hm_ina3, hm_inb3} = (only_multiply) ? {4'b0,ina3,1'b0,inb3} : {quotient_final,2'b0,prime_d4};

hibrid_mul_34x32 im3(clk, hm_ina3, hm_inb3, quotient_times_n_wire);

assign out3 = quotient_times_n_wire[59:0];

always @(posedge clk)
quotient_times_n <= quotient_times_n_wire[63:0];

wire [29:0] b_wire;

reg [62:0] ar1, ar2, ar3, ar4, ar5, ar6, ar7, ar8;

always @(posedge clk)
begin
	ar1<=a; 
	ar2<=ar1; 
	ar3<=ar2; 
	ar4<=ar3;
	ar5<=ar4; 
	ar6<=ar5; 
	ar7<=ar6; 
	ar8<=ar7;	
end	

wire [63:0] r1, r2;

assign r1 = ar8 - quotient_times_n[62:0];
assign r2 = r1 - prime_d8; 

wire res_selector;

assign res_selector = (sel_60_63 == 0) ? r2[60] : r2[63];

assign b_wire = (res_selector == 1) ? r1[29:0] : r2[29:0];

always @(posedge clk)
begin
	b <= b_wire;
	out1_r <= out1;
	out2_r <= out2;
	out3_r <= out3;
end 

endmodule

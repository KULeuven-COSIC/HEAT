`timescale 1ns / 1ps
//.
module modulo_reduction_master(clk, a, prime, barrett_const, 
										 b); 
input clk;
input [59:0] a;
input [29:0] prime;
input [30:0] barrett_const;

output reg [29:0] b;

wire [29:0] a1, a2;
assign {a2, a1} = a;

wire [61:0] ma1, ma2;
wire [90:0] ma;

reg [29:0] prime_d1, prime_d2, prime_d3, prime_d4, prime_d5; 

wire [30:0] barrett_const_ut = barrett_const;
wire [30:0] a1_ROM_CRT_outL = {1'b0,a1};
wire [30:0] a2_ROM_CRT_outH = {1'b0,a2};

always @(posedge clk)
begin
	prime_d1 <= prime; prime_d2 <= prime_d1; prime_d3 <= prime_d2; prime_d4 <= prime_d3; prime_d5 <= prime_d4;
end

hibrid_mul31 im1(clk, barrett_const_ut, a1_ROM_CRT_outL, ma1);
hibrid_mul31 im2(clk, barrett_const_ut, a2_ROM_CRT_outH, ma2);

reg [61:0] ma1_reg, ma2_reg;

always @(posedge clk)
begin
	ma1_reg <= ma1;
	ma2_reg <= ma2;
end

assign ma = {ma2_reg,30'b0} + ma1_reg;
//assign ma = {ma2,30'b0} + ma1;

wire [30:0] quotient_wire;
reg [30:0] quotient;

assign quotient_wire = ma[90:60];

always @(posedge clk)
quotient <= quotient_wire;


wire [60:0] quotient_times_n_wire;
reg [60:0] quotient_times_n;

hibrid_mul31	im3(clk, quotient, {1'b0,prime}, quotient_times_n_wire);

always @(posedge clk)
quotient_times_n <= quotient_times_n_wire;

wire [29:0] b_wire;

reg [59:0] ar1, ar2, ar3, ar4, ar5, ar6, ar7, ar8, ar9;

always @(posedge clk)
begin
	ar1<=a; ar2<=ar1; ar3<=ar2; ar4<=ar3;
	ar5<=ar4; ar6<=ar5; ar7<=ar6; ar8<=ar7; ar9<=ar8;	
end	

wire [60:0] r1, r2;
reg [60:0] r1_reg;

assign r1 = ar9 - quotient_times_n[59:0];

always @(posedge clk)
r1_reg <= r1;

//assign r2 = r1 - prime_d4; 
//assign b_wire = (r2[60]==1'b1) ? r1[29:0] : r2[29:0];

assign r2 = r1_reg - prime_d5; 
assign b_wire = (r2[60]==1'b1) ? r1_reg[29:0] : r2[29:0];

always @(posedge clk)
	b <= b_wire;
	
endmodule

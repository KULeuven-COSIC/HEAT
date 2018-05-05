`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
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

module barrett_red_60by30(clk, a, prime, barrett_const, 
								 only_multiply,
								 ina1, inb1, ina2, inb2, ina3, inb3, ina4, inb4,
								 out1, out2, out3, out4,		
								 b); 
input clk;
input [59:0] a;
input [29:0] prime;
input [30:0] barrett_const;
input only_multiply;
input [29:0] ina1, ina2, ina3, ina4;
input [30:0] inb1, inb2, inb3, inb4;
output [59:0] out1, out2, out3, out4;

output reg [29:0] b;

wire [29:0] a1, a2;
assign {a2, a1} = a;

wire [61:0] ma1, ma2;
wire [90:0] ma;

reg [29:0] prime_d1, prime_d2, prime_d3, prime_d4; 

always @(posedge clk)
begin
	prime_d1 <= prime; prime_d2 <= prime_d1; prime_d3 <= prime_d2; prime_d4 <= prime_d3;
end

wire [30:0] hm_ina1, hm_inb1;
wire [30:0] hm_ina2, hm_inb2;
wire [30:0] hm_ina3, hm_inb3;

assign {hm_ina1, hm_inb1} = (only_multiply) ? {1'b0,ina1,inb1} : {barrett_const,1'b0,a1};
assign {hm_ina2, hm_inb2} = (only_multiply) ? {1'b0,ina2,inb2} : {barrett_const,1'b0,a2};


hibrid_mul31 im1(clk, hm_ina1, hm_inb1, ma1);
hibrid_mul31 im2(clk, hm_ina2, hm_inb2, ma2);
hibrid_mul31 im4(clk, {1'b0,ina4}, inb4, out4);

assign out1 = ma1[59:0];
assign out2 = ma2[59:0];


assign ma = {ma2,30'b0} + ma1;

wire [30:0] quotient_wire;
reg [30:0] quotient;

assign quotient_wire = ma[90:60];

always @(posedge clk)
quotient <= quotient_wire;


wire [60:0] quotient_times_n_wire;
reg [60:0] quotient_times_n;

assign {hm_ina3, hm_inb3} = (only_multiply) ? {1'b0,ina3,inb3} : {quotient,1'b0,prime};

hibrid_mul31	im3(clk, hm_ina3, hm_inb3, quotient_times_n_wire);

assign out3 = quotient_times_n_wire[59:0];

always @(posedge clk)
quotient_times_n <= quotient_times_n_wire;

wire [29:0] b_wire;

reg [59:0] ar1, ar2, ar3, ar4, ar5, ar6, ar7, ar8;

always @(posedge clk)
begin
	ar1<=a; ar2<=ar1; ar3<=ar2; ar4<=ar3;
	ar5<=ar4; ar6<=ar5; ar7<=ar6; ar8<=ar7;	
end	

wire [60:0] r1, r2;

assign r1 = ar8 - quotient_times_n[59:0];
assign r2 = r1 - prime_d4; 

assign b_wire = (r2[60]==1'b1) ? r1[29:0] : r2[29:0];

always @(posedge clk)
	b <= b_wire;
	
endmodule

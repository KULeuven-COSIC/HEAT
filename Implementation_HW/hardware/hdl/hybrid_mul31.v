`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:51:09 02/19/2015 
// Design Name: 
// Module Name:    hybrid_mul31 
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
module hibrid_mul31(clk, a, b, c);
input clk;
input [30:0] a, b;
output [61:0] c;

wire [23:0] a_24;
wire [6:0] a_7;
wire [16:0] b_17;
wire [13:0] b_14;

assign {a_7, a_24} = a;
assign {b_14, b_17} = b;

wire [40:0] m1_out, m2_out;
wire [23:0] m3_out;
wire [20:0] m4_out;


dsp_mult24x17 m1(clk, a_24, b_17, m1_out);
dsp_mult24x17 m2(clk, a_24, {3'b0,b_14}, m2_out);

LUT_mul_7_by_17 m3(clk, a_7, b_17, m3_out);
LUT_mul_7_by_14 m4(clk, a_7, b_14, m4_out);

assign c = m1_out + {m2_out,17'd0} + {m3_out,24'd0} + {m4_out,41'd0};

endmodule

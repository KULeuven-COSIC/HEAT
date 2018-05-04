`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: a
// Engineer: 
// 
// Create Date:    16:20:09 09/16/2017 
// Design Name: 
// Module Name:    hibrid_mul_34x32 
//////////////////////////////////////////////////////////////////////////////////

module hibrid_mul_34x32(
	 input clk,
    input [33:0] in34,
    input [31:0] in32,
    inout [65:0] out66
    );
	 
wire [23:0] a_24L;
wire [9:0]  a_10H;
wire [16:0] b_17L;
wire [14:0] b_15H;

assign {a_10H, a_24L} = in34;
assign {b_15H, b_17L} = in32;

wire [40:0] m1_out, m2_out;
wire [26:0] m3_out;
wire [24:0] m4_out;

dsp_mult_new m1(clk, a_24L, b_17L, m1_out);
dsp_mult_new m2(clk, a_24L, {2'b0,b_15H}, m2_out);

LUT_MULT_10_BY_17_NEW m3(clk, a_10H, b_17L, m3_out);
LUT_MULT_10_BY_15_NEW m4(clk, a_10H, b_15H, m4_out);

assign out66 = m1_out + {m2_out,17'd0} + {m3_out,24'd0} + {m4_out,41'd0};

endmodule

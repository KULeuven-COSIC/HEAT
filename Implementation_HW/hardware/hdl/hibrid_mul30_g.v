`timescale 1ns / 1ps
//.
module hibrid_mul30_g(clk, a, b, c);
input clk;
input [29:0] a, b;
output [59:0] c;

wire [23:0] a_24;
wire [5:0] a_6;
wire [16:0] b_17;
wire [12:0] b_13;

assign {a_6, a_24} = a;
assign {b_13, b_17} = b;

wire [40:0] m1_out, m2_out;
wire [22:0] m3_out;
wire [18:0] m4_out;


dsp_mult_new m1(clk, a_24, b_17, m1_out);
dsp_mult_new m2(clk, a_24, {4'b0,b_13}, m2_out);

LUT_mul_6_by_17 m3(clk, a_6, b_17, m3_out);
LUT_mul_6_by_13 m4(clk, a_6, b_13, m4_out);

assign c = m1_out + {m2_out,17'd0} + {m3_out,24'd0} + {m4_out,41'd0};

endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:13:56 02/19/2015 
// Design Name: 
// Module Name:    hibrid_mul30 
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
module hibrid_mul30(clk, a, b, c);
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


dsp_mult24x17 m1(clk, a_24, b_17, m1_out);
dsp_mult24x17 m2(clk, a_24, {4'b0,b_13}, m2_out);

LUT_mul_6_by_17 m3(clk, a_6, b_17, m3_out);
LUT_mul_6_by_13 m4(clk, a_6, b_13, m4_out);

assign c = m1_out + {m2_out,17'd0} + {m3_out,24'd0} + {m4_out,41'd0};

endmodule

/*
module hibrid_mul30_4stg_pipeline(clk, a, b, c);
input clk;
input [29:0] a, b;
output reg [59:0] c;

wire [23:0] a_24;
wire [5:0] a_6;
wire [16:0] b_17;
wire [12:0] b_13;

assign {a_6, a_24} = a;
assign {b_13, b_17} = b;

wire [40:0] m1_out, m2_out;
wire [22:0] m3_out;
wire [18:0] m4_out;


dsp_mult24x17 m1(clk, a_24, b_17, m1_out);
dsp_mult24x17 m2(clk, a_24, {4'b0,b_13}, m2_out);

LUT_mul_6_by_17 m3(clk, a_6, b_17, m3_out);
LUT_mul_6_by_13 m4(clk, a_6, b_13, m4_out);


wire [59:0] c_wire = m1_out + {m2_out,17'd0} + {m3_out,24'd0} + {m4_out,41'd0};

always @(posedge clk)
c <= c_wire;

endmodule
*/
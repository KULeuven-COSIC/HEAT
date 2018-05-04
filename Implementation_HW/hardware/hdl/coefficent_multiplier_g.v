`timescale 1ns / 1ps
// 
module coefficient_multiplier_g(clk, a, b, c);
input clk;
input [29:0] a, b;
output reg [59:0] c;

wire [59:0] p;

hibrid_mul30_g coeff_mul(clk, a, b, p);

always @(posedge clk)
c <= p;

endmodule
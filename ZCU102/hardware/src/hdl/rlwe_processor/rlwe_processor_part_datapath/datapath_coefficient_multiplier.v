`timescale 1ns / 1ps

module coefficient_multiplier30bit #(parameter modular_index=6) (clk, modulus_sel, a, b, c);
input clk;
input modulus_sel;
input [29:0] a, b;
output [29:0] c;

wire [59:0] p;
reg [59:0] p_reg;


// 4 stage pipelined DSP mult: 4 DSP18 are used. 
dsp_mult mult(
	.clk(clk),
	.a(a[29:0]), // Bus [29 : 0] 
	.b(b[29:0]), // Bus [29 : 0] 
	.p(p)); // Bus [59 : 0] 

always @(posedge clk)
p_reg <= p;

windowed_reduction60bit #(modular_index) WR(clk, modulus_sel, p_reg, c);

endmodule
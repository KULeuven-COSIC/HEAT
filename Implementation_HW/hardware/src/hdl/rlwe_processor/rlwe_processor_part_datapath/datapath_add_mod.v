`timescale 1ns / 1ps

module add_mod30bit #(parameter modular_index=6) (clk, modulus_sel, a, b, c);
input clk;
input modulus_sel;
input [29:0] a, b;
output [29:0] c;


wire [30:0] w1_wire;
reg [30:0] w1;
wire [31:0] w2_S, w2_L, w2;
assign w1_wire = a + b;

always @(posedge clk)
w1 <= w1_wire;


//1068564481, 1069219841, 1070727169, 1071513601, 1072496641, 1073479681
generate
   if (modular_index==3'd0)
			assign w2_S = w1 - 30'd1068564481;
	else if (modular_index==3'd1)	
			assign w2_S = w1 - 30'd1069219841;
	else if (modular_index==3'd2)	
			assign w2_S = w1 - 30'd1070727169;
	else if (modular_index==3'd3)	
			assign w2_S = w1 - 30'd1071513601;
	else if (modular_index==3'd4)	
			assign w2_S = w1 - 30'd1072496641;
	else if (modular_index==3'd5)	
			assign w2_S = w1 - 30'd1073479681;
	else
			assign w2_S = w1 - 30'd1063321601;			
endgenerate

//1068433409, 1068236801, 1065811969, 1065484289, 1064697857, 1063452673
generate
   if (modular_index==3'd0)
			assign w2_L = w1 - 30'd1068433409;
	else if (modular_index==3'd1)	
			assign w2_L = w1 - 30'd1068236801;
	else if (modular_index==3'd2)	
			assign w2_L = w1 - 30'd1065811969;
	else if (modular_index==3'd3)	
			assign w2_L = w1 - 30'd1065484289;
	else if (modular_index==3'd4)	
			assign w2_L = w1 - 30'd1064697857;
	else if (modular_index==3'd5)	
			assign w2_L = w1 - 30'd1063452673;
	else
			assign w2_L = w1 - 30'd1063321601;			
endgenerate

assign w2 = (modulus_sel) ? w2_L : w2_S;
assign c = (w2[31]) ? w1[29:0] : w2[29:0];

endmodule

`timescale 1ns / 1ps
//`define p 18'd147457

/*================================================================================
This HDL-source code of the Ring-LWE Encryption Scheme is released under the 
MPL 1.1/GPL 2.0/LGPL 2.1 triple license.

------------------------------------------------------------------------------
Copyright (c) 2014, KU Leuven. All rights reserved.

The initial developer of this source code is Sujoy Sinha Roy, KU Leuven.
Contact Sujoy.SinhaRoy@esat.kuleuven.be for comments & questions.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright 
     notice, this list of conditions and the following disclaimer in 
     the documentation and/or other materials provided with the distribution.

  3. The names of the authors may not be used to endorse or promote products
     derived from this HDL-source code without specific prior written permission.

THIS HDL-SOURCE CODE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED 
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL KU LEUVEN OR 
ANY CONTRIBUTORS TO THIS HDL-SOURCE CODE BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT 
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

================================================================================*/

/*
module  sub_mod #(parameter modular_index=5) (clk, a, b, c);
input clk;
input [17:0] a, b;

output [17:0] c;

wire [18:0] w1;
wire [17:0] w2;
reg [18:0] w1_reg;

assign w1 = a - b;

always @(posedge clk)
w1_reg <= w1;

//assign w2 = w1_reg[17:0] + `p;

generate
   if (modular_index==3'd0)
			assign w2 = w1_reg[17:0] + 18'd147457;
	else if (modular_index==3'd1)	
			assign w2 = w1_reg[17:0] + 18'd249857;
	else if (modular_index==3'd2)	
			assign w2 = w1_reg[17:0] + 18'd163841;
	else if (modular_index==3'd3)	
			assign w2 = w1_reg[17:0] + 18'd176129;
	else if (modular_index==3'd4)	
			assign w2 = w1_reg[17:0] + 18'd184321;
	else
			assign w2 = w1_reg[17:0] + 18'd188417;
endgenerate

assign c = (w1_reg[18]) ? w2[17:0] : w1_reg[17:0];

endmodule
*/


module  sub_mod30bit #(parameter modular_index=6) (clk, modulus_sel, a, b, c);
input clk;
input modulus_sel;
input [29:0] a, b;

output [29:0] c;

wire [30:0] w1;
wire [29:0] w2_S, w2_L, w2;
reg [30:0] w1_reg;

assign w1 = a - b;

always @(posedge clk)
w1_reg <= w1;

//1068564481, 1069219841, 1070727169, 1071513601, 1072496641, 1073479681
generate
   if (modular_index==3'd0)
			assign w2_S = w1_reg[29:0] + 30'd1068564481;
	else if (modular_index==3'd1)	
			assign w2_S = w1_reg[29:0] + 30'd1069219841;
	else if (modular_index==3'd2)	
			assign w2_S = w1_reg[29:0] + 30'd1070727169;
	else if (modular_index==3'd3)	
			assign w2_S = w1_reg[29:0] + 30'd1071513601;
	else if (modular_index==3'd4)	
			assign w2_S = w1_reg[29:0] + 30'd1072496641;
	else if (modular_index==3'd5)
			assign w2_S = w1_reg[29:0] + 30'd1073479681;
	else
			assign w2_S = w1_reg[29:0] + 30'd1063321601;			
endgenerate

//1068433409, 1068236801, 1065811969, 1065484289, 1064697857, 1063452673
generate
   if (modular_index==3'd0)
			assign w2_L = w1_reg[29:0] + 30'd1068433409;
	else if (modular_index==3'd1)	
			assign w2_L = w1_reg[29:0] + 30'd1068236801;
	else if (modular_index==3'd2)	
			assign w2_L = w1_reg[29:0] + 30'd1065811969;
	else if (modular_index==3'd3)	
			assign w2_L = w1_reg[29:0] + 30'd1065484289;
	else if (modular_index==3'd4)	
			assign w2_L = w1_reg[29:0] + 30'd1064697857;
	else if (modular_index==3'd5)	
			assign w2_L = w1_reg[29:0] + 30'd1063452673;
	else
			assign w2_L = w1_reg[29:0] + 30'd1063321601;			
endgenerate

assign w2 = (modulus_sel) ? w2_L : w2_S;
assign c = (w1_reg[30]) ? w2[29:0] : w1_reg[29:0];

endmodule

/*
module sub_mod_mproc(clk, a, b, prime, c);
input clk;
input [29:0] a, b;
input [29:0] prime;

output [29:0] c;

wire [30:0] w1;
wire [29:0] w2;
reg [30:0] w1_reg;

assign w1 = a - b;

always @(posedge clk)
w1_reg <= w1;

assign w2 = w1_reg[29:0] + prime;

assign c = (w1_reg[30]) ? w2[29:0] : w1_reg[29:0];

endmodule
*/

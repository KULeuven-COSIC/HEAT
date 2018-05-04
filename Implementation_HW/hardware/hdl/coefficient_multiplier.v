`timescale 1ns / 1ps

/*================================================================================
This H DL-source code of the Ring-LWE Encryption Scheme is released under the 
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
module coefficient_multiplier #(parameter modular_index=5) (clk, a, b, c, d);
input clk;
input [17:0] a, b;
output [17:0] c;
output [35:0] d;

//output [25:0] p;


wire [35:0] p;
reg [35:0] p_reg;

dsp_mult mult(
	.clk(clk),
	.a(a), // Bus [17 : 0] 
	.b(b), // Bus [17 : 0] 
	.p(p)); // Bus [35 : 0] 

always @(posedge clk)
p_reg <= p;

assign d = p_reg;
//mod7681	M(clk, p_reg, c);

windowed_reduction #(modular_index) WR(clk, p_reg, c);

//windowed_reduction_q147457 WR(clk, p_reg, c);

//verilog_modulus vmod(clk, p_reg, c);

endmodule
*/


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
//mod_red_q #(modular_index)WR(clk, modulus_sel, p_reg, c);

/*
hibrid_mul30_4stg_pipeline	hmul(clk, a, b, p);
always @(posedge clk)
p_reg <= p;

mod_red_q #(modular_index)WR(clk, modulus_sel, p_reg, c);
*/

endmodule


module coefficient_multiplier_mproc(clk, a, b, c);
input clk;
input [29:0] a, b;
output reg [59:0] c;

wire [59:0] p;

hibrid_mul30 coeff_mul(clk, a, b, p);

always @(posedge clk)
c <= p;

endmodule

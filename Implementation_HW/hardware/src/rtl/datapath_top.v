`timescale 1ns / 1ps

/*================================================================================
This HDL-source code of the Ring-LWE Encryption Scheme is released under the 
MPL 1.1/GPL 2.0/LGPL 2.1 triple license.

------------------------------------------------------------------------------
C opyright (c) 2014, KU Leuven. All rights reserved.

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

module datapath_top #(parameter modular_index=6, parameter core_index=1'b1)
		(clk, modulus_sel, mode, m, w_NTT_ROM, primout_mask,
		 dout_high, dout_low, 
		 load_sel1, load_en1, load_en2, in1, in2, Gsample, message_bit,
		 prim_counter, c4, c5,
		 sel1, sel2, sel3, sel7, sel9, sel10, wtsel2, wtsel3, mz_sel, addin_sel, wtsel_10,
		 wq_en, rst_ac, crt_rom_address,
		
		 din_high, din_low, crt_sum_for_accumulation
		 );


input clk;
input modulus_sel;	// [q0..q5] or [q6..q12]
input [1:0] mode;
input [12:0] m;
input [29:0] w_NTT_ROM;
input primout_mask;
input [29:0] dout_high, dout_low;
input [1:0] load_sel1;
input load_en1, load_en2;
input [29:0] in1, in2, Gsample;
input message_bit;

input [3:0] prim_counter;
input wire [2:0] c4;
input wire [1:0] c5;

input sel3, sel7, sel10, mz_sel, wq_en;
input rst_ac;	// This is used to set wtqsel2=0, wtqsel3=0 during coefficient add/ mult operation
input [1:0] sel2, sel9, wtsel2, wtsel3, addin_sel;
input [2:0] sel1;
input wtsel_10;
input [2:0] crt_rom_address;

output [29:0] din_high, din_low, crt_sum_for_accumulation;


//////////////////////////////////////////////////////////////

reg [3:0] prim_counter_r;
reg [1:0] c5_r;
reg [2:0] c4_r;

reg sel3_r, sel7_r, sel10_r, mz_sel_r, wq_en_r, wq_disable_r, rst_ac_r;
reg [1:0] sel2_r, sel9_r, wtsel2_r, wtsel3_r, addin_sel_r;
reg [2:0] sel1_r; 
reg [2:0] crt_rom_address_r;

always @(posedge clk)
begin
prim_counter_r <= prim_counter; 
crt_rom_address_r <= crt_rom_address;
c4_r <= c4; 
c5_r <= c5;
{sel7_r, sel9_r, sel10_r, mz_sel_r, wq_en_r, rst_ac_r} <= {sel7, sel9, sel10, mz_sel, wq_en, rst_ac};
{sel1_r, sel2_r, sel3_r, wtsel2_r, wtsel3_r, addin_sel_r} <= {sel1, sel2, sel3, wtsel2, wtsel3, addin_sel};
end
//////////////////////////////////////////////////////////////

////////////// DATA Loading Computation //////////////////////
wire [29:0] m1_out, m2_out;
reg [1:0] message_qeue;
wire [29:0] encoded_bit;
reg [29:0] load1, load2;

always @(posedge clk)
	message_qeue <= {message_qeue[0], message_bit};
	
message_encoder encoder(message_qeue[1], encoded_bit);
mux3_30bits m1(in1, encoded_bit, Gsample, load_sel1, m1_out);
mux3_30bits m2(in2, encoded_bit, Gsample, load_sel1, m2_out);

always @(posedge clk)
begin
	if(load_en1) load1 <= m1_out; else load1 <= load1; 
	if(load_en2) load2 <= m2_out; else load2 <= load2;
end


//////////////////////////////////////////////////////////////


datapath	#(modular_index, core_index) DP(clk, modulus_sel, mode, m, w_NTT_ROM, primout_mask,
		dout_high, dout_low, load1, load2,
		prim_counter_r, c4_r, c5_r,
		sel1_r, sel2_r, sel3_r, sel7_r, sel9_r, sel10_r, wtsel2_r, wtsel3_r, mz_sel_r, addin_sel_r, wtsel_10,
		wq_en_r, rst_ac_r, crt_rom_address_r,
		
		din_high, din_low, crt_sum_for_accumulation);
		
endmodule

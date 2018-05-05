`timescale 1ns / 1ps
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
module RLWE_processor_total #(parameter core_index=1'b1)
				   (
					clk, modulus_sel, rst_ld, rst_ac, rst_nc, rst_crt,
					INSTRUCTION_ld, INSTRUCTION_nc, NTT_ITERATION, add_conv,
					
					rdMsel, wtMsel,
					
					ram_write_en_r_p0, write_address_p0, read_address_p0,
					ram_write_en_r_p1, write_address_p1, read_address_p1,
					ram_write_en_r_p2, write_address_p2, read_address_p2,
					ram_write_en_r_p3, write_address_p3, read_address_p3,
					ram_write_en_r_p4, write_address_p4, read_address_p4,
					ram_write_en_r_p5, write_address_p5, read_address_p5,
					ram_write_en_r_p6, write_address_p6, read_address_p6,					

					din_high_p0_message, din_low_p0_message, doutb_p0,
					din_high_p1_message, din_low_p1_message, doutb_p1,
					din_high_p2_message, din_low_p2_message, doutb_p2,
					din_high_p3_message, din_low_p3_message, doutb_p3,
					din_high_p4_message, din_low_p4_message, doutb_p4,
					din_high_p5_message, din_low_p5_message, doutb_p5,
					din_high_p6_message, din_low_p6_message, doutb_p6,
					
					done  
					);

input clk, modulus_sel, rst_ld, rst_ac, rst_nc, rst_crt, add_conv;
input [1:0] INSTRUCTION_ld, INSTRUCTION_nc, NTT_ITERATION;

output [1:0] rdMsel, wtMsel;						// memory control signals

output ram_write_en_r_p0;
output [10:0] read_address_p0, write_address_p0;
output ram_write_en_r_p1;
output [10:0] read_address_p1, write_address_p1;
output ram_write_en_r_p2;
output [10:0] read_address_p2, write_address_p2;
output ram_write_en_r_p3;
output [10:0] read_address_p3, write_address_p3;
output ram_write_en_r_p4;
output [10:0] read_address_p4, write_address_p4;
output ram_write_en_r_p5;
output [10:0] read_address_p5, write_address_p5;
output ram_write_en_r_p6;
output [10:0] read_address_p6, write_address_p6;

output [29:0] din_high_p0_message, din_low_p0_message;
input  [59:0] doutb_p0; 
output [29:0] din_high_p1_message, din_low_p1_message;
input  [59:0] doutb_p1; 
output [29:0] din_high_p2_message, din_low_p2_message;
input  [59:0] doutb_p2; 
output [29:0] din_high_p3_message, din_low_p3_message;
input  [59:0] doutb_p3; 
output [29:0] din_high_p4_message, din_low_p4_message;
input  [59:0] doutb_p4; 
output [29:0] din_high_p5_message, din_low_p5_message;
input  [59:0] doutb_p5; 
output [29:0] din_high_p6_message, din_low_p6_message;
input  [59:0] doutb_p6; 


output done; 



wire [1:0] rdMsel_p0, wtMsel_p0, rdMsel_p1, wtMsel_p1, rdMsel_p2, wtMsel_p2, rdMsel_p3, wtMsel_p3;
wire [1:0] rdMsel_p4, wtMsel_p4, rdMsel_p5, wtMsel_p5, rdMsel_p6, wtMsel_p6;
wire ram_write_en_r_p0, ram_write_en_r_p1, ram_write_en_r_p2, ram_write_en_r_p3;
wire ram_write_en_r_p4, ram_write_en_r_p5, ram_write_en_r_p6;
wire [10:0] read_address_p0, write_address_p0, read_address_p1, write_address_p1, read_address_p2, write_address_p2;	
wire [10:0] read_address_p3, write_address_p3, read_address_p4, write_address_p4, read_address_p5, write_address_p5, read_address_p6, write_address_p6;
wire done_p0, done_p1, done_p2, done_p3, done_p4, done_p5, done_p6;

							

//assign {rdMsel, wtMsel, ram_write_en_r, write_address, read_address, done} = {rdMsel_p0, wtMsel_p0, ram_write_en_r_p0, write_address_p0, read_address_p0, done_p0};
assign {rdMsel, wtMsel, done} = {rdMsel_p0, wtMsel_p0, done_p0};

RLWE_processor_part #(0, core_index) proc0
				   (
					clk, modulus_sel, rst_ld, rst_ac, rst_nc, rst_crt,
					INSTRUCTION_ld, INSTRUCTION_nc, NTT_ITERATION, add_conv,

					rdMsel_p0, wtMsel_p0, ram_write_en_r_p0, write_address_p0, read_address_p0, // op

					din_high_p0_message, din_low_p0_message,	// op 
					doutb_p0,
					done_p0												// op			
					);


RLWE_processor_part #(1, core_index) proc1
				   (
					clk, modulus_sel, rst_ld, rst_ac, rst_nc, rst_crt,
					INSTRUCTION_ld, INSTRUCTION_nc, NTT_ITERATION, add_conv,

					rdMsel_p1, wtMsel_p1, ram_write_en_r_p1, write_address_p1, read_address_p1, // op

					din_high_p1_message, din_low_p1_message,	// op 
					doutb_p1,
					done_p1												// op			
					);

RLWE_processor_part #(2, core_index) proc2
				   (
					clk, modulus_sel, rst_ld, rst_ac, rst_nc, rst_crt,
					INSTRUCTION_ld, INSTRUCTION_nc, NTT_ITERATION, add_conv,

					rdMsel_p2, wtMsel_p2, ram_write_en_r_p2, write_address_p2, read_address_p2, // op

					din_high_p2_message, din_low_p2_message,	// op 
					doutb_p2,
					done_p2												// op			
					);
					
RLWE_processor_part #(3, core_index) proc3
				   (
					clk, modulus_sel, rst_ld, rst_ac, rst_nc, rst_crt,
					INSTRUCTION_ld, INSTRUCTION_nc, NTT_ITERATION, add_conv,

					rdMsel_p3, wtMsel_p3, ram_write_en_r_p3, write_address_p3, read_address_p3, // op

					din_high_p3_message, din_low_p3_message,	// op 
					doutb_p3,
					done_p3												// op			
					);
					
RLWE_processor_part #(4, core_index) proc4
				   (
					clk, modulus_sel, rst_ld, rst_ac, rst_nc, rst_crt,
					INSTRUCTION_ld, INSTRUCTION_nc, NTT_ITERATION, add_conv,

					rdMsel_p4, wtMsel_p4, ram_write_en_r_p4, write_address_p4, read_address_p4, // op

					din_high_p4_message, din_low_p4_message,	// op 
					doutb_p4,
					done_p4												// op			
					);
					
RLWE_processor_part #(5, core_index) proc5
				   (
					clk, modulus_sel, rst_ld, rst_ac, rst_nc, rst_crt,
					INSTRUCTION_ld, INSTRUCTION_nc, NTT_ITERATION, add_conv,

					rdMsel_p5, wtMsel_p5, ram_write_en_r_p5, write_address_p5, read_address_p5, // op

					din_high_p5_message, din_low_p5_message,	// op 
					doutb_p5,
					done_p5												// op			
					);
					
RLWE_processor_part #(6, core_index) proc6
				   (
					clk, modulus_sel, rst_ld, rst_ac, rst_nc, rst_crt,
					INSTRUCTION_ld, INSTRUCTION_nc, NTT_ITERATION, add_conv,

					rdMsel_p6, wtMsel_p6, ram_write_en_r_p6, write_address_p6, read_address_p6, // op

					din_high_p6_message, din_low_p6_message,	// op 
					doutb_p6,
					done_p6												// op			
					);					
					
endmodule

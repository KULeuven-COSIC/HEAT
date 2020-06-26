`timescale 1ns / 1ps

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

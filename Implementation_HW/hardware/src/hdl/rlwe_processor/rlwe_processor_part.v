`timescale 1ns / 1ps

module rlwe_processor_part #(parameter modular_index=6, parameter core_index=1'b1)
				   (
					clk, modulus_sel, rst_ld, rst_ac, rst_nc, rst_crt,
					INSTRUCTION_ld, INSTRUCTION_nc, NTT_ITERATION, add_conv,

					rdMsel, wtMsel, ram_write_en_r, write_address, read_address, 

					din_high_p0_message, din_low_p0_message, doutb_p0,
					addra_NTT_ROM, w_NTT_ROM,
					done
					);

input clk, modulus_sel, rst_ld, rst_ac, rst_nc, rst_crt, add_conv;
input [1:0] INSTRUCTION_ld, INSTRUCTION_nc, NTT_ITERATION;

output [1:0] rdMsel, wtMsel;						// memory control signals
output ram_write_en_r;
output [10:0] read_address, write_address;

output [29:0] din_high_p0_message, din_low_p0_message;
input  [59:0] doutb_p0; 

output [12:0] addra_NTT_ROM;
input [29:0] w_NTT_ROM;

output done; 


wire [10:0] read_address, write_address;
wire [29:0] din_high, din_low;

wire [12:0] m;
wire [3:0] s;
wire [3:0] prim_counter;
wire sel3, sel7, sel9_ac, sel9_nc, wq_en;
wire [1:0] sel2, sel9, sel2_ac, sel2_nc, rdsel_nc, rdsel_ld, rdsel, addin_sel, addin_sel_nc, addin_sel_ac;
wire [2:0] sel1;
wire [10:0] addressin, addressin_nc, addressin_ac, write_address_ld;
wire ram_write_en, ram_write_en_nc, ram_write_en_ac, ram_write_en_ld;
wire mz_sel, mz_sel_nc, mz_sel_ac;
wire done, done_nc, done_ac;
wire [1:0] RdQsel, WtQsel;
wire [1:0] wtsel2, wtsel3, wtsel1_nc, wtsel2_nc, wtsel3_nc, wtsel1_ac, wtsel2_ac, wtsel3_ac, wtsel2_ld, wtsel3_ld;
wire [2:0] wtsel1, wtsel1_ld;
wire [2:0] c4;
wire [1:0] c5;
wire [1:0] rdMsel, wtMsel, rdMsel_ac, wtMsel_ac, rdMsel_nc, wtMsel_nc, rdMsel_ld, wtMsel_ld, rdMsel_crt, wtMsel_crt;
reg [1:0] rdMsel_nc_r, wtMsel_nc_r;
wire [29:0] load1, load2;
wire done_ld;
wire [59:0] doutb;
wire [29:0] dout_high_p0, dout_low_p0;
reg ram_write_en_r;
wire wtsel_10;

wire [2:0] crt_rom_address;
wire mz_sel_crt, sel10_crt;
wire [1:0] sel2_crt, sel9_crt;

wire done_crt;
wire [10:0] read_address_au, write_address_au;
wire [1:0] wtsel2_crt, wtsel3_crt;


wire rst_crt_reduction, sample_result;
wire [110:0] crt_sum_reg;
wire [107:0] crt_reduced_out;
wire [1:0] message;
wire sample_message;
wire [10:0] ram_writeaddress;
wire end_of_decoding;
wire crt_address_change;


wire [29:0] din_high_p0, din_low_p0, din_high_p1, din_low_p1, din_high_p2, din_low_p2;
wire [29:0] din_high_p3, din_low_p3, din_high_p4, din_low_p4, din_high_p5, din_low_p5, din_high_p6, din_low_p6;

wire [29:0] din_high_p0_dp, din_low_p0_dp, din_high_p1_dp, din_low_p1_dp, din_high_p2_dp, din_low_p2_dp;
wire [29:0] din_high_p3_dp, din_low_p3_dp, din_high_p4_dp, din_low_p4_dp, din_high_p5_dp, din_low_p5_dp, din_high_p6_dp, din_low_p6_dp;

wire [29:0] din_high_p0_gs, din_low_p0_gs, din_high_p1_gs, din_low_p1_gs, din_high_p2_gs, din_low_p2_gs;
wire [29:0] din_high_p3_gs, din_low_p3_gs, din_high_p4_gs, din_low_p4_gs, din_high_p5_gs, din_low_p5_gs, din_high_p6_gs, din_low_p6_gs;
wire  primout_mask;

always @(posedge clk)
begin
	ram_write_en_r <= ram_write_en;
end


assign {read_address, write_address} = {read_address_au, write_address_au};

assign addressin = (rst_ac==1'b0) ? addressin_ac : addressin_nc;
assign ram_write_en = (rst_nc==1'b0) ? ram_write_en_nc : (rst_ac==1'b0) ? ram_write_en_ac 
							 : 1'b0;

assign mz_sel = (rst_nc==1'b0) ? mz_sel_nc : mz_sel_ac;
assign sel2 = (rst_nc==1'b0) ? sel2_nc : sel2_ac;
assign sel9 = (rst_nc==1'b0) ? {1'b0,sel9_nc} : {1'b0,sel9_ac};
assign done = (rst_nc==1'b0) ? done_nc : done_ac;
assign addin_sel = (rst_nc==1'b0) ? addin_sel_nc : (rst_ac==1'b0) ? addin_sel_ac : 2'd2;
assign rdsel = rdsel_nc;

assign {wtsel1} = (rst_ld)  ? ((rst_nc) ? {1'b0,wtsel1_ac} : {1'b0,wtsel1_nc})
														: {wtsel1_ld};

assign {wtsel2,wtsel3} = (rst_nc==1'b0) ? {wtsel2_nc,wtsel3_nc} : (rst_ac==1'b0) ? {wtsel2_ac,wtsel3_ac} 
                         : {wtsel2_ld,wtsel3_ld};

assign rdMsel = (rst_ld==1'b0) ? rdMsel_ld : (rst_nc==1'b0) ? rdMsel_nc_r : rdMsel_ac; 
assign wtMsel = (rst_ld==1'b0) ? wtMsel_ld : (rst_nc==1'b0) ? wtMsel_nc_r : wtMsel_ac; 


assign {dout_high_p0, dout_low_p0} = doutb_p0;

assign {din_high_p0, din_low_p0} = {din_high_p0_dp, din_low_p0_dp};
      

assign {din_high_p0_message, din_low_p0_message} = {din_high_p0, din_low_p0};

	
rlwe_processor_part_ntt_control	#(core_index) NC(clk, rst_nc, INSTRUCTION_nc, NTT_ITERATION, 
		m, primout_mask, addressin_nc, s, prim_counter, c4, c5,
	   sel1, sel2_nc, sel3, sel7, sel9_nc, rdsel_nc, wtsel1_nc, wtsel2_nc, wtsel3_nc, mz_sel_nc, addin_sel_nc,
		wq_en, 
		ram_write_en_nc, done_nc, // to top
		rdMsel_nc, wtMsel_nc, addra_NTT_ROM);

always @(posedge clk)
{rdMsel_nc_r, wtMsel_nc_r} <= {rdMsel_nc, wtMsel_nc};


rlwe_processor_part_add_convolution_control	#(core_index) ACC(clk, rst_ac, add_conv,
									addressin_ac, ram_write_en_ac, mz_sel_ac, sel2_ac, sel9_ac, addin_sel_ac, rdMsel_ac, wtMsel_ac, 
									wtsel1_ac, wtsel2_ac, wtsel3_ac, done_ac);

generate
   if (core_index==1'd0)
	begin
		address_dp_c0 ADR(clk, addressin, rdsel, wtsel1, m, s,
								read_address_au, write_address_au, wtsel_10);
	end
	else
	begin
		address_dp_c1 ADR(clk, addressin, rdsel, wtsel1, m, s,
								read_address_au, write_address_au, wtsel_10);
	end
endgenerate	
	
/////////////////////////////////////////////////////////////////////////
////////////////// instance of data path /////////////////////////////

datapath_top #(modular_index, core_index) DTP_p0(clk, modulus_sel, INSTRUCTION_nc, m, w_NTT_ROM, primout_mask,
		 dout_high_p0, dout_low_p0, 
		 , , , , , , ,
		 prim_counter, c4, c5,
		 sel1, sel2, sel3, sel7, sel9, sel10_crt, wtsel2, wtsel3, mz_sel, addin_sel, wtsel_10,
		 wq_en, rst_ac, crt_rom_address, 
		
		 din_high_p0_dp, din_low_p0_dp, crt_sum_for_accumulation_p0);

					
/////////////////////////////////////////////////////////////////////////////////		 


endmodule

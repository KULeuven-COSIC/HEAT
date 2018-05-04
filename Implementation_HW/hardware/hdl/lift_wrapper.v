`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: a
// Engineer: 
// 
// Create Date:    18:26:56 10/16/2017 
// Design Name: 
// Module Name:    lift_wrapper 
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
(* KEEP_HIERARCHY = "TRUE" *)

`default_nettype none
module lift_wrapper(clk, rst, reduction_type, top_address, we, din, data_type, data_valid,
                    read_out, done);
input wire clk, rst;
input wire reduction_type; // If 0 then reduces 180 bit data by qi; else reduces 91 bit two words in two iterations.
input wire [5:0] top_address;
input wire we;
input wire [239:0] din;
input wire data_type;		// 1: lift q-->Q
input wire data_valid;		// goes high after loading the input-buffer RAM;

output wire [239:0] read_out;
output reg done;

wire [5:0] read_address;
wire [4:0] RD_INPUT_ADDR;
wire [2:0] RAM_BANK_SEL;
wire [29:0] read_data0, read_data1, read_data2, read_data3, read_data4, read_data5, read_data6, read_data7;
wire [29:0] D_IN;

wire DONE_RD_8;
wire SIGN;
wire CF_INFO_OUT;
wire sample_CF_INFO_OUT;
wire QUOTIENT_READY_for_modq;
wire QUOTIENT_READY_for_fin_adj;
wire [117:0] QUOTIENT;
wire A_PRIME_QJ_READY;
wire [29:0] A_PRIME_QJ;
wire ToD_SAMPLED;
reg SIGN_REG;

reg [5:0] top_address_r;
reg we_r;
reg [239:0] din_r;

always @(posedge clk)
begin
	top_address_r <= top_address;
	we_r <= we;
	din_r <= din;
end

lift_wrapper_input_buffer ibuff(clk, din_r, top_address_r, we_r, read_address, RAM_BANK_SEL, D_IN);
	
assign read_address = {1'b0,RD_INPUT_ADDR};

LIFT_MOD_PART1 LIFT_MOD_PART1_DP				 (clk,
														  rst,
														  data_type,
														  data_valid,
														  RD_INPUT_ADDR,
														  RAM_BANK_SEL,
														  D_IN,
														  DONE_RD_8,
														  SIGN,
														  CF_INFO_OUT,
														  sample_CF_INFO_OUT,
														  QUOTIENT_READY_for_modq,
														  QUOTIENT_READY_for_fin_adj,
														  QUOTIENT,
														  A_PRIME_QJ_READY,
														  A_PRIME_QJ,
														  ToD_SAMPLED);	 
/*														  
wire [8:0] fake_addres;
wire [7:0] RAM_BANK_SEL_x_OFFSET;
assign RAM_BANK_SEL_x_OFFSET = RAM_BANK_SEL * 3'd6;
assign fake_addres = RAM_BANK_SEL_x_OFFSET + RD_INPUT_ADDR;	
										
INPUT_RAM_FAKE INPUT_RAM_FAKE_DP(fake_addres[5:0],
											30'b0,
											CLK,
											1'b0,
											D_IN);
*/
											
//COEFFICENT_LIST=[
//127904631591249259198033922217180318333075374370975365, 
//750538424709475445007730376215521149574243506629607944, 
//633910381514755979728349784074295687555971049663207167, 
//1104983707548909804379515816512365637858580047733240400, 
//1078435330620719499382744046122441772067459477340572114, 
//1356932857030875610609963397782457481141541435882794974, 
//1280488256140708530061435601448377784155457008713645220, 
//464219187691235736945105017832809292869078733272162085, 
//]

//div_out_data_ready = QUOTIENT_READY_for_fin_adj;
//div_quotient_c3 = QUOTIENT
//small_crt_result_c3 = A_PRIME_QJ
//small_crt_data_ready_c3 = A_PRIME_QJ_READY

wire rst_FA;

wire [59:0] master_processor_out;
wire [10:0] bram_write_address;
wire [3:0] bram_core_index;
wire bram_write_en;
wire master_processor_done;			// becomes 1 after completion
wire mproc_responds;
wire [59:0] ddr_data, div_quotient_c11, small_crt_result_c11;
wire small_crt_data_ready_c11;

assign ddr_data = 60'd0; 
assign div_quotient_c11 = 60'd0; 
assign small_crt_result_c11 = 60'd0;
assign small_crt_data_ready_c11 = 1'b0;

always @(posedge clk)
SIGN_REG <= SIGN;

assign rst_FA = (rst==1'b0 && data_type==1'b1) ? 1'b0 : 1'b1; 

master_processor FA(clk, rst_FA, rst_FA, QUOTIENT_READY_for_fin_adj, SIGN_REG,
								ddr_data, QUOTIENT[59:0], A_PRIME_QJ, div_quotient_c11, small_crt_result_c11,
								A_PRIME_QJ_READY, small_crt_data_ready_c11,
								
								master_processor_out, bram_write_address, bram_core_index, bram_write_en,
								master_processor_done,
								
								mproc_responds
								
								);

wire rst_REDq;
wire [29:0] REDq_data;
wire [5:0] REDq_write_address;
wire REDq_data_ready;
wire [2:0] REDq_write_core_index;
wire REDq_done;

assign rst_REDq = (rst==1'b0 && data_type==1'b0) ? 1'b0 : 1'b1; 

red_180bit_q_then_30bit_qi	REDq(.clk(clk), .rst(rst_REDq), 
										  .read_input_data(QUOTIENT), 
										  .reduction_type(reduction_type),
										  .input_data_ready(QUOTIENT_READY_for_modq),
										  .sign_large_red_in(CF_INFO_OUT), 
										  .div_start_new(1'b0),
										  .sample_CF_INFO_OUT(sample_CF_INFO_OUT),
										  
										  .result(REDq_data), 
										  .result_write_address(REDq_write_address), 
										  .result_write(REDq_data_ready), 
										  .result_counter(REDq_write_core_index),

										  .done(REDq_done),
										  .done_test(),
										  .done_one_BR()
										);

wire [29:0] obuff_in;
wire [2:0] obuff_index;
wire [5:0] obuff_write_address;
wire obuf_write_en;
wire done_wire;

assign obuff_in = (data_type) ? master_processor_out[29:0] : REDq_data;
assign obuff_index = (data_type) ? bram_core_index[2:0] : REDq_write_core_index;
assign obuff_write_address = (data_type) ? bram_write_address[5:0] : REDq_write_address;
assign obuf_write_en = (data_type) ? bram_write_en : REDq_data_ready;

lift_wrapper_output_buffer obuff(clk, obuff_in, obuff_index, obuff_write_address, obuf_write_en, 
                                 top_address, read_out); 
//lift_wrapper_output_buffer obuff(clk, master_processor_out[29:0], bram_core_index[2:0], bram_write_address[5:0], bram_write_en, 
//                                 top_address, read_out); 

assign done_wire = (data_type) ? master_processor_done : REDq_done;

always @(posedge clk)
done <= done_wire;

endmodule
`default_nettype wire
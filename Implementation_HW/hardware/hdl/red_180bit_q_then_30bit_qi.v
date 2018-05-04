`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:53:04 11/02/2017 
// Design Name: 
// Module Name:    red_180bit_q_then_30bit_qi 
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
module red_180bit_q_then_30bit_qi(
			clk, rst, reduction_type, read_input_data, input_data_ready,
         sign_large_red_in, div_start_new,
			sample_CF_INFO_OUT,
			//out_address,
			//out_word1, out_word2, out_word3, out_word4,
			//out_word5, out_word6, out_word7, out_word8,

			result, result_write_address, result_write, result_counter,
			done,
			done_test,
			done_one_BR
			);

input clk;
input rst;
input reduction_type; 	// If 0 then reduces 180 bit data by qi; else reduces 91 bit two words in two iterations.
input [117:0] read_input_data;
input input_data_ready;		// will be connected to the division word ready signal
input sign_large_red_in, div_start_new;
input sample_CF_INFO_OUT;

//input [4:0] out_address;
//output [29:0] out_word1, out_word2, out_word3, out_word4;
//output [29:0] out_word5, out_word6, out_word7, out_word8;

output [29:0] result;
output [5:0] result_write_address;
output result_write;
output [2:0] result_counter;

output done;
output done_test;
output done_one_BR;

wire [58:0] dout0_BR;
wire sign_BR;								// Sign of the result
wire bram_write_BR;						// write enable signal for BRAM
wire [10:0] bram_write_address_BR;	// write address for BRAM	
wire [2:0] bram_core_index_BR;		// unused
wire done_four_lcrts_BR;				// This is a done signal; goes 1 after finishing a burst of 4 large CRTs

wire done_one_BR; 	// SHOULD BE REMOVED

barrett_reduction_180bit	BR180(clk, rst, read_input_data, input_data_ready,
                                 sign_large_red_in, div_start_new,
                                 sample_CF_INFO_OUT,
											dout0_BR, sign_BR, bram_write_BR, bram_write_address_BR, 
											bram_core_index_BR, done_four_lcrts_BR,
											done_one_BR
											);

wire [59:0] din_RED;
wire din_valid_RED;
wire [29:0] result;
wire [5:0] result_write_address;
wire result_write;
wire [2:0] result_counter;
								  
assign din_RED = {sign_BR, dout0_BR};
assign din_valid_RED = bram_write_BR;

red_180bit_by30bit_regbank	RED30(clk, rst, reduction_type, din_RED, din_valid_RED, out_address,
								   //out_word1, out_word2, out_word3, out_word4, 
								   //out_word5, out_word6, out_word7, out_word8,
								   result, result_write_address, result_write, result_counter,		 								  
								   done, done_test);


endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/27/2018 09:02:46 AM
// Design Name: 
// Module Name: lift_core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module lift_core(clk, rst, mode, start, ext_addr, ext_din, ext_we, ext_we_done, result_read_en, ext_dout, eight_lift_result_write_done, last_read_of_buffer_q);
input clk, rst;
input mode;     // 0 for small and 1 for big;
input start;    // Active high: enables computation
input [3:0] ext_addr;
input [239:0] ext_din;
input ext_we;
input ext_we_done;   // This is 1 cycle pulse provided in the last cycle of burst-writing to change the base address for next writing
input result_read_en;   // This is enable for reading result from obuff

output [239:0] ext_dout;
output eight_lift_result_write_done;
output last_read_of_buffer_q;

wire [29:0] ibuff_out_q, ibuff_out_p;
wire [2:0] rd_addr_ibuff_q, rd_addr_ibuff_p;
wire ext_we_q, ext_we_p;
wire [2:0] ext_addr_ibuff_q, ext_addr_ibuff_p;
wire last_read_of_buffer_q, last_read_of_buffer_p;

wire start_ls;
reg start_ls_after_lb;
wire [2:0] rd_addr_q_ls, wt_addr_ls;
wire [29:0] datain_ls, result_ls;
wire result_we_ls;
wire eight_lift_result_write_done;

wire start_lb;
wire [2:0] rd_addr_q_lb, rd_addr_p_lb;
wire [29:0] result_lb;
wire result_we_lb; 
wire [2:0] wt_addr_lb;
wire [29:0] big_lift_op;

/*----------------------------------------------------------------------------------------------------*/
assign rd_addr_ibuff_q = (mode) ? rd_addr_q_lb : rd_addr_q_ls;
assign rd_addr_ibuff_p = rd_addr_p_lb;
assign ext_we_q = (ext_addr < 4'd6) ? ext_we : 1'b0;
assign ext_we_p = (ext_addr > 4'd5) ? ext_we : 1'b0;
assign ext_addr_ibuff_q = ext_addr[2:0];
assign ext_addr_ibuff_p = ext_addr - 4'd6;

din_buff    ibuff_q(clk, rst, ext_addr_ibuff_q, ext_din, ext_we_q, ext_we_done,   rd_addr_ibuff_q, ibuff_out_q, last_read_of_buffer_q);
din_buff    ibuff_p(clk, rst, ext_addr_ibuff_p, ext_din, ext_we_p, ext_we_done,   rd_addr_ibuff_p, ibuff_out_p, last_read_of_buffer_p);

/*----------------------------------------------------------------------------------------------------*/
assign start_lb = (mode) ? start : 1'b0;

lift_big    lb(clk, rst, start_lb, rd_addr_q_lb, ibuff_out_q, rd_addr_p_lb, ibuff_out_p, 
                result_lb, wt_addr_lb, result_we_lb);

lift_buff_mem big_lift_outputs(.a({3'b000,wt_addr_lb}), .d(result_lb), .dpra({3'b000,rd_addr_q_ls}), .clk(clk), .we(result_we_lb), .qdpo_clk(clk), .qdpo(big_lift_op));
/*----------------------------------------------------------------------------------------------------*/

always @(posedge clk)
start_ls_after_lb <= result_we_lb;

assign start_ls = (mode) ? start_ls_after_lb : start;
assign datain_ls = (mode) ? big_lift_op : ibuff_out_q;

lift_small  ls(clk, rst, mode, start_ls, rd_addr_q_ls, datain_ls, 
               result_ls, wt_addr_ls, result_we_ls);

/*----------------------------------------------------------------------------------------------------*/                

dout_buff   obuff(clk, rst, mode, wt_addr_ls, result_we_ls, result_ls,  ext_addr[2:0], result_read_en, ext_dout, eight_lift_result_write_done);

endmodule

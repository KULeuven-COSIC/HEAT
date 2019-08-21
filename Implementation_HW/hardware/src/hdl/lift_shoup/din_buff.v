`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/27/2018 09:32:15 AM
// Design Name: 
// Module Name: din_buff
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


module din_buff(clk, rst, wt_addr, din, we, write_done,
                rd_addr, dout, last_read_of_buffer);

input clk, rst;
input [2:0] wt_addr;
input [239:0] din;
input we;
input write_done;       // This is 1 cycle pulse provided in the last cycle of burst-writing to change the base address for next writing
 
input [2:0] rd_addr; 
output [29:0] dout;
output reg last_read_of_buffer;

wire [29:0] din_m0, din_m1, din_m2, din_m3, din_m4, din_m5, din_m6, din_m7;
wire [29:0] dout_m0, dout_m1, dout_m2, dout_m3, dout_m4, dout_m5, dout_m6, dout_m7;

reg wt_addr_base_sel;
wire [5:0] wt_addr_in;

reg rd_addr_base_sel;
wire [5:0] rd_addr_in;
reg [2:0] bank_sel, bank_sel_r;
wire read_done;

assign {din_m7, din_m6, din_m5, din_m4, din_m3, din_m2, din_m1, din_m0} = din;

assign dout = (bank_sel_r==3'd0) ? dout_m0 : (bank_sel_r==3'd1) ? dout_m1 : (bank_sel_r==3'd2) ? dout_m2 :
              (bank_sel_r==3'd3) ? dout_m3 : (bank_sel_r==3'd4) ? dout_m4 : (bank_sel_r==3'd5) ? dout_m5 :
              (bank_sel_r==3'd6) ? dout_m6 : dout_m7;   

always @(posedge clk)
begin
    if(rst)
        wt_addr_base_sel <= 1'b0;
    else if(write_done)
        wt_addr_base_sel <= ~wt_addr_base_sel;    
    else    
        wt_addr_base_sel <= wt_addr_base_sel;
end        

assign wt_addr_in = (wt_addr_base_sel) ? {1'b1, 2'b00, wt_addr[2:0]} : {1'b0, 2'b00, wt_addr[2:0]};

always @(posedge clk)
begin
    if(rst)
        bank_sel <= 3'd0;
    else if(rd_addr==3'd6)
        bank_sel <= bank_sel + 1'b1;
    else
        bank_sel <= bank_sel;
end
always @(posedge clk)
bank_sel_r <= bank_sel;
                
always @(posedge clk)
begin
    if(rst)
        rd_addr_base_sel <= 1'b0;
    else if(read_done)
        rd_addr_base_sel <= ~rd_addr_base_sel;    
    else    
        rd_addr_base_sel <= rd_addr_base_sel;
end        

assign read_done = (rd_addr==3'd6 && bank_sel==3'd7) ? 1'b1 : 1'b0;
assign rd_addr_in = (rd_addr_base_sel) ? {1'b1, 2'b00, rd_addr[2:0]} : {1'b0, 2'b00, rd_addr[2:0]};

lift_buff_mem m0(.a(wt_addr_in), .d(din_m0), .dpra(rd_addr_in), .clk(clk), .we(we), .qdpo_clk(clk), .qdpo(dout_m0));
lift_buff_mem m1(.a(wt_addr_in), .d(din_m1), .dpra(rd_addr_in), .clk(clk), .we(we), .qdpo_clk(clk), .qdpo(dout_m1));
lift_buff_mem m2(.a(wt_addr_in), .d(din_m2), .dpra(rd_addr_in), .clk(clk), .we(we), .qdpo_clk(clk), .qdpo(dout_m2));
lift_buff_mem m3(.a(wt_addr_in), .d(din_m3), .dpra(rd_addr_in), .clk(clk), .we(we), .qdpo_clk(clk), .qdpo(dout_m3));
lift_buff_mem m4(.a(wt_addr_in), .d(din_m4), .dpra(rd_addr_in), .clk(clk), .we(we), .qdpo_clk(clk), .qdpo(dout_m4));
lift_buff_mem m5(.a(wt_addr_in), .d(din_m5), .dpra(rd_addr_in), .clk(clk), .we(we), .qdpo_clk(clk), .qdpo(dout_m5));
lift_buff_mem m6(.a(wt_addr_in), .d(din_m6), .dpra(rd_addr_in), .clk(clk), .we(we), .qdpo_clk(clk), .qdpo(dout_m6));
lift_buff_mem m7(.a(wt_addr_in), .d(din_m7), .dpra(rd_addr_in), .clk(clk), .we(we), .qdpo_clk(clk), .qdpo(dout_m7));

wire last_read_of_buffer_wire = (bank_sel_r==3'd7 && rd_addr_in[2:0]==3'd6) ? 1'b1 : 1'b0;
always @(posedge clk)
last_read_of_buffer <= last_read_of_buffer_wire;

endmodule

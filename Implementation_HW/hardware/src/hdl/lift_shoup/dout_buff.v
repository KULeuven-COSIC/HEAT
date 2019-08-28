`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/27/2018 11:15:04 AM
// Design Name: 
// Module Name: dout_buff
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


module dout_buff(clk, rst, mode, wt_addr, we, din, 
                    rd_addr, result_read_en, dout, eight_lift_result_write_done);
                    
input clk, rst;
input mode;     // 0 --> 7 inputs; 1 --> 6 inputs;
input [2:0] wt_addr, rd_addr;
input we;
input [29:0] din;
input result_read_en;

output [239:0] dout;
output reg eight_lift_result_write_done;

wire we_m0, we_m1, we_m2, we_m3, we_m4, we_m5, we_m6, we_m7;
wire [29:0] dout_m0, dout_m1, dout_m2, dout_m3, dout_m4, dout_m5, dout_m6, dout_m7;
wire [5:0] wt_addr_in, rd_addr_in;

reg wt_base_sel, rd_base_sel;

wire write_done;        // becomes 1 when 8 banks are filled
reg [2:0] bank_sel;

wire read_done;         // becomes 1 when 6 or 7 words (240 bit) are read 



/* Write logic */
always @(posedge clk)
begin
    if(rst)
        bank_sel <= 3'd0;
    else if(mode==1'b0 && wt_addr==3'd6 && we==1'b1)
        bank_sel <= bank_sel + 1'b1;
    else if(mode==1'b1 && wt_addr==3'd5 && we==1'b1)
        bank_sel <= bank_sel + 1'b1;
    else
        bank_sel <= bank_sel;                        
end
assign write_done = (bank_sel==3'd7 && ((mode==1'b0 && wt_addr==3'd6 && we==1'b1) || (mode==1'b1 && wt_addr==3'd5 && we==1'b1))) ? 1'b1 : 1'b0;
always @(posedge clk)
begin
    if(rst)
        wt_base_sel <= 1'b0;
    else if(write_done)
        wt_base_sel <= ~wt_base_sel;
    else
        wt_base_sel <= wt_base_sel;        
end
assign wt_addr_in = {wt_base_sel, 2'b00, wt_addr};

/* Read logic */
assign read_done = ((result_read_en==1'b1 && mode==1'b0 && rd_addr==3'd6)||(result_read_en==1'b1 && mode==1'b1 && rd_addr==3'd5)) ? 1'b1 : 1'b0; 
always @(posedge clk)
begin
    if(rst)
        rd_base_sel <= 1'b0;
    else if(read_done)
        rd_base_sel <= ~rd_base_sel;
    else
        rd_base_sel <= rd_base_sel;        
end
assign rd_addr_in = {rd_base_sel, 2'b00, rd_addr};

assign we_m0 = (bank_sel==3'd0) ? we : 1'b0;
assign we_m1 = (bank_sel==3'd1) ? we : 1'b0;
assign we_m2 = (bank_sel==3'd2) ? we : 1'b0;
assign we_m3 = (bank_sel==3'd3) ? we : 1'b0;
assign we_m4 = (bank_sel==3'd4) ? we : 1'b0;
assign we_m5 = (bank_sel==3'd5) ? we : 1'b0;
assign we_m6 = (bank_sel==3'd6) ? we : 1'b0;
assign we_m7 = (bank_sel==3'd7) ? we : 1'b0;

lift_buff_mem m0(.a(wt_addr_in), .d(din), .dpra(rd_addr_in), .clk(clk), .we(we_m0), .qdpo_clk(clk), .qdpo(dout_m0));
lift_buff_mem m1(.a(wt_addr_in), .d(din), .dpra(rd_addr_in), .clk(clk), .we(we_m1), .qdpo_clk(clk), .qdpo(dout_m1));
lift_buff_mem m2(.a(wt_addr_in), .d(din), .dpra(rd_addr_in), .clk(clk), .we(we_m2), .qdpo_clk(clk), .qdpo(dout_m2));
lift_buff_mem m3(.a(wt_addr_in), .d(din), .dpra(rd_addr_in), .clk(clk), .we(we_m3), .qdpo_clk(clk), .qdpo(dout_m3));
lift_buff_mem m4(.a(wt_addr_in), .d(din), .dpra(rd_addr_in), .clk(clk), .we(we_m4), .qdpo_clk(clk), .qdpo(dout_m4));
lift_buff_mem m5(.a(wt_addr_in), .d(din), .dpra(rd_addr_in), .clk(clk), .we(we_m5), .qdpo_clk(clk), .qdpo(dout_m5));
lift_buff_mem m6(.a(wt_addr_in), .d(din), .dpra(rd_addr_in), .clk(clk), .we(we_m6), .qdpo_clk(clk), .qdpo(dout_m6));
lift_buff_mem m7(.a(wt_addr_in), .d(din), .dpra(rd_addr_in), .clk(clk), .we(we_m7), .qdpo_clk(clk), .qdpo(dout_m7));


assign dout = {dout_m7, dout_m6, dout_m5, dout_m4, dout_m3, dout_m2, dout_m1, dout_m0};

always @(posedge clk)
eight_lift_result_write_done <= write_done;

endmodule

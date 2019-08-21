`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2018 03:57:59 PM
// Design Name: 
// Module Name: sum_fixedpt_blift
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

module sum_fixedpt_blift(clk, rst, start, rd_addr, a_shares, rounded_sop, rounded_sop_write);
input clk, rst;
input start;        // This signal is set 1 after input data is ready.

output [2:0] rd_addr;
input [29:0] a_shares;   // Scaled data comes from outside and gets written in internal memory;

output [33:0] rounded_sop;
output rounded_sop_write;

reg [2:0] rd_addr;
wire [29:0] a_shares;

wire [5:0] ROM_addr;
wire [59:0] fixed_pt_constant;
wire [89:0] mul_out;
reg [93:0] acc_reg;
wire [46:0] acc_in_low, acc_in_high;
reg acc_in_sel, acc_in_sel_r0, acc_in_sel_r1;
wire [46:0] c_low, c_high;

reg rounded_sop_write_r0, rounded_sop_write_r1, rounded_sop_write_r2, rounded_sop_write_r3, rounded_sop_write_r4, rounded_sop_write_r5, rounded_sop_write_r6;

assign ROM_addr = {3'b000, rd_addr};

ROM_fixed_pt_blift ROM_fixedpt(.a(ROM_addr), .clk(clk), .qspo(fixed_pt_constant));

multiplier_30x60 mul(.CLK(clk), .A(a_shares), .B(fixed_pt_constant), .P(mul_out));

adder_94bit adder(clk, {4'd0,mul_out}, {acc_in_high,acc_in_low}, c_low, c_high);

always @(posedge clk)
acc_reg <= {c_high, c_low};

assign acc_in_low = (acc_in_sel_r0) ? acc_reg[46:0] : 46'd0;
assign acc_in_high = (acc_in_sel_r1) ? acc_reg[93:47] : 46'd0;

always @(posedge clk)
begin
    if(rst)
        rd_addr <= 3'd0;
    else if(rd_addr==3'd6)
        rd_addr <= 3'd0;        
    else if(start)
        rd_addr <= rd_addr + 1'b1;
    else    
        rd_addr <= 3'd0;
end


/* Pipeline for acc_in_sel */
always @(posedge clk)
begin
    if(rd_addr==3'd5)           // Since the multiplier has 6 stages, rd_addr==5 is enough for correct synchronization of acc<- mult + 0
        acc_in_sel <= 1'b0; 
    else
        acc_in_sel <= 1'b1;
        
    acc_in_sel_r0 <= acc_in_sel;
    acc_in_sel_r1 <= acc_in_sel_r0;    
end



/* Rounding calculation */
/* acc_reg = xxxx.yyy---yyy where yyyy part is 89 bit */
/* Originally: Least 88 bits of y are checked if they are 0 or nonzero; If nonzero and 89th bit is 1 then xxxx+1 else xxxx*/
/* If we decide only based on 89th bit, then probability of bieing wrong approx 2^-89 */

assign rounded_sop = (acc_reg[59]) ? acc_reg[93:60]+1'b1 : acc_reg[93:60];

always @(posedge clk)
begin
    rounded_sop_write_r0 <= !acc_in_sel_r1;
    rounded_sop_write_r1 <= rounded_sop_write_r0;
    rounded_sop_write_r2 <= rounded_sop_write_r1;
    rounded_sop_write_r3 <= rounded_sop_write_r2;
    rounded_sop_write_r4 <= rounded_sop_write_r3;
    rounded_sop_write_r5 <= rounded_sop_write_r4;
            
end
assign rounded_sop_write = rounded_sop_write_r5;

/* Acc testing logic */
reg [46:0] acc_low_r;
always @(posedge clk)
acc_low_r <= acc_reg[46:0];
wire [93:0] test = {acc_reg[93:47], acc_low_r};

endmodule

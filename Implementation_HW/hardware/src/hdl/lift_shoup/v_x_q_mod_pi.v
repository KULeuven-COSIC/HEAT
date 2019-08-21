`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2018 01:01:28 PM
// Design Name: 
// Module Name: v_x_q_mod_pi
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


module v_x_q_mod_pi(clk, rst, mode, start, rounded_sop, rounded_sop_write, result   );
input clk, rst;
input mode;
input start;            // Start and rounded_sop_write should arrive together
input [3:0] rounded_sop;
input rounded_sop_write;

output [29:0] result;

reg [2:0] rd_addr;
reg [2:0] wt_addr_r0, wt_addr_r1, wt_addr_r2, wt_addr_r3, wt_addr_r4, wt_addr_r5, wt_addr_r6, wt_addr_r7;
reg we_r0, we_r1, we_r2, we_r3, we_r4, we_r5, we_r6, we_r7;

reg [3:0] rounded_sop_reg;
wire [29:0] q_mod_pi;
wire [5:0] ROM_addr;

wire [33:0] mul_out;
wire [29:0] mod_out;
wire [3:0] mod_sel, mod_sel_base;

reg [3:0] mod_sel_r0, mod_sel_r1, mod_sel_r2;

always @(posedge clk)
begin
    if(rounded_sop_write)
        rounded_sop_reg <= rounded_sop;
    else     
        rounded_sop_reg <= rounded_sop_reg;
end

assign ROM_addr = {mode, 2'b00, rd_addr};  // First 6 constants are in address {0-5} and last 7 are in address {32-38}
ROM_q_mod_pi ROM_q_pi(.a(ROM_addr), .clk(clk), .qspo(q_mod_pi));

multiplier_4x30 mult(.CLK(clk), .A(rounded_sop_reg), .B(q_mod_pi), .P(mul_out));

windowed_reduction34bit_q_select mod(clk, mod_sel, mul_out, mod_out);



always @(posedge clk)
begin
    if(rst)
        rd_addr <= 3'd0;
    else if(rd_addr==3'd6)
        rd_addr <= 3'd0;        
    //else if(mode==1'b1 && rd_addr==3'd5)
    //    rd_addr <= 3'd0;    
    else if(start)
        rd_addr <= rd_addr + 1'b1;
    else    
        rd_addr <= 3'd0;
end

/* Pipeline for mod_sel */
always @(posedge clk)
begin
    mod_sel_r0<=(rd_addr + mod_sel_base); 
    mod_sel_r1<=mod_sel_r0; mod_sel_r2<=mod_sel_r1;  
end
assign mod_sel_base = (mode) ? 4'd0 : 4'd6;
assign mod_sel = mod_sel_r2;


assign result = mod_out;

endmodule

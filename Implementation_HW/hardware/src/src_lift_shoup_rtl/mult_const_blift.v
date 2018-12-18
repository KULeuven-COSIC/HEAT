`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2018 04:44:47 PM
// Design Name: 
// Module Name: mult_const_blift
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

module ap_const_rom(clk, addr, out);
input clk;
input [2:0] addr;
output reg [29:0] out;

wire [29:0] out_wire;

assign out_wire = 
                (addr==3'd0) ? 30'd318931683 : 
                (addr==3'd1) ? 30'd991350525 : 
                (addr==3'd2) ? 30'd428501086 : 
                (addr==3'd3) ? 30'd665588608 : 
                (addr==3'd4) ? 30'd602266786 :
                (addr==3'd5) ? 30'd734861690 :
                (addr==3'd6) ? 30'd373752559 : 30'd0;

always @(posedge clk)
out <= out_wire;

endmodule



module mult_const_blift(clk, rst, start, rd_addr, ap_shares, out);
input clk, rst; 
input start;

output reg [2:0] rd_addr;
input [29:0] ap_shares;

output [59:0] out;

wire [29:0] const_out;
wire [59:0] mul_out;

ap_const_rom const_rom(clk, rd_addr, const_out);

/* This multiplier has additional pipeline stages to sync output with other blocks (value of rounded_real) */
dsp_mul30_extra_delay_15stg mul(.CLK(clk), .A(ap_shares), .B(const_out), .P(mul_out));

assign out = mul_out;

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

endmodule

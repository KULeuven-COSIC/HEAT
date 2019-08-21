`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/25/2018 05:45:12 PM
// Design Name: 
// Module Name: adder_93bit
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


module adder_94bit(clk, a, b, c_low, c_high);
input clk;
input [93:0] a, b;
output [46:0] c_low, c_high;

wire [46:0] a_high, a_low, b_high, b_low;

assign {a_high, a_low} = a;
assign {b_high, b_low} = b;

wire [46:0] c_low, c_high;
wire carry_low;
reg carry_low_r;

/* First stage of the pipeline addition */
assign {carry_low, c_low} = a_low + b_low;
always @(posedge clk)
carry_low_r <= carry_low;

/* Second stage of the pipeline addition */
reg [46:0] a_high_r, b_high_r;

always @(posedge clk)
begin
    a_high_r <= a_high;
    //b_high_r <= b_high;    
end
assign c_high = a_high_r + b_high + carry_low_r;


endmodule



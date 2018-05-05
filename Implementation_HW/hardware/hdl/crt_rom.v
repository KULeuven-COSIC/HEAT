`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: a
// Engineer: 
// 
// Create Date:    14:26:09 06/16/2016 
// Design Name: 
// Module Name:    crt_rom 
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
module crt_rom #(parameter modular_index=5) (address, dataout);

input [2:0] address;
output [29:0] dataout;


generate
   if (modular_index==3'd0)
		mux8_30bits	rom(30'd65438, 30'd176129, 30'd94531, 30'd176482, 30'd246718, 30'd53024, 30'd0, 30'd0, address, dataout);
	else if (modular_index==3'd1)
		mux8_30bits	rom(30'd4901, 30'd73729, 30'd78275, 30'd179626, 30'd129727, 30'd31293, 30'd0, 30'd0, address, dataout);
	else if (modular_index==3'd2)
		mux8_30bits	rom(30'd154847, 30'd159745, 30'd44611, 30'd37934, 30'd125673, 30'd47722, 30'd0, 30'd0, address, dataout);
	else if (modular_index==3'd3)
		mux8_30bits	rom(30'd118688, 30'd147457, 30'd8515, 30'd170687, 30'd6029, 30'd44393, 30'd0, 30'd0, address, dataout);
	else if (modular_index==3'd4)
		mux8_30bits	rom(30'd30224, 30'd139265, 30'd247235, 30'd80394, 30'd2742, 30'd42420, 30'd0, 30'd0, address, dataout);
	else	
		mux8_30bits	rom(30'd142002, 30'd135169, 30'd235715, 30'd117579, 30'd220519, 30'd41497, 30'd0, 30'd0, address, dataout);
endgenerate


endmodule

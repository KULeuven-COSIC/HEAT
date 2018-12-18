`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: a
// Engineer: 
// 
// Create Date:    14:28:31 06/16/2016 
// Design Name: 
// Module Name:    mux8_18bits 
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
/*
module mux8_18bits(in1, in2, in3, in4, in5, in6, in7, in8,sel, out);
input [17:0] in1, in2, in3, in4, in5, in6, in7, in8;
input [2:0] sel;
output [17:0] out;

assign out = (sel==3'd0) ? in1
				:(sel==3'd1) ? in2
				:(sel==3'd2) ? in3
				:(sel==3'd3) ? in4
				:(sel==3'd4) ? in5
				:(sel==3'd5) ? in6
				:(sel==3'd6) ? in7
				:in8;
				
endmodule
*/

module mux8_30bits(in1, in2, in3, in4, in5, in6, in7, in8,sel, out);
input [29:0] in1, in2, in3, in4, in5, in6, in7, in8;
input [2:0] sel;
output [29:0] out;

assign out = (sel==3'd0) ? in1
				:(sel==3'd1) ? in2
				:(sel==3'd2) ? in3
				:(sel==3'd3) ? in4
				:(sel==3'd4) ? in5
				:(sel==3'd5) ? in6
				:(sel==3'd6) ? in7
				:in8;
				
endmodule


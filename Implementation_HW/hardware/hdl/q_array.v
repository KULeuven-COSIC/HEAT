`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:16:08 05/21/2017 
// Design Name: 
// Module Name:    qs_array 
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
module qs_array(clk, sel, qs_word);
input clk;
input [5:0] sel;

output reg [58:0] qs_word;

wire [58:0] qs_word_wire;

assign qs_word_wire = 
						(sel==6'd0) ? 59'd34152170140925953 :
						(sel==6'd1) ? 59'd444374133218821435 :
						(sel==6'd2) ? 59'd487512997152645794 :
						(sel==6'd3) ? 59'd145266018071494356 :
						(sel==6'd4) ? 59'd250335040473236502 :
						(sel==6'd5) ? 59'd543897856481800353 :
						(sel==6'd6) ? 59'd349039569536075659 :
						(sel==6'd7) ? 59'd501789829997767770 :
						(sel==6'd8) ? 59'd551414956817062285 :
						(sel==6'd9) ? 59'd24509987548147633 :
						(sel==6'd10) ? 59'd449180600184380882 :
						(sel==6'd11) ? 59'd401613062390743101 :
						(sel==6'd12) ? 59'd157276307947514199 :
						(sel==6'd13) ? 59'd510813978440401562 :
						(sel==6'd14) ? 59'd512570135333756073 :
						(sel==6'd15) ? 59'd335931810173693039 :
						(sel==6'd16) ? 59'd413042890894122509 :
						(sel==6'd17) ? 59'd212485532342988167 :
						(sel==6'd18) ? 59'd307702571462986180 :
						(sel==6'd19) ? 59'd177077087796176018 :
						(sel==6'd20) ? 59'd148420268329261 : 
						59'd0; 

always @(posedge clk)
	qs_word <= qs_word_wire;

endmodule
*/


module qs_array_q180bit(clk, sel, qs_word);
input clk;
input [5:0] sel;

output reg [58:0] qs_word;

wire [58:0] qs_word_wire;

assign qs_word_wire = 
						(sel==6'd0) ? 59'd393394748469346305:
						(sel==6'd1) ? 59'd417767552804925659:
						(sel==6'd2) ? 59'd506224710668493737:
						(sel==6'd3) ? 59'd7:
						59'd0;

always @(posedge clk)
	qs_word <= qs_word_wire;

endmodule





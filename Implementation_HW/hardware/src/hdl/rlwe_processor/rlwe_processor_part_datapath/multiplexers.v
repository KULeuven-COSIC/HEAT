`timescale 1ns / 1ps

module mux2_30bits(in1, in2, sel, out);

input [29:0] in1, in2;
input sel;
output [29:0] out;

assign out = (sel==0) ? in1 : in2;

endmodule

////

module mux4_30bits_special(in1, in2, in3, in4, sel2, primsel, out);

input [29:0] in1, in2, in3, in4;
input [1:0] sel2;
input primsel;
output [29:0] out;

assign out = (sel2==2'd0) ? in1
				:(sel2==2'd1) ? in2
				:(sel2==2'd2) ? in3
				:in4;
endmodule

////

module mux4_30bits(in1, in2, in3, in4, sel, out);

input [29:0] in1, in2, in3, in4;
input [1:0] sel;
output [29:0] out;

assign out = (sel==2'd0) ? in1
				:(sel==2'd1) ? in2
				:(sel==2'd2) ? in3
				:in4;
				
endmodule

////

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

////

module mux16_30bits(in1, in2, in3, in4, in5, in6, in7, in8, 
						  in9, in10, in11, in12, in13, in14, in15, in16, sel, out);
input [29:0] in1, in2, in3, in4, in5, in6, in7, in8;
input [29:0] in9, in10, in11, in12, in13, in14, in15, in16;
input [3:0] sel;
output [29:0] out;

assign out = (sel==4'd0) ? in1
				:(sel==4'd1) ? in2
				:(sel==4'd2) ? in3
				:(sel==4'd3) ? in4
				:(sel==4'd4) ? in5
				:(sel==4'd5) ? in6
				:(sel==4'd6) ? in7
				:(sel==4'd7) ? in8
				:(sel==4'd8) ? in9
				:(sel==4'd9) ? in10
				:(sel==4'd10) ? in11
				:(sel==4'd11) ? in12
				:(sel==4'd12) ? in13
				:(sel==4'd13) ? in14
				:(sel==4'd14) ? in15
				:in16;
				
endmodule

////

module mux3_30bits(in1, in2, in3, sel, out);
input [29:0] in1, in2, in3;
input [1:0] sel;
output [29:0] out;

assign out = (sel==2'd0) ? in1 : (sel==2'd1) ? in2 : in3;

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:15:46 08/27/2017 
// Design Name: 
// Module Name:    window_reduction60bit 
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:45:45 06/06/2016 
// Design Name: 
// Module Name:    windowed_reduction_q147457 
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
//long long int q = 147457;
//long long int q = 249857;
//long long int q = 163841;
//long long int q = 176129;
//long long int q = 184321;
//long long int q = 188417;
//1063321601
module windowed_reduction60bit #(parameter modular_index=6) (clk, modulus_sel, in, out);
input clk;
input modulus_sel;
input [59:0] in;
output reg [29:0] out;	// modular_index is 0 to 5 for the 6 different moduli

reg [29:0] out1;
wire [53:0] w1_S = in[53:0];
wire [53:0] w1_L = in[53:0];
wire [29:0] T1_S_out, T2_S_out, T3_S_out, T4_S_out, T5_S_out, T6_S_out;
wire [29:0] T1_L_out, T2_L_out, T3_L_out, T4_L_out, T5_L_out, T6_L_out;

//1068564481, 1069219841, 1070727169, 1071513601, 1072496641, 1073479681
generate
   if (modular_index==3'd0)
		reduction_table_q1068564481 T1_S(in[59:54], T1_S_out);
	else if (modular_index==3'd1)	
		reduction_table_q1069219841 T1_S(in[59:54], T1_S_out);
	else if (modular_index==3'd2)	
		reduction_table_q1070727169 T1_S(in[59:54], T1_S_out);
	else if (modular_index==3'd3)	
		reduction_table_q1071513601 T1_S(in[59:54], T1_S_out);
	else if (modular_index==3'd4)	
		reduction_table_q1072496641 T1_S(in[59:54], T1_S_out);
	else if (modular_index==3'd5)	
		reduction_table_q1073479681 T1_S(in[59:54], T1_S_out);	
	else
		reduction_table_q1063321601 T1_S(in[59:54], T1_S_out);			
endgenerate
wire [54:0] w2_S = w1_S + (T1_S_out<<6'd24);
wire [48:0] w3_S = w2_S[48:0];

generate
   if (modular_index==3'd0)
		reduction_table_q1068433409 T1_L(in[59:54], T1_L_out);
	else if (modular_index==3'd1)	
		reduction_table_q1068236801 T1_L(in[59:54], T1_L_out);
	else if (modular_index==3'd2)	
		reduction_table_q1065811969 T1_L(in[59:54], T1_L_out);
	else if (modular_index==3'd3)	
		reduction_table_q1065484289 T1_L(in[59:54], T1_L_out);
	else if (modular_index==3'd4)	
		reduction_table_q1064697857 T1_L(in[59:54], T1_L_out);
	else if (modular_index==3'd5)	
		reduction_table_q1063452673 T1_L(in[59:54], T1_L_out);	
	else
		reduction_table_q1063321601 T1_L(in[59:54], T1_L_out);			
endgenerate
wire [54:0] w2_L = w1_L + (T1_L_out<<6'd24);
wire [48:0] w3_L = w2_L[48:0];

//-----------------------------------------------------------------------------


generate
   if (modular_index==3'd0)
		reduction_table_q1068564481 T2_S(w2_S[54:49], T2_S_out);	
	else if (modular_index==3'd1)	
		reduction_table_q1069219841 T2_S(w2_S[54:49], T2_S_out);
	else if (modular_index==3'd2)	
		reduction_table_q1070727169 T2_S(w2_S[54:49], T2_S_out);
	else if (modular_index==3'd3)	
		reduction_table_q1071513601 T2_S(w2_S[54:49], T2_S_out);
	else if (modular_index==3'd4)	
		reduction_table_q1072496641 T2_S(w2_S[54:49], T2_S_out);
	else if (modular_index==3'd5)
		reduction_table_q1073479681 T2_S(w2_S[54:49], T2_S_out);
	else
		reduction_table_q1063321601 T2_S(w2_S[54:49], T2_S_out);		
endgenerate

wire [49:0] w4_S_wire = w3_S + (T2_S_out<<6'd19);
reg [49:0] w4_S;
always @(posedge clk)
w4_S <= w4_S_wire;

wire [43:0] w5_S = w4_S[43:0];

generate
   if (modular_index==3'd0)
		reduction_table_q1068433409 T2_L(w2_L[54:49], T2_L_out);	
	else if (modular_index==3'd1)	
		reduction_table_q1068236801 T2_L(w2_L[54:49], T2_L_out);
	else if (modular_index==3'd2)	
		reduction_table_q1065811969 T2_L(w2_L[54:49], T2_L_out);
	else if (modular_index==3'd3)	
		reduction_table_q1065484289 T2_L(w2_L[54:49], T2_L_out);
	else if (modular_index==3'd4)	
		reduction_table_q1064697857 T2_L(w2_L[54:49], T2_L_out);
	else if (modular_index==3'd5)	
		reduction_table_q1063452673 T2_L(w2_L[54:49], T2_L_out);
	else
		reduction_table_q1063321601 T2_L(w2_L[54:49], T2_L_out);		
endgenerate

wire [49:0] w4_L_wire = w3_L + (T2_L_out<<6'd19);
reg [49:0] w4_L;
always @(posedge clk)
w4_L <= w4_L_wire;

wire [43:0] w5_L = w4_L[43:0];

//-----------------------------------------------------------------------------


generate
   if (modular_index==3'd0)
		reduction_table_q1068564481 T3_S(w4_S[49:44], T3_S_out);		
	else if (modular_index==3'd1)	
		reduction_table_q1069219841 T3_S(w4_S[49:44], T3_S_out);
	else if (modular_index==3'd2)	
		reduction_table_q1070727169 T3_S(w4_S[49:44], T3_S_out);
	else if (modular_index==3'd3)	
		reduction_table_q1071513601 T3_S(w4_S[49:44], T3_S_out);
	else if (modular_index==3'd4)	
		reduction_table_q1072496641 T3_S(w4_S[49:44], T3_S_out);
	else if (modular_index==3'd5)
		reduction_table_q1073479681 T3_S(w4_S[49:44], T3_S_out);
	else 
		reduction_table_q1063321601 T3_S(w4_S[49:44], T3_S_out);		
endgenerate
wire [44:0] w6_S = w5_S + (T3_S_out<<6'd14);
wire [38:0] w7_S = w6_S[38:0];

generate
   if (modular_index==3'd0)
		reduction_table_q1068433409 T3_L(w4_L[49:44], T3_L_out);		
	else if (modular_index==3'd1)	
		reduction_table_q1068236801 T3_L(w4_L[49:44], T3_L_out);
	else if (modular_index==3'd2)	
		reduction_table_q1065811969 T3_L(w4_L[49:44], T3_L_out);
	else if (modular_index==3'd3)	
		reduction_table_q1065484289 T3_L(w4_L[49:44], T3_L_out);
	else if (modular_index==3'd4)	
		reduction_table_q1064697857 T3_L(w4_L[49:44], T3_L_out);
	else if (modular_index==3'd5)	
		reduction_table_q1063452673 T3_L(w4_L[49:44], T3_L_out);
	else
		reduction_table_q1063321601 T3_L(w4_L[49:44], T3_L_out);		
endgenerate
wire [44:0] w6_L = w5_L + (T3_L_out<<6'd14);
wire [38:0] w7_L = w6_L[38:0];

//-----------------------------------------------------------------------------


generate
   if (modular_index==3'd0)
		reduction_table_q1068564481 T4_S(w6_S[44:39], T4_S_out);		
	else if (modular_index==3'd1)	
		reduction_table_q1069219841 T4_S(w6_S[44:39], T4_S_out);
	else if (modular_index==3'd2)	
		reduction_table_q1070727169 T4_S(w6_S[44:39], T4_S_out);
	else if (modular_index==3'd3)	
		reduction_table_q1071513601 T4_S(w6_S[44:39], T4_S_out);
	else if (modular_index==3'd4)	
		reduction_table_q1072496641 T4_S(w6_S[44:39], T4_S_out);
	else if (modular_index==3'd5)	
		reduction_table_q1073479681 T4_S(w6_S[44:39], T4_S_out);
	else
		reduction_table_q1063321601 T4_S(w6_S[44:39], T4_S_out);		
endgenerate
wire [39:0] w8_S = w7_S + (T4_S_out<<6'd9);


generate
   if (modular_index==3'd0)
		reduction_table_q1068433409 T4_L(w6_L[44:39], T4_L_out);		
	else if (modular_index==3'd1)	
		reduction_table_q1068236801 T4_L(w6_L[44:39], T4_L_out);
	else if (modular_index==3'd2)	
		reduction_table_q1065811969 T4_L(w6_L[44:39], T4_L_out);
	else if (modular_index==3'd3)	
		reduction_table_q1065484289 T4_L(w6_L[44:39], T4_L_out);
	else if (modular_index==3'd4)	
		reduction_table_q1064697857 T4_L(w6_L[44:39], T4_L_out);
	else if (modular_index==3'd5)	
		reduction_table_q1063452673 T4_L(w6_L[44:39], T4_L_out);
	else
		reduction_table_q1063321601 T4_L(w6_L[44:39], T4_L_out);		
endgenerate
wire [39:0] w8_L = w7_L + (T4_L_out<<6'd9);


//-----------------------------------------------------------------------------


wire [33:0] w9_S = w8_S[33:0];
wire [33:0] w9_L = w8_L[33:0];

generate
   if (modular_index==3'd0)
		reduction_table_q1068564481 T5_S(w8_S[39:34], T5_S_out);		
	else if (modular_index==3'd1)	
		reduction_table_q1069219841 T5_S(w8_S[39:34], T5_S_out);
	else if (modular_index==3'd2)	
		reduction_table_q1070727169 T5_S(w8_S[39:34], T5_S_out);
	else if (modular_index==3'd3)	
		reduction_table_q1071513601 T5_S(w8_S[39:34], T5_S_out);
	else if (modular_index==3'd4)	
		reduction_table_q1072496641 T5_S(w8_S[39:34], T5_S_out);
	else if (modular_index==3'd5)
		reduction_table_q1073479681 T5_S(w8_S[39:34], T5_S_out);
	else
		reduction_table_q1063321601 T5_S(w8_S[39:34], T5_S_out);		
endgenerate
wire [34:0] w10_S_wire = w9_S + (T5_S_out<<6'd4);
reg [34:0] w10_S;

always @(posedge clk)
w10_S <= w10_S_wire;

wire [29:0] w11_S = w10_S[29:0];


generate
   if (modular_index==3'd0)
		reduction_table_q1068433409 T5_L(w8_L[39:34], T5_L_out);		
	else if (modular_index==3'd1)	
		reduction_table_q1068236801 T5_L(w8_L[39:34], T5_L_out);
	else if (modular_index==3'd2)	
		reduction_table_q1065811969 T5_L(w8_L[39:34], T5_L_out);
	else if (modular_index==3'd3)	
		reduction_table_q1065484289 T5_L(w8_L[39:34], T5_L_out);
	else if (modular_index==3'd4)	
		reduction_table_q1064697857 T5_L(w8_L[39:34], T5_L_out);
	else if (modular_index==3'd5)	
		reduction_table_q1063452673 T5_L(w8_L[39:34], T5_L_out);
	else
		reduction_table_q1063321601 T5_L(w8_L[39:34], T5_L_out);		
endgenerate
wire [34:0] w10_L_wire = w9_L + (T5_L_out<<6'd4);
reg [34:0] w10_L;

always @(posedge clk)
w10_L <= w10_L_wire;

wire [29:0] w11_L = w10_L[29:0];

//-----------------------------------------------------------------------------


generate
   if (modular_index==3'd0)
		reduction_table_q1068564481 T6_S({1'b0,w10_S[34:30]}, T6_S_out);	
	else if (modular_index==3'd1)	
		reduction_table_q1069219841 T6_S({1'b0,w10_S[34:30]}, T6_S_out);
	else if (modular_index==3'd2)	
		reduction_table_q1070727169 T6_S({1'b0,w10_S[34:30]}, T6_S_out);
	else if (modular_index==3'd3)	
		reduction_table_q1071513601 T6_S({1'b0,w10_S[34:30]}, T6_S_out);
	else if (modular_index==3'd4)	
		reduction_table_q1072496641 T6_S({1'b0,w10_S[34:30]}, T6_S_out);
	else if (modular_index==3'd5)	
		reduction_table_q1073479681 T6_S({1'b0,w10_S[34:30]}, T6_S_out);
	else
		reduction_table_q1063321601 T6_S({1'b0,w10_S[34:30]}, T6_S_out);		
endgenerate
wire [30:0] w12_S = w11_S + T6_S_out;
wire [31:0] w13_S, w14_S;

generate
   if (modular_index==3'd0)
		reduction_table_q1068433409 T6_L({1'b0,w10_L[34:30]}, T6_L_out);	
	else if (modular_index==3'd1)	
		reduction_table_q1068236801 T6_L({1'b0,w10_L[34:30]}, T6_L_out);
	else if (modular_index==3'd2)	
		reduction_table_q1065811969 T6_L({1'b0,w10_L[34:30]}, T6_L_out);
	else if (modular_index==3'd3)	
		reduction_table_q1065484289 T6_L({1'b0,w10_L[34:30]}, T6_L_out);
	else if (modular_index==3'd4)	
		reduction_table_q1064697857 T6_L({1'b0,w10_L[34:30]}, T6_L_out);
	else if (modular_index==3'd5)	
		reduction_table_q1063452673 T6_L({1'b0,w10_L[34:30]}, T6_L_out);
	else
		reduction_table_q1063321601 T6_L({1'b0,w10_L[34:30]}, T6_L_out);		
endgenerate
wire [30:0] w12_L = w11_L + T6_L_out;
wire [31:0] w13_L, w14_L;

//-----------------------------------------------------------------------------



//1068564481, 1069219841, 1070727169, 1071513601, 1072496641, 1073479681
generate
   if (modular_index==3'd0)
		begin
			assign w13_S = w12_S - 30'd1068564481;
			assign w14_S = w12_S - {30'd1068564481,1'b0};			
		end
	else if (modular_index==3'd1)	
		begin
			assign w13_S = w12_S - 30'd1069219841;
			assign w14_S = w12_S - {30'd1069219841,1'b0};
		end
	else if (modular_index==3'd2)	
		begin
			assign w13_S = w12_S - 30'd1070727169;
			assign w14_S = w12_S - {30'd1070727169,1'b0};
		end
	else if (modular_index==3'd3)	
		begin
			assign w13_S = w12_S - 30'd1071513601;
			assign w14_S = w12_S - {30'd1071513601,1'b0};
		end
	else if (modular_index==3'd4)	
		begin
			assign w13_S = w12_S - 30'd1072496641;
			assign w14_S = w12_S - {30'd1072496641,1'b0};
		end
	else if (modular_index==3'd5)	
		begin
			assign w13_S = w12_S - 30'd1073479681;
			assign w14_S = w12_S - {30'd1073479681,1'b0};
		end
	else 
		begin
			assign w13_S = w12_S - 30'd1063321601;
			assign w14_S = w12_S - {30'd1063321601,1'b0};
		end		
endgenerate


//1068433409, 1068236801, 1065811969, 1065484289, 1064697857, 1063452673
generate
   if (modular_index==3'd0)
		begin
			assign w13_L = w12_L - 30'd1068433409;
			assign w14_L = w12_L - {30'd1068433409,1'b0};			
		end
	else if (modular_index==3'd1)	
		begin
			assign w13_L = w12_L - 30'd1068236801;
			assign w14_L = w12_L - {30'd1068236801,1'b0};
		end
	else if (modular_index==3'd2)	
		begin
			assign w13_L = w12_L - 30'd1065811969;
			assign w14_L = w12_L - {30'd1065811969,1'b0};
		end
	else if (modular_index==3'd3)	
		begin
			assign w13_L = w12_L - 30'd1065484289;
			assign w14_L = w12_L - {30'd1065484289,1'b0};
		end
	else if (modular_index==3'd4)	
		begin
			assign w13_L = w12_L - 30'd1064697857;
			assign w14_L = w12_L - {30'd1064697857,1'b0};
		end
	else if (modular_index==3'd5)
		begin
			assign w13_L = w12_L - 30'd1063452673;
			assign w14_L = w12_L - {30'd1063452673,1'b0};
		end
	else
		begin
			assign w13_L = w12_L - 30'd1063321601;
			assign w14_L = w12_L - {30'd1063321601,1'b0};
		end
endgenerate

wire [29:0] out_S_wire = (w14_S[31]==1'b0) ? w14_S[29:0]
							:(w13_S[31]==1'b0) ? w13_S[29:0]
							:w12_S[29:0];	

wire [29:0] out_L_wire = (w14_L[31]==1'b0) ? w14_L[29:0]
							:(w13_L[31]==1'b0) ? w13_L[29:0]
							:w12_L[29:0];
	
wire [29:0] out_wire = (modulus_sel) ? out_L_wire : out_S_wire;
	
always @(posedge clk)
out <= out_wire;

	
endmodule




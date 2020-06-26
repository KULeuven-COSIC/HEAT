`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/25/2018 12:22:32 PM
// Design Name: 
// Module Name: windowed_reduction60bit_q_select
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


module mux13_to_1(in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, sel, out);
input [29:0] in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12;
input [3:0] sel;
output [29:0] out;

assign out = (sel==4'd0) ? in0
                :(sel==4'd1) ? in1
                :(sel==4'd2) ? in2
                :(sel==4'd3) ? in3
                :(sel==4'd4) ? in4
                :(sel==4'd5) ? in5
                :(sel==4'd6) ? in6
                :(sel==4'd7) ? in7
                :(sel==4'd8) ? in8
                :(sel==4'd9) ? in9
                :(sel==4'd10) ? in10
                :(sel==4'd11) ? in11
                :in12;
endmodule


module windowed_reduction60bit_q_select (clk, q_sel, in, out);
input clk;
input [3:0] q_sel;
input [59:0] in;
output reg [29:0] out;    // modular_index is 0 to 5 for the 6 different moduli

reg [29:0] out1;
wire [53:0] w1_S = in[53:0];


wire [29:0] T1_q0_out, T1_q1_out, T1_q2_out, T1_q3_out, T1_q4_out, T1_q5_out, T1_q6_out;
wire [29:0] T1_q7_out, T1_q8_out, T1_q9_out, T1_q10_out, T1_q11_out, T1_q12_out, T1_out;

        reduction_table_q1068564481 T1_q0(in[59:54], T1_q0_out);
        reduction_table_q1069219841 T1_q1(in[59:54], T1_q1_out);
        reduction_table_q1070727169 T1_q2(in[59:54], T1_q2_out);
        reduction_table_q1071513601 T1_q3(in[59:54], T1_q3_out);
        reduction_table_q1072496641 T1_q4(in[59:54], T1_q4_out);
        reduction_table_q1073479681 T1_q5(in[59:54], T1_q5_out);
        reduction_table_q1068433409 T1_q6(in[59:54], T1_q6_out);
        reduction_table_q1068236801 T1_q7(in[59:54], T1_q7_out);
        reduction_table_q1065811969 T1_q8(in[59:54], T1_q8_out);
        reduction_table_q1065484289 T1_q9(in[59:54], T1_q9_out);
        reduction_table_q1064697857 T1_q10(in[59:54], T1_q10_out);
        reduction_table_q1063452673 T1_q11(in[59:54], T1_q11_out);
        reduction_table_q1063321601 T1_q12(in[59:54], T1_q12_out);

        mux13_to_1 T1(T1_q0_out, T1_q1_out, T1_q2_out, T1_q3_out, T1_q4_out, T1_q5_out, T1_q6_out,
                             T1_q7_out, T1_q8_out, T1_q9_out, T1_q10_out, T1_q11_out, T1_q12_out, q_sel, T1_out);

        wire [54:0] w2_S = w1_S + (T1_out<<6'd24);
        wire [48:0] w3_S = w2_S[48:0];



//-----------------------------------------------------------------------------

wire [29:0] T2_q0_out, T2_q1_out, T2_q2_out, T2_q3_out, T2_q4_out, T2_q5_out, T2_q6_out;
wire [29:0] T2_q7_out, T2_q8_out, T2_q9_out, T2_q10_out, T2_q11_out, T2_q12_out, T2_out;


        reduction_table_q1068564481 T2_q0(w2_S[54:49], T2_q0_out);
        reduction_table_q1069219841 T2_q1(w2_S[54:49], T2_q1_out);
        reduction_table_q1070727169 T2_q2(w2_S[54:49], T2_q2_out);
        reduction_table_q1071513601 T2_q3(w2_S[54:49], T2_q3_out);
        reduction_table_q1072496641 T2_q4(w2_S[54:49], T2_q4_out);
        reduction_table_q1073479681 T2_q5(w2_S[54:49], T2_q5_out);
        reduction_table_q1068433409 T2_q6(w2_S[54:49], T2_q6_out);
        reduction_table_q1068236801 T2_q7(w2_S[54:49], T2_q7_out);
        reduction_table_q1065811969 T2_q8(w2_S[54:49], T2_q8_out);
        reduction_table_q1065484289 T2_q9(w2_S[54:49], T2_q9_out);
        reduction_table_q1064697857 T2_q10(w2_S[54:49], T2_q10_out);
        reduction_table_q1063452673 T2_q11(w2_S[54:49], T2_q11_out);
        reduction_table_q1063321601 T2_q12(w2_S[54:49], T2_q12_out);

          mux13_to_1 T2(T2_q0_out, T2_q1_out, T2_q2_out, T2_q3_out, T2_q4_out, T2_q5_out, T2_q6_out,
                             T2_q7_out, T2_q8_out, T2_q9_out, T2_q10_out, T2_q11_out, T2_q12_out, q_sel, T2_out);

        wire [49:0] w4_S_wire = w3_S + (T2_out<<6'd19);
        reg [49:0] w4_S;
        reg [3:0] q_sel_1;

        always @(posedge clk)
        begin
            w4_S <= w4_S_wire;
            q_sel_1 <= q_sel;
        end

        wire [43:0] w5_S = w4_S[43:0];



//-----------------------------------------------------------------------------

wire [29:0] T3_q0_out, T3_q1_out, T3_q2_out, T3_q3_out, T3_q4_out, T3_q5_out, T3_q6_out;
wire [29:0] T3_q7_out, T3_q8_out, T3_q9_out, T3_q10_out, T3_q11_out, T3_q12_out, T3_out;


        reduction_table_q1068564481 T3_q0(w4_S[49:44], T3_q0_out);
        reduction_table_q1069219841 T3_q1(w4_S[49:44], T3_q1_out);
        reduction_table_q1070727169 T3_q2(w4_S[49:44], T3_q2_out);
        reduction_table_q1071513601 T3_q3(w4_S[49:44], T3_q3_out);
        reduction_table_q1072496641 T3_q4(w4_S[49:44], T3_q4_out);
        reduction_table_q1073479681 T3_q5(w4_S[49:44], T3_q5_out);
        reduction_table_q1068433409 T3_q6(w4_S[49:44], T3_q6_out);
        reduction_table_q1068236801 T3_q7(w4_S[49:44], T3_q7_out);
        reduction_table_q1065811969 T3_q8(w4_S[49:44], T3_q8_out);
        reduction_table_q1065484289 T3_q9(w4_S[49:44], T3_q9_out);
        reduction_table_q1064697857 T3_q10(w4_S[49:44], T3_q10_out);
        reduction_table_q1063452673 T3_q11(w4_S[49:44], T3_q11_out);
        reduction_table_q1063321601 T3_q12(w4_S[49:44], T3_q12_out);

          mux13_to_1 T3(T3_q0_out, T3_q1_out, T3_q2_out, T3_q3_out, T3_q4_out, T3_q5_out, T3_q6_out,
                             T3_q7_out, T3_q8_out, T3_q9_out, T3_q10_out, T3_q11_out, T3_q12_out, q_sel_1, T3_out);

        wire [44:0] w6_S = w5_S + (T3_out<<6'd14);
        wire [38:0] w7_S = w6_S[38:0];


//-----------------------------------------------------------------------------
wire [29:0] T4_q0_out, T4_q1_out, T4_q2_out, T4_q3_out, T4_q4_out, T4_q5_out, T4_q6_out;
wire [29:0] T4_q7_out, T4_q8_out, T4_q9_out, T4_q10_out, T4_q11_out, T4_q12_out, T4_out;


        reduction_table_q1068564481 T4_q0(w6_S[44:39], T4_q0_out);
        reduction_table_q1069219841 T4_q1(w6_S[44:39], T4_q1_out);
        reduction_table_q1070727169 T4_q2(w6_S[44:39], T4_q2_out);
        reduction_table_q1071513601 T4_q3(w6_S[44:39], T4_q3_out);
        reduction_table_q1072496641 T4_q4(w6_S[44:39], T4_q4_out);
        reduction_table_q1073479681 T4_q5(w6_S[44:39], T4_q5_out);
        reduction_table_q1068433409 T4_q6(w6_S[44:39], T4_q6_out);
        reduction_table_q1068236801 T4_q7(w6_S[44:39], T4_q7_out);
        reduction_table_q1065811969 T4_q8(w6_S[44:39], T4_q8_out);
        reduction_table_q1065484289 T4_q9(w6_S[44:39], T4_q9_out);
        reduction_table_q1064697857 T4_q10(w6_S[44:39], T4_q10_out);
        reduction_table_q1063452673 T4_q11(w6_S[44:39], T4_q11_out);
        reduction_table_q1063321601 T4_q12(w6_S[44:39], T4_q12_out);

          mux13_to_1 T4(T4_q0_out, T4_q1_out, T4_q2_out, T4_q3_out, T4_q4_out, T4_q5_out, T4_q6_out,
                             T4_q7_out, T4_q8_out, T4_q9_out, T4_q10_out, T4_q11_out, T4_q12_out, q_sel_1, T4_out);

wire [39:0] w8_S = w7_S + (T4_out<<6'd9);




//-----------------------------------------------------------------------------

wire [29:0] T5_q0_out, T5_q1_out, T5_q2_out, T5_q3_out, T5_q4_out, T5_q5_out, T5_q6_out;
wire [29:0] T5_q7_out, T5_q8_out, T5_q9_out, T5_q10_out, T5_q11_out, T5_q12_out, T5_out;

wire [33:0] w9_S = w8_S[33:0];

        reduction_table_q1068564481 T5_q0(w8_S[39:34], T5_q0_out);
        reduction_table_q1069219841 T5_q1(w8_S[39:34], T5_q1_out);
        reduction_table_q1070727169 T5_q2(w8_S[39:34], T5_q2_out);
        reduction_table_q1071513601 T5_q3(w8_S[39:34], T5_q3_out);
        reduction_table_q1072496641 T5_q4(w8_S[39:34], T5_q4_out);
        reduction_table_q1073479681 T5_q5(w8_S[39:34], T5_q5_out);
        reduction_table_q1068433409 T5_q6(w8_S[39:34], T5_q6_out);
        reduction_table_q1068236801 T5_q7(w8_S[39:34], T5_q7_out);
        reduction_table_q1065811969 T5_q8(w8_S[39:34], T5_q8_out);
        reduction_table_q1065484289 T5_q9(w8_S[39:34], T5_q9_out);
        reduction_table_q1064697857 T5_q10(w8_S[39:34], T5_q10_out);
        reduction_table_q1063452673 T5_q11(w8_S[39:34], T5_q11_out);
        reduction_table_q1063321601 T5_q12(w8_S[39:34], T5_q12_out);

          mux13_to_1 T5(T5_q0_out, T5_q1_out, T5_q2_out, T5_q3_out, T5_q4_out, T5_q5_out, T5_q6_out,
                             T5_q7_out, T5_q8_out, T5_q9_out, T5_q10_out, T5_q11_out, T5_q12_out, q_sel_1, T5_out);

wire [34:0] w10_S_wire = w9_S + (T5_out<<6'd4);
reg [34:0] w10_S;
reg [3:0] q_sel_2;

always @(posedge clk)
begin
    w10_S <= w10_S_wire;
    q_sel_2 <= q_sel_1;
end

wire [29:0] w11_S = w10_S[29:0];



//-----------------------------------------------------------------------------

wire [29:0] T6_q0_out, T6_q1_out, T6_q2_out, T6_q3_out, T6_q4_out, T6_q5_out, T6_q6_out;
wire [29:0] T6_q7_out, T6_q8_out, T6_q9_out, T6_q10_out, T6_q11_out, T6_q12_out, T6_out;

        reduction_table_q1068564481 T6_q0({1'b0,w10_S[34:30]}, T6_q0_out);
        reduction_table_q1069219841 T6_q1({1'b0,w10_S[34:30]}, T6_q1_out);
        reduction_table_q1070727169 T6_q2({1'b0,w10_S[34:30]}, T6_q2_out);
        reduction_table_q1071513601 T6_q3({1'b0,w10_S[34:30]}, T6_q3_out);
        reduction_table_q1072496641 T6_q4({1'b0,w10_S[34:30]}, T6_q4_out);
        reduction_table_q1073479681 T6_q5({1'b0,w10_S[34:30]}, T6_q5_out);
        reduction_table_q1068433409 T6_q6({1'b0,w10_S[34:30]}, T6_q6_out);
        reduction_table_q1068236801 T6_q7({1'b0,w10_S[34:30]}, T6_q7_out);
        reduction_table_q1065811969 T6_q8({1'b0,w10_S[34:30]}, T6_q8_out);
        reduction_table_q1065484289 T6_q9({1'b0,w10_S[34:30]}, T6_q9_out);
        reduction_table_q1064697857 T6_q10({1'b0,w10_S[34:30]}, T6_q10_out);
        reduction_table_q1063452673 T6_q11({1'b0,w10_S[34:30]}, T6_q11_out);
        reduction_table_q1063321601 T6_q12({1'b0,w10_S[34:30]}, T6_q12_out);

          mux13_to_1 T6(T6_q0_out, T6_q1_out, T6_q2_out, T6_q3_out, T6_q4_out, T6_q5_out, T6_q6_out,
                             T6_q7_out, T6_q8_out, T6_q9_out, T6_q10_out, T6_q11_out, T6_q12_out, q_sel_2, T6_out);

wire [30:0] w12_S = w11_S + T6_out;


//-----------------------------------------------------------------------------
wire [31:0] w13_S, w14_S;
wire [29:0] T7_out;

          mux13_to_1 T7(       30'd1068564481,
                                      30'd1069219841,
                                      30'd1070727169,
                                      30'd1071513601,
                                      30'd1072496641,
                                      30'd1073479681,
                                      30'd1068433409,
                                      30'd1068236801,
                                      30'd1065811969,
                                      30'd1065484289,
                                      30'd1064697857,
                                      30'd1063452673,
                                      30'd1063321601,
                                      q_sel_2, T7_out);



            assign w13_S = w12_S - T7_out;
            assign w14_S = w12_S - {T7_out,1'b0};

wire [29:0] out_wire =     (w14_S[31]==1'b0) ? w14_S[29:0] :
                           (w13_S[31]==1'b0) ? w13_S[29:0] : w12_S[29:0] ;


always @(posedge clk)
out <= out_wire;


endmodule


module windowed_reduction34bit_q_select (clk, q_sel, in, out);
input clk;
input [3:0] q_sel;
input [33:0] in;
output reg [29:0] out;    // modular_index is 0 to 5 for the 6 different moduli


wire [5:0] T1_in = {2'd0,in[33:30]};


wire [29:0] T1_q0_out, T1_q1_out, T1_q2_out, T1_q3_out, T1_q4_out, T1_q5_out, T1_q6_out;
wire [29:0] T1_q7_out, T1_q8_out, T1_q9_out, T1_q10_out, T1_q11_out, T1_q12_out, T1_out;

        reduction_table_q1068564481 T1_q0(T1_in, T1_q0_out);
        reduction_table_q1069219841 T1_q1(T1_in, T1_q1_out);
        reduction_table_q1070727169 T1_q2(T1_in, T1_q2_out);
        reduction_table_q1071513601 T1_q3(T1_in, T1_q3_out);
        reduction_table_q1072496641 T1_q4(T1_in, T1_q4_out);
        reduction_table_q1073479681 T1_q5(T1_in, T1_q5_out);
        reduction_table_q1068433409 T1_q6(T1_in, T1_q6_out);
        reduction_table_q1068236801 T1_q7(T1_in, T1_q7_out);
        reduction_table_q1065811969 T1_q8(T1_in, T1_q8_out);
        reduction_table_q1065484289 T1_q9(T1_in, T1_q9_out);
        reduction_table_q1064697857 T1_q10(T1_in, T1_q10_out);
        reduction_table_q1063452673 T1_q11(T1_in, T1_q11_out);
        reduction_table_q1063321601 T1_q12(T1_in, T1_q12_out);

        mux13_to_1 T1(T1_q0_out, T1_q1_out, T1_q2_out, T1_q3_out, T1_q4_out, T1_q5_out, T1_q6_out,
                             T1_q7_out, T1_q8_out, T1_q9_out, T1_q10_out, T1_q11_out, T1_q12_out, q_sel, T1_out);

        wire [30:0] w2_S = in[29:0] + T1_out;



//-----------------------------------------------------------------------------
wire [31:0] w13_S, w14_S;
wire [29:0] T7_out;

          mux13_to_1        T7(       30'd1068564481,
                                      30'd1069219841,
                                      30'd1070727169,
                                      30'd1071513601,
                                      30'd1072496641,
                                      30'd1073479681,
                                      30'd1068433409,
                                      30'd1068236801,
                                      30'd1065811969,
                                      30'd1065484289,
                                      30'd1064697857,
                                      30'd1063452673,
                                      30'd1063321601,
                                      q_sel, T7_out);



            assign w13_S = w2_S - T7_out;
            assign w14_S = w2_S - {T7_out,1'b0};

wire [29:0] out_wire =     (w14_S[31]==1'b0) ? w14_S[29:0] :
                           (w13_S[31]==1'b0) ? w13_S[29:0] : w2_S[29:0] ;


always @(posedge clk)
out <= out_wire;


endmodule
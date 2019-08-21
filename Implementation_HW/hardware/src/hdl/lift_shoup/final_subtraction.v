`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2018 02:26:10 PM
// Design Name: 
// Module Name: final_subtraction
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


module final_subtraction(clk, rst, mode, a_shares, a_shares_we, quo_x_q_mod_pi,
                         final_subtraction_result, final_subtraction_result_we);
input clk, rst;
input mode;     // If 0 then small lift (6 input coeff); If 1 then big ligt (7 input coeff);
input [29:0] a_shares;
input a_shares_we;  // write enable
input [29:0] quo_x_q_mod_pi; // comes 3 cycles after a_shares;

output [29:0] final_subtraction_result;
output final_subtraction_result_we;

reg [29:0] a_shares_r0, a_shares_r1, a_shares_r2; // as a_shares comes 3 cycles before quo_x_q_mod_pi
reg a_shares_we_r0, a_shares_we_r1, a_shares_we_r2, a_shares_we_r3;
reg final_subtraction_result_we_r0, final_subtraction_result_we_r1;
reg [29:0] final_subtraction_result_r;

always @(posedge clk)
begin
    a_shares_r0 <= a_shares; a_shares_r1 <= a_shares_r0; a_shares_r2 <= a_shares_r1;
    a_shares_we_r0 <= a_shares_we; a_shares_we_r1 <= a_shares_we_r0; a_shares_we_r2 <= a_shares_we_r1; a_shares_we_r3 <= a_shares_we_r2;
end

reg [2:0] q_sel;

always @(posedge clk)
begin
    if(rst)
        q_sel <= 3'd0;
    else if(q_sel==3'd6)
        q_sel <= 3'd0;
    else if(a_shares_we_r3)
        q_sel <= q_sel + 1'b1;
    else
        q_sel <= q_sel;            
end

wire [30:0] sub = a_shares_r2 - quo_x_q_mod_pi;
reg [30:0] sub_r;
wire [29:0] mod_value;

wire [2:0] q_sel_base;
wire [3:0] q_sel_in;
assign q_sel_base = (mode==1'b1) ? 3'd0 : 3'd6;
assign q_sel_in = q_sel + q_sel_base;

always @(posedge clk)
sub_r <= sub;

          mux13_to_1 modulus(         30'd1068564481,
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
                                      q_sel_in, mod_value);



wire [29:0] add_mod = sub_r + mod_value;

wire [29:0] mod_sub_result  = (sub_r[30]) ? add_mod : sub_r;

always @(posedge clk)
begin
    final_subtraction_result_r <= mod_sub_result;
    final_subtraction_result_we_r0 <= a_shares_we_r3;
end

assign final_subtraction_result = final_subtraction_result_r;
assign final_subtraction_result_we = final_subtraction_result_we_r0;

endmodule

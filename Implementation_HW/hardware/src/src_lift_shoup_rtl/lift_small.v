`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2018 10:25:55 AM
// Design Name: 
// Module Name: lift_small
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


module lift_small(clk, rst, mode, start, rd_addr, coeff_in,
                  final_subtraction_result, final_subtraction_result_addr, final_subtraction_result_we);
input clk;
input rst;
input mode;             // If 0 then small lift (6 input coeff); If 1 then big ligt (7 input coeff);
input start;            // This signal is set 1 after input data is ready.

output [2:0] rd_addr; 
input [29:0] coeff_in;

output [29:0] final_subtraction_result;
output reg [2:0] final_subtraction_result_addr;
output final_subtraction_result_we;

wire start_scaling;
wire [2:0] rd_addr_scaling;     // Coefficients are assumed to be in a RAM.
wire [29:0] coeff_in_scaling;   // A coefficient arrives one cycle after address.
wire [2:0] wt_addr_scaling;     // write address for output values
wire we_scaling;                // write enable for output values
wire [29:0] coeff_out_scaling;  // output coefficients

wire start_fixedpt;
reg start_fixedpt_r0, start_fixedpt_r1, start_fixedpt_r2, start_fixedpt_r3, start_fixedpt_r4, start_fixedpt_r5, start_fixedpt_r6, start_fixedpt_r7, start_fixedpt_r8;
wire [2:0] ext_addr_fixedpt;
wire ext_we_fixedpt;
wire [29:0] ext_din_fixedpt;   // Scaled data comes from outside and gets written in internal memory;
wire [3:0] rounded_sop;
wire rounded_sop_write;

wire sop_mod_qi_we;
wire [29:0] sop_mod_qi;
wire [29:0] quo_x_q_mod_pi;

wire start_quo_mod_pi;
reg start_quo_mod_pi_r0, start_quo_mod_pi_r1, start_quo_mod_pi_r2, start_quo_mod_pi_r3, start_quo_mod_pi_r4, start_quo_mod_pi_r5, start_quo_mod_pi_r6;
reg start_quo_mod_pi_r7, start_quo_mod_pi_r8, start_quo_mod_pi_r9, start_quo_mod_pi_r10, start_quo_mod_pi_r11, start_quo_mod_pi_r12, start_quo_mod_pi_r13, start_quo_mod_pi_r14;

/* Scaling of input shares */
assign start_scaling = start;
assign rd_addr = rd_addr_scaling;
assign coeff_in_scaling = coeff_in;

scale_a_shares  scaling(clk, rst, mode, start_scaling, rd_addr_scaling, coeff_in_scaling,
                        wt_addr_scaling, we_scaling, coeff_out_scaling);


/* SOP of fixed point constants */
assign ext_addr_fixedpt = wt_addr_scaling;
assign ext_we_fixedpt = we_scaling;
assign ext_din_fixedpt = coeff_out_scaling;

always @(posedge clk)
begin
    start_fixedpt_r0<=start_scaling; start_fixedpt_r1<=start_fixedpt_r0; start_fixedpt_r2<=start_fixedpt_r1; start_fixedpt_r3<=start_fixedpt_r2;
    start_fixedpt_r4<=start_fixedpt_r3; start_fixedpt_r5<=start_fixedpt_r4; start_fixedpt_r6<=start_fixedpt_r5; start_fixedpt_r7<=start_fixedpt_r6;
    start_fixedpt_r8<=start_fixedpt_r7;
end
assign start_fixedpt = start_fixedpt_r8;
sum_fixedpt     fixedpt(clk, rst, mode, start_fixedpt, ext_addr_fixedpt, ext_we_fixedpt, ext_din_fixedpt, rounded_sop, rounded_sop_write);


/* 7 or 6 SOPs mod pi or qi */
sop_mod_qi sop_mod(
                clk,
                rst,
      
                // Mode of operation, should be sampled at data_valid
                mode,
            
                we_scaling,
                wt_addr_scaling,
                coeff_out_scaling,
                
                sop_mod_qi_we,
                sop_mod_qi
                );



/* Computation of rounded_sop*q mod pi */
always @(posedge clk)
begin
    start_quo_mod_pi_r0<=start_fixedpt; start_quo_mod_pi_r1<=start_quo_mod_pi_r0;start_quo_mod_pi_r2<=start_quo_mod_pi_r1; 
    start_quo_mod_pi_r3<=start_quo_mod_pi_r2; start_quo_mod_pi_r4<=start_quo_mod_pi_r3; start_quo_mod_pi_r5<=start_quo_mod_pi_r4;
    start_quo_mod_pi_r6<=start_quo_mod_pi_r5; start_quo_mod_pi_r7<=start_quo_mod_pi_r6; start_quo_mod_pi_r8<=start_quo_mod_pi_r7;
    start_quo_mod_pi_r9<=start_quo_mod_pi_r8; start_quo_mod_pi_r10<=start_quo_mod_pi_r9; start_quo_mod_pi_r11<=start_quo_mod_pi_r10;
    start_quo_mod_pi_r12<=start_quo_mod_pi_r11; start_quo_mod_pi_r13<=start_quo_mod_pi_r12; start_quo_mod_pi_r14<=start_quo_mod_pi_r13;
end
//assign start_quo_mod_pi = start_quo_mod_pi_r13;
assign start_quo_mod_pi = start_quo_mod_pi_r14;
v_x_q_mod_pi quo_mod_pi(clk, rst, mode, start_quo_mod_pi, rounded_sop, rounded_sop_write, quo_x_q_mod_pi);


/* Final modular subtraction */
final_subtraction fsub(clk, rst, mode, sop_mod_qi, sop_mod_qi_we, quo_x_q_mod_pi,
                         final_subtraction_result, final_subtraction_result_we);
                         

/* Write address and Bank selection */                         
always @(posedge clk)
begin
    if(rst)
        final_subtraction_result_addr <= 3'd0;
    else if(mode==1'b0 && final_subtraction_result_addr==3'd6 && final_subtraction_result_we==1'b1)
        final_subtraction_result_addr <= 3'd0;
    else if(mode==1'b1 && final_subtraction_result_addr==3'd5 && final_subtraction_result_we==1'b1)
        final_subtraction_result_addr <= 3'd0;
    else if(final_subtraction_result_we)
        final_subtraction_result_addr <= final_subtraction_result_addr + 1'b1;    
    else
        final_subtraction_result_addr <= final_subtraction_result_addr;    
end

                
endmodule

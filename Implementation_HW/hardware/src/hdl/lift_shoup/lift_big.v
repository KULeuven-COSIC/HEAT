`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2018 05:50:37 PM
// Design Name: 
// Module Name: lift_big
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


module lift_big(clk, rst, start, rd_addr_q, coeff_in_q, rd_addr_p, coeff_in_p, 
                result_mod_pi, result_mod_pi_addr, result_mod_pi_we );
input clk;
input rst;
input start;            // This signal is set 1 after input data is ready.

output [2:0] rd_addr_q; 
input [29:0] coeff_in_q;
output [2:0] rd_addr_p; 
input [29:0] coeff_in_p;

output [29:0] result_mod_pi; 
output reg [2:0] result_mod_pi_addr;
output result_mod_pi_we; 


wire [59:0] scaled_coeff_p;
reg [59:0] scaled_coeff_p_r0, scaled_coeff_p_r1;

wire [33:0] rounded_fixedpt;
reg [33:0] rounded_fixedpt_r0;
wire rounded_fixedpt_write;

wire start_mul_const, start_sum_fixedpt;

wire [62:0] integer_part_out;
wire integer_part_out_valid;
reg [62:0] integer_part_out_r0, integer_part_out_r1;
reg [63:0] rounded_real, rounded_real_plus_scaled_coeff_p;

assign start_mul_const = start;
assign start_sum_fixedpt = start;

mult_const_blift    mul_const(clk, rst, start_mul_const, rd_addr_p, coeff_in_p, scaled_coeff_p);

sum_fixedpt_blift   sum_fixedpt(clk, rst, start_sum_fixedpt, rd_addr_q, coeff_in_q, rounded_fixedpt, rounded_fixedpt_write);
always @(posedge clk)
begin
    if(rounded_fixedpt_write)
        rounded_fixedpt_r0 <= rounded_fixedpt;
    else
        rounded_fixedpt_r0 <= rounded_fixedpt_r0;
end            

lift_big_sop        sop(clk, rst, start_mul_const, rd_addr_p, coeff_in_q, integer_part_out, integer_part_out_valid);
always @(posedge clk)   // two stage delay added to synchronize with rounded_fixedpt
begin
    integer_part_out_r0 <= integer_part_out;
    integer_part_out_r1 <= integer_part_out_r0;
end

    
always @(posedge clk)
rounded_real <= integer_part_out_r1 + rounded_fixedpt_r0;

always @(posedge clk)
rounded_real_plus_scaled_coeff_p <= scaled_coeff_p + rounded_real;







/* Final Reduction by pi*/ 
reg [3:0] q_sel;
wire [29:0] red_out;
reg rounded_fixedpt_write_r0, rounded_fixedpt_write_r1;
reg red_start;
reg result_mod_pi_we_r0, result_mod_pi_we_r1, result_mod_pi_we_r2;

always @(posedge clk)
begin
    rounded_fixedpt_write_r0<=rounded_fixedpt_write; rounded_fixedpt_write_r1<=rounded_fixedpt_write_r0;

    if(rst)
        red_start <= 1'b0;
    else if(integer_part_out_valid==1'b0)
        red_start <= 1'b0; 
    else if(rounded_fixedpt_write_r1)
        red_start <= 1'b1;
    else
        red_start <= red_start;    
end

always @(posedge clk)
begin
    if(rst)
        q_sel <= 4'd6;
    else if(q_sel==4'd12)
        q_sel <= 4'd6;    
    else if(red_start==1'b1 && start==1'b1)
        q_sel <= q_sel + 1'b1;
    else
        q_sel <= q_sel;
end
               
windowed_reduction64bit_q_select red(clk, q_sel, rounded_real_plus_scaled_coeff_p, red_out);

assign result_mod_pi = red_out;
assign result_mod_pi_we = result_mod_pi_we_r2;

always @(posedge clk)
begin
    result_mod_pi_we_r0 <= red_start; result_mod_pi_we_r1 <= result_mod_pi_we_r0; result_mod_pi_we_r2 <= result_mod_pi_we_r1;
end

always @(posedge clk)
begin
    if(rst)
        result_mod_pi_addr <= 3'd0;
    else if(result_mod_pi_addr==3'd6)
        result_mod_pi_addr <= 3'd0;      
    else if(result_mod_pi_we)
        result_mod_pi_addr <= result_mod_pi_addr + 1'b1;
    else
        result_mod_pi_addr <= 3'd0;      
end

endmodule

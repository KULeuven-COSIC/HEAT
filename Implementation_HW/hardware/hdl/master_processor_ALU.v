`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:25:04 12/03/2016 
// Design Name: 
// Module Name:    master_processor_ALU 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments:  a
//
//////////////////////////////////////////////////////////////////////////////////
module master_processor_ALU(clk, rst_alu, sign,  
									 prime_sel_inc, quot_addr_inc, a_addr_inc, qj_addr_inc, sel1, sel2, quot_we, a_we, mode,
									 ddr_data, div_quotient_c3, small_crt_result_c3, div_quotient_c11, small_crt_result_c11, 
									 alu_out, write_address_full);
input clk, rst_alu;
input sign;
input prime_sel_inc, quot_addr_inc, a_addr_inc, qj_addr_inc;
input [2:0] sel1;
input [1:0] sel2;
input quot_we, a_we;
input mode;				// This is used during the subtraction operation for direct address change without using the pipeline
input [59:0] ddr_data, div_quotient_c3, small_crt_result_c3, div_quotient_c11, small_crt_result_c11;
output reg [29:0] alu_out;
output write_address_full;

wire [59:0] mod_input, cm_out;
wire [29:0] mod_out, quot_out, a_out, qj_out, sub_out, m2_out, qj_minus_mod_out;
wire [30:0] barrett_constant;
wire [29:0] prime_constant;
wire prime_full, barrett_full, quot_addr_full;

reg [6:0] prime_sel, barrett_sel;
reg [5:0] quot_addr, a_addr, qj_addr;
reg prime_sel_inc_d1, prime_sel_inc_d2, prime_sel_inc_d3, prime_sel_inc_d4, prime_sel_inc_d5;
reg quot_we_d1, quot_we_d2, quot_we_d3, quot_we_d4, quot_we_d5, quot_we_d6, quot_we_d7, quot_we_d8, quot_we_d9, quot_we_d10, quot_we_d11, quot_we_d12, quot_we_d13;

reg a_addr_inc_d1, a_addr_inc_d2, a_addr_inc_d3, a_addr_inc_d4, a_addr_inc_d5, a_addr_inc_d6, a_addr_inc_d7, a_addr_inc_d8;
reg a_addr_inc_d9, a_addr_inc_d10, a_addr_inc_d11, a_addr_inc_d12, a_addr_inc_d13;

reg a_we_d1, a_we_d2, a_we_d3, a_we_d4, a_we_d5, a_we_d6, a_we_d7, a_we_d8, a_we_d9, a_we_d10, a_we_d11, a_we_d12, a_we_d13;

always @(posedge clk)
begin
	if(rst_alu==1'b1 || prime_full==1'b1)
		//prime_sel <= 7'd41;
		prime_sel <= 7'd6;
	else if((mode==1'b0 && prime_sel_inc_d5==1) || (mode==1'b1 && prime_sel_inc==1))
		prime_sel <= prime_sel + 1'b1;
	else
		prime_sel <= prime_sel;
end
//assign prime_full = (prime_sel==7'd47) ? 1'b1 : 1'b0;
assign prime_full = (prime_sel==7'd12) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
	if(rst_alu==1'b1 || barrett_full==1'b1)
		//barrett_sel <= 7'd41;
		barrett_sel <= 7'd6;
	else if(prime_sel_inc)
		barrett_sel <= barrett_sel + 1'b1;
	else
		barrett_sel <= barrett_sel;
end
//assign barrett_full = (barrett_sel==7'd83) ? 1'b1 : 1'b0;
assign barrett_full = (barrett_sel==7'd12) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
	if(rst_alu)
	begin
	prime_sel_inc_d1<=0; prime_sel_inc_d2<=0; prime_sel_inc_d3<=0; 
	prime_sel_inc_d4<=0; prime_sel_inc_d5<=0;
	end
	else
	begin
	prime_sel_inc_d1<=prime_sel_inc; prime_sel_inc_d2<=prime_sel_inc_d1;prime_sel_inc_d3<=prime_sel_inc_d2; 
	prime_sel_inc_d4<=prime_sel_inc_d3; prime_sel_inc_d5<=prime_sel_inc_d4;
	end
	
	quot_we_d1<=quot_we; quot_we_d2<=quot_we_d1; quot_we_d3<=quot_we_d2; quot_we_d4<=quot_we_d3; quot_we_d5<=quot_we_d4; quot_we_d6<=quot_we_d5;
	quot_we_d7<=quot_we_d6; quot_we_d8<=quot_we_d7; quot_we_d9<=quot_we_d8; quot_we_d10<=quot_we_d9; quot_we_d11<=quot_we_d10; quot_we_d12<=quot_we_d11; 	quot_we_d7<=quot_we_d6; quot_we_d8<=quot_we_d7; quot_we_d9<=quot_we_d8; quot_we_d10<=quot_we_d9; quot_we_d11<=quot_we_d10; quot_we_d12<=quot_we_d11;
	quot_we_d13<=quot_we_d12;
	
	a_addr_inc_d1<=a_addr_inc; a_addr_inc_d2<=a_addr_inc_d1; a_addr_inc_d3<=a_addr_inc_d2; a_addr_inc_d4<=a_addr_inc_d3; a_addr_inc_d5<=a_addr_inc_d4;
	a_addr_inc_d6<=a_addr_inc_d5; a_addr_inc_d7<=a_addr_inc_d6; a_addr_inc_d8<=a_addr_inc_d7; a_addr_inc_d9<=a_addr_inc_d8; a_addr_inc_d10<=a_addr_inc_d9;
	a_addr_inc_d11<=a_addr_inc_d10; a_addr_inc_d12<=a_addr_inc_d11; a_addr_inc_d13<=a_addr_inc_d12;

	a_we_d1<=a_we; a_we_d2<=a_we_d1; a_we_d3<=a_we_d2; a_we_d4<=a_we_d3; a_we_d5<=a_we_d4; a_we_d6<=a_we_d5; a_we_d7<=a_we_d6; a_we_d8<=a_we_d7;
	a_we_d9<=a_we_d8; a_we_d10<=a_we_d9; a_we_d11<=a_we_d10; a_we_d12<=a_we_d11; a_we_d13<=a_we_d12;

	
	if(rst_alu)
	begin
		a_addr_inc_d1<=0; a_addr_inc_d2<=0; a_addr_inc_d3<=0; a_addr_inc_d4<=0; a_addr_inc_d5<=0; a_addr_inc_d6<=0; a_addr_inc_d7<=0; a_addr_inc_d8<=0;
		a_addr_inc_d9<=0; a_addr_inc_d10<=0; a_addr_inc_d11<=0; a_addr_inc_d12<=0; a_addr_inc_d13<=0;
	end
	else
	begin
		a_addr_inc_d1<=a_addr_inc; a_addr_inc_d2<=a_addr_inc_d1; a_addr_inc_d3<=a_addr_inc_d2; a_addr_inc_d4<=a_addr_inc_d3; a_addr_inc_d5<=a_addr_inc_d4;
		a_addr_inc_d6<=a_addr_inc_d5; a_addr_inc_d7<=a_addr_inc_d6; a_addr_inc_d8<=a_addr_inc_d7; a_addr_inc_d9<=a_addr_inc_d8; a_addr_inc_d10<=a_addr_inc_d9;
		a_addr_inc_d11<=a_addr_inc_d10; a_addr_inc_d12<=a_addr_inc_d11; a_addr_inc_d13<=a_addr_inc_d12;	
	end
end 
always @(posedge clk)
begin
	if(rst_alu==1'b1 || quot_addr_full==1'b1)
		quot_addr <= 6'd0;
	else if(quot_we_d13)
		quot_addr <= quot_addr + 1'b1;
	else
		quot_addr <= quot_addr;
end
assign quot_addr_full = (quot_addr==6'd6) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
	if(rst_alu)
		a_addr <= 6'd0;
	else if((mode==1'b0 && a_addr_inc_d13==1'b1) || (mode==1'b1 && a_addr_inc==1'b1))
		a_addr <= a_addr + 1'b1;
	else
		a_addr <= a_addr;
end
always @(posedge clk)
begin
	if(rst_alu)
		qj_addr <= 6'd0;
	else if(qj_addr_inc)
		qj_addr <= qj_addr + 1'b1;
	else
		qj_addr <= qj_addr;
end

		
primes_rom prom(prime_sel, clk, prime_constant);
barrett_rom brom(barrett_sel, clk, barrett_constant);

assign mod_input = 
								(sel1==3'd0) ? ddr_data : 
								(sel1==3'd1) ? div_quotient_c3 :
								(sel1==3'd2) ? small_crt_result_c3 :
								(sel1==3'd3) ? cm_out :
								(sel1==3'd4) ? div_quotient_c11 :
								small_crt_result_c11;
								
modulo_reduction_master mod(clk, mod_input, prime_constant, barrett_constant, mod_out); 

quo_ram_dual quotient_ram(quot_addr, mod_out, qj_addr, clk, quot_we_d13, clk, quot_out);
//quo_ram_dual quotient_ram(quot_addr, mod_out, a_addr, clk, quot_we_d13, clk, quot_out);
quo_ram a_ram(a_addr, mod_out, clk, a_we_d13, a_out);
q_qj_rom qjr(qj_addr, clk, qj_out);


coefficient_multiplier_mproc cm(clk, qj_out, quot_out, cm_out);

//coefficient_multiplier_mproc cm(clk, qj_out, div_quotient_c3, cm_out);
//sub_mod_mproc	sm(clk, a_out, quot_out, prime_constant, sub_out);
sub_mod_mproc	sm(clk, small_crt_result_c3, quot_out, prime_constant, sub_out);

reg [29:0] prime_constant_d;
wire [29:0] qj_out_or_zero, sub_out1;
reg [29:0] qj_out_or_zero_reg;

always @(posedge clk)
prime_constant_d <= prime_constant;

assign qj_out_or_zero = (sign) ? qj_out : 30'd0;

always @(posedge clk)
qj_out_or_zero_reg <= qj_out_or_zero;

sub_mod_mproc	sm1(clk, sub_out, qj_out_or_zero_reg, prime_constant_d, sub_out1);

always @(posedge clk)
alu_out <= sub_out1;


//assign qj_minus_mod_out = prime_constant - mod_out;
//mux4x_30bit m2(sub_out1, qj_minus_mod_out, mod_out, 30'd0, sel2, m2_out);
//always @(posedge clk)
//alu_out <= m2_out;

//assign write_address_full = (a_addr==6'd42 || quot_addr==6'd42) ? 1'b1 : 1'b0;
assign write_address_full = (a_addr==6'd6 || quot_addr==6'd6) ? 1'b1 : 1'b0;

endmodule

/*
module mux4x_30bit(in0, in1, in2, in3, sel, out);
input [29:0] in0, in1, in2, in3;
input [1:0] sel;
output [29:0] out;

assign out = (sel==2'd0) ? in0 : (sel==2'd1) ? in1 : (sel==2'd2) ? in2 : in3;

endmodule
*/

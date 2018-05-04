`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:45:49 12/03/2016 
// Design Name: 
// Module Name:    master_processor 
// Project Name: a
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
// `default_nettype none

module master_processor(clk, reset_outside, rst, div_out_data_ready, sign,
								ddr_data, div_quotient_c3, small_crt_result_c3, div_quotient_c11, small_crt_result_c11,
								small_crt_data_ready_c3, small_crt_data_ready_c11,
								
								master_processor_out, bram_write_address, bram_core_index, bram_write_en,
								master_processor_done,
								
								//addrb_top, mproc_dram_data, 
								mproc_responds
								
								);
input clk, reset_outside, rst;
input div_out_data_ready;
input sign;
input [59:0] ddr_data, div_quotient_c3, small_crt_result_c3, div_quotient_c11, small_crt_result_c11;
input small_crt_data_ready_c3; 
input small_crt_data_ready_c11;

output [59:0] master_processor_out;
output reg [10:0] bram_write_address;
output reg [3:0] bram_core_index;
output bram_write_en;
output reg master_processor_done;			// becomes 1 after completion

//input [10:0] addrb_top;
//output [255:0] mproc_dram_data;

output reg mproc_responds;

wire [29:0] alu_out;
reg rst_alu, prime_sel_inc, quot_addr_inc, a_addr_inc, qj_addr_inc, quot_we, a_we;
reg [2:0] sel1;
reg [1:0] sel2;
reg [5:0] state, nextstate;
reg [6:0] counter;
reg rst_counter, inc_counter;
wire counter_is42, counter_is43, counter_is2, counter_is_greater39, counter_is_greater44, counter_is98;
wire write_address_full;	// Becomes 1 when the RAM write address is 42 in ALU
reg mode;
reg [59:0] div_quotient_c3_reg, div_quotient_c11_reg;

reg fifo1_rd_en, fifo2_rd_en; 
wire [59:0] fifo1_out, fifo2_out;
wire fifo1_full, fifo1_empty, fifo2_full, fifo2_empty;

reg rst_bram_write_address;
reg inc_bram_write_address, inc_bram_write_address_d1, inc_bram_write_address_d2, inc_bram_write_address_d3;
reg rst_bram_core_index, inc_bram_core_index;
reg inc_bram_core_index_d, inc_bram_core_index_d1;
wire bram_core_index_odd, bram_core_index_full;

always @(posedge clk)
begin
	if(div_out_data_ready==1'b1 && state==6'd0)
		div_quotient_c3_reg <= div_quotient_c3;
	else
		div_quotient_c3_reg <= div_quotient_c3_reg;
end
		
always @(posedge clk)
begin
	//if(state==6'd1 && bram_core_index[0]==1'b0 && counter==7'd0)
	if(state==6'd11 && bram_core_index[0]==1'b0)
		div_quotient_c11_reg <= div_quotient_c11;
	else
		div_quotient_c11_reg <= div_quotient_c11_reg;
end		

always @(posedge clk)
begin
	inc_bram_write_address_d1<=inc_bram_write_address; inc_bram_write_address_d2<=inc_bram_write_address_d1; inc_bram_write_address_d3<=inc_bram_write_address_d2;
	inc_bram_core_index_d <= inc_bram_core_index;
	inc_bram_core_index_d1 <= inc_bram_core_index_d;
	if(rst)
		bram_write_address<=11'd1024;
	else if(rst_bram_write_address)
		bram_write_address<=11'd1024;
	else if(inc_bram_write_address_d3)
		bram_write_address<=bram_write_address+1'b1;
	else
		bram_write_address<=bram_write_address;
		
	if(rst)	
		bram_core_index<=4'd0;
	else if(rst_bram_core_index)
		bram_core_index<=4'd0;	
	else if(inc_bram_core_index_d1)
		bram_core_index<=bram_core_index+1'b1;
	else
		bram_core_index<=bram_core_index;
end

assign bram_write_en = inc_bram_write_address_d3;
//assign bram_core_index_odd = bram_core_index[0];
assign bram_core_index_odd = 1'b0;
assign bram_core_index_full = (bram_core_index==4'd7) ? 1'b1 : 1'b0;

fifo128x_60bits fifo1(clk, rst, small_crt_result_c3, small_crt_data_ready_c3, fifo1_rd_en, fifo1_out, fifo1_full, fifo1_empty);
fifo128x_60bits fifo2(clk, rst, small_crt_result_c11, small_crt_data_ready_c11, fifo2_rd_en, fifo2_out, fifo2_full, fifo2_empty);
 
master_processor_ALU		ALU(clk, rst_alu, sign, 
                            prime_sel_inc, quot_addr_inc, a_addr_inc, qj_addr_inc, sel1, sel2, quot_we, a_we, mode,
									 ddr_data, div_quotient_c3_reg, fifo1_out, div_quotient_c11_reg, fifo2_out, 
									 alu_out, write_address_full);


always @(posedge clk)
begin
	if(rst)
		counter <= 7'd0;
	else if(rst_counter)
		counter <= 7'd0;
	else if(inc_counter)
		counter <= counter + 1'b1;
	else
		counter <= counter;
end
		
//assign counter_is42 = (counter==7'd42) ? 1'b1 : 1'b0;
assign counter_is42 = (counter==7'd6) ? 1'b1 : 1'b0;
assign counter_is43 = (counter==7'd7) ? 1'b1 : 1'b0;	
assign counter_is2 = (counter==7'd2) ? 1'b1 : 1'b0;
assign counter_is_greater39 = (counter > 7'd39) ? 1'b1 : 1'b0;
assign counter_is_greater44 = (counter > 7'd44) ? 1'b1 : 1'b0;
//assign counter_is98 = (counter==7'd85) ? 1'b1 : 1'b0;	
assign counter_is98 = (counter==7'd19) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
	if(rst)
		state <= 6'd0;
	else
		state <= nextstate;
end		


always @(state or counter_is2 or counter_is42 or counter_is_greater39 or counter_is_greater44 or bram_core_index_odd or bram_core_index_full)
begin
	case(state)
	6'd0: begin	// Idle
			rst_alu<=1; prime_sel_inc<=0; quot_addr_inc<=0; a_addr_inc<=0; qj_addr_inc<=0; sel1<=3'd0; sel2<=2'd0; quot_we<=0; a_we<=0;
			rst_counter<=1; inc_counter<=0; fifo1_rd_en<=0; fifo2_rd_en<=0; mode<=0;
			rst_bram_write_address<=1; inc_bram_write_address<=0; rst_bram_core_index<=0; inc_bram_core_index<=0;
			end
	
		
	// STEP1: Compute [a/q]_qj for j in (41,83)	
	6'd1: begin	
			rst_alu<=0; prime_sel_inc<=1; quot_addr_inc<=1; a_addr_inc<=0; sel2<=2'd0; quot_we<=1; a_we<=0;
			rst_counter<=0; inc_counter<=1; fifo1_rd_en<=0; fifo2_rd_en<=0; mode<=0;
			rst_bram_write_address<=1; inc_bram_write_address<=0; rst_bram_core_index<=0; inc_bram_core_index<=0;
			if(counter_is_greater39) qj_addr_inc<=1; else qj_addr_inc<=0;
			if(bram_core_index_odd) sel1<=3'd4; else sel1<=3'd1; 
			end
	6'd2: begin	// Wait for previous computation to finish || Compute [ [a/q]_qj*[q]_qj ]_qj
			rst_alu<=0; prime_sel_inc<=1; quot_addr_inc<=0; a_addr_inc<=0; qj_addr_inc<=1; sel2<=2'd0; quot_we<=0; a_we<=0;
			rst_counter<=0; inc_counter<=1; fifo1_rd_en<=0; fifo2_rd_en<=0; mode<=0;
			rst_bram_write_address<=0; inc_bram_write_address<=0; rst_bram_core_index<=0; inc_bram_core_index<=0;
			if(counter_is_greater44) sel1<=3'd3; else if(bram_core_index_odd) sel1<=3'd4; else sel1<=3'd1;	
			end
	
	// STEP2: Compute [ [a/q]_qj*[q]_qj ]_qj
	6'd3: begin	// Reset ALU
			rst_alu<=1; prime_sel_inc<=0; quot_addr_inc<=0; a_addr_inc<=0; qj_addr_inc<=0; sel1<=3'd0; sel2<=2'd0; quot_we<=0; a_we<=0;
			rst_counter<=1; inc_counter<=0; fifo1_rd_en<=0; fifo2_rd_en<=0; mode<=0;
			rst_bram_write_address<=0; inc_bram_write_address<=0; rst_bram_core_index<=0; inc_bram_core_index<=0;
			end	
	6'd4: begin	// Multiply  [ [a/q]_qj*[q]_qj ] 
			rst_alu<=0; prime_sel_inc<=0; quot_addr_inc<=0; a_addr_inc<=0; qj_addr_inc<=1; sel1<=3'd3; sel2<=2'd0; quot_we<=0; a_we<=0;
			inc_counter<=1; fifo1_rd_en<=0; fifo2_rd_en<=0; mode<=0;
			if(counter_is2) rst_counter<=1; else rst_counter<=0;  
			rst_bram_write_address<=0; inc_bram_write_address<=0; rst_bram_core_index<=0; inc_bram_core_index<=0;
			end			
	6'd5: begin	// Multiply and compute mod qj [ [a/q]_qj*[q]_qj ] 
			rst_alu<=0; prime_sel_inc<=1; quot_addr_inc<=1; a_addr_inc<=0; qj_addr_inc<=1; sel1<=3'd3; sel2<=2'd0; quot_we<=1; a_we<=0;
			rst_counter<=0; inc_counter<=1; fifo1_rd_en<=0; fifo2_rd_en<=0; mode<=0;
			rst_bram_write_address<=0; inc_bram_write_address<=0; rst_bram_core_index<=0; inc_bram_core_index<=0;
			end
	6'd6: begin	// Wait for computation to finish
			rst_alu<=0; prime_sel_inc<=0; quot_addr_inc<=0; a_addr_inc<=0; qj_addr_inc<=0; sel1<=3'd3; sel2<=2'd0; quot_we<=0; a_we<=0;
			rst_counter<=1; inc_counter<=0; fifo1_rd_en<=0; fifo2_rd_en<=0; mode<=0;
			rst_bram_write_address<=0; inc_bram_write_address<=0; rst_bram_core_index<=0; inc_bram_core_index<=0;
			end			
	
	// STEP3: Compute [a']_qj for j in (41,83) and store in 'a_ram'	
	6'd7: begin	// Reset ALU
			rst_alu<=1; prime_sel_inc<=0; quot_addr_inc<=0; a_addr_inc<=0; qj_addr_inc<=0; sel1<=3'd0; sel2<=2'd0; quot_we<=0; a_we<=0;
			rst_counter<=1; inc_counter<=0; fifo1_rd_en<=0; fifo2_rd_en<=0; mode<=0;
			rst_bram_write_address<=0; inc_bram_write_address<=0; rst_bram_core_index<=0; inc_bram_core_index<=0;
			end	
	6'd8: begin	
			rst_alu<=0; prime_sel_inc<=1; quot_addr_inc<=0; a_addr_inc<=1; qj_addr_inc<=0; sel2<=2'd0; quot_we<=0; a_we<=1;
			rst_counter<=0; inc_counter<=0; fifo1_rd_en<=0; fifo2_rd_en<=0; mode<=0;
			rst_bram_write_address<=0; inc_bram_write_address<=0; rst_bram_core_index<=0; inc_bram_core_index<=0;
			if(bram_core_index_odd) sel1<=3'd5; else sel1<=3'd2;
			end
	6'd9: begin	
			rst_alu<=0; prime_sel_inc<=1; quot_addr_inc<=0; a_addr_inc<=1; qj_addr_inc<=0; sel2<=2'd0; quot_we<=0; a_we<=1;
			rst_counter<=0; inc_counter<=1; mode<=0;
			rst_bram_write_address<=0; inc_bram_write_address<=0; rst_bram_core_index<=0; inc_bram_core_index<=0;
			if(bram_core_index_odd) begin fifo1_rd_en<=0; fifo2_rd_en<=1; sel1<=3'd5; end
			else begin fifo1_rd_en<=1; fifo2_rd_en<=0; sel1<=3'd2; end
			end			
	6'd10: begin	// Wait for computation to finish
			rst_alu<=0; prime_sel_inc<=0; quot_addr_inc<=0; a_addr_inc<=0; qj_addr_inc<=0; sel2<=2'd0; quot_we<=0; a_we<=0;
			rst_counter<=1; inc_counter<=0; fifo1_rd_en<=0; fifo2_rd_en<=0; mode<=0;
			rst_bram_write_address<=0; inc_bram_write_address<=0; rst_bram_core_index<=0; inc_bram_core_index<=0;
			if(bram_core_index_odd) sel1<=3'd5; else sel1<=3'd2;
			end	

	// STEP4: Compute [ [a']_qj - [a/q]_qj*[q]_qj ]_qj for j in (41,83) 	
	6'd11: begin	// Reset ALU
			rst_alu<=1; prime_sel_inc<=0; quot_addr_inc<=0; a_addr_inc<=0; qj_addr_inc<=0; sel1<=3'd0; sel2<=2'd0; quot_we<=0; a_we<=0;
			rst_counter<=1; inc_counter<=0; mode<=1;
			rst_bram_write_address<=1; inc_bram_write_address<=0; rst_bram_core_index<=0; inc_bram_core_index<=0;
			if(bram_core_index_odd) begin fifo1_rd_en<=0; fifo2_rd_en<=0; end	// Clear the extra data that appears in the tail of small-crt
			else begin fifo1_rd_en<=0; fifo2_rd_en<=0; end			
			end	
	6'd12: begin	// Subtraction 
			rst_alu<=0; prime_sel_inc<=1; quot_addr_inc<=0; a_addr_inc<=1; qj_addr_inc<=1; sel1<=3'd0; sel2<=2'd0; quot_we<=0; a_we<=0;
			rst_counter<=0; inc_counter<=1; fifo1_rd_en<=0; fifo2_rd_en<=0; mode<=1;
			rst_bram_write_address<=0; inc_bram_write_address<=0; rst_bram_core_index<=0; inc_bram_core_index<=0;
			end
	6'd13: begin	// Wait for computation to finish
			rst_alu<=0; prime_sel_inc<=1; quot_addr_inc<=0; a_addr_inc<=1; qj_addr_inc<=1; sel1<=3'd0; sel2<=2'd0; quot_we<=0; a_we<=0;
			rst_counter<=0; inc_counter<=1; fifo1_rd_en<=1; fifo2_rd_en<=0; mode<=1;
			rst_bram_write_address<=0; inc_bram_write_address<=1; rst_bram_core_index<=0; inc_bram_core_index<=0;
			end

	6'd62: begin	
			rst_alu<=0; prime_sel_inc<=0; quot_addr_inc<=0; a_addr_inc<=0; qj_addr_inc<=0; sel1<=3'd1; sel2<=2'd0; quot_we<=0; a_we<=0;
			rst_counter<=0; inc_counter<=0; fifo1_rd_en<=0; fifo2_rd_en<=0; mode<=1;
			rst_bram_write_address<=0; inc_bram_write_address<=0; rst_bram_core_index<=0; 
			inc_bram_core_index<=0;
			end

	6'd63: begin	
			rst_alu<=1; prime_sel_inc<=0; quot_addr_inc<=0; a_addr_inc<=0; qj_addr_inc<=0; sel1<=3'd1; sel2<=2'd0; quot_we<=0; a_we<=0;
			rst_counter<=1; inc_counter<=0; fifo1_rd_en<=0; fifo2_rd_en<=0; mode<=1;
			rst_bram_write_address<=0; inc_bram_write_address<=0; rst_bram_core_index<=0; 
			if(bram_core_index_full) inc_bram_core_index<=0; else inc_bram_core_index<=1;
			end

	default: begin	
			rst_alu<=1; prime_sel_inc<=0; quot_addr_inc<=0; a_addr_inc<=0; qj_addr_inc<=0; sel1<=3'd1; sel2<=2'd0; quot_we<=0; a_we<=0;
			rst_counter<=1; inc_counter<=0; fifo1_rd_en<=0; fifo2_rd_en<=0; mode<=1;
			rst_bram_write_address<=0; inc_bram_write_address<=0; rst_bram_core_index<=0; 
			inc_bram_core_index<=0; 
			end				
	endcase
end	

always @(state or div_out_data_ready or counter_is42 or counter_is43 or write_address_full or counter_is2 or counter_is98 or bram_core_index_full)
begin
	case(state)
/*	6'd0: begin
				if(div_out_data_ready)
					nextstate <= 6'd3;	// previously 1
				else
					nextstate <= 6'd0;
			end		*/
	//6'd0: nextstate <= 6'd3;		
	6'd0: begin
				if(div_out_data_ready)
					nextstate <= 6'd1;
				else
					nextstate <= 6'd0;
			end		
	6'd1: begin
				if(counter_is42)
					nextstate <= 6'd2;
				else 			
					nextstate <= 6'd1;
			end
	6'd2: begin
				if(counter_is98)
					nextstate <= 6'd3;
				else	
					nextstate <= 6'd2;
			end	

	// STEP 2	
	6'd3: nextstate <= 6'd4;
/*	6'd3: begin
				if(div_out_data_ready)
					nextstate <= 6'd4;	
				else
					nextstate <= 6'd3;
			end		*/
	6'd4: begin
				if(counter_is2)
					nextstate <= 6'd5;
				else
					nextstate <= 6'd4;
			end
	6'd5: begin
				if(counter_is42)
					nextstate <= 6'd6;
				else 			
					nextstate <= 6'd5;
			end
	6'd6: begin
				if(write_address_full)
					nextstate <= 6'd11;	// previously 7
				else	
					nextstate <= 6'd6;
			end
	// STEP 3
	6'd7: nextstate <= 6'd8;
	6'd8: nextstate <= 6'd9;	
	6'd9: begin
				if(counter_is42)
					nextstate <= 6'd10;
				else 			
					nextstate <= 6'd9;
			end
	6'd10: begin
				if(write_address_full)
					nextstate <= 6'd11;
				else	
					nextstate <= 6'd10;
			end
			

	// STEP 4
	6'd11: nextstate <= 6'd12;
	6'd12: nextstate <= 6'd13;	
	6'd13: begin
				if(counter_is43)
					nextstate <= 6'd62;
				else 
					nextstate <= 6'd13;
			end

	6'd62: nextstate <= 6'd63;	
	6'd63: begin
				if(bram_core_index_full)
					nextstate <= 6'd63;
				else
					nextstate <= 6'd0;
			end
	default: nextstate <= 6'd0;			
	endcase
end

assign master_processor_out = {30'd0, alu_out};
wire master_processor_done_wire = (state==6'd63 && bram_core_index_full==1'b1) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
	if(rst)
		master_processor_done <= 1'b0;
	else if(reset_outside)
		master_processor_done <= 1'b0;
	else if(master_processor_done_wire)
		master_processor_done <= 1'b1;
	else
		master_processor_done <= master_processor_done;
end		

/*
wire bram_write_en_lr0 = (bram_core_index==4'd0 && bram_write_en==1'b1) ? 1'b1 : 1'b0;
wire bram_write_en_lr1 = (bram_core_index==4'd1 && bram_write_en==1'b1) ? 1'b1 : 1'b0;
wire bram_write_en_lr2 = (bram_core_index==4'd2 && bram_write_en==1'b1) ? 1'b1 : 1'b0;
wire bram_write_en_lr3 = (bram_core_index==4'd3 && bram_write_en==1'b1) ? 1'b1 : 1'b0;
wire bram_write_en_lr4 = (bram_core_index==4'd4 && bram_write_en==1'b1) ? 1'b1 : 1'b0;
wire bram_write_en_lr5 = (bram_core_index==4'd5 && bram_write_en==1'b1) ? 1'b1 : 1'b0;
wire bram_write_en_lr6 = (bram_core_index==4'd6 && bram_write_en==1'b1) ? 1'b1 : 1'b0;
wire bram_write_en_lr7 = (bram_core_index==4'd7 && bram_write_en==1'b1) ? 1'b1 : 1'b0;

wire [29:0] data_out_lr0, qspo_lr0, data_out_lr1, qspo_lr1, data_out_lr2, qspo_lr2, data_out_lr3, qspo_lr3;
wire [29:0] data_out_lr4, qspo_lr4, data_out_lr5, qspo_lr5, data_out_lr6, qspo_lr6, data_out_lr7, qspo_lr7;
wire [5:0] addrb_top_part;
reg [5:0] address_lr0, address_lr1, address_lr2, address_lr3, address_lr4, address_lr5, address_lr6, address_lr7;

assign addrb_top_part = addrb_top[5:0];
assign mproc_dram_data = {2'd0,data_out_lr7, 2'd0,data_out_lr6, 2'd0,data_out_lr5, 2'd0,data_out_lr4, 2'd0,data_out_lr3, 2'd0,data_out_lr2, 2'd0,data_out_lr1, 2'd0,data_out_lr0};

always @(posedge clk)
begin
	if(rst)
		address_lr0 <= 6'd0;
	else if(bram_write_en_lr0)
		address_lr0 <= address_lr0 + 1'b1;
	else
		address_lr0 <= address_lr0;
end
always @(posedge clk)
begin
	if(rst)
		address_lr1 <= 6'd0;
	else if(bram_write_en_lr1)
		address_lr1 <= address_lr1 + 1'b1;
	else
		address_lr1 <= address_lr1;
end
always @(posedge clk)
begin
	if(rst)
		address_lr2 <= 6'd0;
	else if(bram_write_en_lr2)
		address_lr2 <= address_lr2 + 1'b1;
	else
		address_lr2 <= address_lr2;
end
always @(posedge clk)
begin
	if(rst)
		address_lr3 <= 6'd0;
	else if(bram_write_en_lr3)
		address_lr3 <= address_lr3 + 1'b1;
	else
		address_lr3 <= address_lr3;
end
always @(posedge clk)
begin
	if(rst)
		address_lr4 <= 6'd0;
	else if(bram_write_en_lr4)
		address_lr4 <= address_lr4 + 1'b1;
	else
		address_lr4 <= address_lr4;
end
always @(posedge clk)
begin
	if(rst)
		address_lr5 <= 6'd0;
	else if(bram_write_en_lr5)
		address_lr5 <= address_lr5 + 1'b1;
	else
		address_lr5 <= address_lr5;
end
always @(posedge clk)
begin
	if(rst)
		address_lr6 <= 6'd0;
	else if(bram_write_en_lr6)
		address_lr6 <= address_lr6 + 1'b1;
	else
		address_lr6 <= address_lr6;
end
always @(posedge clk)
begin
	if(rst)
		address_lr7 <= 6'd0;
	else if(bram_write_en_lr7)
		address_lr7 <= address_lr7 + 1'b1;
	else
		address_lr7 <= address_lr7;
end


mproc_local_dram lr0(
  .a(address_lr0), // input [5 : 0] a
  .d(alu_out), // input [29 : 0] d
  .dpra(addrb_top_part), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(bram_write_en_lr0), // input we
  .qdpo_clk(clk), // input qdpo_clk
  .qspo(qspo_lr0), // output [29 : 0] qspo
  .qdpo(data_out_lr0) // output [29 : 0] qdpo
);

mproc_local_dram lr1(
  .a(address_lr1), // input [5 : 0] a
  .d(alu_out), // input [29 : 0] d
  .dpra(addrb_top_part), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(bram_write_en_lr1), // input we
  .qdpo_clk(clk), // input qdpo_clk
  .qspo(qspo_lr1), // output [29 : 0] qspo
  .qdpo(data_out_lr1) // output [29 : 0] qdpo
);
	
mproc_local_dram lr2(
  .a(address_lr2), // input [5 : 0] a
  .d(alu_out), // input [29 : 0] d
  .dpra(addrb_top_part), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(bram_write_en_lr2), // input we
  .qdpo_clk(clk), // input qdpo_clk
  .qspo(qspo_lr2), // output [29 : 0] qspo
  .qdpo(data_out_lr2) // output [29 : 0] qdpo
);

mproc_local_dram lr3(
  .a(address_lr3), // input [5 : 0] a
  .d(alu_out), // input [29 : 0] d
  .dpra(addrb_top_part), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(bram_write_en_lr3), // input we
  .qdpo_clk(clk), // input qdpo_clk
  .qspo(qspo_lr3), // output [29 : 0] qspo
  .qdpo(data_out_lr3) // output [29 : 0] qdpo
);
	
mproc_local_dram lr4(
  .a(address_lr4), // input [5 : 0] a
  .d(alu_out), // input [29 : 0] d
  .dpra(addrb_top_part), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(bram_write_en_lr4), // input we
  .qdpo_clk(clk), // input qdpo_clk
  .qspo(qspo_lr4), // output [29 : 0] qspo
  .qdpo(data_out_lr4) // output [29 : 0] qdpo
);

mproc_local_dram lr5(
  .a(address_lr5), // input [5 : 0] a
  .d(alu_out), // input [29 : 0] d
  .dpra(addrb_top_part), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(bram_write_en_lr5), // input we
  .qdpo_clk(clk), // input qdpo_clk
  .qspo(qspo_lr5), // output [29 : 0] qspo
  .qdpo(data_out_lr5) // output [29 : 0] qdpo
);

mproc_local_dram lr6(
  .a(address_lr6), // input [5 : 0] a
  .d(alu_out), // input [29 : 0] d
  .dpra(addrb_top_part), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(bram_write_en_lr6), // input we
  .qdpo_clk(clk), // input qdpo_clk
  .qspo(qspo_lr6), // output [29 : 0] qspo
  .qdpo(data_out_lr6) // output [29 : 0] qdpo
);

mproc_local_dram lr7(
  .a(address_lr7), // input [5 : 0] a
  .d(alu_out), // input [29 : 0] d
  .dpra(addrb_top_part), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(bram_write_en_lr7), // input we
  .qdpo_clk(clk), // input qdpo_clk
  .qspo(qspo_lr7), // output [29 : 0] qspo
  .qdpo(data_out_lr7) // output [29 : 0] qdpo
);
*/
always @(posedge clk)
begin
	if(reset_outside)
		mproc_responds <= 1'b1;
	else if(state == 6'd13)
		mproc_responds <= 1'b0;
	else
		mproc_responds <= mproc_responds;
end

endmodule

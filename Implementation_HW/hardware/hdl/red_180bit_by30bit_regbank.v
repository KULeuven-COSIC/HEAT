`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:50:32 11/14/2017 
// Design Name: 
// Module Name:    red_180bit_by30bit_regbank 
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
module red_180bit_by30bit_regbank(clk, rst, reduction_type, din, din_valid, out_address,
								  //out_word1, out_word2, out_word3, out_word4, 
								  //out_word5, out_word6, out_word7, out_word8,

								  result_reg, result_write_address, result_write_reg, out_data_counter_reg,		
								  
								  done, done_test);
input clk;
input rst;
input reduction_type;	// If 0 then reduces 180 bit data by qi; else reduces 91 bit two words in two iterations.
input [59:0] din;
input din_valid;
input [4:0] out_address;

//output [29:0] out_word1, out_word2, out_word3, out_word4;
//output [29:0] out_word5, out_word6, out_word7, out_word8;

output reg [29:0] result_reg;
output reg [5:0] result_write_address;
output reg result_write_reg;
output reg [2:0] out_data_counter_reg;

output reg done;
output done_test;

reg rst1, inc1, rst2, inc2, rst3, inc3, m0sel, m3sel, addsub, rst_acc, rst_acc_d, only_multiply;
reg wen_acc_core1, wen_acc_core2, wen_acc_core3, wen_acc_core4;
reg [1:0] m1sel, m2sel;

// to delay wen for the pipelined multiplier with 3 stages; 
reg wen_acc_core1_d0, wen_acc_core1_d1, wen_acc_core1_d2;
reg wen_acc_core2_d0, wen_acc_core2_d1, wen_acc_core2_d2;
reg wen_acc_core3_d0, wen_acc_core3_d1, wen_acc_core3_d2;
reg wen_acc_core4_d0, wen_acc_core4_d1, wen_acc_core4_d2;

reg [4:0] addr0, addr1;
reg [9:0] addr2;
wire [59:0] mod_q_data_word;
wire [30:0] rom_word_core1, rom_word_core2, rom_word_core3, rom_word_core4;
wire [29:0] result;
reg sign_mod_q_data;
reg [2:0] wait_counter_state14;
wire wait_counter_state14_end;
wire wen_acc_core1_d2_or_wen_acc_core1, wen_acc_core2_d2_or_wen_acc_core2;
wire wen_acc_core3_d2_or_wen_acc_core3, wen_acc_core4_d2_or_wen_acc_core4;
wire [30:0] barrett_constant;
wire [29:0] prime;
reg [1:0] const_sel;
reg [1:0] wait_counter_state4;
wire wait_counter_state4_end;
// boundary signals
wire inRAM_filled;	// becomes 1 after the input 128 bit data is stored in the inRAM
wire mul_chain_finished;	// becomes 1 after the multiplication chain is finished.
wire addr3_end;
reg [2:0] out_data_counter;

reg [4:0] state, nextstate;

always @(posedge clk)
begin
	if(rst)
		addr0 <= 5'd0;
	//else if(addr0==5'd21)
	else if(state==5'd31)
		addr0 <= 5'd0;		
	else if(din_valid)
		addr0 <= addr0 + 1'b1;
	else
		addr0 <= addr0;
end
assign inRAM_filled = (addr0>5'd0) ? 1'b1 : 1'b0;
//assign mul_chain_finished = (addr1==5'd21) ? 1'b1 : 1'b0;
assign mul_chain_finished = (addr1==5'd4) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
	if(rst)
		addr1 <= 5'd0;
	else if(rst1)
		addr1 <= 5'd0;
	else if(inc1)
		addr1 <= addr1 + 1'b1;
	else
		addr1 <= addr1;
end

always @(posedge clk)
begin
	if(rst)
		addr2 <= 10'd0;
	else if(rst2)
		addr2 <= 10'd0;
	else if(inc2)
		addr2 <= addr2 + 1'b1;
	else
		addr2 <= addr2;
end

reg [179:0] mod_q_data_reg;
reg [5:0] addr1_delayed;
reg reduction_iteration_flag;

always @(posedge clk)
begin
	if(addr0==5'd0 && din_valid==1'b1)
		mod_q_data_reg[58:0] <= din[58:0];
	else if(addr0==5'd1 && din_valid==1'b1)
		mod_q_data_reg[117:59] <= din[58:0];
	else if(addr0==5'd2 && din_valid==1'b1)
		mod_q_data_reg[176:118] <= din[58:0];
	else if(addr0==5'd3 && din_valid==1'b1)
		mod_q_data_reg[179:177] <= din[2:0];
	else		
		mod_q_data_reg <= mod_q_data_reg;
end

always @(posedge clk)
addr1_delayed <= addr1;

always @(posedge clk)
begin
	if(rst)
		reduction_iteration_flag <=0;
	else if(reduction_type==1'b1 && (state==5'd19 || addr3_end==1'b1) )
		reduction_iteration_flag <= reduction_iteration_flag + 1'b1;
	else	
		reduction_iteration_flag <= reduction_iteration_flag;
end		
	
assign mod_q_data_word = (addr1_delayed==6'd0 && reduction_type==1'b0) ? {1'b0,mod_q_data_reg[58:0]}
                        :(addr1_delayed==6'd1 && reduction_type==1'b0) ? {1'b0,mod_q_data_reg[117:59]}
                        :(addr1_delayed==6'd2 && reduction_type==1'b0) ? {1'b0,mod_q_data_reg[176:118]}
								:(reduction_type==1'b0) ? {57'd0,mod_q_data_reg[179:177]}
								

								// first iteration: reduction of operand[90:0]
								:(addr1_delayed==6'd0 && reduction_type==1'b1 && reduction_iteration_flag==1'b0) ? {1'b0,mod_q_data_reg[58:0]}
								:(addr1_delayed==6'd1 && reduction_type==1'b1 && reduction_iteration_flag==1'b0) ? {28'd0,mod_q_data_reg[90:59]}								
								:(reduction_type==1'b1 && reduction_iteration_flag==1'b0) ? 60'd0

								// second iteration: reduction of operand[179:91]		
								:(addr1_delayed==6'd0 && reduction_type==1'b1 && reduction_iteration_flag==1'b1) ? {1'b0,mod_q_data_reg[149:91]}
								:(addr1_delayed==6'd1 && reduction_type==1'b1 && reduction_iteration_flag==1'b1) ? {30'd0,mod_q_data_reg[179:150]}								
								: 60'd0;

/*								
inRAM 	mod_q_data(
							  .a(addr0), // input [4 : 0] a
							  .d(din), // input [59 : 0] d
							  .dpra(addr1), // input [4 : 0] dpra
							  .clk(clk), // input clk
							  .we(din_valid), // input we
							  .qdpo(mod_q_data_word) // output [59 : 0] qdpo
							);
*/							
reg [5:0] addr3;
wire [5:0] out_address; 
wire out_en1, out_en2, out_en3, out_en4;
wire out_en5, out_en6, out_en7, out_en8;
wire [29:0] out_word1, out_word2, out_word3, out_word4;
reg state_18_d;

always @(posedge clk)
begin
	if(rst)
		state_18_d <= 1'b0;
	else if(state==5'd18)
		state_18_d <= 1'b1;
	else
		state_18_d<= 1'b0;
end

always @(posedge clk)
begin
	if(rst)
		addr3 <= 6'd0;
	else if(rst3)
		addr3 <= 6'd0;
	else if(out_en1 | out_en2 | out_en3 | out_en4 | out_en5 | out_en6 | out_en7 | out_en8)
		addr3 <= addr3 + 1'b1;
	else
		addr3 <= addr3;
end

always @(posedge clk)
result_reg <= result;

always @(posedge clk)
result_write_reg <= (state==5'd16 || state==5'd17 || state==5'd18 || state_18_d==1'b1);

always @(posedge clk)
begin
	if(rst)
		result_write_address <= 6'd0;
	else if(rst3)
		result_write_address <= 6'd0;
	else if(result_write_reg)
		result_write_address <= result_write_address + 1'b1;
	else
		result_write_address <= result_write_address;
end
		
assign out_en1 = ((state==5'd16 || state==5'd17 || state==5'd18 || state_18_d==1'b1) && out_data_counter==3'd0) ? 1'b1 : 1'b0;
assign out_en2 = ((state==5'd16 || state==5'd17 || state==5'd18 || state_18_d==1'b1) && out_data_counter==3'd1) ? 1'b1 : 1'b0;
assign out_en3 = ((state==5'd16 || state==5'd17 || state==5'd18 || state_18_d==1'b1) && out_data_counter==3'd2) ? 1'b1 : 1'b0;
assign out_en4 = ((state==5'd16 || state==5'd17 || state==5'd18 || state_18_d==1'b1) && out_data_counter==3'd3) ? 1'b1 : 1'b0;
assign out_en5 = ((state==5'd16 || state==5'd17 || state==5'd18 || state_18_d==1'b1) && out_data_counter==3'd4) ? 1'b1 : 1'b0;
assign out_en6 = ((state==5'd16 || state==5'd17 || state==5'd18 || state_18_d==1'b1) && out_data_counter==3'd5) ? 1'b1 : 1'b0;
assign out_en7 = ((state==5'd16 || state==5'd17 || state==5'd18 || state_18_d==1'b1) && out_data_counter==3'd6) ? 1'b1 : 1'b0;
assign out_en8 = ((state==5'd16 || state==5'd17 || state==5'd18 || state_18_d==1'b1) && out_data_counter==3'd7) ? 1'b1 : 1'b0;


always @(posedge clk)
begin
	if(rst)
		out_data_counter <= 3'd0;
	else if(addr3_end==1'b1 && state==5'd17)
		out_data_counter <= out_data_counter + 1'b1;
	else
		out_data_counter <= out_data_counter;
end

always @(posedge clk)
out_data_counter_reg <= out_data_counter;
							
assign addr3_end = ( (addr3==6'd5 && reduction_type==1'b0) || (addr3==6'd11 && reduction_type==1'b1) ) ? 1'b1 : 1'b0;							
							
always @(posedge clk)
begin
	if(rst)
		sign_mod_q_data <= 0;
	else if(addr0==5'd2 && din_valid==1'b1)
		sign_mod_q_data <= din[59];
	else
		sign_mod_q_data <= sign_mod_q_data;
end
		

red_ROM1 		ROM1(
					  .clka(clk), // input clka
					  .addra(addr2), // input [9 : 0] addra
					  .douta(rom_word_core1), // output [29 : 0] douta
					  .clkb(clk), // input clkb
					  .addrb(addr2+10'd512), // input [9 : 0] addrb
					  .doutb(rom_word_core2) // output [29 : 0] doutb
					);
red_ROM2 		ROM2(
					  .clka(clk), // input clka
					  .addra(addr2), // input [9 : 0] addra
					  .douta(rom_word_core3), // output [29 : 0] douta
					  .clkb(clk), // input clkb
					  .addrb(addr2+10'd512), // input [9 : 0] addrb
					  .doutb(rom_word_core4) // output [29 : 0] doutb
					);


assign barrett_constant = (const_sel==2'd0) ? rom_word_core1 : (const_sel==2'd1) ? rom_word_core2 
                        : (const_sel==2'd2) ? rom_word_core3 : rom_word_core4;
assign prime = (const_sel==2'd0) ? rom_word_core1[29:0] : (const_sel==2'd1) ? rom_word_core2[29:0]
             : (const_sel==2'd2) ? rom_word_core3[29:0] : rom_word_core4[29:0];								
			
red_alu	alu(clk, mod_q_data_word, 
					barrett_constant, prime, const_sel,
				   rom_word_core1, rom_word_core2, rom_word_core3, rom_word_core4,
               rst_acc_d, 
					/*wen_acc_core1, wen_acc_core2, wen_acc_core3, wen_acc_core4,*/
					wen_acc_core1_d2_or_wen_acc_core1, wen_acc_core2_d2_or_wen_acc_core2, 
					wen_acc_core3_d2_or_wen_acc_core3, wen_acc_core4_d2_or_wen_acc_core4,
					only_multiply,
					m0sel, m1sel, m2sel, m3sel, addsub, 
					result
					);				

wire state_smaller15 = (state<5'd15) ? 1'b1 : 1'b0;
always @(posedge clk)
begin
	wen_acc_core1_d0<=wen_acc_core1&state_smaller15; wen_acc_core1_d1<=wen_acc_core1_d0; wen_acc_core1_d2<=wen_acc_core1_d1;
	wen_acc_core2_d0<=wen_acc_core2&state_smaller15; wen_acc_core2_d1<=wen_acc_core2_d0; wen_acc_core2_d2<=wen_acc_core2_d1;
	wen_acc_core3_d0<=wen_acc_core3&state_smaller15; wen_acc_core3_d1<=wen_acc_core3_d0; wen_acc_core3_d2<=wen_acc_core3_d1;
	wen_acc_core4_d0<=wen_acc_core4&state_smaller15; wen_acc_core4_d1<=wen_acc_core4_d0; wen_acc_core4_d2<=wen_acc_core4_d1;	
	rst_acc_d <= rst_acc;
end
assign wen_acc_core1_d2_or_wen_acc_core1 = (state>5'd14) ? wen_acc_core1 : wen_acc_core1_d2;
assign wen_acc_core2_d2_or_wen_acc_core2 = (state>5'd14) ? wen_acc_core2 : wen_acc_core2_d2;
assign wen_acc_core3_d2_or_wen_acc_core3 = (state>5'd14) ? wen_acc_core3 : wen_acc_core3_d2;
assign wen_acc_core4_d2_or_wen_acc_core4 = (state>5'd14) ? wen_acc_core4 : wen_acc_core4_d2;

always @(posedge clk)
begin
	if(rst)
		state <= 5'd0;
	else
		state <= nextstate;
end

always @(posedge clk)
begin
	if(rst)
		wait_counter_state14 <= 3'd0;
	else if(state==5'd14)
		wait_counter_state14 <= wait_counter_state14 + 1'b1;
	else
		wait_counter_state14 <= 3'd0;
end

assign wait_counter_state14_end = (wait_counter_state14==3'd1) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
	if(rst)
		wait_counter_state4 <= 2'd0;
	else if(state==5'd4)
		wait_counter_state4 <= wait_counter_state4 + 1'b1;
	else
		wait_counter_state4 <= wait_counter_state4;
end

assign wait_counter_state4_end = (wait_counter_state4==2'd2) ? 1'b1 : 1'b0;		

always @(state or sign_mod_q_data)
begin
	case(state)
	5'd0: begin // rst
				rst1<=1; inc1<=0; rst2<=1; inc2<=0; rst3<=1; 
				m0sel<=0; m1sel<=2'd0; m2sel<=2'd0; m3sel<=1'd0; addsub<=1; 
				rst_acc<=1; only_multiply<=1; const_sel<=2'd0;
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=0;
			end

	// Start of the multiply accumulate chain
	5'd1: begin // fetch data from inRAM[0] and ROM[0]; inc addr2 
				rst1<=0; inc1<=0; rst2<=0; inc2<=1; rst3<=0;  
				m0sel<=0; m1sel<=2'd0; m2sel<=2'd0; m3sel<=1'd0; addsub<=1; 
				rst_acc<=0; only_multiply<=1; const_sel<=2'd0;
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=0;
			end
	5'd2: begin // multiply L*ROM; inc addr2; inc addr1;
				rst1<=0; inc1<=1; rst2<=0; inc2<=1; rst3<=0;  
				m0sel<=0; m1sel<=2'd0; m2sel<=2'd0; m3sel<=1'd0; addsub<=1; 
				rst_acc<=0; only_multiply<=1; const_sel<=2'd0;
				wen_acc_core1<=1; wen_acc_core2<=1; wen_acc_core3<=1; wen_acc_core4<=1;				
			end
	5'd3: begin // multiply H*ROM; inc addr2; 
				rst1<=0; inc1<=0; rst2<=0; inc2<=1; rst3<=0;  
				m0sel<=1; m1sel<=2'd0; m2sel<=2'd0; m3sel<=1'd0; addsub<=1; 
				rst_acc<=0; only_multiply<=1; const_sel<=2'd0;
				wen_acc_core1<=1; wen_acc_core2<=1; wen_acc_core3<=1; wen_acc_core4<=1;				
			end
	5'd4: begin // wait for the completion of the last multiplications 
				rst1<=0; inc1<=0; rst2<=0; inc2<=0; rst3<=0;  
				m0sel<=1; m1sel<=2'd0; m2sel<=2'd0; m3sel<=1'd0; addsub<=1; 
				rst_acc<=0; only_multiply<=1; const_sel<=2'd0;
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=0;				
			end
	5'd27: begin // wait for the completion of the last multiplications 
				rst1<=0; inc1<=0; rst2<=0; inc2<=0; rst3<=0;  
				m0sel<=1; m1sel<=2'd0; m2sel<=2'd0; m3sel<=1'd0; addsub<=1; 
				rst_acc<=0; only_multiply<=1; const_sel<=2'd0;
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=0;				
			end
	5'd28: begin // wait for the completion of the last multiplications 
				rst1<=0; inc1<=0; rst2<=0; inc2<=0; rst3<=0;  
				m0sel<=1; m1sel<=2'd0; m2sel<=2'd0; m3sel<=1'd0; addsub<=1; 
				rst_acc<=0; only_multiply<=1; const_sel<=2'd0;
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=0;				
			end			
	// End of the multiply accumulate chain

	// Start of reducing 66 bit acc into less than 60 bit 
	5'd5: begin // multiply acc[65:58]*rom 
				rst1<=0; inc1<=0; rst2<=0; inc2<=1; rst3<=0;  
				m0sel<=1; m1sel<=2'd1; m2sel<=2'd1; m3sel<=1'd0; addsub<=1; 
				rst_acc<=0; only_multiply<=1; const_sel<=2'd0;
				wen_acc_core1<=1; wen_acc_core2<=1; wen_acc_core3<=1; wen_acc_core4<=1;				
			end
	5'd6: begin // wait for the multiplication; add acc[57:0]+multout 
				rst1<=0; inc1<=0; rst2<=0; inc2<=0; rst3<=0;  
				m0sel<=1; m1sel<=2'd1; m2sel<=2'd1; m3sel<=1'd0; addsub<=1; 
				rst_acc<=0; only_multiply<=1; const_sel<=2'd0;
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=0;	
			end
	// End of reducing 66 bit acc into less than 60 bit 

	// Start of reducing 60 bit acc into 30 bit using Barrett
	5'd7: begin //  
				rst1<=0; inc1<=0; rst2<=0; inc2<=0; rst3<=0;  
				m0sel<=1; m1sel<=2'd2; m2sel<=2'd2; m3sel<=1'd0; addsub<=1; 
				rst_acc<=0; only_multiply<=0; const_sel<=2'd0;
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=0;				
			end
	5'd8: begin // wait for the multiplication; add acc[57:0]+multout 
				rst1<=0; inc1<=0; rst2<=0; inc2<=0; rst3<=0;  
				m0sel<=1; m1sel<=2'd2; m2sel<=2'd2; m3sel<=1'd0; addsub<=1; 
				rst_acc<=0; only_multiply<=0; const_sel<=2'd1;
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=0;				
			end
	5'd9: begin // wait for the multiplication; add acc[57:0]+multout 
				rst1<=0; inc1<=0; rst2<=0; inc2<=1; rst3<=0;  
				m0sel<=1; m1sel<=2'd2; m2sel<=2'd2; m3sel<=1'd0; addsub<=1; 
				rst_acc<=0; only_multiply<=0; const_sel<=2'd2;
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=0;				
			end
	5'd10: begin // wait for the multiplication; add acc[57:0]+multout 
				rst1<=0; inc1<=0; rst2<=0; inc2<=0; rst3<=0;  
				m0sel<=1; m1sel<=2'd2; m2sel<=2'd2; m3sel<=1'd0; addsub<=1; 
				rst_acc<=0; only_multiply<=0; const_sel<=2'd3;
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=0;				
			end
			
	5'd11: begin // wait for the multiplication; add acc[57:0]+multout 
				rst1<=0; inc1<=0; rst2<=0; inc2<=0; rst3<=0;  
				m0sel<=1; m1sel<=2'd2; m2sel<=2'd2; m3sel<=1'd0; addsub<=1; 
				rst_acc<=0; only_multiply<=0; const_sel<=2'd0;
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=0;				
			end
	5'd12: begin // wait for the multiplication; add acc[57:0]+multout 
				rst1<=0; inc1<=0; rst2<=0; inc2<=0; rst3<=0;  
				m0sel<=1; m1sel<=2'd2; m2sel<=2'd2; m3sel<=1'd0; addsub<=1; 
				rst_acc<=0; only_multiply<=0; const_sel<=2'd1;
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=0;				
			end
	5'd13: begin // wait for the multiplication; add acc[57:0]+multout 
				rst1<=0; inc1<=0; rst2<=0; inc2<=0; rst3<=0;  
				m0sel<=1; m1sel<=2'd2; m2sel<=2'd2; m3sel<=1'd0; addsub<=1; 
				rst_acc<=0; only_multiply<=0; const_sel<=2'd2;
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=0;				
			end			
	5'd14: begin // wait for the multiplication; add acc[57:0]+multout 
				rst1<=0; inc1<=0; rst2<=0; inc2<=0; rst3<=0;  
				m0sel<=1; m1sel<=2'd2; m2sel<=2'd2; m3sel<=1'd0; addsub<=1; 
				rst_acc<=0; only_multiply<=0; const_sel<=2'd3;
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=0;				
			end			
	// End of reducing 60 bit acc into less than 31 bit 

		
	// Start of q_i-acc; update acc only if the 1228 bit input data was -ve.
	5'd15: begin // subtract q_i-barrett_out or 0+barrett_out
				rst1<=0; inc1<=0; rst2<=0; inc2<=0; rst3<=0;  
				m0sel<=1; m1sel<=2'd3; m3sel<=1'd1;  
				rst_acc<=0; only_multiply<=1; const_sel<=2'd0;
				if(sign_mod_q_data) begin m2sel<=2'd3; addsub<=0; end
				else begin m2sel<=2'd2; addsub<=1; end	
				wen_acc_core1<=1; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=0;				
			end
	5'd16: begin // subtract q_i-barrett_out or 0+barrett_out
				rst1<=0; inc1<=0; rst2<=0; inc2<=0; rst3<=0;  
				m0sel<=1; m1sel<=2'd3; m3sel<=1'd1;  
				rst_acc<=0; only_multiply<=1; const_sel<=2'd1;
				if(sign_mod_q_data) begin m2sel<=2'd3; addsub<=0; end
				else begin m2sel<=2'd2; addsub<=1; end
				wen_acc_core1<=0; wen_acc_core2<=1; wen_acc_core3<=0; wen_acc_core4<=0;				
			end			
	5'd17: begin // subtract q_i-barrett_out or 0+barrett_out
				rst1<=1; inc1<=0; rst2<=0; inc2<=1; rst3<=0;  
				m0sel<=1; m1sel<=2'd3; m3sel<=1'd1;  
				rst_acc<=0; only_multiply<=1; const_sel<=2'd2;
				if(sign_mod_q_data) begin m2sel<=2'd3; addsub<=0; end
				else begin m2sel<=2'd2; addsub<=1; end
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=1; wen_acc_core4<=0;				
			end
	5'd18: begin // subtract q_i-barrett_out or 0+barrett_out
				rst1<=0; inc1<=0; rst2<=0; inc2<=1; rst3<=0;  
				m0sel<=1; m1sel<=2'd3; m3sel<=1'd1;  
				rst_acc<=1; only_multiply<=1; const_sel<=2'd3;
				if(sign_mod_q_data) begin m2sel<=2'd3; addsub<=0; end
				else begin m2sel<=2'd2; addsub<=1; end
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=1;				
			end			
	// End of q_i-acc; update acc only if the 1228 bit input data was -ve.
		
	
	5'd19: begin 
				rst1<=1; inc1<=0; rst2<=1; inc2<=0; rst3<=0;  
				m0sel<=0; m1sel<=2'd0; m2sel<=2'd0; m3sel<=1'd0; addsub<=1; 
				rst_acc<=1; only_multiply<=1; const_sel<=2'd0;
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=0;				
			end
	
	5'd31: begin // rst
				rst1<=1; inc1<=0; rst2<=1; inc2<=0; rst3<=1;  
				m0sel<=0; m1sel<=2'd0; m2sel<=2'd0; m3sel<=1'd0; addsub<=1; 
				rst_acc<=1; only_multiply<=1; const_sel<=2'd0;
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=0;				
			end
	default: begin // rst
				rst1<=1; inc1<=0; rst2<=1; inc2<=0; rst3<=1;  
				m0sel<=0; m1sel<=2'd0; m2sel<=2'd0; m3sel<=1'd0; addsub<=1; 
				rst_acc<=1; only_multiply<=1; const_sel<=2'd0;
				wen_acc_core1<=0; wen_acc_core2<=0; wen_acc_core3<=0; wen_acc_core4<=0;				
			end
	
	endcase
end

always @(state or inRAM_filled or mul_chain_finished or wen_acc_core1_d2 
         or wait_counter_state4_end or wait_counter_state14_end or addr3_end or addr3)
begin
	case(state)
	5'd0: begin
				if(inRAM_filled)
					nextstate <= 5'd1;
				else
					nextstate <= 5'd0;
			end		
	5'd1: nextstate <= 5'd2;
	//5'd2: nextstate <= 5'd3;
	5'd2: begin
				if(addr3_end)
					nextstate <= 5'd31;
				else	
					nextstate <= 5'd3;
			end		
	5'd3: begin
				if(mul_chain_finished)
					nextstate <= 5'd4;
				else
					nextstate <= 5'd2;
			end
	5'd4: begin
				if(wait_counter_state4_end)
					nextstate <= 5'd5;
				else
					nextstate <= 5'd4;
			end

	
	5'd5: nextstate <= 5'd6;
	5'd6: begin
				if(wen_acc_core1_d2)
					nextstate <= 5'd7;
				else
					nextstate <= 5'd6;
			end
			

	5'd7: nextstate <= 5'd8;
	5'd8: nextstate <= 5'd9;
	5'd9: nextstate <= 5'd10;
	5'd10: nextstate <= 5'd11;	
	5'd11: nextstate <= 5'd12;	
	5'd12: nextstate <= 5'd13;
	5'd13: nextstate <= 5'd14;		
	5'd14: begin
				if(wait_counter_state14_end)
					nextstate <= 5'd15;
				else	
					nextstate <= 5'd14;
			end		
			
	5'd15: nextstate <= 5'd16;
	5'd16: nextstate <= 5'd17;
	5'd17: begin
				if(addr3_end)
					nextstate <= 5'd31;
				else if(addr3==6'd5)
					nextstate <= 5'd19;				
				else	
					nextstate <= 5'd18;
			end		
	//5'd17: nextstate <= 5'd18;
	5'd18: nextstate <= 5'd2;
	5'd19: nextstate <= 5'd1;
	
	5'd31: nextstate <= 5'd0;
	default: nextstate <= 5'd0;	
	endcase	
end

always @(posedge clk)
begin
	if(rst)
		done <= 1'b0;
	else if(state==5'd31 && out_data_counter==3'd0 && reduction_type==1'b0)
		done <= 1'b1;
	else if(state==5'd31 && out_data_counter==3'd0 && reduction_type==1'b1)
		done <= 1'b1;
	else
		done <= 1'b0;
end		
assign done_test = (state==5'd31) ? 1'b1 : 1'b0;

endmodule


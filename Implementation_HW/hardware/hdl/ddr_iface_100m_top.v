`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:00:37 09/04/2017 
// Design Name: 
// Module Name:    ddr_iface_100m_top 
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
module ddr_iface_100MHz(
								clk_100, rst, instruction, ddr_base_address_in, ddr_base_address_out,
								bram_address, bram_wen,
								lift_address, lift_we,
								ddr_address, ddr_wen,
								
								fifo_read_en, fifo_read_empty, 
								fifo_write_en, fifo_write_almost_full, fifo_write_full,
								address_tag_in,
							 
								rst_lift, lift_dv, lift_done,
								done				 
								);

input clk_100; 						// computation clock
input rst;								// system reset when 1
input [7:0] instruction;			// 3 => pol copy BRAM-->DDR
											// 4 => pol copy DDR-->BRAM
											// 5 => lift_q_to_Q
											// 6 => lift_Q_to_q
											
input [7:0] ddr_base_address_in;	// base address of DDR data 	
input [7:0] ddr_base_address_out; // base address for writing DDR data (only for lifting).	

output [8:0] bram_address;      // 0-2047 BRAM address.
output bram_wen;

output [5:0] lift_address;      // 0-5 address.
output lift_we;					  // 1 to write ddr data in the input buffer of lift module.	

output [24:0] ddr_address; 
output ddr_wen;

output fifo_read_en;
input fifo_read_empty;
output fifo_write_en;
input fifo_write_almost_full, fifo_write_full;
input [7:0] address_tag_in;

output reg rst_lift, lift_dv;
input lift_done;
output done;

/////////////////////////////////////////////////////////////////////////////////////////////

wire read_write;
wire lift_type_crt, reduction_type_crt;
wire [8:0] bram_address_pol, bram_address_crt;
wire bram_wen_pol, bram_wen_crt;
wire [24:0] ddr_address_pol, ddr_address_crt;
wire ddr_wen_pol, ddr_wen_crt;
wire fifo_read_en_pol, fifo_read_en_crt;
wire fifo_write_en_pol, fifo_write_en_crt;
wire ddr_offset511_crt;
wire done_pol, done_crt;

wire [5:0] lift_address;
wire lift_we;

reg rst_pol, rst_crt;
reg rst_ddr_offset_crt, inc_ddr_offset_crt; // are used to reset or increment the offset during CRT
reg [3:0] state, nextstate;
reg read_write_crt;
reg [7:0] delay_reg;
wire delay_full;

assign read_write = (instruction==8'd3) ? 1'b1 : 1'b0;
assign lift_type_crt = (instruction==8'd5) ? 1'b1 : 1'b0;
assign reduction_type_crt = (instruction==8'd7) ? 1'b1 : 1'b0;

ddr_iface_100m_pol	pol(
								clk_100, rst_pol, read_write, ddr_base_address_in, 
								bram_address_pol, bram_wen_pol,
								ddr_address_pol, ddr_wen_pol,

								fifo_read_en_pol, fifo_read_empty, 
								fifo_write_en_pol, fifo_write_almost_full, fifo_write_full,
								address_tag_in,
							 
								done_pol				 
								);


ddr_iface_100m_crt	crt(
								clk_100, 1'b1, /*rst_crt,*/ read_write_crt, lift_type_crt, reduction_type_crt, ddr_base_address_in, ddr_base_address_out,
								rst_ddr_offset_crt, inc_ddr_offset_crt,
								lift_address, lift_we,
								ddr_address_crt, ddr_wen_crt,

								fifo_read_en_crt, fifo_read_empty, 
								fifo_write_en_crt, fifo_write_almost_full, fifo_write_full,
								address_tag_in,
							 
								ddr_offset511_crt,
								done_crt
								);


assign bram_address = bram_address_pol;
assign bram_wen = bram_wen_pol;

assign ddr_address = (rst_crt) ? ddr_address_pol : ddr_address_crt;
assign ddr_wen = (rst_crt) ? ddr_wen_pol : ddr_wen_crt;
assign fifo_read_en = (rst_crt) ? fifo_read_en_pol : fifo_read_en_crt;
assign fifo_write_en = (rst_crt) ? fifo_write_en_pol : fifo_write_en_crt;


always @(posedge clk_100)
begin
	if(rst)
		delay_reg <= 8'd0;
	else if(state==4'd10 || state==4'd11)
		delay_reg <= delay_reg + 1'b1;
	else
		delay_reg <= 8'd0;
end
//assign delay_full = (delay_reg==5'd31) ? 1'b1 : 1'b0;
assign delay_full = ((delay_reg==8'd255 && lift_type_crt==1'b0) || (delay_reg==8'd31 && lift_type_crt==1'b1)) ? 1'b1 : 1'b0;
		
always @(posedge clk_100)
begin
	if(rst)
		state <= 4'd0;
	else
		state <= nextstate;
end

always @(state)
begin
	case(state)
	4'd0: begin	
				rst_pol<=1'b1; rst_crt<=1'b1; rst_lift<=1'b1; lift_dv<=1'b0; read_write_crt<=0;
				rst_ddr_offset_crt<=1'b1; inc_ddr_offset_crt<=1'b0;
			end
			
	4'd1: begin // Polynomial copy	
				rst_pol<=1'b0; rst_crt<=1'b1; rst_lift<=1'b1; lift_dv<=1'b0; read_write_crt<=0;
				rst_ddr_offset_crt<=1'b1; inc_ddr_offset_crt<=1'b0;
			end


	4'd2: begin // coefficient-set copy during CRT	
				rst_pol<=1'b1; rst_crt<=1'b0; rst_lift<=1'b1; lift_dv<=1'b0; read_write_crt<=0;
				rst_ddr_offset_crt<=1'b0; inc_ddr_offset_crt<=1'b0;
			end	
	4'd3: begin // wait for completion of copy	
				rst_pol<=1'b1; rst_crt<=1'b0; rst_lift<=1'b1; lift_dv<=1'b0; read_write_crt<=0;
				rst_ddr_offset_crt<=1'b0; inc_ddr_offset_crt<=1'b0;
			end	
			
	4'd12: begin // initiate lift;	rst_lift-->0
				rst_pol<=1'b1; rst_crt<=1'b1; rst_lift<=1'b0; lift_dv<=1'b0; read_write_crt<=0;
				rst_ddr_offset_crt<=1'b0; inc_ddr_offset_crt<=1'b0;
			end			
	4'd5: begin // initiate lift;	lift_dv-->1
				rst_pol<=1'b1; rst_crt<=1'b1; rst_lift<=1'b0; lift_dv<=1'b1; read_write_crt<=0;
				rst_ddr_offset_crt<=1'b0; inc_ddr_offset_crt<=1'b0;
			end	
	4'd6: begin // wait for lift to finish;	
				rst_pol<=1'b1; rst_crt<=1'b1; rst_lift<=1'b0; lift_dv<=1'b0; read_write_crt<=0;
				rst_ddr_offset_crt<=1'b0; inc_ddr_offset_crt<=1'b0;
			end

	4'd10: begin // Delay 32 cycles;	
				rst_pol<=1'b1; rst_crt<=1'b1; rst_lift<=1'b0; lift_dv<=1'b0; read_write_crt<=0;
				rst_ddr_offset_crt<=1'b0; inc_ddr_offset_crt<=1'b0;
			end

	4'd13: begin // Set output base address	
				rst_pol<=1'b1; rst_crt<=1'b1; rst_lift<=1'b1; lift_dv<=1'b0; read_write_crt<=1;
				rst_ddr_offset_crt<=1'b0; inc_ddr_offset_crt<=1'b0;
			end	
	4'd8: begin // coefficient-set Lift --> DDR after lift	
				rst_pol<=1'b1; rst_crt<=1'b0; rst_lift<=1'b1; lift_dv<=1'b0; read_write_crt<=1;
				rst_ddr_offset_crt<=1'b0; inc_ddr_offset_crt<=1'b0;
			end	
	4'd9: begin // wait for completion of copy	
				rst_pol<=1'b1; rst_crt<=1'b0; rst_lift<=1'b1; lift_dv<=1'b0; read_write_crt<=1;
				rst_ddr_offset_crt<=1'b0; inc_ddr_offset_crt<=1'b0;
			end	
	4'd11: begin // Delay 32 cycles;	
				rst_pol<=1'b1; rst_crt<=1'b0; rst_lift<=1'b1; lift_dv<=1'b0; read_write_crt<=1;
				rst_ddr_offset_crt<=1'b0; inc_ddr_offset_crt<=1'b0;
			end	
			
	4'd4: begin // increment ddr_offset and reset others;	
				rst_pol<=1'b1; rst_crt<=1'b1; rst_lift<=1'b1; lift_dv<=1'b0; read_write_crt<=0;
				rst_ddr_offset_crt<=1'b0; inc_ddr_offset_crt<=1'b1;
			end	

	4'd7: begin	
				rst_pol<=1'b1; rst_crt<=1'b1; rst_lift<=1'b1; lift_dv<=1'b0; read_write_crt<=0;
				rst_ddr_offset_crt<=1'b1; inc_ddr_offset_crt<=1'b1;
			end
	default: begin	
				rst_pol<=1'b1; rst_crt<=1'b1; rst_lift<=1'b1; lift_dv<=1'b0; read_write_crt<=0;
				rst_ddr_offset_crt<=1'b1; inc_ddr_offset_crt<=1'b0;
			end
	endcase
end
	

always @(state or instruction or done_pol or done_crt or lift_done or ddr_offset511_crt or delay_full)
begin
	case(state)
	4'd0: begin
				if(instruction==8'd3 || instruction==8'd4)
					nextstate <= 4'd1;
				else if(instruction==8'd5 || instruction==8'd6 || instruction==8'd7)
					nextstate <= 4'd2;
				else
					nextstate <= 4'd0;
			end
		
	4'd1: begin
				if(done_pol)
					nextstate <= 4'd7;
				else
					nextstate <= 4'd1;
			end
			
			
	4'd2: nextstate <= 4'd3;
	4'd3: begin
				if(done_crt)
					nextstate <= 4'd12;	//5
				else
					nextstate <= 4'd3;
			end

	// Lift operation
	4'd12: nextstate <= 4'd5;
	4'd5: nextstate <= 4'd6;
	4'd6: begin
				if(lift_done)
					nextstate <= 4'd10;	//previously 8
				else
					nextstate <= 4'd6;
			end

	4'd10: begin
				if(delay_full)
					nextstate <= 4'd13; //previously 8	
				else
					nextstate <= 4'd10;
			end
	
	// Write back after Lift operation
	4'd13: nextstate <= 4'd8;
	4'd8: nextstate <= 4'd9;
	4'd9: begin
				if(done_crt)
					nextstate <= 4'd11;	//previously 4
				else
					nextstate <= 4'd9;
			end

	4'd11: begin
				if(delay_full)
					nextstate <= 4'd4;	
				else
					nextstate <= 4'd11;
			end
	
	
	4'd4: begin
				if(ddr_offset511_crt)
					nextstate <= 4'd7;
				else
					nextstate <= 4'd2;
			end
	4'd7: nextstate <= 4'd7;
	default: nextstate <= 4'd0;
	endcase
end



assign done = (state==4'd7) ? 1'b1 : 1'b0;

endmodule



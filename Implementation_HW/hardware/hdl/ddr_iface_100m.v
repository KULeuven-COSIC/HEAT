`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:41:56 06/16/2017 
// Design Name: 
// Module Name:    ddr_iface_100m 
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
module ddr_iface_100m_pol(clk_100, rst, read_write, ddr_base_address_in, 
                      bram_address, bram_wen,
							 ddr_address, ddr_wen,

							 fifo_read_en, fifo_read_empty, 
							 fifo_write_en, fifo_write_almost_full, fifo_write_full,
							 address_tag_in,
							 
							 done				 
							 );

input clk_100; 						// computation clock
input rst;								// system reset when 1
input read_write;						// 0 for ddr-read, 1 for ddr_write
input [7:0] ddr_base_address_in;	// base address of DDR data 	

output [8:0] bram_address;      // 0-2047 BRAM address.
output bram_wen;

output [24:0] ddr_address; 
output ddr_wen;

output reg fifo_read_en;
input fifo_read_empty;
output reg fifo_write_en;
input fifo_write_almost_full, fifo_write_full;
input [7:0] address_tag_in;

output done;



///////////////////////// DDR ///////////////////////////////////////
reg [9:0] ddr_base_address;
reg [9:0] ddr_offset;
reg rst_ddr_offset, inc_ddr_offset;
reg ddr_wen;
wire ddr_offset_full;
reg ddr_offset_full_d;
wire address_tag_in_invalid_wire;
reg address_tag_in_invalid;

always @(posedge clk_100)
begin
	if(rst_ddr_offset)
		ddr_base_address <= {2'b11,ddr_base_address_in};
	else
		ddr_base_address <= ddr_base_address;
end
always @(posedge clk_100)
begin
	if(rst_ddr_offset)
		ddr_offset <= 9'd0;
	else if(inc_ddr_offset)
		ddr_offset <= ddr_offset + 1'b1;
	else
		ddr_offset <= ddr_offset;
end

assign ddr_address = ddr_offset + (ddr_base_address<<9);
assign ddr_offset_full = (ddr_offset==9'd511) ? 1'b1 : 1'b0;

always @(posedge clk_100)
begin
	if(rst_ddr_offset)
		ddr_offset_full_d <= 1'b0;
	else if(ddr_offset_full & fifo_write_en)
		ddr_offset_full_d <= 1'b1;
	else	
		ddr_offset_full_d <= ddr_offset_full_d;
end		
////////////////////////////////////////////////////////////////////


///////////////////////// BRAM ///////////////////////////////////////
reg [8:0] bram_address;      
reg rst_bram_address, inc_bram_address;
reg bram_wen;
wire bram_address_full;

always @(posedge clk_100)
begin
	if(rst_bram_address)
		bram_address <= 9'd0;
	else if(inc_bram_address)
		bram_address <= bram_address + 1'b1;
	else
		bram_address <= bram_address;
end


assign bram_address_full = (bram_address==9'd511) ? 1'b1 : 1'b0;
 
////////////////////////////////////////////////////////////////////////

assign address_tag_in_invalid_wire = ((address_tag_in[3:0] != bram_address[3:0]) && bram_wen==1'b1) ? 1'b1 : 1'b0;
//assign address_tag_in_invalid_wire = 1'b0;

always @(posedge clk_100)
	address_tag_in_invalid <= address_tag_in_invalid_wire;

reg [3:0] state, nextstate;

always @(posedge clk_100)
begin
	if(rst)
		state <= 4'd0;
	else
		state <= nextstate;
end


reg [5:0] test_interval;
wire test_interval_end;

always @(posedge clk_100)
begin
	if(state==4'd6)
		test_interval <= 6'd0;
	else if(state==4'd7)
		test_interval <= test_interval + 1'b1;
	else
		test_interval <= 6'd0;
end		
assign test_interval_end = (test_interval==6'd31) ? 1'b1 : 1'b0;
		
//fifo_read_en;
//fifo_read_empty;
//fifo_write_en;
//fifo_write_almost_full;

always @(state or fifo_read_empty or fifo_write_almost_full or fifo_write_full
         or ddr_offset_full or ddr_offset_full_d)
begin
	case(state)
	4'd0: begin	// Reset state;
				rst_ddr_offset<=1; inc_ddr_offset<=0; ddr_wen<=0; 
				rst_bram_address<=1; inc_bram_address<=0; bram_wen<=0;
				fifo_read_en<=0; fifo_write_en<=0;
			end
			
	//// START:  DDR Write states ////
	4'd1: begin	// Wait for DDR ready; indicated by fifo_write_almost_full
				rst_ddr_offset<=0; inc_ddr_offset<=0; ddr_wen<=0;
				rst_bram_address<=0; inc_bram_address<=0; bram_wen<=0;
				fifo_read_en<=0; fifo_write_en<=0;				
			end
	4'd2: begin	// Set BRAM address; Increment BRAM address;
				rst_ddr_offset<=0; inc_ddr_offset<=0; ddr_wen<=0;
				rst_bram_address<=0; inc_bram_address<=1; bram_wen<=0;
				fifo_read_en<=0; fifo_write_en<=0;				
			end
	4'd3: begin	// Write BRAM_data in DDR_fifo; Increment BRAM address; Continue until DDR fifo is filled (e.g. 64 times).
				rst_ddr_offset<=0; 
				rst_bram_address<=0; bram_wen<=0;
				fifo_read_en<=0; 
				if(fifo_write_almost_full) begin  inc_bram_address<=0; end
				else begin inc_bram_address<=1; end	
				if(fifo_write_full) begin ddr_wen<=0; fifo_write_en<=0; inc_ddr_offset<=0; end 
				else begin ddr_wen<=1; fifo_write_en<=1; inc_ddr_offset<=1; end
			end
	4'd4: begin	// wait for fifo_write_almost_full to go down
				rst_ddr_offset<=0; inc_ddr_offset<=0; ddr_wen<=0;
				rst_bram_address<=0; bram_wen<=0;
				fifo_read_en<=0; fifo_write_en<=0;	
				if(fifo_write_almost_full) inc_bram_address<=0;  else inc_bram_address<=1; 	
			end			
	//// END:  DDR Write states ////
	


	//// START:  DDR Read states ////	

	4'd6: begin	// Clean the READ-fifo
				rst_ddr_offset<=0; ddr_wen<=0;
				rst_bram_address<=0; inc_bram_address<=0; bram_wen<=0; inc_ddr_offset<=0; fifo_write_en<=0;
				if(fifo_read_empty) fifo_read_en<=0; else	fifo_read_en<=1;
			end
	4'd7: begin	// Verify again the READ-fifo
				rst_ddr_offset<=0; ddr_wen<=0;
				rst_bram_address<=0; inc_bram_address<=0; bram_wen<=0; inc_ddr_offset<=0; fifo_write_en<=0;
				fifo_read_en<=0;
			end
	
	4'd5: begin	// read data from fifo and write in BRAM.
				rst_ddr_offset<=0; ddr_wen<=0;
				rst_bram_address<=0; 
				if(fifo_read_empty) 
				begin	fifo_read_en<=0; inc_bram_address<=0; bram_wen<=0; end
				else begin	fifo_read_en<=1; inc_bram_address<=1; bram_wen<=1; end
				
				if(ddr_offset_full==1'b1 || fifo_write_almost_full==1'b1) inc_ddr_offset<=0; else inc_ddr_offset<=1; 
				if(ddr_offset_full_d==1'b1 || fifo_write_almost_full==1'b1) fifo_write_en<=0; else fifo_write_en<=1;
			end	
	

	4'd15: begin // Reset state;
				rst_ddr_offset<=1; inc_ddr_offset<=0; ddr_wen<=0; 
				rst_bram_address<=1; inc_bram_address<=0; bram_wen<=0;
				fifo_read_en<=0; fifo_write_en<=0;
			end	

	default: begin	// Reset state;
				rst_ddr_offset<=1; inc_ddr_offset<=0; ddr_wen<=0; 
				rst_bram_address<=1; inc_bram_address<=0; bram_wen<=0;
				fifo_read_en<=0; fifo_write_en<=0;
			end	
	endcase
end


always @(state or read_write or fifo_write_almost_full or bram_address_full 
			or fifo_write_en or fifo_read_empty or ddr_offset_full or bram_wen 
			or test_interval_end or address_tag_in_invalid)
begin
	case(state)
	4'd0: begin
				if(read_write)
					nextstate <= 4'd1;
				else
					nextstate <= 4'd6;
			end

	// DDR Write states ///
	4'd1: begin
				if(fifo_write_almost_full)
					nextstate <= 4'd1;
				else
					nextstate <= 4'd2;
			end
	4'd2: nextstate <= 4'd3;
	4'd3: begin
				if(ddr_offset_full==1'b1 && fifo_write_en==1'b1)
					nextstate <= 4'd15;
				else if(fifo_write_almost_full)
					nextstate <= 4'd4;
				else	
					nextstate <= 4'd3;
			end
	4'd4: begin
				if(fifo_write_almost_full)
					nextstate <= 4'd4;
				else
					nextstate <= 4'd3;
			end



	// DDR Read states ///
	4'd6: begin
				if(fifo_read_empty)
					nextstate <= 4'd7;
				else
					nextstate <= 4'd6;
			end	
	4'd7: begin
				if(fifo_read_empty==1'b1 && test_interval_end==1'b1)
					nextstate <= 4'd5;
				else if(fifo_read_empty==1'b0 && test_interval_end==1'b1)
					nextstate <= 4'd6;					
				else
					nextstate <= 4'd7;
			end

			
	4'd5: begin
				if(address_tag_in_invalid)
					nextstate <= 4'd0;
				else if(bram_address_full==1'b1 && bram_wen==1'b1)
					nextstate <= 4'd15;
				else
					nextstate <= 4'd5;
			end
	

	4'd15: nextstate <= 4'd15;
	default: nextstate <= 4'd0;
	endcase
end	
 	
assign done = (state==4'd15) ? 1'b1 : 1'b0;


endmodule

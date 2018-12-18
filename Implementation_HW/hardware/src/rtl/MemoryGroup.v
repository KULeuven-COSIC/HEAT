`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: a
// Engineer: 
// 
// Create Date:    16:19:35 06/07/2016 
// Design Name: 
// Module Name:    MemoryGroup 
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

module MemoryGroup_eth(clk1, clk2, 
						 top_mem_sel, top_mem_sel_override, interrupt_eth_all_processors_accessed,
						 rdMsel, wtMsel, 

						 processor_sel,

						 interrupt_eth, dinb_eth, web_eth, doutb_eth, 
						 
						 ram_write_en_p0, write_address_p0, read_address_p0,
						 ram_write_en_p1, write_address_p1, read_address_p1,
						 ram_write_en_p2, write_address_p2, read_address_p2,
						 ram_write_en_p3, write_address_p3, read_address_p3,
						 ram_write_en_p4, write_address_p4, read_address_p4,
						 ram_write_en_p5, write_address_p5, read_address_p5,
						 ram_write_en_p6, write_address_p6, read_address_p6,						 

						 
						 dina_high_p0, dina_low_p0, doutb_p0_new,
						 dina_high_p1, dina_low_p1, doutb_p1_new,
						 dina_high_p2, dina_low_p2, doutb_p2_new,
						 dina_high_p3, dina_low_p3, doutb_p3_new,
						 dina_high_p4, dina_low_p4, doutb_p4_new,
						 dina_high_p5, dina_low_p5, doutb_p5_new,
						 dina_high_p6, dina_low_p6, doutb_p6_new,
						 
						 
						 ram_write_en_p0_n, write_address_p0_n, read_address_p0_n,
						 ram_write_en_p1_n, write_address_p1_n, read_address_p1_n,
						 ram_write_en_p2_n, write_address_p2_n, read_address_p2_n,
						 ram_write_en_p3_n, write_address_p3_n, read_address_p3_n,
						 ram_write_en_p4_n, write_address_p4_n, read_address_p4_n,
						 ram_write_en_p5_n, write_address_p5_n, read_address_p5_n,
						 ram_write_en_p6_n, write_address_p6_n, read_address_p6_n,
						 
						 dina_high_p0_n, dina_low_p0_n, doutb_p0_new_n,
						 dina_high_p1_n, dina_low_p1_n, doutb_p1_new_n,
						 dina_high_p2_n, dina_low_p2_n, doutb_p2_new_n,
						 dina_high_p3_n, dina_low_p3_n, doutb_p3_new_n,
						 dina_high_p4_n, dina_low_p4_n, doutb_p4_new_n,
						 dina_high_p5_n, dina_low_p5_n, doutb_p5_new_n,
						 dina_high_p6_n, dina_low_p6_n, doutb_p6_new_n,						 
						
						 ddr_interrupt, ddr_address, ddr_we, ddr_din, ddr_dout
						 );
input clk1, clk2;
input [3:0] top_mem_sel;		// This is used by the top module to seleach one of the two internal-memory for read/write
input top_mem_sel_override;	// This is used by the top module to override memory selection
input interrupt_eth_all_processors_accessed; // This signal is raised (simultaneously with interrupt_eth) to enable writing same data in all 6 processors.

input [3:0] rdMsel, wtMsel;	// Memory Index selection
input [2:0] processor_sel;		// one of the 7 processor memories

input interrupt_eth;
input [59:0] dinb_eth;
output [59:0] doutb_eth;
input web_eth;

input ram_write_en_p0;				
input [10:0] write_address_p0, read_address_p0;
input ram_write_en_p1;				
input [10:0] write_address_p1, read_address_p1;
input ram_write_en_p2;				
input [10:0] write_address_p2, read_address_p2;
input ram_write_en_p3;				
input [10:0] write_address_p3, read_address_p3;
input ram_write_en_p4;				
input [10:0] write_address_p4, read_address_p4;
input ram_write_en_p5;				
input [10:0] write_address_p5, read_address_p5;
input ram_write_en_p6;				
input [10:0] write_address_p6, read_address_p6;

input [29:0] dina_high_p0, dina_low_p0;
output [59:0] doutb_p0_new;

input [29:0] dina_high_p1, dina_low_p1;
output [59:0] doutb_p1_new;

input [29:0] dina_high_p2, dina_low_p2;
output [59:0] doutb_p2_new;

input [29:0] dina_high_p3, dina_low_p3;
output [59:0] doutb_p3_new;

input [29:0] dina_high_p4, dina_low_p4;
output [59:0] doutb_p4_new;

input [29:0] dina_high_p5, dina_low_p5;
output [59:0] doutb_p5_new;

input [29:0] dina_high_p6, dina_low_p6;
output [59:0] doutb_p6_new;

/////////////////
input ram_write_en_p0_n;
input [10:0] write_address_p0_n, read_address_p0_n;
input ram_write_en_p1_n;
input [10:0] write_address_p1_n, read_address_p1_n;
input ram_write_en_p2_n;
input [10:0] write_address_p2_n, read_address_p2_n;
input ram_write_en_p3_n;
input [10:0] write_address_p3_n, read_address_p3_n;
input ram_write_en_p4_n;
input [10:0] write_address_p4_n, read_address_p4_n;
input ram_write_en_p5_n;
input [10:0] write_address_p5_n, read_address_p5_n;
input ram_write_en_p6_n;
input [10:0] write_address_p6_n, read_address_p6_n;

input [29:0] dina_high_p0_n, dina_low_p0_n;
output [59:0] doutb_p0_new_n;

input [29:0] dina_high_p1_n, dina_low_p1_n;
output [59:0] doutb_p1_new_n;

input [29:0] dina_high_p2_n, dina_low_p2_n;
output [59:0] doutb_p2_new_n;

input [29:0] dina_high_p3_n, dina_low_p3_n;
output [59:0] doutb_p3_new_n;

input [29:0] dina_high_p4_n, dina_low_p4_n;
output [59:0] doutb_p4_new_n;

input [29:0] dina_high_p5_n, dina_low_p5_n;
output [59:0] doutb_p5_new_n;

input [29:0] dina_high_p6_n, dina_low_p6_n;
output [59:0] doutb_p6_new_n;

/////////////////



input ddr_interrupt; 
input [8:0] ddr_address;
input ddr_we;
input [239:0] ddr_din;
output [239:0] ddr_dout;


wire ram_write_en0, ram_write_en1, ram_write_en2, ram_write_en3, ram_write_en4, ram_write_en5, ram_write_en6;
wire ram_write_en0_n, ram_write_en1_n, ram_write_en2_n, ram_write_en3_n, ram_write_en4_n, ram_write_en5_n, ram_write_en6_n;

wire ddr_we_p0, ddr_we_p1, ddr_we_p2, ddr_we_p3, ddr_we_p4, ddr_we_p5, ddr_we_p6; 
wire [239:0] ddr_dout_p0, ddr_dout_p1, ddr_dout_p2, ddr_dout_p3, ddr_dout_p4, ddr_dout_p5, ddr_dout_p6;
wire [239:0] ddr_dout_p0_eth, ddr_dout_p1_eth, ddr_dout_p2_eth, ddr_dout_p3_eth, ddr_dout_p4_eth, ddr_dout_p5_eth, ddr_dout_p6_eth;
wire [239:0] ddr_dout_p0_new, ddr_dout_p1_new, ddr_dout_p2_new, ddr_dout_p3_new, ddr_dout_p4_new, ddr_dout_p5_new, ddr_dout_p6_new;

wire [59:0] doutb_p0, doutb_p1, doutb_p2, doutb_p3, doutb_p4, doutb_p5, doutb_p6;
wire [59:0] doutb_p0_new, doutb_p1_new, doutb_p2_new, doutb_p3_new, doutb_p4_new, doutb_p5_new, doutb_p6_new;
wire [59:0] doutb_p0_eth, doutb_p1_eth, doutb_p2_eth, doutb_p3_eth, doutb_p4_eth, doutb_p5_eth, doutb_p6_eth;

wire [59:0] doutb_p0_n, doutb_p1_n, doutb_p2_n, doutb_p3_n, doutb_p4_n, doutb_p5_n, doutb_p6_n;
wire [59:0] doutb_p0_new_n, doutb_p1_new_n, doutb_p2_new_n, doutb_p3_new_n, doutb_p4_new_n, doutb_p5_new_n, doutb_p6_new_n;
wire [59:0] doutb_p0_eth_n, doutb_p1_eth_n, doutb_p2_eth_n, doutb_p3_eth_n, doutb_p4_eth_n, doutb_p5_eth_n, doutb_p6_eth_n;

wire [29:0] dina_high_p0_eth, dina_low_p0_eth, dina_high_p1_eth, dina_low_p1_eth, dina_high_p2_eth, dina_low_p2_eth;
wire [29:0] dina_high_p3_eth, dina_low_p3_eth, dina_high_p4_eth, dina_low_p4_eth, dina_high_p5_eth, dina_low_p5_eth, dina_high_p6_eth, dina_low_p6_eth;

wire [29:0] dina_high_p0_eth_n, dina_low_p0_eth_n, dina_high_p1_eth_n, dina_low_p1_eth_n, dina_high_p2_eth_n, dina_low_p2_eth_n;
wire [29:0] dina_high_p3_eth_n, dina_low_p3_eth_n, dina_high_p4_eth_n, dina_low_p4_eth_n, dina_high_p5_eth_n, dina_low_p5_eth_n, dina_high_p6_eth_n, dina_low_p6_eth_n;

assign ram_write_en0 = (interrupt_eth_all_processors_accessed) ? ram_write_en_p0 : (top_mem_sel_override==1'b1 && processor_sel==3'd0) ? ram_write_en_p0 : (top_mem_sel_override==1'b0) ? ram_write_en_p0 : 1'b0;
assign ram_write_en1 = (interrupt_eth_all_processors_accessed) ? ram_write_en_p1 : (top_mem_sel_override==1'b1 && processor_sel==3'd1) ? ram_write_en_p1 : (top_mem_sel_override==1'b0) ? ram_write_en_p1 : 1'b0;
assign ram_write_en2 = (interrupt_eth_all_processors_accessed) ? ram_write_en_p2 : (top_mem_sel_override==1'b1 && processor_sel==3'd2) ? ram_write_en_p2 : (top_mem_sel_override==1'b0) ? ram_write_en_p2 : 1'b0;
assign ram_write_en3 = (interrupt_eth_all_processors_accessed) ? ram_write_en_p3 : (top_mem_sel_override==1'b1 && processor_sel==3'd3) ? ram_write_en_p3 : (top_mem_sel_override==1'b0) ? ram_write_en_p3 : 1'b0;
assign ram_write_en4 = (interrupt_eth_all_processors_accessed) ? ram_write_en_p4 : (top_mem_sel_override==1'b1 && processor_sel==3'd4) ? ram_write_en_p4 : (top_mem_sel_override==1'b0) ? ram_write_en_p4 : 1'b0;
assign ram_write_en5 = (interrupt_eth_all_processors_accessed) ? ram_write_en_p5 : (top_mem_sel_override==1'b1 && processor_sel==3'd5) ? ram_write_en_p5 : (top_mem_sel_override==1'b0) ? ram_write_en_p5 : 1'b0;
assign ram_write_en6 = (top_mem_sel_override==1'b1 && processor_sel==3'd6) ? ram_write_en_p6 : (top_mem_sel_override==1'b0) ? ram_write_en_p6 : 1'b0;

assign ram_write_en0_n = (top_mem_sel_override==1'b1 && processor_sel==3'd0) ? ram_write_en_p0_n : (top_mem_sel_override==1'b0) ? ram_write_en_p0_n : 1'b0;
assign ram_write_en1_n = (top_mem_sel_override==1'b1 && processor_sel==3'd1) ? ram_write_en_p1_n : (top_mem_sel_override==1'b0) ? ram_write_en_p1_n : 1'b0;
assign ram_write_en2_n = (top_mem_sel_override==1'b1 && processor_sel==3'd2) ? ram_write_en_p2_n : (top_mem_sel_override==1'b0) ? ram_write_en_p2_n : 1'b0;
assign ram_write_en3_n = (top_mem_sel_override==1'b1 && processor_sel==3'd3) ? ram_write_en_p3_n : (top_mem_sel_override==1'b0) ? ram_write_en_p3_n : 1'b0;
assign ram_write_en4_n = (top_mem_sel_override==1'b1 && processor_sel==3'd4) ? ram_write_en_p4_n : (top_mem_sel_override==1'b0) ? ram_write_en_p4_n : 1'b0;
assign ram_write_en5_n = (top_mem_sel_override==1'b1 && processor_sel==3'd5) ? ram_write_en_p5_n : (top_mem_sel_override==1'b0) ? ram_write_en_p5_n : 1'b0;
assign ram_write_en6_n = (top_mem_sel_override==1'b1 && processor_sel==3'd6) ? ram_write_en_p6_n : (top_mem_sel_override==1'b0) ? ram_write_en_p6_n : 1'b0;

assign ddr_we_p0 = (ddr_interrupt==1'b1 && processor_sel==3'd0) ? ddr_we : 1'b0;
assign ddr_we_p1 = (ddr_interrupt==1'b1 && processor_sel==3'd1) ? ddr_we : 1'b0;
assign ddr_we_p2 = (ddr_interrupt==1'b1 && processor_sel==3'd2) ? ddr_we : 1'b0;
assign ddr_we_p3 = (ddr_interrupt==1'b1 && processor_sel==3'd3) ? ddr_we : 1'b0;
assign ddr_we_p4 = (ddr_interrupt==1'b1 && processor_sel==3'd4) ? ddr_we : 1'b0;
assign ddr_we_p5 = (ddr_interrupt==1'b1 && processor_sel==3'd5) ? ddr_we : 1'b0;
assign ddr_we_p6 = (ddr_interrupt==1'b1 && processor_sel==3'd6) ? ddr_we : 1'b0;

assign ddr_dout =   (processor_sel==3'd0) ? ddr_dout_p0_new
						: (processor_sel==3'd1) ? ddr_dout_p1_new 
						: (processor_sel==3'd2) ? ddr_dout_p2_new
						: (processor_sel==3'd3) ? ddr_dout_p3_new
						: (processor_sel==3'd4) ? ddr_dout_p4_new
						: (processor_sel==3'd5) ? ddr_dout_p5_new						
						: ddr_dout_p6_new;
						

assign {dina_high_p0_eth, dina_low_p0_eth} = (interrupt_eth) ? dinb_eth : {dina_high_p0, dina_low_p0};
assign {dina_high_p1_eth, dina_low_p1_eth} = (interrupt_eth) ? dinb_eth : {dina_high_p1, dina_low_p1};
assign {dina_high_p2_eth, dina_low_p2_eth} = (interrupt_eth) ? dinb_eth : {dina_high_p2, dina_low_p2};
assign {dina_high_p3_eth, dina_low_p3_eth} = (interrupt_eth) ? dinb_eth : {dina_high_p3, dina_low_p3};
assign {dina_high_p4_eth, dina_low_p4_eth} = (interrupt_eth) ? dinb_eth : {dina_high_p4, dina_low_p4};
assign {dina_high_p5_eth, dina_low_p5_eth} = (interrupt_eth) ? dinb_eth : {dina_high_p5, dina_low_p5};
assign {dina_high_p6_eth, dina_low_p6_eth} = (interrupt_eth) ? dinb_eth : {dina_high_p6, dina_low_p6};

assign {dina_high_p0_eth_n, dina_low_p0_eth_n} = (interrupt_eth) ? dinb_eth : {dina_high_p0_n, dina_low_p0_n};
assign {dina_high_p1_eth_n, dina_low_p1_eth_n} = (interrupt_eth) ? dinb_eth : {dina_high_p1_n, dina_low_p1_n};
assign {dina_high_p2_eth_n, dina_low_p2_eth_n} = (interrupt_eth) ? dinb_eth : {dina_high_p2_n, dina_low_p2_n};
assign {dina_high_p3_eth_n, dina_low_p3_eth_n} = (interrupt_eth) ? dinb_eth : {dina_high_p3_n, dina_low_p3_n};
assign {dina_high_p4_eth_n, dina_low_p4_eth_n} = (interrupt_eth) ? dinb_eth : {dina_high_p4_n, dina_low_p4_n};
assign {dina_high_p5_eth_n, dina_low_p5_eth_n} = (interrupt_eth) ? dinb_eth : {dina_high_p5_n, dina_low_p5_n};
assign {dina_high_p6_eth_n, dina_low_p6_eth_n} = (interrupt_eth) ? dinb_eth : {dina_high_p6_n, dina_low_p6_n};


assign doutb_eth = (processor_sel==3'd0) ? doutb_p0_eth :
                   (processor_sel==3'd1) ? doutb_p1_eth :
                   (processor_sel==3'd2) ? doutb_p2_eth :
                   (processor_sel==3'd3) ? doutb_p3_eth :
                   (processor_sel==3'd4) ? doutb_p4_eth :
                   (processor_sel==3'd5) ? doutb_p5_eth :
                   doutb_p6_eth ;
						 
MemorySelectBlock_eth MB0_eth(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en0, write_address_p0, read_address_p0, dina_high_p0_eth, dina_low_p0_eth, doutb_p0_eth,
							 ram_write_en0_n, write_address_p0_n, read_address_p0_n, dina_high_p0_eth_n, dina_low_p0_eth_n, doutb_p0_eth_n,							 
							 ddr_interrupt, ddr_address, ddr_we_p0, ddr_din, ddr_dout_p0_eth);

MemorySelectBlock MB0(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en0, write_address_p0, read_address_p0, dina_high_p0, dina_low_p0, doutb_p0_eth, doutb_p0,
							 ram_write_en0_n, write_address_p0_n, read_address_p0_n, dina_high_p0_n, dina_low_p0_n, doutb_p0_eth_n, doutb_p0_n,							 
							 ddr_interrupt, ddr_address, ddr_we_p0, ddr_din, ddr_dout_p0);
					
assign doutb_p0_new = doutb_p0;
assign doutb_p0_new_n = doutb_p0_n;
assign ddr_dout_p0_new = (top_mem_sel==4'd4) ? ddr_dout_p0_eth :ddr_dout_p0;
					
MemorySelectBlock_eth MB1_eth(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en1, write_address_p1, read_address_p1, dina_high_p1_eth, dina_low_p1_eth, doutb_p1_eth,
							 ram_write_en1_n, write_address_p1_n, read_address_p1_n, dina_high_p1_eth_n, dina_low_p1_eth_n, doutb_p1_eth_n,							 
							 ddr_interrupt, ddr_address, ddr_we_p1, ddr_din, ddr_dout_p1_eth);
							 
MemorySelectBlock MB1(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en1, write_address_p1, read_address_p1, dina_high_p1, dina_low_p1, doutb_p1_eth, doutb_p1,
							 ram_write_en1_n, write_address_p1_n, read_address_p1_n, dina_high_p1_n, dina_low_p1_n, doutb_p1_eth_n, doutb_p1_n,							 
							 ddr_interrupt, ddr_address, ddr_we_p1, ddr_din, ddr_dout_p1);

assign doutb_p1_new = doutb_p1;
assign doutb_p1_new_n = doutb_p1_n;
assign ddr_dout_p1_new = (top_mem_sel==4'd4) ? ddr_dout_p1_eth :ddr_dout_p1;

MemorySelectBlock_eth MB2_eth(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en2, write_address_p2, read_address_p2, dina_high_p2_eth, dina_low_p2_eth, doutb_p2_eth,
							 ram_write_en2_n, write_address_p2_n, read_address_p2_n, dina_high_p2_eth_n, dina_low_p2_eth_n, doutb_p2_eth_n,							 
							 ddr_interrupt, ddr_address, ddr_we_p2, ddr_din, ddr_dout_p2_eth);
							 
MemorySelectBlock MB2(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en2, write_address_p2, read_address_p2, dina_high_p2, dina_low_p2, doutb_p2_eth, doutb_p2,
							 ram_write_en2_n, write_address_p2_n, read_address_p2_n, dina_high_p2_n, dina_low_p2_n, doutb_p2_eth_n, doutb_p2_n,							 
							 ddr_interrupt, ddr_address, ddr_we_p2, ddr_din, ddr_dout_p2);

assign doutb_p2_new = doutb_p2;
assign doutb_p2_new_n = doutb_p2_n;
assign ddr_dout_p2_new = (top_mem_sel==4'd4) ? ddr_dout_p2_eth :ddr_dout_p2;

MemorySelectBlock_eth MB3_eth(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en3, write_address_p3, read_address_p3, dina_high_p3_eth, dina_low_p3_eth, doutb_p3_eth,
							 ram_write_en3_n, write_address_p3_n, read_address_p3_n, dina_high_p3_eth_n, dina_low_p3_eth_n, doutb_p3_eth_n,							 
							 ddr_interrupt, ddr_address, ddr_we_p3, ddr_din, ddr_dout_p3_eth);
							 
MemorySelectBlock MB3(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en3, write_address_p3, read_address_p3, dina_high_p3, dina_low_p3, doutb_p3_eth, doutb_p3,
							 ram_write_en3_n, write_address_p3_n, read_address_p3_n, dina_high_p3_n, dina_low_p3_n, doutb_p3_eth_n, doutb_p3_n,							 
							 ddr_interrupt, ddr_address, ddr_we_p3, ddr_din, ddr_dout_p3);

assign doutb_p3_new = doutb_p3;
assign doutb_p3_new_n = doutb_p3_n;
assign ddr_dout_p3_new = (top_mem_sel==4'd4) ? ddr_dout_p3_eth :ddr_dout_p3;

MemorySelectBlock_eth MB4_eth(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en4, write_address_p4, read_address_p4, dina_high_p4_eth, dina_low_p4_eth, doutb_p4_eth,
							 ram_write_en4_n, write_address_p4_n, read_address_p4_n, dina_high_p4_eth_n, dina_low_p4_eth_n, doutb_p4_eth_n,							 
							 ddr_interrupt, ddr_address, ddr_we_p4, ddr_din, ddr_dout_p4_eth);
							 
MemorySelectBlock MB4(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en4, write_address_p4, read_address_p4, dina_high_p4, dina_low_p4, doutb_p4_eth, doutb_p4,
							 ram_write_en4_n, write_address_p4_n, read_address_p4_n, dina_high_p4_n, dina_low_p4_n, doutb_p4_eth_n, doutb_p4_n,							 
							 ddr_interrupt, ddr_address, ddr_we_p4, ddr_din, ddr_dout_p4);

assign doutb_p4_new = doutb_p4;
assign doutb_p4_new_n = doutb_p4_n;
assign ddr_dout_p4_new = (top_mem_sel==4'd4) ? ddr_dout_p4_eth :ddr_dout_p4;

MemorySelectBlock_eth MB5_eth(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en5, write_address_p5, read_address_p5, dina_high_p5_eth, dina_low_p5_eth, doutb_p5_eth,
							 ram_write_en5_n, write_address_p5_n, read_address_p5_n, dina_high_p5_eth_n, dina_low_p5_eth_n, doutb_p5_eth_n,							 
							 ddr_interrupt, ddr_address, ddr_we_p5, ddr_din, ddr_dout_p5_eth);

MemorySelectBlock MB5(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en5, write_address_p5, read_address_p5, dina_high_p5, dina_low_p5, doutb_p5_eth, doutb_p5,
							 ram_write_en5_n, write_address_p5_n, read_address_p5_n, dina_high_p5_n, dina_low_p5_n, doutb_p5_eth_n, doutb_p5_n,							 
							 ddr_interrupt, ddr_address, ddr_we_p5, ddr_din, ddr_dout_p5);							 

assign doutb_p5_new = doutb_p5;
assign doutb_p5_new_n = doutb_p5_n;
assign ddr_dout_p5_new = (top_mem_sel==4'd4) ? ddr_dout_p5_eth :ddr_dout_p5;

MemorySelectBlock_eth MB6_eth(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en6, write_address_p6, read_address_p6, dina_high_p6_eth, dina_low_p6_eth, doutb_p6_eth,
							 ram_write_en6_n, write_address_p6_n, read_address_p6_n, dina_high_p6_eth_n, dina_low_p6_eth_n, doutb_p6_eth_n,							 
							 ddr_interrupt, ddr_address, ddr_we_p6, ddr_din, ddr_dout_p6_eth);

MemorySelectBlock MB6(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en6, write_address_p6, read_address_p6, dina_high_p6, dina_low_p6, doutb_p6_eth, doutb_p6,
							 ram_write_en6_n, write_address_p6_n, read_address_p6_n, dina_high_p6_n, dina_low_p6_n, doutb_p6_eth_n, doutb_p6_n,							 
							 ddr_interrupt, ddr_address, ddr_we_p6, ddr_din, ddr_dout_p6);	
							 						

assign doutb_p6_new = doutb_p6;
assign doutb_p6_new_n = doutb_p6_n;
assign ddr_dout_p6_new = (top_mem_sel==4'd4) ? ddr_dout_p6_eth : ddr_dout_p6;

endmodule

/*
module MemoryGroup(clk1, clk2, 
						 top_mem_sel, top_mem_sel_override,
						 rdMsel, wtMsel, 
						 ram_write_en, processor_sel,
						 
						 write_address, read_address,
						 dina_high_p0, dina_low_p0, doutb_p0,
						 dina_high_p1, dina_low_p1, doutb_p1,
						 dina_high_p2, dina_low_p2, doutb_p2,
						 
						 dina_high_p3, dina_low_p3, doutb_p3,
						 dina_high_p4, dina_low_p4, doutb_p4,
						 dina_high_p5, dina_low_p5, doutb_p5,
						 dina_high_p6, dina_low_p6, doutb_p6,
						
						 ddr_interrupt, ddr_address, ddr_we, ddr_din, ddr_dout
						 );
input clk1, clk2;
input [3:0] top_mem_sel;				// This is used by the top module to seleach one of the two internal-memory for read/write
input top_mem_sel_override;	// This is used by the top module to override memory selection


input [3:0] rdMsel, wtMsel;			// Memory Index selection
input ram_write_en;				// Write enable signal for the RAM
input [2:0] processor_sel;		// one of the 7 processor memories
input [10:0] write_address, read_address;		// 11-bit address; 

input [29:0] dina_high_p0, dina_low_p0;
output [59:0] doutb_p0;

input [29:0] dina_high_p1, dina_low_p1;
output [59:0] doutb_p1;


input [29:0] dina_high_p2, dina_low_p2;
output [59:0] doutb_p2;

input [29:0] dina_high_p3, dina_low_p3;
output [59:0] doutb_p3;

input [29:0] dina_high_p4, dina_low_p4;
output [59:0] doutb_p4;

input [29:0] dina_high_p5, dina_low_p5;
output [59:0] doutb_p5;

input [29:0] dina_high_p6, dina_low_p6;
output [59:0] doutb_p6;

input ddr_interrupt; 
input [8:0] ddr_address;
input ddr_we;
input [239:0] ddr_din;
output [239:0] ddr_dout;


wire ram_write_en0, ram_write_en1, ram_write_en2, ram_write_en3, ram_write_en4, ram_write_en5, ram_write_en6;

wire ddr_we_p0, ddr_we_p1, ddr_we_p2, ddr_we_p3, ddr_we_p4, ddr_we_p5, ddr_we_p6; 
wire [239:0] ddr_dout_p0, ddr_dout_p1, ddr_dout_p2, ddr_dout_p3, ddr_dout_p4, ddr_dout_p5, ddr_dout_p6;


assign ram_write_en0 = (top_mem_sel_override==1'b1 && processor_sel==3'd0) ? ram_write_en : (top_mem_sel_override==1'b0) ? ram_write_en : 1'b0;
assign ram_write_en1 = (top_mem_sel_override==1'b1 && processor_sel==3'd1) ? ram_write_en : (top_mem_sel_override==1'b0) ? ram_write_en : 1'b0;
assign ram_write_en2 = (top_mem_sel_override==1'b1 && processor_sel==3'd2) ? ram_write_en : (top_mem_sel_override==1'b0) ? ram_write_en : 1'b0;
assign ram_write_en3 = (top_mem_sel_override==1'b1 && processor_sel==3'd3) ? ram_write_en : (top_mem_sel_override==1'b0) ? ram_write_en : 1'b0;
assign ram_write_en4 = (top_mem_sel_override==1'b1 && processor_sel==3'd4) ? ram_write_en : (top_mem_sel_override==1'b0) ? ram_write_en : 1'b0;
assign ram_write_en5 = (top_mem_sel_override==1'b1 && processor_sel==3'd5) ? ram_write_en : (top_mem_sel_override==1'b0) ? ram_write_en : 1'b0;
assign ram_write_en6 = (top_mem_sel_override==1'b1 && processor_sel==3'd6) ? ram_write_en : (top_mem_sel_override==1'b0) ? ram_write_en : 1'b0;

assign ddr_we_p0 = (ddr_interrupt==1'b1 && processor_sel==3'd0) ? ddr_we : 1'b0;
assign ddr_we_p1 = (ddr_interrupt==1'b1 && processor_sel==3'd1) ? ddr_we : 1'b0;
assign ddr_we_p2 = (ddr_interrupt==1'b1 && processor_sel==3'd2) ? ddr_we : 1'b0;
assign ddr_we_p3 = (ddr_interrupt==1'b1 && processor_sel==3'd3) ? ddr_we : 1'b0;
assign ddr_we_p4 = (ddr_interrupt==1'b1 && processor_sel==3'd4) ? ddr_we : 1'b0;
assign ddr_we_p5 = (ddr_interrupt==1'b1 && processor_sel==3'd5) ? ddr_we : 1'b0;
assign ddr_we_p6 = (ddr_interrupt==1'b1 && processor_sel==3'd6) ? ddr_we : 1'b0;

assign ddr_dout =   (processor_sel==3'd0) ? ddr_dout_p0
						: (processor_sel==3'd1) ? ddr_dout_p1 
						: (processor_sel==3'd2) ? ddr_dout_p2
						: (processor_sel==3'd3) ? ddr_dout_p3
						: (processor_sel==3'd4) ? ddr_dout_p4
						: (processor_sel==3'd5) ? ddr_dout_p5						
						: ddr_dout_p6;
						
						
						
MemorySelectBlock MB0(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en0, write_address, read_address, dina_high_p0, dina_low_p0, doutb_p0,
							 ddr_interrupt, ddr_address, ddr_we_p0, ddr_din, ddr_dout_p0);
							 
MemorySelectBlock MB1(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en1, write_address, read_address, dina_high_p1, dina_low_p1, doutb_p1,
							 ddr_interrupt, ddr_address, ddr_we_p1, ddr_din, ddr_dout_p1);

MemorySelectBlock MB2(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en2, write_address, read_address, dina_high_p2, dina_low_p2, doutb_p2,
							 ddr_interrupt, ddr_address, ddr_we_p2, ddr_din, ddr_dout_p2);

MemorySelectBlock MB3(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en3, write_address, read_address, dina_high_p3, dina_low_p3, doutb_p3,
							 ddr_interrupt, ddr_address, ddr_we_p3, ddr_din, ddr_dout_p3);

MemorySelectBlock MB4(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en4, write_address, read_address, dina_high_p4, dina_low_p4, doutb_p4,
							 ddr_interrupt, ddr_address, ddr_we_p4, ddr_din, ddr_dout_p4);

MemorySelectBlock MB5(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en5, write_address, read_address, dina_high_p5, dina_low_p5, doutb_p5,
							 ddr_interrupt, ddr_address, ddr_we_p5, ddr_din, ddr_dout_p5);							 

MemorySelectBlockM6 MB6(clk1, clk2, top_mem_sel, top_mem_sel_override,
							 rdMsel, wtMsel,
							 ram_write_en6, write_address, read_address, dina_high_p6, dina_low_p6, doutb_p6,
							 ddr_interrupt, ddr_address, ddr_we_p6, ddr_din, ddr_dout_p6);							

endmodule
*/
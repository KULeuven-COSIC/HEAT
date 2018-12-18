`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:07:37 07/26/2017 
// Design Name: 
// Module Name:    RLWE_proc_sim 
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
(* keep_hierarchy = "yes" *)
module PROCESSOR_POLY (clk, modulus_sel, instruction,
						interrupt_eth, interrupt_eth_all_processors_accessed, processor_sel, address_eth, dinb_eth, web_eth, doutb_eth, 
						top_mem_sel, rdM0, rdM1, wtM0, wtM1,
						
						ddr_interrupt, ddr_address, ddr_we, ddr_din, ddr_dout,
						
						done
						);

input clk, modulus_sel;	// modulus_sel=0 then q0 to q5 else q6 to q12
input [7:0] instruction;
input interrupt_eth;    // This signal is used by ARM to choose a particular processor for reading or writing
input interrupt_eth_all_processors_accessed;    // This signal is raised (simultaneously with interrupt_eth) to enable writing same data in all 6 processors.
input [2:0] processor_sel;
input [10:0] address_eth;
input [59:0] dinb_eth; 
input web_eth;
output [59:0] doutb_eth;
input [3:0] top_mem_sel, rdM0, rdM1, wtM0, wtM1;

input ddr_interrupt;
input [8:0] ddr_address; 
input ddr_we;
input [239:0] ddr_din;
output [239:0] ddr_dout;

output done;

/////////////////// MEM signals  ///////////////////////////
wire mem_sel_override;			// This is used by the top module to override memory selection
wire [2:0] RdQIn, WtQIn;		// Inputs to the read and write memory index qeues 
wire RdQen, WtQen;				// Input enable for the read and write memory index qeues 
wire [1:0] rdMsel, wtMsel;	// Memory Index selection
wire wea_memsegment0, wea_memsegment1;							// Write enable signal for the RAM
wire [10:0] addra, addrb;		// 9-bit address; 
wire [29:0] dina_high_p0, dina_low_p0;
wire [59:0] doutb_p0;
wire [29:0] dina_high_p1, dina_low_p1;
wire [59:0] doutb_p1;
wire [29:0] dina_high_p2, dina_low_p2;
wire [59:0] doutb_p2;
wire [29:0] dina_high_p3, dina_low_p3;
wire [59:0] doutb_p3;
wire [29:0] dina_high_p4, dina_low_p4;
wire [59:0] doutb_p4;
wire [29:0] dina_high_p5, dina_low_p5;
wire [59:0] doutb_p5;
wire [29:0] dina_high_p6, dina_low_p6;
wire [59:0] doutb_p6;

wire [1:0] rdMsel_n, wtMsel_n;	// Memory Index selection
wire random_enable_n, done_poly_arithmetic_n;
wire wea_em_n;
wire [10:0] addra_em_n, addrb_em_n, mem_write_address_n, mem_read_address_n;

wire [29:0] dina_high_p0_n, dina_low_p0_n;
wire [59:0] doutb_p0_n;
wire [29:0] dina_high_p1_n, dina_low_p1_n;
wire [59:0] doutb_p1_n;
wire [29:0] dina_high_p2_n, dina_low_p2_n;
wire [59:0] doutb_p2_n;
wire [29:0] dina_high_p3_n, dina_low_p3_n;
wire [59:0] doutb_p3_n;
wire [29:0] dina_high_p4_n, dina_low_p4_n;
wire [59:0] doutb_p4_n;
wire [29:0] dina_high_p5_n, dina_low_p5_n;
wire [59:0] doutb_p5_n;
wire [29:0] dina_high_p6_n, dina_low_p6_n;
wire [59:0] doutb_p6_n;

//////////////////// EMU Signals  //////////////////////////
wire rst_comp;
wire data_load;
wire [29:0] in1, in2;
wire message_bit;
wire initiate_loading_r2, initiate_loading_r2_n; 			// this signal is used by the emulator to inform top for loading r2

wire wea_em;
wire [10:0] addra_em, addrb_em, mem_write_address, mem_read_address;
wire random_enable;
wire [8:0] random;

wire [29:0] dina_high_p0_em, dina_low_p0_em;
wire [29:0] dina_high_p1_em, dina_low_p1_em;
wire [29:0] dina_high_p2_em, dina_low_p2_em;
wire [29:0] dina_high_p3_em, dina_low_p3_em;
wire [29:0] dina_high_p4_em, dina_low_p4_em;
wire [29:0] dina_high_p5_em, dina_low_p5_em;
wire [29:0] dina_high_p6_em, dina_low_p6_em;

wire [29:0] dina_high_p0_em_n, dina_low_p0_em_n;
wire [29:0] dina_high_p1_em_n, dina_low_p1_em_n;
wire [29:0] dina_high_p2_em_n, dina_low_p2_em_n;
wire [29:0] dina_high_p3_em_n, dina_low_p3_em_n;
wire [29:0] dina_high_p4_em_n, dina_low_p4_em_n;
wire [29:0] dina_high_p5_em_n, dina_low_p5_em_n;
wire [29:0] dina_high_p6_em_n, dina_low_p6_em_n;

wire wea_p0_em, wea_p1_em, wea_p2_em, wea_p3_em, wea_p4_em, wea_p5_em, wea_p6_em;
wire [10:0] addra_p0_em, addrb_p0_em, addra_p1_em, addrb_p1_em, addra_p2_em, addrb_p2_em, addra_p3_em, addrb_p3_em;
wire [10:0] addra_p4_em, addrb_p4_em, addra_p5_em, addrb_p5_em, addra_p6_em, addrb_p6_em;

wire wea_p0_em_n, wea_p1_em_n, wea_p2_em_n, wea_p3_em_n, wea_p4_em_n, wea_p5_em_n, wea_p6_em_n;
wire [10:0] addra_p0_em_n, addrb_p0_em_n, addra_p1_em_n, addrb_p1_em_n, addra_p2_em_n, addrb_p2_em_n, addra_p3_em_n, addrb_p3_em_n;
wire [10:0] addra_p4_em_n, addrb_p4_em_n, addra_p5_em_n, addrb_p5_em_n, addra_p6_em_n, addrb_p6_em_n;

wire mem_write_en_p0, mem_write_en_p1, mem_write_en_p2, mem_write_en_p3, mem_write_en_p4, mem_write_en_p5, mem_write_en_p6;
wire [10:0] mem_write_address_p0, mem_read_address_p0, mem_write_address_p1, mem_read_address_p1, mem_write_address_p2, mem_read_address_p2;
wire [10:0] mem_write_address_p3, mem_read_address_p3, mem_write_address_p4, mem_read_address_p4, mem_write_address_p5, mem_read_address_p5;
wire [10:0] mem_write_address_p6, mem_read_address_p6;

wire mem_write_en_p0_n, mem_write_en_p1_n, mem_write_en_p2_n, mem_write_en_p3_n, mem_write_en_p4_n, mem_write_en_p5_n, mem_write_en_p6_n;
wire [10:0] mem_write_address_p0_n, mem_read_address_p0_n, mem_write_address_p1_n, mem_read_address_p1_n, mem_write_address_p2_n, mem_read_address_p2_n;
wire [10:0] mem_write_address_p3_n, mem_read_address_p3_n, mem_write_address_p4_n, mem_read_address_p4_n, mem_write_address_p5_n, mem_read_address_p5_n;
wire [10:0] mem_write_address_p6_n, mem_read_address_p6_n;

wire [5:0] state;
wire [29:0] doutH, doutL;
wire message_bit_H, message_bit_L;
wire readon;
wire mem_write_en, mem_write_en_n; 
wire [2:0] processor_sel;

wire [12:0] addra_NTT_ROM_p0_em, addra_NTT_ROM_p0_em_n;
wire [29:0] w_NTT_ROM_p0_em, w_NTT_ROM_p0_em_n;
wire [29:0] w_NTT_ROM_p1_em, w_NTT_ROM_p1_em_n;
wire [29:0] w_NTT_ROM_p2_em, w_NTT_ROM_p2_em_n;
wire [29:0] w_NTT_ROM_p3_em, w_NTT_ROM_p3_em_n;
wire [29:0] w_NTT_ROM_p4_em, w_NTT_ROM_p4_em_n;
wire [29:0] w_NTT_ROM_p5_em, w_NTT_ROM_p5_em_n;
wire [29:0] w_NTT_ROM_p6_em, w_NTT_ROM_p6_em_n;

 (* dont_touch = "true" *)  wire rst_lift, bram_we_lift;
 (* dont_touch = "true" *)  wire [2:0] processor_sel_lift;
 (* dont_touch = "true" *) wire [3:0] memory_sel_lift;
 (* dont_touch = "true" *)  wire [8:0] bram_address_lift;
 (* dont_touch = "true" *)  wire [3:0] MemR0, MemR1, MemW0, MemW1;
 (* dont_touch = "true" *)  wire [239:0] lift_data_in, lift_data_out;
 (* dont_touch = "true" *)  wire done_poly_arithmetic, done_lift;
 (* dont_touch = "true" *)  wire [239:0] ddr_dout_or_lift_data_in;

assign done = (rst_lift==1'b0) ? done_lift : done_poly_arithmetic; 

assign mem_sel_override = interrupt_eth;

assign mem_write_en_p0 = (interrupt_eth) ? web_eth : wea_p0_em;
assign mem_write_address_p0 = (interrupt_eth) ? address_eth : addra_p0_em;
assign mem_read_address_p0 = (interrupt_eth) ? address_eth : addrb_p0_em;

assign mem_write_en_p1 = (interrupt_eth) ? web_eth : wea_p1_em;
assign mem_write_address_p1 = (interrupt_eth) ? address_eth : addra_p1_em;
assign mem_read_address_p1 = (interrupt_eth) ? address_eth : addrb_p1_em;

assign mem_write_en_p2 = (interrupt_eth) ? web_eth : wea_p2_em;
assign mem_write_address_p2 = (interrupt_eth) ? address_eth : addra_p2_em;
assign mem_read_address_p2 = (interrupt_eth) ? address_eth : addrb_p2_em;

assign mem_write_en_p3 = (interrupt_eth) ? web_eth : wea_p3_em;
assign mem_write_address_p3 = (interrupt_eth) ? address_eth : addra_p3_em;
assign mem_read_address_p3 = (interrupt_eth) ? address_eth : addrb_p3_em;

assign mem_write_en_p4 = (interrupt_eth) ? web_eth : wea_p4_em;
assign mem_write_address_p4 = (interrupt_eth) ? address_eth : addra_p4_em;
assign mem_read_address_p4 = (interrupt_eth) ? address_eth : addrb_p4_em;

assign mem_write_en_p5 = (interrupt_eth) ? web_eth : wea_p5_em;
assign mem_write_address_p5 = (interrupt_eth) ? address_eth : addra_p5_em;
assign mem_read_address_p5 = (interrupt_eth) ? address_eth : addrb_p5_em;

assign mem_write_en_p6 = (interrupt_eth) ? web_eth : wea_p6_em;
assign mem_write_address_p6 = (interrupt_eth) ? address_eth : addra_p6_em;
assign mem_read_address_p6 = (interrupt_eth) ? address_eth : addrb_p6_em;

/////

assign mem_write_en_p0_n = (interrupt_eth) ? 1'b0 : wea_p0_em_n;
assign mem_write_address_p0_n = (interrupt_eth) ? address_eth : addra_p0_em_n;
assign mem_read_address_p0_n = (interrupt_eth) ? address_eth : addrb_p0_em_n;

assign mem_write_en_p1_n = (interrupt_eth) ? 1'b0 : wea_p1_em_n;
assign mem_write_address_p1_n = (interrupt_eth) ? address_eth : addra_p1_em_n;
assign mem_read_address_p1_n = (interrupt_eth) ? address_eth : addrb_p1_em_n;

assign mem_write_en_p2_n = (interrupt_eth) ? 1'b0 : wea_p2_em_n;
assign mem_write_address_p2_n = (interrupt_eth) ? address_eth : addra_p2_em_n;
assign mem_read_address_p2_n = (interrupt_eth) ? address_eth : addrb_p2_em_n;

assign mem_write_en_p3_n = (interrupt_eth) ? 1'b0 : wea_p3_em_n;
assign mem_write_address_p3_n = (interrupt_eth) ? address_eth : addra_p3_em_n;
assign mem_read_address_p3_n = (interrupt_eth) ? address_eth : addrb_p3_em_n;

assign mem_write_en_p4_n = (interrupt_eth) ? 1'b0 : wea_p4_em_n;
assign mem_write_address_p4_n = (interrupt_eth) ? address_eth : addra_p4_em_n;
assign mem_read_address_p4_n = (interrupt_eth) ? address_eth : addrb_p4_em_n;

assign mem_write_en_p5_n = (interrupt_eth) ? 1'b0 : wea_p5_em_n;
assign mem_write_address_p5_n = (interrupt_eth) ? address_eth : addra_p5_em_n;
assign mem_read_address_p5_n = (interrupt_eth) ? address_eth : addrb_p5_em_n;

assign mem_write_en_p6_n = (interrupt_eth) ? 1'b0 : wea_p6_em_n;
assign mem_write_address_p6_n = (interrupt_eth) ? address_eth : addra_p6_em_n;
assign mem_read_address_p6_n = (interrupt_eth) ? address_eth : addrb_p6_em_n;




assign {dina_high_p0, dina_low_p0} = {dina_high_p0_em, dina_low_p0_em};
assign {dina_high_p1, dina_low_p1} = {dina_high_p1_em, dina_low_p1_em};
assign {dina_high_p2, dina_low_p2} = {dina_high_p2_em, dina_low_p2_em};
assign {dina_high_p3, dina_low_p3} = {dina_high_p3_em, dina_low_p3_em};
assign {dina_high_p4, dina_low_p4} = {dina_high_p4_em, dina_low_p4_em};
assign {dina_high_p5, dina_low_p5} = {dina_high_p5_em, dina_low_p5_em};
assign {dina_high_p6, dina_low_p6} = {dina_high_p6_em, dina_low_p6_em};

assign {dina_high_p0_n, dina_low_p0_n} = {dina_high_p0_em_n, dina_low_p0_em_n};
assign {dina_high_p1_n, dina_low_p1_n} = {dina_high_p1_em_n, dina_low_p1_em_n};
assign {dina_high_p2_n, dina_low_p2_n} = {dina_high_p2_em_n, dina_low_p2_em_n};
assign {dina_high_p3_n, dina_low_p3_n} = {dina_high_p3_em_n, dina_low_p3_em_n};
assign {dina_high_p4_n, dina_low_p4_n} = {dina_high_p4_em_n, dina_low_p4_em_n};
assign {dina_high_p5_n, dina_low_p5_n} = {dina_high_p5_em_n, dina_low_p5_em_n};
assign {dina_high_p6_n, dina_low_p6_n} = {dina_high_p6_em_n, dina_low_p6_em_n};


wire [3:0] rdM, wtM;
assign rdM = (rdMsel[0]) ? rdM1 : rdM0;
assign wtM = (wtMsel[0]) ? wtM1 : wtM0;


assign rst_comp = (instruction==8'd0) ? 1'b1 : 1'b0;


emulator #(0)		EM
					  (clk, modulus_sel, rst_comp, instruction,
						data_load, in1, in2, message_bit, 
						initiate_loading_r2,
						rdMsel, wtMsel,
						
						wea_p0_em, addra_p0_em, addrb_p0_em, 
						wea_p1_em, addra_p1_em, addrb_p1_em,						
						wea_p2_em, addra_p2_em, addrb_p2_em,
						wea_p3_em, addra_p3_em, addrb_p3_em,
						wea_p4_em, addra_p4_em, addrb_p4_em,
						wea_p5_em, addra_p5_em, addrb_p5_em,
						wea_p6_em, addra_p6_em, addrb_p6_em,
						
						random_enable, random, 
						
						dina_high_p0_em, dina_low_p0_em, doutb_p0,
						dina_high_p1_em, dina_low_p1_em, doutb_p1,
						dina_high_p2_em, dina_low_p2_em, doutb_p2,

						dina_high_p3_em, dina_low_p3_em, doutb_p3,
						dina_high_p4_em, dina_low_p4_em, doutb_p4,
						dina_high_p5_em, dina_low_p5_em, doutb_p5,
						dina_high_p6_em, dina_low_p6_em, doutb_p6,
						addra_NTT_ROM_p0_em, 
						w_NTT_ROM_p0_em, 
						w_NTT_ROM_p1_em,
						w_NTT_ROM_p2_em,
						w_NTT_ROM_p3_em,
						w_NTT_ROM_p4_em,
						w_NTT_ROM_p5_em,
						w_NTT_ROM_p6_em,
						done_poly_arithmetic
					 );

emulator	#(1)		EM_n
					  (clk, modulus_sel, rst_comp, instruction,
						data_load, in1, in2, message_bit, 
						initiate_loading_r2_n,
						rdMsel_n, wtMsel_n, 

						wea_p0_em_n, addra_p0_em_n, addrb_p0_em_n, 
						wea_p1_em_n, addra_p1_em_n, addrb_p1_em_n,
						wea_p2_em_n, addra_p2_em_n, addrb_p2_em_n,	
						wea_p3_em_n, addra_p3_em_n, addrb_p3_em_n,
						wea_p4_em_n, addra_p4_em_n, addrb_p4_em_n,
						wea_p5_em_n, addra_p5_em_n, addrb_p5_em_n,
						wea_p6_em_n, addra_p6_em_n, addrb_p6_em_n,			
												
						random_enable_n, random, 
						
						dina_high_p0_em_n, dina_low_p0_em_n, doutb_p0_n,
						dina_high_p1_em_n, dina_low_p1_em_n, doutb_p1_n,
						dina_high_p2_em_n, dina_low_p2_em_n, doutb_p2_n,
						dina_high_p3_em_n, dina_low_p3_em_n, doutb_p3_n,
						dina_high_p4_em_n, dina_low_p4_em_n, doutb_p4_n,
						dina_high_p5_em_n, dina_low_p5_em_n, doutb_p5_n,
						dina_high_p6_em_n, dina_low_p6_em_n, doutb_p6_n,
						addra_NTT_ROM_p0_em_n, 
						w_NTT_ROM_p0_em_n,
						w_NTT_ROM_p1_em_n,
						w_NTT_ROM_p2_em_n,
						w_NTT_ROM_p3_em_n,
						w_NTT_ROM_p4_em_n,
						w_NTT_ROM_p5_em_n,
						w_NTT_ROM_p6_em_n,
						done_poly_arithmetic_n
					 );
					 


assign MemR0 = rdM0;
assign MemR1 = rdM1;
assign MemW0 = wtM0;
assign MemW1 = wtM1;

assign rst_lift = (instruction==8'd5 || instruction==8'd6 || instruction==8'd7) ? 1'b0 : 1'b1;


//lift_control_single_core    LC(	clk, rst_lift, instruction, MemR0, MemR1, MemW0, MemW1, 
//												processor_sel_lift, memory_sel_lift, bram_address_lift, bram_we_lift,
//												lift_data_in, lift_data_out,
//												done_lift
//											);

//lift_control_parallel_cores	LC(	clk, rst_lift, instruction, MemR0, MemR1, MemW0, MemW1, 
//												processor_sel_lift, memory_sel_lift, bram_address_lift, bram_we_lift,
//												lift_data_in, lift_data_out,
//												done_lift
//											);

//lift_control_parallel_cores4 LC(	clk, rst_lift, instruction, MemR0, MemR1, MemW0, MemW1, 
//												processor_sel_lift, memory_sel_lift, bram_address_lift, bram_we_lift,
//												lift_data_in, lift_data_out,
//												done_lift
//											);


lift_control_wrapper_2core  LC_shoup(clk, rst_lift, instruction, MemR0, MemR1, MemW0, MemW1, 
                          processor_sel_lift, memory_sel_lift, bram_address_lift, bram_we_lift,
						  lift_data_in, lift_data_out,
                          done_lift	
						  );



/*
wire [3:0] top_mem_sel_new = (rst_lift==1'b0) ? memory_sel_lift : top_mem_sel;
wire [2:0] processor_sel_new = (rst_lift==1'b0) ? processor_sel_lift : processor_sel;
wire ddr_lift_interrupt = (rst_lift==1'b0) ? 1'b1 : ddr_interrupt;
wire [8:0] ddr_lift_address = (rst_lift==1'b0) ? bram_address_lift : ddr_address;
wire ddr_lift_we = (rst_lift==1'b0) ? bram_we_lift : ddr_we;
wire [239:0] ddr_din_or_lift_data_out = (rst_lift==1'b0) ? lift_data_out : ddr_din;
assign lift_data_in = ddr_dout_or_lift_data_in;
assign ddr_dout = ddr_dout_or_lift_data_in;
*/

wire [3:0] top_mem_sel_new = (rst_lift==1'b0) ? memory_sel_lift : top_mem_sel;
wire [2:0] processor_sel_new = (rst_lift==1'b0) ? processor_sel_lift : processor_sel;
wire ddr_lift_interrupt = (rst_lift==1'b0) ? 1'b1 : 1'b0;
wire [8:0] ddr_lift_address = (rst_lift==1'b0) ? bram_address_lift : 9'd0;
wire ddr_lift_we = (rst_lift==1'b0) ? bram_we_lift : 1'b0;
wire [239:0] ddr_din_or_lift_data_out = (rst_lift==1'b0) ? lift_data_out : 240'd0;
assign lift_data_in = ddr_dout_or_lift_data_in;
assign ddr_dout = ddr_dout_or_lift_data_in;

reg [2:0] processor_sel_new_latched;

always @(posedge clk) 
    processor_sel_new_latched <= processor_sel_new;

wire [2:0] processor_sel_to_MB;

assign processor_sel_to_MB = (interrupt_eth==1'b1 && web_eth==1'b0) ? processor_sel_new_latched :
                                                                      processor_sel_new;
				
NTT_ROM  Twiddel(clk, instruction, modulus_sel, addra_NTT_ROM_p0_em, addra_NTT_ROM_p0_em_n, 
                        w_NTT_ROM_p0_em, w_NTT_ROM_p0_em_n,
                        w_NTT_ROM_p1_em, w_NTT_ROM_p1_em_n,
                        w_NTT_ROM_p2_em, w_NTT_ROM_p2_em_n,
                        w_NTT_ROM_p3_em, w_NTT_ROM_p3_em_n,
                        w_NTT_ROM_p4_em, w_NTT_ROM_p4_em_n,
                        w_NTT_ROM_p5_em, w_NTT_ROM_p5_em_n,
                        w_NTT_ROM_p6_em, w_NTT_ROM_p6_em_n
                        );
                                                                                          
MemoryGroup_eth	MB_eth(clk, clk,
						top_mem_sel_new, mem_sel_override, interrupt_eth_all_processors_accessed,
						rdM, wtM,		
						processor_sel_to_MB,
						interrupt_eth, dinb_eth, web_eth, doutb_eth,

						mem_write_en_p0, mem_write_address_p0, mem_read_address_p0,
						mem_write_en_p1, mem_write_address_p1, mem_read_address_p1,
						mem_write_en_p2, mem_write_address_p2, mem_read_address_p2,
						mem_write_en_p3, mem_write_address_p3, mem_read_address_p3,
						mem_write_en_p4, mem_write_address_p4, mem_read_address_p4,
						mem_write_en_p5, mem_write_address_p5, mem_read_address_p5,
						mem_write_en_p6, mem_write_address_p6, mem_read_address_p6,						

						dina_high_p0, dina_low_p0, doutb_p0,
						dina_high_p1, dina_low_p1, doutb_p1,
						dina_high_p2, dina_low_p2, doutb_p2,
						dina_high_p3, dina_low_p3, doutb_p3,
						dina_high_p4, dina_low_p4, doutb_p4,
						dina_high_p5, dina_low_p5, doutb_p5,
						dina_high_p6, dina_low_p6, doutb_p6,
						
						mem_write_en_p0_n, mem_write_address_p0_n, mem_read_address_p0_n,
						mem_write_en_p1_n, mem_write_address_p1_n, mem_read_address_p1_n,
						mem_write_en_p2_n, mem_write_address_p2_n, mem_read_address_p2_n,
						mem_write_en_p3_n, mem_write_address_p3_n, mem_read_address_p3_n,
						mem_write_en_p4_n, mem_write_address_p4_n, mem_read_address_p4_n,
						mem_write_en_p5_n, mem_write_address_p5_n, mem_read_address_p5_n,
						mem_write_en_p6_n, mem_write_address_p6_n, mem_read_address_p6_n,						
						
						dina_high_p0_n, dina_low_p0_n, doutb_p0_n,
						dina_high_p1_n, dina_low_p1_n, doutb_p1_n,
						dina_high_p2_n, dina_low_p2_n, doutb_p2_n,
						dina_high_p3_n, dina_low_p3_n, doutb_p3_n,
						dina_high_p4_n, dina_low_p4_n, doutb_p4_n,
						dina_high_p5_n, dina_low_p5_n, doutb_p5_n,
						dina_high_p6_n, dina_low_p6_n, doutb_p6_n,						
						
						ddr_lift_interrupt, ddr_lift_address, ddr_lift_we, ddr_din_or_lift_data_out, ddr_dout_or_lift_data_in
						);
				

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:23:05 06/06/2016 
// Design Name: 
// Module Name:    MemorySelectBlock 
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
module MemorySelectBlock_eth(clk1, clk2,
								 top_mem_sel, mem_sel_override,
								 RdQsel, WtQsel, 
								 wea, addra, addrb, dina_high, dina_low, doutb,
 								 wea_n, addra_n, addrb_n, dina_high_n, dina_low_n, doutb_n,
								 ddr_interrupt, ddr_address, ddr_we, ddr_din, ddr_dout);
input clk1, clk2;
input [3:0] top_mem_sel;				// This is used by the top module to seleach one of the two memory for read/write
input mem_sel_override;			// This is used by the top module to override memory selection

input [3:0] RdQsel, WtQsel;			// Memory Index selection
input wea;							// Write enable signal for the RAM
input [10:0] addra, addrb;		// 9-bit address; 
input [29:0] dina_high, dina_low;
output [59:0] doutb;

input wea_n;							// Write enable signal for the RAM
input [10:0] addra_n, addrb_n;		// 9-bit address; 
input [29:0] dina_high_n, dina_low_n;
output [59:0] doutb_n;

input ddr_interrupt;
input [8:0] ddr_address;
input ddr_we;
input [239:0] ddr_din;
output [239:0] ddr_dout;

wire [1:0] addra_2msb, addrb_2msb;
wire wea4;
wire [59:0] doutb4;
wire [3:0] RdRegsel, WtRegsel;
wire [3:0] doutb_sel_wire;
reg  [3:0] doutb_sel;
wire [59:0] dina;
wire [29:0] doutb_high, doutb_low;

wire wea4_n;
wire [59:0] doutb4_n;
wire [59:0] dina_n;

wire ddr_we4;
wire [239:0] ddr_dout4;

assign RdRegsel = (mem_sel_override) ? top_mem_sel : RdQsel;
assign WtRegsel = (mem_sel_override) ? top_mem_sel : WtQsel;

assign doutb_sel_wire =  RdRegsel;

always @(posedge clk2)	// Delayed by one cycle as data in dout appears after one cycle.
doutb_sel <= doutb_sel_wire;
	
assign doutb = doutb4;
assign doutb_n = doutb4_n;

assign wea4 = (WtRegsel==4'd4) & wea;
assign wea4_n = (WtRegsel==4'd4) & wea_n;

assign dina = {dina_high, dina_low};
assign dina_n = {dina_high_n, dina_low_n};

assign ddr_we4 = (top_mem_sel==4'd4) & ddr_we;
assign ddr_dout =   ddr_dout4;	
						
						
memory2048 ME4(clk1, clk2, 
                  addra, addrb, wea4, dina, doutb4,
						addra_n, addrb_n, wea4_n, dina_n, doutb4_n,
						ddr_interrupt, ddr_address, ddr_we4, ddr_din, ddr_dout4
						);
						
endmodule


module MemorySelectBlock(clk1, clk2,
								 top_mem_sel, mem_sel_override,
								 RdQsel, WtQsel, 
								 wea, addra, addrb, dina_high, dina_low, doutb4, doutb,
								 wea_n, addra_n, addrb_n, dina_high_n, dina_low_n, doutb4_n, doutb_n,
								 ddr_interrupt, ddr_address, ddr_we, ddr_din, ddr_dout);
input clk1, clk2;
input [3:0] top_mem_sel;				// This is used by the top module to seleach one of the two memory for read/write
input mem_sel_override;			// This is used by the top module to override memory selection

input [3:0] RdQsel, WtQsel;			// Memory Index selection

input wea;							// Write enable signal for the RAM
input [10:0] addra, addrb;		// 9-bit address; 
input [29:0] dina_high, dina_low;
input [59:0] doutb4;
output [59:0] doutb;

input wea_n;							// Write enable signal for the RAM
input [10:0] addra_n, addrb_n;		// 9-bit address; 
input [29:0] dina_high_n, dina_low_n;
input [59:0] doutb4_n;
output [59:0] doutb_n;

input ddr_interrupt;
input [8:0] ddr_address;
input ddr_we;
input [239:0] ddr_din;
output [239:0] ddr_dout;

wire [1:0] addra_2msb, addrb_2msb;
wire wea0, wea1, wea2, wea3, wea4, wea5, wea6, wea7, wea8, wea9, wea10, wea11;
wire [59:0] doutb0, doutb1, doutb2, doutb3, doutb5, doutb6, doutb7, doutb8, doutb9, doutb10, doutb11;
wire [3:0] RdRegsel, WtRegsel;
wire [3:0] doutb_sel_wire;
reg  [3:0] doutb_sel;
wire [59:0] dina;

wire wea0_n, wea1_n, wea2_n, wea3_n, wea5_n, wea6_n, wea7_n, wea8_n, wea9_n, wea10_n;
wire [59:0] doutb0_n, doutb1_n, doutb2_n, doutb3_n, doutb5_n, doutb6_n, doutb7_n, doutb8_n, doutb9_n, doutb10_n;
wire [59:0] dina_n;
wire [29:0] doutb_hign_n, doutb_low_n;

wire ddr_we0, ddr_we1, ddr_we2, ddr_we3, ddr_we4, ddr_we5, ddr_we6, ddr_we7, ddr_we8, ddr_we9, ddr_we10, ddr_we11;
wire [239:0] ddr_dout0, ddr_dout1, ddr_dout2, ddr_dout3;
wire [239:0] ddr_dout4, ddr_dout5, ddr_dout6, ddr_dout7;
wire [239:0] ddr_dout8, ddr_dout9, ddr_dout10, ddr_dout11;

assign RdRegsel = (mem_sel_override) ? top_mem_sel : RdQsel;
assign WtRegsel = (mem_sel_override) ? top_mem_sel : WtQsel;

assign doutb_sel_wire =  RdRegsel;
								
always @(posedge clk2)	// Delayed by one cycle as data in dout appears after one cycle.
doutb_sel <= doutb_sel_wire;
								
assign doutb =   	(doutb_sel==4'd1) ? doutb1 :
						(doutb_sel==4'd2) ? doutb2 :
						(doutb_sel==4'd3) ? doutb3 :
						(doutb_sel==4'd4) ? doutb4:
						(doutb_sel==4'd5) ? doutb5 :
						(doutb_sel==4'd6) ? doutb6 :
						(doutb_sel==4'd7) ? doutb7 :
						(doutb_sel==4'd8) ? doutb8 :
						(doutb_sel==4'd9) ? doutb9 : 
						60'd0;

assign doutb_n =  (doutb_sel==4'd1) ? doutb1_n :
						(doutb_sel==4'd2) ? doutb2_n :
						(doutb_sel==4'd3) ? doutb3_n :
						(doutb_sel==4'd4) ? doutb4_n :
						(doutb_sel==4'd5) ? doutb5_n :
						(doutb_sel==4'd6) ? doutb6_n :
						(doutb_sel==4'd7) ? doutb7_n :
						(doutb_sel==4'd8) ? doutb8_n :
						(doutb_sel==4'd9) ? doutb9_n : 
						60'd0;
					
assign wea1 = (WtRegsel==4'd1) & wea;
assign wea2 = (WtRegsel==4'd2) & wea;
assign wea3 = (WtRegsel==4'd3) & wea;
assign wea5 = (WtRegsel==4'd5) & wea;
assign wea6 = (WtRegsel==4'd6) & wea;
assign wea7 = (WtRegsel==4'd7) & wea;
assign wea8 = (WtRegsel==4'd8) & wea;
assign wea9 = (WtRegsel==4'd9) & wea;

assign wea1_n = (WtRegsel==4'd1) & wea_n;
assign wea2_n = (WtRegsel==4'd2) & wea_n;
assign wea3_n = (WtRegsel==4'd3) & wea_n;
assign wea5_n = (WtRegsel==4'd5) & wea_n;
assign wea6_n = (WtRegsel==4'd6) & wea_n;
assign wea7_n = (WtRegsel==4'd7) & wea_n;
assign wea8_n = (WtRegsel==4'd8) & wea_n;
assign wea9_n = (WtRegsel==4'd9) & wea_n;

assign dina = {dina_high, dina_low};

assign dina_n = {dina_high_n, dina_low_n};	

assign ddr_we1 = (top_mem_sel==4'd1) & ddr_we;
assign ddr_we2 = (top_mem_sel==4'd2) & ddr_we;
assign ddr_we3 = (top_mem_sel==4'd3) & ddr_we;
assign ddr_we5 = (top_mem_sel==4'd5) & ddr_we;
assign ddr_we6 = (top_mem_sel==4'd6) & ddr_we;
assign ddr_we7 = (top_mem_sel==4'd7) & ddr_we;
assign ddr_we8 = (top_mem_sel==4'd8) & ddr_we;
assign ddr_we9 = (top_mem_sel==4'd9) & ddr_we;

assign ddr_dout =   (top_mem_sel==4'd1) ? ddr_dout1 :
                    (top_mem_sel==4'd2) ? ddr_dout2 :
                    (top_mem_sel==4'd3) ? ddr_dout3 :
                    (top_mem_sel==4'd5) ? ddr_dout5 :
                    (top_mem_sel==4'd6) ? ddr_dout6 :
                    (top_mem_sel==4'd7) ? ddr_dout7 :
                    (top_mem_sel==4'd8) ? ddr_dout8 :
                    ddr_dout9;		
						
memory2048 ME1(clk1, clk2, 
                  addra, addrb, wea1, dina, doutb1,
                  addra_n, addrb_n, wea1_n, dina_n, doutb1_n,						
						ddr_interrupt, ddr_address, ddr_we1, ddr_din, ddr_dout1
						);						

memory2048 ME2(clk1, clk2, 
                  addra, addrb, wea2, dina, doutb2,
                  addra_n, addrb_n, wea2_n, dina_n, doutb2_n,						
						ddr_interrupt, ddr_address, ddr_we2, ddr_din, ddr_dout2
						);

memory2048 ME3(clk1, clk2,
                  addra, addrb, wea3, dina, doutb3,
                  addra_n, addrb_n, wea3_n, dina_n, doutb3_n,						
						ddr_interrupt, ddr_address, ddr_we3, ddr_din, ddr_dout3
						);

						
memory2048 ME5(clk1, clk2, 
                  addra, addrb, wea5, dina, doutb5,
                  addra_n, addrb_n, wea5_n, dina_n, doutb5_n,						
						ddr_interrupt, ddr_address, ddr_we5, ddr_din, ddr_dout5
						);						
						
memory2048 ME6(clk1, clk2,
                  addra, addrb, wea6, dina, doutb6,
                  addra_n, addrb_n, wea6_n, dina_n, doutb6_n,						
						ddr_interrupt, ddr_address, ddr_we6, ddr_din, ddr_dout6
						);

memory2048 ME7(clk1, clk2,
                  addra, addrb, wea7, dina, doutb7,
                  addra_n, addrb_n, wea7_n, dina_n, doutb7_n,						
						ddr_interrupt, ddr_address, ddr_we7, ddr_din, ddr_dout7
						);
						
memory2048 ME8(clk1, clk2, 
                  addra, addrb, wea8, dina, doutb8,
                  addra_n, addrb_n, wea8_n, dina_n, doutb8_n,						
						ddr_interrupt, ddr_address, ddr_we8, ddr_din, ddr_dout8
						);
						
memory2048 ME9(clk1, clk2,
                  addra, addrb, wea9, dina, doutb9,
                  addra_n, addrb_n, wea9_n, dina_n, doutb9_n,						
						ddr_interrupt, ddr_address, ddr_we9, ddr_din, ddr_dout9
						);
						
endmodule

/*
module MemorySelectBlockM6(clk1, clk2,
								 top_mem_sel, mem_sel_override,
								 RdQsel, WtQsel, 
								 wea, addra, addrb, dina_high, dina_low, doutb4, doutb,
								 wea_n, addra_n, addrb_n, dina_high_n, dina_low_n, doutb4_n, doutb_n,
								 ddr_interrupt, ddr_address, ddr_we, ddr_din, ddr_dout);
input clk1, clk2;
input [3:0] top_mem_sel;				// This is used by the top module to seleach one of the two memory for read/write
input mem_sel_override;			// This is used by the top module to override memory selection

input [3:0] RdQsel, WtQsel;			// Memory Index selection
input wea;							// Write enable signal for the RAM
input [10:0] addra, addrb;		// 9-bit address; 
input [29:0] dina_high, dina_low;
input [59:0] doutb4;
output [59:0] doutb;

input wea_n;							// Write enable signal for the RAM
input [10:0] addra_n, addrb_n;	// 9-bit address; 
input [29:0] dina_high_n, dina_low_n;
input [59:0] doutb4_n;
output [59:0] doutb_n;


input ddr_interrupt;
input [8:0] ddr_address;
input ddr_we;
input [239:0] ddr_din;
output [239:0] ddr_dout;

wire [1:0] addra_2msb, addrb_2msb;
wire wea5, wea6, wea7, wea8, wea9;
wire wea5_n, wea6_n, wea7_n, wea8_n, wea9_n;
wire [59:0] doutb5, doutb6, doutb7, doutb8, doutb9;
wire [59:0] doutb5_n, doutb6_n, doutb7_n, doutb8_n, doutb9_n;
wire [3:0] RdRegsel, WtRegsel;
wire [3:0] doutb_sel_wire;
reg  [3:0] doutb_sel;
wire [59:0] dina;
wire [59:0] dina_n;

wire ddr_we5, ddr_we6, ddr_we7, ddr_we8, ddr_we9, ddr_we10, ddr_we11;
wire [239:0] ddr_dout5, ddr_dout6, ddr_dout7;
wire [239:0] ddr_dout8, ddr_dout9, ddr_dout10, ddr_dout11;

assign RdRegsel = (mem_sel_override) ? top_mem_sel : RdQsel;
assign WtRegsel = (mem_sel_override) ? top_mem_sel : WtQsel;

assign doutb_sel_wire =  RdRegsel;
								
always @(posedge clk2)	// Delayed by one cycle as data in dout appears after one cycle.
doutb_sel <= doutb_sel_wire;
								
assign doutb =   	(doutb_sel==4'd4) ? doutb4 :
						(doutb_sel==4'd5) ? doutb5 :
						(doutb_sel==4'd6) ? doutb6 :
						(doutb_sel==4'd7) ? doutb7 :
						(doutb_sel==4'd8) ? doutb8 :
						(doutb_sel==4'd9) ? doutb9 :
						60'd0;
					
assign doutb_n =  (doutb_sel==4'd4) ? doutb4_n :
						(doutb_sel==4'd5) ? doutb5_n :
						(doutb_sel==4'd6) ? doutb6_n :
						(doutb_sel==4'd7) ? doutb7_n :
						(doutb_sel==4'd8) ? doutb8_n :
						(doutb_sel==4'd9) ? doutb9_n :
						60'd0;
						
assign wea5 = (WtRegsel==4'd5) & wea;
assign wea6 = (WtRegsel==4'd6) & wea;
assign wea7 = (WtRegsel==4'd7) & wea;
assign wea8 = (WtRegsel==4'd8) & wea;
assign wea9 = (WtRegsel==4'd9) & wea;

assign wea5_n = (WtRegsel==4'd5) & wea_n;
assign wea6_n = (WtRegsel==4'd6) & wea_n;
assign wea7_n = (WtRegsel==4'd7) & wea_n;
assign wea8_n = (WtRegsel==4'd8) & wea_n;
assign wea9_n = (WtRegsel==4'd9) & wea_n;

assign dina = {dina_high, dina_low};
assign dina_n = {dina_high_n, dina_low_n};	


assign ddr_we5 = (top_mem_sel==4'd5) & ddr_we;
assign ddr_we6 = (top_mem_sel==4'd6) & ddr_we;
assign ddr_we7 = (top_mem_sel==4'd7) & ddr_we;
assign ddr_we8 = (top_mem_sel==4'd8) & ddr_we;
assign ddr_we9 = (top_mem_sel==4'd9) & ddr_we;


assign ddr_dout =   (top_mem_sel==4'd5) ? ddr_dout5 :
                    (top_mem_sel==4'd6) ? ddr_dout6 :
                    (top_mem_sel==4'd7) ? ddr_dout7 :
                    (top_mem_sel==4'd8) ? ddr_dout8 :
                    ddr_dout9 ;
						  

memory2048 ME5(clk1, clk2, 
                  addra, addrb, wea5, dina, doutb5,
                  addra_n, addrb_n, wea5_n, dina_n, doutb5_n,						
						ddr_interrupt, ddr_address, ddr_we5, ddr_din, ddr_dout5
						);						
						
memory2048 ME6(clk1, clk2,
                  addra, addrb, wea6, dina, doutb6,
                  addra_n, addrb_n, wea6_n, dina_n, doutb6_n,						
						ddr_interrupt, ddr_address, ddr_we6, ddr_din, ddr_dout6
						);

memory2048 ME7(clk1, clk2, 
                  addra, addrb, wea7, dina, doutb7,
                  addra_n, addrb_n, wea7_n, dina_n, doutb7_n,						
						ddr_interrupt, ddr_address, ddr_we7, ddr_din, ddr_dout7
						);
						
memory2048 ME8(clk1, clk2,
                  addra, addrb, wea8, dina, doutb8,
                  addra_n, addrb_n, wea8_n, dina_n, doutb8_n,						
						ddr_interrupt, ddr_address, ddr_we8, ddr_din, ddr_dout8
						);
						
memory2048 ME9(clk1, clk2,
                  addra, addrb, wea9, dina, doutb9,
                  addra_n, addrb_n, wea9_n, dina_n, doutb9_n,						
						ddr_interrupt, ddr_address, ddr_we9, ddr_din, ddr_dout9
						);
				
endmodule
*/























//module MemorySelectBlock_old(clk1, clk2,
//								 top_mem_sel, mem_sel_override,
//								 RdQsel, WtQsel, 
//								 wea, addra, addrb, dina_high, dina_low, doutb,
//								 ddr_interrupt, ddr_address, ddr_we, ddr_din, ddr_dout);
//input clk1, clk2;
//input [3:0] top_mem_sel;				// This is used by the top module to seleach one of the two memory for read/write
//input mem_sel_override;			// This is used by the top module to override memory selection

//input [3:0] RdQsel, WtQsel;			// Memory Index selection
//input wea;							// Write enable signal for the RAM
//input [10:0] addra, addrb;		// 9-bit address; 
//input [29:0] dina_high, dina_low;

//output [59:0] doutb;

//input ddr_interrupt;
//input [8:0] ddr_address;
//input ddr_we;
//input [239:0] ddr_din;
//output [239:0] ddr_dout;

////reg [2:0] RdQ1, RdQ2, RdQ3, WtQ1, WtQ2, WtQ3;
//wire [1:0] addra_2msb, addrb_2msb;
//wire wea0, wea1, wea2, wea3, wea4, wea5, wea6, wea7, wea8, wea9, wea10, wea11;
//wire [59:0] doutb0, doutb1, doutb2, doutb3, doutb4, doutb5, doutb6, doutb7, doutb8, doutb9, doutb10, doutb11;
//wire [3:0] RdRegsel, WtRegsel;
//wire [3:0] doutb_sel_wire;
//reg  [3:0] doutb_sel;
//wire [59:0] dina;
//wire [29:0] doutb_hign, doutb_low;

//wire ddr_we0, ddr_we1, ddr_we2, ddr_we3, ddr_we4, ddr_we5, ddr_we6, ddr_we7, ddr_we8, ddr_we9, ddr_we10, ddr_we11;
//wire [239:0] ddr_dout0, ddr_dout1, ddr_dout2, ddr_dout3;
//wire [239:0] ddr_dout4, ddr_dout5, ddr_dout6, ddr_dout7;
//wire [239:0] ddr_dout8, ddr_dout9, ddr_dout10, ddr_dout11;

//assign RdRegsel = (mem_sel_override) ? top_mem_sel : RdQsel;
//assign WtRegsel = (mem_sel_override) ? top_mem_sel : WtQsel;

//assign doutb_sel_wire =  RdRegsel;
								
//always @(posedge clk2)	// Delayed by one cycle as data in dout appears after one cycle.
//doutb_sel <= doutb_sel_wire;
								
//assign doutb =   	(doutb_sel==4'd0) ? doutb0 :
//						(doutb_sel==4'd1) ? doutb1 :
//						(doutb_sel==4'd2) ? doutb2 :
//						(doutb_sel==4'd3) ? doutb3 :
//						(doutb_sel==4'd4) ? doutb4 :
//						(doutb_sel==4'd5) ? doutb5 :
//						(doutb_sel==4'd6) ? doutb6 :
//						(doutb_sel==4'd7) ? doutb7 :
//						(doutb_sel==4'd8) ? doutb8 :
//						(doutb_sel==4'd9) ? doutb9 :
//						(doutb_sel==4'd10) ? doutb10 :
//						doutb11;	
					
//assign wea0 = (WtRegsel==4'd0) & wea;
//assign wea1 = (WtRegsel==4'd1) & wea;
//assign wea2 = (WtRegsel==4'd2) & wea;
//assign wea3 = (WtRegsel==4'd3) & wea;
//assign wea4 = (WtRegsel==4'd4) & wea;
//assign wea5 = (WtRegsel==4'd5) & wea;
//assign wea6 = (WtRegsel==4'd6) & wea;
//assign wea7 = (WtRegsel==4'd7) & wea;
//assign wea8 = (WtRegsel==4'd8) & wea;
//assign wea9 = (WtRegsel==4'd9) & wea;
//assign wea10 = (WtRegsel==4'd10) & wea;
//assign wea11 = (WtRegsel==4'd11) & wea;

//assign dina = {dina_high, dina_low};
	

//assign ddr_we0 = (top_mem_sel==4'd0) & ddr_we;
//assign ddr_we1 = (top_mem_sel==4'd1) & ddr_we;
//assign ddr_we2 = (top_mem_sel==4'd2) & ddr_we;
//assign ddr_we3 = (top_mem_sel==4'd3) & ddr_we;
//assign ddr_we4 = (top_mem_sel==4'd4) & ddr_we;
//assign ddr_we5 = (top_mem_sel==4'd5) & ddr_we;
//assign ddr_we6 = (top_mem_sel==4'd6) & ddr_we;
//assign ddr_we7 = (top_mem_sel==4'd7) & ddr_we;
//assign ddr_we8 = (top_mem_sel==4'd8) & ddr_we;
//assign ddr_we9 = (top_mem_sel==4'd9) & ddr_we;
//assign ddr_we10 = (top_mem_sel==4'd10) & ddr_we;
//assign ddr_we11 = (top_mem_sel==4'd11) & ddr_we;

//assign ddr_dout =   (top_mem_sel==4'd0) ? ddr_dout0 : 
//                    (top_mem_sel==4'd1) ? ddr_dout1 :
//                    (top_mem_sel==4'd2) ? ddr_dout2 :
//                    (top_mem_sel==4'd3) ? ddr_dout3 :
//                    (top_mem_sel==4'd4) ? ddr_dout4 :
//                    (top_mem_sel==4'd5) ? ddr_dout5 :
//                    (top_mem_sel==4'd6) ? ddr_dout6 :
//                    (top_mem_sel==4'd7) ? ddr_dout7 :
//                    (top_mem_sel==4'd8) ? ddr_dout8 :
//                    (top_mem_sel==4'd9) ? ddr_dout9 :		
//                    (top_mem_sel==4'd10) ? ddr_dout10 :
//                    ddr_dout11 ;
						  
///*
//memory2048 ME0(clk1, clk2, 
//                  addra, addrb, wea0, dina, doutb0,
//						ddr_interrupt, ddr_address, ddr_we0, ddr_din, ddr_dout0
//						);
//*/						
//memory2048 ME1(clk1, clk2, 
//                  addra, addrb, wea1, dina, doutb1,
//						ddr_interrupt, ddr_address, ddr_we1, ddr_din, ddr_dout1
//						);						

//memory2048 ME2(clk1, clk2, 
//                  addra, addrb, wea2, dina, doutb2,
//						ddr_interrupt, ddr_address, ddr_we2, ddr_din, ddr_dout2
//						);

//memory2048 ME3(clk1, clk2, 
//                  addra, addrb, wea3, dina, doutb3,
//						ddr_interrupt, ddr_address, ddr_we3, ddr_din, ddr_dout3
//						);


						
//memory2048 ME4(clk1, clk2, 
//                  addra, addrb, wea4, dina, doutb4,
//						ddr_interrupt, ddr_address, ddr_we4, ddr_din, ddr_dout4
//						);
						
//memory2048 ME5(clk1, clk2, 
//                  addra, addrb, wea5, dina, doutb5,
//						ddr_interrupt, ddr_address, ddr_we5, ddr_din, ddr_dout5
//						);						
						
//memory2048 ME6(clk1, clk2, 
//                  addra, addrb, wea6, dina, doutb6,
//						ddr_interrupt, ddr_address, ddr_we6, ddr_din, ddr_dout6
//						);

//memory2048 ME7(clk1, clk2, 
//                  addra, addrb, wea7, dina, doutb7,
//						ddr_interrupt, ddr_address, ddr_we7, ddr_din, ddr_dout7
//						);
						
//memory2048 ME8(clk1, clk2, 
//                  addra, addrb, wea8, dina, doutb8,
//						ddr_interrupt, ddr_address, ddr_we8, ddr_din, ddr_dout8
//						);
						
//memory2048 ME9(clk1, clk2, 
//                  addra, addrb, wea9, dina, doutb9,
//						ddr_interrupt, ddr_address, ddr_we9, ddr_din, ddr_dout9
//						);
///*						
//memory2048 ME10(clk1, clk2, 
//                  addra, addrb, wea10, dina, doutb10,
//						ddr_interrupt, ddr_address, ddr_we10, ddr_din, ddr_dout10
//						);						

//memory2048 ME11(clk1, clk2, 
//                  addra, addrb, wea11, dina, doutb11,
//						ddr_interrupt, ddr_address, ddr_we11, ddr_din, ddr_dout11
//						);
//*/
						
//endmodule



/*
module MemorySelectBlockM6_old(clk1, clk2,
								 top_mem_sel, mem_sel_override,
								 RdQsel, WtQsel, 
								 wea, addra, addrb, dina_high, dina_low, doutb,
								 ddr_interrupt, ddr_address, ddr_we, ddr_din, ddr_dout);
input clk1, clk2;
input [3:0] top_mem_sel;				// This is used by the top module to seleach one of the two memory for read/write
input mem_sel_override;			// This is used by the top module to override memory selection

input [3:0] RdQsel, WtQsel;			// Memory Index selection
input wea;							// Write enable signal for the RAM
input [10:0] addra, addrb;		// 9-bit address; 
input [29:0] dina_high, dina_low;

output [59:0] doutb;

input ddr_interrupt;
input [8:0] ddr_address;
input ddr_we;
input [239:0] ddr_din;
output [239:0] ddr_dout;

//reg [2:0] RdQ1, RdQ2, RdQ3, WtQ1, WtQ2, WtQ3;
wire [1:0] addra_2msb, addrb_2msb;
wire wea0, wea1, wea2, wea3, wea4, wea5, wea6, wea7, wea8, wea9, wea10, wea11;
wire [59:0] doutb0, doutb1, doutb2, doutb3, doutb4, doutb5, doutb6, doutb7, doutb8, doutb9, doutb10, doutb11;
wire [3:0] RdRegsel, WtRegsel;
wire [3:0] doutb_sel_wire;
reg  [3:0] doutb_sel;
wire [59:0] dina;
wire [29:0] doutb_hign, doutb_low;

wire ddr_we0, ddr_we1, ddr_we2, ddr_we3, ddr_we4, ddr_we5, ddr_we6, ddr_we7, ddr_we8, ddr_we9, ddr_we10, ddr_we11;
wire [239:0] ddr_dout0, ddr_dout1, ddr_dout2, ddr_dout3;
wire [239:0] ddr_dout4, ddr_dout5, ddr_dout6, ddr_dout7;
wire [239:0] ddr_dout8, ddr_dout9, ddr_dout10, ddr_dout11;

assign RdRegsel = (mem_sel_override) ? top_mem_sel : RdQsel;
assign WtRegsel = (mem_sel_override) ? top_mem_sel : WtQsel;

assign doutb_sel_wire =  RdRegsel;
								
always @(posedge clk2)	// Delayed by one cycle as data in dout appears after one cycle.
doutb_sel <= doutb_sel_wire;
								
assign doutb =   	(doutb_sel==4'd0) ? doutb0 :
						(doutb_sel==4'd1) ? doutb1 :
						(doutb_sel==4'd2) ? doutb2 :
						(doutb_sel==4'd3) ? doutb3 :
						(doutb_sel==4'd4) ? doutb4 :
						(doutb_sel==4'd5) ? doutb5 :
						(doutb_sel==4'd6) ? doutb6 :
						(doutb_sel==4'd7) ? doutb7 :
						(doutb_sel==4'd8) ? doutb8 :
						(doutb_sel==4'd9) ? doutb9 :
						(doutb_sel==4'd10) ? doutb10 :
						doutb11;	
					
assign wea0 = (WtRegsel==4'd0) & wea;
assign wea1 = (WtRegsel==4'd1) & wea;
assign wea2 = (WtRegsel==4'd2) & wea;
assign wea3 = (WtRegsel==4'd3) & wea;
assign wea4 = (WtRegsel==4'd4) & wea;
assign wea5 = (WtRegsel==4'd5) & wea;
assign wea6 = (WtRegsel==4'd6) & wea;
assign wea7 = (WtRegsel==4'd7) & wea;
assign wea8 = (WtRegsel==4'd8) & wea;
assign wea9 = (WtRegsel==4'd9) & wea;
assign wea10 = (WtRegsel==4'd10) & wea;
assign wea11 = (WtRegsel==4'd11) & wea;

assign dina = {dina_high, dina_low};
	

assign ddr_we0 = (top_mem_sel==4'd0) & ddr_we;
assign ddr_we1 = (top_mem_sel==4'd1) & ddr_we;
assign ddr_we2 = (top_mem_sel==4'd2) & ddr_we;
assign ddr_we3 = (top_mem_sel==4'd3) & ddr_we;
assign ddr_we4 = (top_mem_sel==4'd4) & ddr_we;
assign ddr_we5 = (top_mem_sel==4'd5) & ddr_we;
assign ddr_we6 = (top_mem_sel==4'd6) & ddr_we;
assign ddr_we7 = (top_mem_sel==4'd7) & ddr_we;
assign ddr_we8 = (top_mem_sel==4'd8) & ddr_we;
assign ddr_we9 = (top_mem_sel==4'd9) & ddr_we;
assign ddr_we10 = (top_mem_sel==4'd10) & ddr_we;
assign ddr_we11 = (top_mem_sel==4'd11) & ddr_we;

assign ddr_dout =   (top_mem_sel==4'd0) ? ddr_dout0 : 
                    (top_mem_sel==4'd1) ? ddr_dout1 :
                    (top_mem_sel==4'd2) ? ddr_dout2 :
                    (top_mem_sel==4'd3) ? ddr_dout3 :
                    (top_mem_sel==4'd4) ? ddr_dout4 :
                    (top_mem_sel==4'd5) ? ddr_dout5 :
                    (top_mem_sel==4'd6) ? ddr_dout6 :
                    (top_mem_sel==4'd7) ? ddr_dout7 :
                    (top_mem_sel==4'd8) ? ddr_dout8 :
                    (top_mem_sel==4'd9) ? ddr_dout9 :		
                    (top_mem_sel==4'd10) ? ddr_dout10 :
                    ddr_dout11 ;
						  

memory2048 ME0(clk1, clk2, 
                  addra, addrb, wea0, dina, doutb0,
						ddr_interrupt, ddr_address, ddr_we0, ddr_din, ddr_dout0
						);
						
memory2048 ME1(clk1, clk2, 
                  addra, addrb, wea1, dina, doutb1,
						ddr_interrupt, ddr_address, ddr_we1, ddr_din, ddr_dout1
						);						

memory2048 ME2(clk1, clk2, 
                  addra, addrb, wea2, dina, doutb2,
						ddr_interrupt, ddr_address, ddr_we2, ddr_din, ddr_dout2
						);

memory2048 ME3(clk1, clk2, 
                  addra, addrb, wea3, dina, doutb3,
						ddr_interrupt, ddr_address, ddr_we3, ddr_din, ddr_dout3
						);


						
memory2048 ME4(clk1, clk2, 
                  addra, addrb, wea4, dina, doutb4,
						ddr_interrupt, ddr_address, ddr_we4, ddr_din, ddr_dout4
						);
						
memory2048 ME5(clk1, clk2, 
                  addra, addrb, wea5, dina, doutb5,
						ddr_interrupt, ddr_address, ddr_we5, ddr_din, ddr_dout5
						);						
						
memory2048 ME6(clk1, clk2, 
                  addra, addrb, wea6, dina, doutb6,
						ddr_interrupt, ddr_address, ddr_we6, ddr_din, ddr_dout6
						);

memory2048 ME7(clk1, clk2, 
                  addra, addrb, wea7, dina, doutb7,
						ddr_interrupt, ddr_address, ddr_we7, ddr_din, ddr_dout7
						);
						
memory2048 ME8(clk1, clk2, 
                  addra, addrb, wea8, dina, doutb8,
						ddr_interrupt, ddr_address, ddr_we8, ddr_din, ddr_dout8
						);
						
memory2048 ME9(clk1, clk2, 
                  addra, addrb, wea9, dina, doutb9,
						ddr_interrupt, ddr_address, ddr_we9, ddr_din, ddr_dout9
						);
						
memory2048 ME10(clk1, clk2, 
                  addra, addrb, wea10, dina, doutb10,
						ddr_interrupt, ddr_address, ddr_we10, ddr_din, ddr_dout10
						);						

memory2048 ME11(clk1, clk2, 
                  addra, addrb, wea11, dina, doutb11,
						ddr_interrupt, ddr_address, ddr_we11, ddr_din, ddr_dout11
						);

						
endmodule

*/


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:36:13 08/31/2017 
// Design Name: 
// Module Name:    memory2048 
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


module memory2048(clka, clkb, 
                  addra, addrb, wea, dina, doutb,
						addra_n, addrb_n, wea_n, dina_n, doutb_n,
						ddr_interrupt, ddr_address, ddr_we, ddr_din, ddr_dout
						);


input clka, clkb;
input [10:0] addra, addrb;
input wea;
input [59:0] dina;
output [59:0] doutb;

input [10:0] addra_n, addrb_n;
input wea_n;
input [59:0] dina_n;
output [59:0] doutb_n;

input ddr_interrupt;
input [8:0] ddr_address;
input ddr_we;
input [239:0] ddr_din;
output [239:0] ddr_dout;



// Memory signals
wire [9:0] addra_new, addrb_new;
wire wea_MH, wea_ML, web_MH, web_ML;
wire [59:0] dina_MH, dina_ML, dinb_MH, dinb_ML;
wire [59:0] douta_MH, douta_ML, doutb_MH, doutb_ML;
reg addrb_10_r;

wire [9:0] addra_new_H, addra_new_L, addrb_new_H, addrb_new_L;

always @(posedge clkb)
addrb_10_r <= addrb[10];


//assign addra_new = (ddr_interrupt) ? {1'b0, ddr_address} : addra[9:0];
//assign addrb_new = (ddr_interrupt) ? {1'b1, ddr_address} : addrb[9:0];

assign addra_new_H = (ddr_interrupt) ? {1'b0, ddr_address} : (addra[10]) ? addra[9:0] : addra_n[9:0];
assign addra_new_L = (ddr_interrupt) ? {1'b0, ddr_address} : (addra[10]) ? addra_n[9:0] : addra[9:0];

assign addrb_new_H = (ddr_interrupt) ? {1'b1, ddr_address} : (addrb[10])? addrb[9:0] : addrb_n[9:0];
assign addrb_new_L = (ddr_interrupt) ? {1'b1, ddr_address} : (addrb[10])? addrb_n[9:0] : addrb[9:0];

//assign wea_MH = (ddr_interrupt) ? ddr_we : (addra[10]) ? wea : 1'b0; 
//assign wea_ML = (ddr_interrupt) ? ddr_we : (addra[10]==1'b0) ? wea : 1'b0; 

assign wea_MH = (ddr_interrupt) ? ddr_we : (addra[10]) ? wea : wea_n; 
assign wea_ML = (ddr_interrupt) ? ddr_we : (addra[10]) ? wea_n : wea; 

assign dina_MH = (ddr_interrupt) ? ddr_din[179:120] : (addra[10]) ? dina : dina_n;
assign dina_ML = (ddr_interrupt) ? ddr_din[59:0] : (addra[10]) ? dina_n : dina;

assign web_MH = (ddr_interrupt) ? ddr_we : 1'b0;
assign web_ML = (ddr_interrupt) ? ddr_we : 1'b0;
assign dinb_MH = ddr_din[239:180];
assign dinb_ML = ddr_din[119:60];

assign doutb = (addrb_10_r) ? doutb_MH : doutb_ML;	// selection is delayes as data from RAM comes one cycle after address-input.
assign doutb_n = (addrb_10_r) ? doutb_ML : doutb_MH;	// selection is delayes as data from RAM comes one cycle after address-input.

assign ddr_dout = (ddr_interrupt) ? {doutb_MH, douta_MH, doutb_ML, douta_ML} : 240'd0;


memory1024 MH(
  .clka(clka), // input clka
  .wea(wea_MH), // input [0 : 0] wea
  .addra(addra_new_H), // input [9 : 0] addra
  .dina(dina_MH), // input [59 : 0] dina
  .douta(douta_MH), // output [59 : 0] douta
  .clkb(clkb), // input clkb
  .web(web_MH), // input [0 : 0] web
  .addrb(addrb_new_H), // input [9 : 0] addrb
  .dinb(dinb_MH), // input [59 : 0] dinb
  .doutb(doutb_MH) // output [59 : 0] doutb
);


memory1024 ML(
  .clka(clka), // input clka
  .wea(wea_ML), // input [0 : 0] wea
  .addra(addra_new_L), // input [9 : 0] addra
  .dina(dina_ML), // input [59 : 0] dina
  .douta(douta_ML), // output [59 : 0] douta
  .clkb(clkb), // input clkb
  .web(web_ML), // input [0 : 0] web
  .addrb(addrb_new_L), // input [9 : 0] addrb
  .dinb(dinb_ML), // input [59 : 0] dinb
  .doutb(doutb_ML) // output [59 : 0] doutb
);

endmodule











/*
module memory2048_old(clka, clkb, 
                  addra, addrb, wea, dina, doutb,
						ddr_interrupt, ddr_address, ddr_we, ddr_din, ddr_dout
						);


input clka, clkb;
input [10:0] addra, addrb;
input wea;
input [59:0] dina;
output [59:0] doutb;

input ddr_interrupt;
input [8:0] ddr_address;
input ddr_we;
input [239:0] ddr_din;
output [239:0] ddr_dout;



// Memory signals
wire [9:0] addra_new, addrb_new;
wire wea_MH, wea_ML, web_MH, web_ML;
wire [59:0] dina_MH, dina_ML, dinb_MH, dinb_ML;
wire [59:0] douta_MH, douta_ML, doutb_MH, doutb_ML;
reg addrb_10_r;

always @(posedge clkb)
addrb_10_r <= addrb[10];

assign addra_new = (ddr_interrupt) ? {1'b0, ddr_address} : addra[9:0];
assign addrb_new = (ddr_interrupt) ? {1'b1, ddr_address} : addrb[9:0];

assign wea_MH = (ddr_interrupt) ? ddr_we : (addra[10]) ? wea : 1'b0; 
assign wea_ML = (ddr_interrupt) ? ddr_we : (addra[10]==1'b0) ? wea : 1'b0; 
assign dina_MH = (ddr_interrupt) ? ddr_din[179:120] : dina;
assign dina_ML = (ddr_interrupt) ? ddr_din[59:0] : dina;

assign web_MH = (ddr_interrupt) ? ddr_we : 1'b0;
assign web_ML = (ddr_interrupt) ? ddr_we : 1'b0;
assign dinb_MH = ddr_din[239:180];
assign dinb_ML = ddr_din[119:60];

assign doutb = (addrb_10_r) ? doutb_MH : doutb_ML;	// selection is delayes as data from RAM comes one cycle after address-input.
assign ddr_dout = (ddr_interrupt) ? {doutb_MH, douta_MH, doutb_ML, douta_ML} : 240'd0;


memory1024 MH(
  .clka(clka), // input clka
  .wea(wea_MH), // input [0 : 0] wea
  .addra(addra_new), // input [9 : 0] addra
  .dina(dina_MH), // input [59 : 0] dina
  .douta(douta_MH), // output [59 : 0] douta
  .clkb(clkb), // input clkb
  .web(web_MH), // input [0 : 0] web
  .addrb(addrb_new), // input [9 : 0] addrb
  .dinb(dinb_MH), // input [59 : 0] dinb
  .doutb(doutb_MH) // output [59 : 0] doutb
);


memory1024 ML(
  .clka(clka), // input clka
  .wea(wea_ML), // input [0 : 0] wea
  .addra(addra_new), // input [9 : 0] addra
  .dina(dina_ML), // input [59 : 0] dina
  .douta(douta_ML), // output [59 : 0] douta
  .clkb(clkb), // input clkb
  .web(web_ML), // input [0 : 0] web
  .addrb(addrb_new), // input [9 : 0] addrb
  .dinb(dinb_ML), // input [59 : 0] dinb
  .doutb(doutb_ML) // output [59 : 0] doutb
);

endmodule

*/

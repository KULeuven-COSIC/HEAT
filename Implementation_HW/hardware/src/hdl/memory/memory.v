`timescale 1ns / 1ps

module memory2048(
    input  wire         clk,

    input  wire [10:0]  core0_wr_addr,
    input  wire [10:0]  core0_rd_addr,
    input  wire         core0_wr_en,
    input  wire [59:0]  core0_wr_data,
    output wire [59:0]  core0_rd_data,

    input  wire [10:0]  core1_wr_addr,
    input  wire [10:0]  core1_rd_addr,
    input  wire         core1_wr_en,
    input  wire [59:0]  core1_wr_data,
    output wire [59:0]  core1_rd_data,

    input  wire         lift_interrupt,
    input  wire [8:0]   lift_address,
    input  wire         lift_we,
    input  wire [239:0] lift_wr_data,
    output wire [239:0] lift_rd_data
    );

// Multiplexed Inputs

wire [9:0]  addra_MH   = (lift_interrupt) ? {1'b0, lift_address} : (core0_wr_addr[10]) ? core0_wr_addr[9:0] : core1_wr_addr[9:0];
wire [9:0]  addra_ML   = (lift_interrupt) ? {1'b0, lift_address} : (core0_wr_addr[10]) ? core1_wr_addr[9:0] : core0_wr_addr[9:0];

wire [9:0]  addrb_MH   = (lift_interrupt) ? {1'b1, lift_address} : (core0_rd_addr[10]) ? core0_rd_addr[9:0] : core1_rd_addr[9:0];
wire [9:0]  addrb_ML   = (lift_interrupt) ? {1'b1, lift_address} : (core0_rd_addr[10]) ? core1_rd_addr[9:0] : core0_rd_addr[9:0];

wire        wea_MH     = (lift_interrupt) ? lift_we : (core0_wr_addr[10]) ? core0_wr_en : core1_wr_en;
wire        wea_ML     = (lift_interrupt) ? lift_we : (core0_wr_addr[10]) ? core1_wr_en : core0_wr_en;

wire        web_MH     = (lift_interrupt) ? lift_we : 1'b0;
wire        web_ML     = (lift_interrupt) ? lift_we : 1'b0;

wire [59:0] dina_MH    = (lift_interrupt) ? lift_wr_data[179:120] : (core0_wr_addr[10]) ? core0_wr_data : core1_wr_data;
wire [59:0] dina_ML    = (lift_interrupt) ? lift_wr_data[59:0]    : (core0_wr_addr[10]) ? core1_wr_data : core0_wr_data;

wire [59:0] dinb_MH    = lift_wr_data[239:180];
wire [59:0] dinb_ML    = lift_wr_data[119:60];

// Multiplexed Outputs

wire [59:0] douta_MH;
wire [59:0] douta_ML;
wire [59:0] doutb_MH;
wire [59:0] doutb_ML;

reg addrb_10_r;
always @(posedge clk)
  addrb_10_r <= core0_rd_addr[10];

assign core0_rd_data = (addrb_10_r) ? doutb_MH : doutb_ML;	// selection is delayed as data from RAM comes one cycle after address-input.
assign core1_rd_data = (addrb_10_r) ? doutb_ML : doutb_MH;	// selection is delayed as data from RAM comes one cycle after address-input.

assign lift_rd_data  = (lift_interrupt) ? {doutb_MH, douta_MH, doutb_ML, douta_ML} : 240'd0;

memory1024 MH(
  .clka   (clk),         // input           clka
  .wea    (wea_MH),      // input  [0 : 0]  wea
  .addra  (addra_MH),    // input  [9 : 0]  addra
  .dina   (dina_MH),     // input  [59 : 0] dina
  .douta  (douta_MH),    // output [59 : 0] douta

  .clkb   (clk),         // input           clkb
  .web    (web_MH),      // input  [0 : 0]  web
  .addrb  (addrb_MH),    // input  [9 : 0]  addrb
  .dinb   (dinb_MH),     // input  [59 : 0] dinb
  .doutb  (doutb_MH)     // output [59 : 0] doutb
);

memory1024 ML(
  .clka  (clk),         // input           clka
  .wea   (wea_ML),      // input  [0 : 0]  wea
  .addra (addra_ML),    // input  [9 : 0]  addra
  .dina  (dina_ML),     // input  [59 : 0] dina
  .douta (douta_ML),    // output [59 : 0] douta

  .clkb  (clk),         // input           clkb
  .web   (web_ML),      // input  [0 : 0]  web
  .addrb (addrb_ML),    // input  [9 : 0]  addrb
  .dinb  (dinb_ML),     // input  [59 : 0] dinb
  .doutb (doutb_ML)     // output [59 : 0] doutb
);

endmodule
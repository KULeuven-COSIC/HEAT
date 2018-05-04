`timescale 1ns / 1ps

// Create Date:    17:38:36 09/28/2017 
// Design Name: 
// Module Name:    AmQ_DP 

module AmQ_DP_2(
	 input clk,
    input [117:0] D_IN,
    input [1:0] RD_RES_ADDR,
    output [117:0] D_OUT,
	 input CARRY_SEL,
	 input S_REG_RST,
	 input S_REG_EN,
	 input WB_PHASE,
	 input WE_RAM,
	 input [1:0] WB_ADDR,
	 input [2:0] WR_VAR_OFFSET,
	 input MEM_CONFIG,
	 input [1:0] RAM_ADDR,
	 input [2:0] RD_VAR_OFFSET,
	 input [4:0] Qns_ADDR_FINAL,
	 input [2:0] FIN_RES_OFF, //final result offset
	 output C_OUT_DPq,
	 input ADD_sub

    );
	 
wire [3:0] RAM_A_addr;
wire [3:0] RAM_B_addr;
wire [3:0] RAM_RD_RES_addr;
wire [3:0] WB_ADDR_FINAL;

assign RAM_RD_RES_addr = RD_RES_ADDR + FIN_RES_OFF;
assign WB_ADDR_FINAL = WB_ADDR + WR_VAR_OFFSET;

assign RAM_A_addr = (MEM_CONFIG == 0) ? WB_ADDR_FINAL : RAM_RD_RES_addr;
assign RAM_B_addr = (MEM_CONFIG == 0) ? RAM_RD_RES_addr : WB_ADDR_FINAL;


wire [117:0] WB_DATA;
wire [3:0] RAM_RD_ADDR;

assign RAM_RD_ADDR = RAM_ADDR + RD_VAR_OFFSET;

wire RAM_A_WE;
wire RAM_B_WE;

assign RAM_A_WE = (MEM_CONFIG == 0) ? WE_RAM : 1'b0;
assign RAM_B_WE = (MEM_CONFIG == 0) ? 1'b0 : WE_RAM;

wire [117:0] RAM_A_qspo;
wire [117:0] RAM_A_RD_DATA;

wire [117:0] RAM_B_qspo;
wire [117:0] RAM_B_RD_DATA;

DP_RAM_118x16 RAM_A (
  .a(RAM_A_addr), // input [3 : 0] a
  .d(WB_DATA), 	// input [117 : 0] d
  .dpra(RAM_RD_ADDR), 	// input [3 : 0] dpra
  .clk(clk), 		// input clk
  .we(RAM_A_WE), 	// input we
  .qspo(RAM_A_qspo), 	// output [117 : 0] qspo
  .qdpo(RAM_A_RD_DATA) 	// output [117 : 0] qdpo
); 

DP_RAM_118x16 RAM_B (
  .a(RAM_B_addr),	// input [3 : 0] a
  .d(WB_DATA), 	// input [117 : 0] d
  .dpra(RAM_RD_ADDR), 	// input [3 : 0] dpra
  .clk(clk), 		// input clk
  .we(RAM_B_WE), 	// input we
  .qspo(RAM_B_qspo), 	// output [117 : 0] qspo
  .qdpo(RAM_B_RD_DATA) 	// output [117 : 0] qdpo
); 

assign D_OUT = (MEM_CONFIG == 0) ? RAM_B_qspo : RAM_A_qspo;

wire [117:0] Qns_DATA;

Qns_ROM Qns_ROM_DP (
  .a(Qns_ADDR_FINAL), // input [4 : 0] a
  .clk(clk), 	// input clk
  .qspo(Qns_DATA) 	// output [117 : 0] qspo
);

wire [117:0] RAM_RD_DATA_FIN;

assign RAM_RD_DATA_FIN = (MEM_CONFIG == 0) ? RAM_A_RD_DATA : RAM_B_RD_DATA;

wire [58:0] RAM_RD_DATA_FIN_LOW;
wire [58:0] RAM_RD_DATA_FIN_HIGH;
assign RAM_RD_DATA_FIN_LOW = RAM_RD_DATA_FIN[58:0];
assign RAM_RD_DATA_FIN_HIGH = RAM_RD_DATA_FIN[117:59];

wire [58:0] Qns_DATA_LOW;
wire [58:0] Qns_DATA_HIGH;
assign Qns_DATA_LOW 	= Qns_DATA[58:0];
assign Qns_DATA_HIGH = Qns_DATA[117:59];

wire L1_COUT;

wire [58:0] SL;
wire [58:0] SH_0;
wire [58:0] SH_1;
wire [58:0] SH;
wire CIN_L1;

wire ADDsub_STARTvalue;
assign ADDsub_STARTvalue = (ADD_sub == 0) ? 1'b1 : 1'b0;

assign CIN_L1 = (CARRY_SEL == 0) ? ADDsub_STARTvalue : COUT_REG;

ADDsub_new ADDsub_L1111 (
  .a(Qns_DATA_LOW), // input [58 : 0] a
  .b(RAM_RD_DATA_FIN_LOW), // input [58 : 0] b
  .add(ADD_sub),
  .c_in(CIN_L1), // input c_in
  .c_out(L1_COUT), // output c_out
  .s(SL) // output [58 : 0] s
);


wire L2_0_COUT, L2_1_COUT, L2_COUT;

parameter zero_bit = 1'b0;
parameter one_bit = 1'b1;


ADDsub_new ADDsub_L2_0000 (
  .a(Qns_DATA_HIGH), // input [58 : 0] a
  .b(RAM_RD_DATA_FIN_HIGH), // input [58 : 0] b
  .add(ADD_sub), // input add
  .c_in(zero_bit), // input c_in
  .c_out(L2_0_COUT), // output c_out
  .s(SH_0) // output [58 : 0] s
);


ADDsub_new ADDsub_L2_1111 (
                          .a(Qns_DATA_HIGH), // input [58 : 0] a
								  .b(RAM_RD_DATA_FIN_HIGH), // input [58 : 0] b
								  .add(ADD_sub),
								  .c_in(one_bit), // input c_in 1
								  .c_out(L2_1_COUT), // output c_out
								  .s(SH_1) // output [58 : 0] s
								);


assign SH = (L1_COUT == 0) ? SH_0 : SH_1;
assign L2_COUT = (L1_COUT == 0) ? L2_0_COUT : L2_1_COUT;

reg [58:0] SL_REG;
reg [58:0] SH_REG;
reg COUT_REG;

always @(posedge clk)
begin
	if (S_REG_RST)
		begin
			SL_REG <= 59'b0;
			SH_REG <= 59'b0;
			COUT_REG <= 1'b0;
		end
	else if (S_REG_EN)
		begin
			SL_REG <= SL;
			SH_REG <= SH;
			COUT_REG <= L2_COUT;
		end
	else
		begin
			SL_REG <= SL_REG;
			SH_REG <= SH_REG;
			COUT_REG <= COUT_REG;
		end
end

assign C_OUT_DPq = COUT_REG;

assign WB_DATA = (WB_PHASE == 0) ? D_IN : {SH_REG,SL_REG};


endmodule

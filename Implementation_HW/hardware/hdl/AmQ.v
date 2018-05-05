`timescale 1ns / 1ps

// Create Date:    10:54:16 10/05/2017 
// Design Name: 
// Module Name:    AmQ 

module AmQ(
    input CLK,
    input RST,
    input [117:0] D_IN,
    output [1:0] RD_INPUT_ADDR,
    input DATA_VALID,
    input [1:0] RD_RES_ADDR,
    output [117:0] D_OUT,
    output DONE_AmQ,
	 output CENTRAL_L_HAPPENED
    );
	 
wire CARRY_SEL;
wire S_REG_RST;
wire S_REG_EN;
wire WB_PHASE;
wire WE_RAM;
wire [1:0] WB_ADDR;
wire [2:0] WR_VAR_OFFSET;
wire MEM_CONFIG;
wire [1:0] RAM_ADDR;
wire [2:0] RD_VAR_OFFSET;
wire [4:0] Qns_ADDR_FINAL;
wire [2:0] FIN_RES_OFF;
wire C_OUT_DPq;
wire ADD_sub;
	 
	 
AmQ_DP_2 AmQ_DP_DP(	CLK,
						D_IN,
						RD_RES_ADDR,
						D_OUT,
						CARRY_SEL,
						S_REG_RST,
						S_REG_EN,
						WB_PHASE,
						WE_RAM,
						WB_ADDR,
						WR_VAR_OFFSET,
						MEM_CONFIG,
						RAM_ADDR,
						RD_VAR_OFFSET,
						Qns_ADDR_FINAL,
						FIN_RES_OFF,
						C_OUT_DPq,
						ADD_sub);
						
AmQ_CU AmQ_CU_DP (CLK,
						RST,
						DATA_VALID,
						RD_INPUT_ADDR,
						DONE_AmQ,
						CARRY_SEL,
						S_REG_RST,
						S_REG_EN,
						WB_PHASE,
						WE_RAM,
						WB_ADDR,
						WR_VAR_OFFSET,
						MEM_CONFIG,
						RAM_ADDR,
						RD_VAR_OFFSET,
						Qns_ADDR_FINAL,
						FIN_RES_OFF,
						C_OUT_DPq,
						CENTRAL_L_HAPPENED,
						ADD_sub);						
						
	 
	 

	 



endmodule

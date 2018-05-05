`timescale 1ns / 1ps
// s
module LIFT_STG1_TOP_DP_V(
	 input CLK,
	 input RST,
	 input  [1:0] RD_RESULT_ADDR,
	 output [117:0] D_OUT_SOP,
	 output SOP_DONE,
	 input  [2:0] RD_RESULT_ADDR_2,
	 output [62:0] D_OUT_SOP_2,
	 output SOP_DONE_2,
    input  TYPE_OF_DATA,
    input  DATA_VALID,
	 output [4:0] rd_addr_to_read_input_value,
	 output [2:0] bank_sel,
    input  [29:0] D_IN_SOP,
	 input go_signal,
	 output Done_rd_8,
	 output ToD_SAMPLED);


wire [4:0] BCONST_QI_ADDR;
wire MUX_MUL1_IN1_SEL;
wire MUX_MUL1_IN2_SEL;
wire [3:0] BRR_ADDR;
wire BRR_WE;
wire MUX_MANY_MUL_SEL;
wire [5:0] MAIN_ROM_ADDR;
wire [5:0] AUX2_ROM_ADDR;
wire [5:0] AUX_ROM_ADDR;
wire ONLY_MUL_CU;
wire MUX_SB_TOP_SEL;
wire S2_RS_EN;
wire S2_RS_RST;
wire MUX_SOP_SEL;
wire REG_ADD_L_EN;
wire REG_ADD_L_RST;
wire REG_ADD_H_EN;
wire REG_ADD_H_RST;
wire REG_62_CB_EN;
wire REG_62_CB_RST;
wire [2:0] MUX_WB_SEL;
wire WB_WINDOW;
wire RD_WINDOW;
wire [1:0] WB_RESULT_ADDR;
wire WB_WE;

wire SEL_60_63;
wire COMB_EN;
wire COMB_RST;
wire B2_SOP_TRANSFORM;
wire B2_PHASE;
wire WB_WINDOW_2;
wire RD_WINDOW_2;
wire [2:0] WB_RESULT_ADDR_2;
wire WB_WE_2;


LIFT_STG1_MAIN_CU LIFT_STG1_MAIN_CU_FINAL_DP(CLK,
															RST,
															TYPE_OF_DATA,
															DATA_VALID,
															bank_sel,
															rd_addr_to_read_input_value,
															Done_rd_8,
															SOP_DONE,
															SOP_DONE_2,
															go_signal,
															BCONST_QI_ADDR,
															MUX_MUL1_IN1_SEL,
															MUX_MUL1_IN2_SEL,
															BRR_ADDR,
															BRR_WE,
															MUX_MANY_MUL_SEL,
															MAIN_ROM_ADDR,
															AUX2_ROM_ADDR,
															AUX_ROM_ADDR,
															ONLY_MUL_CU,
															MUX_SB_TOP_SEL,
															S2_RS_EN,
															S2_RS_RST,
															MUX_SOP_SEL,
															REG_ADD_L_EN,
															REG_ADD_L_RST,
															REG_ADD_H_EN,
															REG_ADD_H_RST,
															REG_62_CB_EN,
															REG_62_CB_RST,
															MUX_WB_SEL,
															WB_WINDOW,
															RD_WINDOW,
															WB_RESULT_ADDR,
															WB_WE,
															SEL_60_63,
															COMB_EN, 
															COMB_RST, 
															B2_SOP_TRANSFORM,
															B2_PHASE,
															WB_WINDOW_2,
															RD_WINDOW_2,
															WB_RESULT_ADDR_2,
															WB_WE_2,
															ToD_SAMPLED);

LIFT_STG1_DP LIFT_STG1_DP_FINAL_DP (CLK,
												D_IN_SOP,
												RD_RESULT_ADDR,
												D_OUT_SOP,
												RD_RESULT_ADDR_2,
												D_OUT_SOP_2,
												BCONST_QI_ADDR,
												MUX_MUL1_IN1_SEL,
												MUX_MUL1_IN2_SEL,
												SEL_60_63,
												COMB_EN, 
												COMB_RST, 
												B2_SOP_TRANSFORM,
												B2_PHASE,
												BRR_ADDR,
												BRR_WE,
												MUX_MANY_MUL_SEL,
												MAIN_ROM_ADDR,
												AUX2_ROM_ADDR,
												AUX_ROM_ADDR,
												ONLY_MUL_CU,
												MUX_SB_TOP_SEL,
												S2_RS_EN,
												S2_RS_RST,
												MUX_SOP_SEL,
												REG_ADD_L_EN,
												REG_ADD_L_RST,
												REG_ADD_H_EN,
												REG_ADD_H_RST,
												REG_62_CB_EN,
												REG_62_CB_RST,
												MUX_WB_SEL,
												WB_WINDOW,
												RD_WINDOW,
												WB_WINDOW_2,
												RD_WINDOW_2,
												WB_RESULT_ADDR,
												WB_RESULT_ADDR_2,
												WB_WE,
												WB_WE_2);

endmodule

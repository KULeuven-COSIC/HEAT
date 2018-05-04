`timescale 1ns / 1ps

// Create Date:    19:16:11 10/05/2017 
// Design Name: a
// Module Name:    LIFT_MOD_PART1 

module LIFT_MOD_PART1(
    input CLK,
    input RST,
    input TYPE_OF_DATA,
    input DATA_VALID,
    output [4:0] RD_INPUT_ADDR,
    output [2:0] RAM_BANK_SEL,
    input [29:0] D_IN,
    output DONE_RD_8,
    output SIGN,
	 output CF_INFO_OUT, //1: central lift happened during Asp mod Q, 0: not happened.
	 output sample_CF_INFO_OUT, 
	 output QUOTIENT_READY_for_modq, 
    output QUOTIENT_READY_for_fin_adj, //QUOTIENT_READY
    output [117:0] QUOTIENT,
    output A_PRIME_QJ_READY,
    output [29:0] A_PRIME_QJ,
    output ToD_SAMPLED_out);
	 
reg CF_INFO_1;
reg CF_INFO_0;	 
wire AmQ_CF_HAPPENED;
 
wire ToD_SAMPLED; //Type of data sampled. comes from stg1

assign ToD_SAMPLED_out = ToD_SAMPLED;
	 
wire [1:0] RD_RESULT_ADDR_to_STG1;
wire [117:0] D_OUT_SOP;
wire SOP_DONE;
wire [2:0] RD_RESULT_ADDR_2;
wire [62:0] D_OUT_SOP_2;
wire SOP_DONE_2;
wire go_signal;

wire [1:0] RD_INPUT_ADDR_from_AmQ; //vedi che sono solo due bit! dovrai estendere!
wire DATA_VALID_AmQ;
wire [1:0] RD_RES_ADDR_AmQ;
wire [117:0] D_OUT_AmQ;
wire DONE_AmQ;

wire [1:0] RD_RESULT_ADDR_from_DRU_2bits;

assign RD_RESULT_ADDR_to_STG1 = (ToD_SAMPLED == 0) ? RD_INPUT_ADDR_from_AmQ : RD_RESULT_ADDR_from_DRU_2bits;
assign RD_RES_ADDR_AmQ = (ToD_SAMPLED == 0) ? RD_RESULT_ADDR_from_DRU_2bits : 2'b0;
assign DATA_VALID_AmQ = (ToD_SAMPLED == 0) ? SOP_DONE : 1'b0;
		  
AmQ AmQ_DP(	CLK,
				RST,
				D_OUT_SOP,
				RD_INPUT_ADDR_from_AmQ,
				DATA_VALID_AmQ,
				RD_RES_ADDR_AmQ,
				D_OUT_AmQ,
				DONE_AmQ,
				AmQ_CF_HAPPENED);

LIFT_STG1_TOP_DP_V STG1_DP(
          CLK,
          RST,
          RD_RESULT_ADDR_to_STG1,
          D_OUT_SOP,
          SOP_DONE,
          RD_RESULT_ADDR_2,
          D_OUT_SOP_2,
          SOP_DONE_2,
          TYPE_OF_DATA,
          DATA_VALID,
          RD_INPUT_ADDR,
          RAM_BANK_SEL,
          D_IN,
          go_signal,
          DONE_RD_8,
			 ToD_SAMPLED);
			 
always @(posedge CLK)
begin
	if (RST)
		begin
			CF_INFO_0 <= 1'b0;
			CF_INFO_1 <= 1'b0;
		end
	else
		begin
			if (DONE_AmQ)
				begin
					CF_INFO_0 <= AmQ_CF_HAPPENED;
					CF_INFO_1 <= CF_INFO_0;
				end
			else 
				begin
					CF_INFO_0 <= CF_INFO_0;
					CF_INFO_1 <= CF_INFO_1;
				end
		end
	 
end

//assign CF_INFO_OUT = CF_INFO_1;
assign CF_INFO_OUT = AmQ_CF_HAPPENED;
assign sample_CF_INFO_OUT = DONE_AmQ;
			 
assign A_PRIME_QJ = D_OUT_SOP_2[29:0];
			 
wire go_signal_small;
wire go_signal_big;
			 
delayer#(4, 8) delayer_SMALL(	CLK, //numb_bit delay, CCd (Clock Cycles delay)
										RST,
										SOP_DONE_2,
										go_signal_small);
										
delayer#(7, 80) delayer_BIG(CLK,//numb_bit delay, CCd (Clock Cycles delay)
									RST,
									SOP_DONE,
									go_signal_big);
									
//how to calculate delays:
//	CCd  = CCd_slower_pipeline block - CCd_STG1
									
assign go_signal = (ToD_SAMPLED == 0) ? go_signal_big : go_signal_small;
										
										
								  
feeder feeder_DP(CLK,
					  RST,
					  SOP_DONE_2,
					  RD_RESULT_ADDR_2,
					  A_PRIME_QJ_READY);
					  


wire [117:0] QUOTIENT_wire;
wire QUOTIENT_READY_wire;

wire busy_DRU;
 
wire [4:0] RD_RESULT_ADDR_from_DRU;

assign RD_RESULT_ADDR_from_DRU_2bits = RD_RESULT_ADDR_from_DRU[1:0];

wire [117:0] C_IN_to_DRU;
wire C_READY_to_DRU;

assign C_IN_to_DRU = (ToD_SAMPLED == 0) ? D_OUT_AmQ : D_OUT_SOP;
assign C_READY_to_DRU = (ToD_SAMPLED == 0) ? DONE_AmQ : SOP_DONE;

div_unit_118 div_unit_118_DP(CLK,
									  RST,
									  ToD_SAMPLED,
									  C_READY_to_DRU,
									  C_IN_to_DRU,
									  RD_RESULT_ADDR_from_DRU,
									  QUOTIENT_wire,
									  QUOTIENT_READY_wire,
									  busy_DRU);

assign QUOTIENT = QUOTIENT_wire;
wire QUOTIENT_READY_for_fin_adj_wire;
assign QUOTIENT_READY_for_fin_adj_wire = (ToD_SAMPLED == 0) ? 1'b0 : QUOTIENT_READY_wire;
assign QUOTIENT_READY_for_fin_adj = QUOTIENT_READY_for_fin_adj_wire;
assign QUOTIENT_READY_for_modq = (ToD_SAMPLED == 0) ? QUOTIENT_READY_wire : 1'b0;

wire [71:0] SENSED_ASP_MSBSPECIAL;

wire [1:0] RD_RESULT_ADDR_for_DETECT_72;

assign RD_RESULT_ADDR_for_DETECT_72 = (ToD_SAMPLED == 0) ? 2'b0 : RD_RESULT_ADDR_to_STG1;


DETECT_72 DETECT_72_DP(CLK,
							  RST,
							  QUOTIENT_READY_for_fin_adj_wire,
							  RD_RESULT_ADDR_for_DETECT_72,
							  {D_OUT_SOP[61:0],10'b0},
							  SENSED_ASP_MSBSPECIAL);
							  
reg [71:0] SENSED_ASP_MSBSPECIAL_previous_stage;

always @(posedge CLK)
begin
	if (RST)
		SENSED_ASP_MSBSPECIAL_previous_stage <= 72'b0;
	else
		if (QUOTIENT_READY_for_fin_adj_wire)
			SENSED_ASP_MSBSPECIAL_previous_stage <= SENSED_ASP_MSBSPECIAL;
		else 
			SENSED_ASP_MSBSPECIAL_previous_stage <= SENSED_ASP_MSBSPECIAL_previous_stage;
end

wire sign_wire;
wire done_sign;
wire SIGN_RST;
wire [35:0] QUOT_SENSED;

DETECT_QUOT DETECT_QUOT_DP(CLK,
									RST,
									QUOTIENT_READY_for_fin_adj_wire,
									{QUOTIENT_wire[35:0]}, 
									done_sign,           
									SIGN_RST, 
									QUOT_SENSED);
									
sign_calculation sign_calculation_DP(CLK,
												 SIGN_RST,
												 QUOT_SENSED,
												 SENSED_ASP_MSBSPECIAL_previous_stage,
												 sign_wire,
												 done_sign);

reg sign_reg;

always @(posedge CLK)
begin
	if (RST)
		sign_reg <= 1'b0;
	else
		begin
		if (done_sign)
			sign_reg <= sign_wire;
		else 
			sign_reg <= sign_reg;
		end
end

assign SIGN = sign_reg;

endmodule

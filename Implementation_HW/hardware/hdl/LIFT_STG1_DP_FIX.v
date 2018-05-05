`timescale 1ns / 1ps
//
module LIFT_STG1_DP(	input CLK,
							input [29:0] D_IN_SOP,
							input [1:0] RD_RESULT_ADDR,
							output [117:0] D_OUT_SOP,
							input [2:0] RD_RESULT_ADDR_2,
							output [62:0] D_OUT_SOP_2,
							input [4:0] BCONST_QI_ADDR, //modified to 4:0
							input MUX_MUL1_IN1_SEL, MUX_MUL1_IN2_SEL,
							input SEL_60_63, //0,60; 1,63;
							input COMB_EN, //NEW //NEW//NEW
							input COMB_RST, //NEW//NEW//NEW
							input B2_SOP_TRANSFORM, //NEW//NEW//NEW
							input B2_PHASE,
							input [3:0] BRR_ADDR,
							input BRR_WE,
							input MUX_MANY_MUL_SEL, 
							input [5:0] MAIN_ROM_ADDR,
							input [5:0] AUX2_ROM_ADDR,
							input [5:0] AUX_ROM_ADDR,
							input ONLY_MUL_CU,
							input MUX_SB_TOP_SEL,
							input S2_RS_EN,
							input S2_RS_RST,
							input MUX_SOP_SEL,
							input REG_ADD_L_EN, REG_ADD_L_RST,
							input REG_ADD_H_EN, REG_ADD_H_RST,
							input REG_62_CB_EN,
							input REG_62_CB_RST,
							input [2:0] MUX_WB_SEL,
							input WB_WINDOW,
							input RD_WINDOW,
							input WB_WINDOW_2,
							input RD_WINDOW_2,
							input [1:0] WB_RESULT_ADDR,
							input [2:0] WB_RESULT_ADDR_2,
							input WB_WE,
							input WB_WE_2);
							
reg [29:0] comb_tooth_0, comb_tooth_1, comb_tooth_2, comb_tooth_3, comb_tooth_4, comb_tooth_5;

always @(posedge CLK)
begin
	if (COMB_RST)
		begin 
			comb_tooth_5 <= 30'b0; 
			comb_tooth_4 <= 30'b0; 
			comb_tooth_3 <= 30'b0;  
			comb_tooth_2 <= 30'b0; 
			comb_tooth_1 <= 30'b0; 
			comb_tooth_0 <= 30'b0; 
		end
	else if (COMB_EN)
		begin
			comb_tooth_5 <= D_IN_SOP; 
			comb_tooth_4 <= comb_tooth_5; 
			comb_tooth_3 <= comb_tooth_4;  
			comb_tooth_2 <= comb_tooth_3; 
			comb_tooth_1 <= comb_tooth_2; 
			comb_tooth_0 <= comb_tooth_1; 
		end
end


	 
wire [63:0] BCONST_QI_D_OUT;

Bconst_Qi_ROM Bconst_Qi_ROM_DP(BCONST_QI_ADDR, CLK, BCONST_QI_D_OUT);


wire [29:0] MUL1_IN1, MUL1_IN2, MUL1_IN1_TEMP;
wire [59:0] MAIN_ROM_D_OUT;
wire [59:0] AUX2_ROM_D_OUT;
wire [59:0] AUX_ROM_D_OUT;

assign MUL1_IN1_TEMP = (MUX_MUL1_IN1_SEL == 0) ? BRR_OUT : D_IN_SOP;
assign MUL1_IN1 = (B2_SOP_TRANSFORM == 0) ? MUL1_IN1_TEMP : comb_tooth_5;
assign MUL1_IN2 = (MUX_MUL1_IN2_SEL == 0) ? MAIN_ROM_D_OUT[29:0] :  MAIN_ROM_D_OUT[59:30];

MAIN_ROM MAIN_ROM_DP(
    .a(MAIN_ROM_ADDR),      
    .clk(CLK),              
    .qspo(MAIN_ROM_D_OUT));

//AUX and AUX_2_ROM address protection
wire [5:0] AUX_ROM_ADDR_PROTECTED, AUX2_ROM_ADDR_PROTECTED;


assign AUX2_ROM_ADDR_PROTECTED = (AUX2_ROM_ADDR > 47) ? 6'b0 : AUX2_ROM_ADDR;
assign AUX_ROM_ADDR_PROTECTED = (AUX_ROM_ADDR > 47) ? 6'b0 : AUX_ROM_ADDR;


AUX_2_ROM AUX2_ROM_DP(AUX2_ROM_ADDR_PROTECTED, CLK, AUX2_ROM_D_OUT);
AUX_ROM AUX_ROM_DP(AUX_ROM_ADDR_PROTECTED, CLK, AUX_ROM_D_OUT);

//AUX_2_ROM AUX2_ROM_DP(AUX2_ROM_ADDR, CLK, AUX2_ROM_D_OUT);
//AUX_ROM AUX_ROM_DP(AUX_ROM_ADDR, CLK, AUX_ROM_D_OUT);

wire [59:0] MUL1_OUT;
coefficient_multiplier_g MUL1(CLK, MUL1_IN1, MUL1_IN2, MUL1_OUT);

wire [29:0] MUX_MANY_MUL_OUT;
assign MUX_MANY_MUL_OUT = (MUX_MANY_MUL_SEL == 0) ? D_IN_SOP : BRR_OUT;

wire [59:0] MUL2_OUT, MUL3_OUT, MUL4_OUT;

wire [29:0] MUL2_IN1, MUL3_IN1, MUL4_IN1, MUL5_IN1, MUL6_IN1;
wire [29:0] MUL2_IN2, MUL3_IN2, MUL4_IN2, MUL5_IN2, MUL6_IN2;

assign MUL2_IN1 = (B2_SOP_TRANSFORM == 0) ? MUX_MANY_MUL_OUT : comb_tooth_4;
assign MUL2_IN2 = MAIN_ROM_D_OUT[29:0];
assign MUL3_IN1 = (B2_SOP_TRANSFORM == 0) ? MUX_MANY_MUL_OUT : comb_tooth_3;
assign MUL3_IN2 = AUX2_ROM_D_OUT[59:30];
assign MUL4_IN1 = (B2_SOP_TRANSFORM == 0) ? MUX_MANY_MUL_OUT : comb_tooth_2;
assign MUL4_IN2 = AUX2_ROM_D_OUT[29:0];


wire [29:0] BARR_OUT;

wire [62:0] BARR_IN;

assign BARR_IN = (SEL_60_63 == 0) ? {3'b0,MUL1_OUT} : OUTPUT_RDPD_RAM_2_internal_out;

barrett_red_63_by30mod BARRET_DP(	CLK,
											SEL_60_63,
											BARR_IN, 
											BCONST_QI_D_OUT[29:0], 
											BCONST_QI_D_OUT[63:30], 
											ONLY_MUL_CU, 
											MUL2_IN1, 
											{1'b0,MUL2_IN2},
											MUL3_IN1, 
											{1'b0,MUL3_IN2},
											MUL4_IN1, 
											{1'b0,MUL4_IN2},
											MUL2_OUT, 
											MUL3_OUT, 
											MUL4_OUT, 
											BARR_OUT);
											
assign MUL5_IN1 = (B2_SOP_TRANSFORM == 0) ? MUX_MANY_MUL_OUT : comb_tooth_1;
assign MUL5_IN2 = AUX_ROM_D_OUT[59:30];
assign MUL6_IN1 = (B2_SOP_TRANSFORM == 0) ? MUX_MANY_MUL_OUT : comb_tooth_0;
assign MUL6_IN2 = AUX_ROM_D_OUT[29:0];											

wire [59:0] MUL5_OUT;
coefficient_multiplier_g MUL5(CLK, MUL5_IN1, MUL5_IN2, MUL5_OUT);

wire [59:0] MUL6_OUT;
coefficient_multiplier_g MUL6(CLK, MUL6_IN1, MUL6_IN2, MUL6_OUT);

wire [29:0] BRR_OUT;
BARR_RES_RAM BARR_RES_RAM_DP(BRR_ADDR, BARR_OUT, CLK, BRR_WE, BRR_OUT);

wire [31:0] ra6, ra5, ra4, ra3, ra2, ra1, ra0_1; //result add
wire [3:0] ra0_0;
reg [31:0] rsum5, rsum3, rsum1; //register sum
reg [29:0] rsum6, rsum4, rsum2, rsum0_1; //register sum
reg [3:0] rsum0_0;

always @(posedge CLK)
begin
	if (REG_ADD_H_RST)
		begin 
			rsum4 <= 30'b0; 
			rsum3 <= 32'b0; 
			rsum2 <= 30'b0;  
			rsum1 <= 32'b0; 
			rsum0_1 <= 30'b0; 
			rsum0_0 <= 4'b0; 
		end
	else if (REG_ADD_H_EN)
		begin
			rsum4 <= ra4[29:0]; 
			rsum3 <= ra3; 
			rsum2 <= ra2[29:0];  
			rsum1 <= ra1; 
			rsum0_1 <= ra0_1[29:0]; 
			rsum0_0 <= ra0_0;  
		end
end

wire [29:0] MUX_SOP_1_OUT;	
wire [31:0] MUX_SOP_2_OUT;


assign MUX_SOP_1_OUT = (MUX_SOP_SEL == 1) ? rsum0_1 : ra6[29:0];
assign MUX_SOP_2_OUT = (MUX_SOP_SEL == 1) ? {28'b0,rsum0_0} : ra5;

always @(posedge CLK)
begin
	if (REG_ADD_L_RST)
		begin 
			rsum6 <= 30'b0; 
			rsum5 <= 32'b0; 
		end
	else if (REG_ADD_L_EN)
		begin
			rsum6 <= MUX_SOP_1_OUT; 
			rsum5 <= MUX_SOP_2_OUT; 
		end
end

wire [59:0] MUX_SB_TOP_OUT;

assign MUX_SB_TOP_OUT = (MUX_SB_TOP_SEL == 0) ? MUL1_OUT : 60'b0;

wire [29:0] a6_in30_1;
wire [29:0] a6_in30_2;
assign a6_in30_1 = MUL6_OUT[29:0];
assign a6_in30_2 = rsum6[29:0];

wire [1:0] a5_in2;
wire [29:0] a5_in30_1;
wire [29:0] a5_in30_2;
wire [29:0] a5_in30_3;
//assign a5_in2 = rsum6[31:30];
assign a5_in2 = ra6[31:30];
assign a5_in30_1 = MUL6_OUT[59:30];
assign a5_in30_2 = MUL5_OUT[29:0];
assign a5_in30_3 = rsum5[29:0];

wire [1:0] a4_in2;
wire [29:0] a4_in30_1;
wire [29:0] a4_in30_2;
wire [29:0] a4_in30_3;
assign a4_in2 = rsum5[31:30];
assign a4_in30_1 = MUL5_OUT[59:30];
assign a4_in30_2 = MUL4_OUT[29:0];
assign a4_in30_3 = rsum4[29:0];

wire [1:0] a3_in2;
wire [29:0] a3_in30_1;
wire [29:0] a3_in30_2;
wire [29:0] a3_in30_3;
//assign a3_in2 = rsum4[31:30];
assign a3_in2 = ra4[31:30];
assign a3_in30_1 = MUL4_OUT[59:30];
assign a3_in30_2 = MUL3_OUT[29:0];
assign a3_in30_3 = rsum3[29:0];

wire [1:0] a2_in2;
wire [29:0] a2_in30_1;
wire [29:0] a2_in30_2;
wire [29:0] a2_in30_3;
assign a2_in2 = rsum3[31:30];
assign a2_in30_1 = MUL3_OUT[59:30];
assign a2_in30_2 = MUL2_OUT[29:0];
assign a2_in30_3 = rsum2[29:0];

wire [1:0] a1_in2;
wire [29:0] a1_in30_1;
wire [29:0] a1_in30_2;
wire [29:0] a1_in30_3;
//assign a1_in2 = rsum2[31:30];
assign a1_in2 = ra2[31:30];
assign a1_in30_1 = MUL2_OUT[59:30];
assign a1_in30_2 = MUL1_OUT[29:0];
assign a1_in30_3 = rsum1[29:0];

wire [1:0] a0_1_in2;
wire [29:0] a0_1_in30_1;
wire [29:0] a0_1_in30_2;
assign a0_1_in2 = rsum1[31:30];
assign a0_1_in30_1 = MUX_SB_TOP_OUT[59:30];
assign a0_1_in30_2 = rsum0_1[29:0];

wire [1:0] a0_0_in2;
wire [3:0] a0_0_in4;
//assign a0_0_in2 = rsum0_1[31:30];
assign a0_0_in2 = ra0_1[31:30];
assign a0_0_in4 = rsum0_0;

adder_30_30 	  	adder_30_30_DP6		 	(a6_in30_1,a6_in30_2,ra6);
adder_2_30_30_30 	adder_2_30_30_30_DP5  	(a5_in2,a5_in30_1,a5_in30_2,a5_in30_3,ra5);
adder_2_30_30_30 	adder_2_30_30_30_DP4  	(a4_in2,a4_in30_1,a4_in30_2,a4_in30_3,ra4);
adder_2_30_30_30 	adder_2_30_30_30_DP3  	(a3_in2,a3_in30_1,a3_in30_2,a3_in30_3,ra3);
adder_2_30_30_30 	adder_2_30_30_30_DP2  	(a2_in2,a2_in30_1,a2_in30_2,a2_in30_3,ra2);
adder_2_30_30_30 	adder_2_30_30_30_DP1  	(a1_in2,a1_in30_1,a1_in30_2,a1_in30_3,ra1);
adder_2_30_30		adder_2_30_30_DP0_1		(a0_1_in2,a0_1_in30_1,a0_1_in30_2,ra0_1);
adder_2_4			adder_2_4_DP0_0			(a0_0_in2,a0_0_in4,ra0_0);

wire [60:0] S2_S1, S2_S2, S2_S3;//61BITS
wire [62:0] S2_S123; //63BITS
reg [60:0] S2_RS1, S2_RS2,  S2_RS3;
reg [62:0] S2_RS123;

assign S2_S1 = MUL1_OUT + MUL2_OUT;
assign S2_S2 = MUL3_OUT + MUL4_OUT;
assign S2_S3 = MUL5_OUT + MUL6_OUT;

always @ (posedge CLK) 
begin
	if (S2_RS_RST)
		begin
			S2_RS1 <= 61'b0;
			S2_RS2 <= 61'b0;
			S2_RS3 <= 61'b0;
		end 
	else if (S2_RS_EN) 
		begin
			S2_RS1 <= S2_S1;
			S2_RS2 <= S2_S2;
			S2_RS3 <= S2_S3;
		end
	else 
		begin
			S2_RS1 <= S2_RS1;
			S2_RS2 <= S2_RS2;
			S2_RS3 <= S2_RS3;
		end
end

assign S2_S123 = S2_RS1 + S2_RS2 + S2_RS3;

always @ (posedge CLK)
	if (S2_RS_RST)
		S2_RS123 <= 63'b0;
	else if (S2_RS_EN)
		S2_RS123<= S2_S123;
	else
		S2_RS123<= S2_RS123;


assign MUX_SB_TOP_OUT = (MUX_SB_TOP_SEL == 0) ? MUL1_OUT : 60'b0;


wire [59:0] A,B,C;
wire [33:0] D;
assign A = {rsum5[29:0],rsum6[29:0]};
assign B = {rsum3[29:0],rsum4[29:0]};
assign C = {rsum1[29:0],rsum2[29:0]};
assign D = {rsum0_0,rsum0_1[29:0]};

reg [61:0] REG_62_CB;

always @ (posedge CLK) 
begin
	if (REG_62_CB_RST)
		REG_62_CB <= 96'b0;
	else if (REG_62_CB_EN)
		REG_62_CB <= {C,B[59:58]};
	else 
		REG_62_CB <= REG_62_CB;
end	

wire [117:0] MUX_WB_OUT;
assign MUX_WB_OUT = (MUX_WB_SEL == 0) ? {B[57:0],A} : 
						  (MUX_WB_SEL == 1) ? {22'b0,D,C,B[59:58]} :
						  (MUX_WB_SEL == 2) ? {B[57:0],A} :
						  (MUX_WB_SEL == 3) ? {A[55:0],REG_62_CB} :
						  (MUX_WB_SEL == 4) ? {C[53:0],B,A[59:56]} :
						  {78'b0,D,C[59:54]};
						  
localparam [3:0] OFFSET_WINDOWS=8;

wire [3:0] OUTPUT_RAM_DPRA_FINAL;
wire [5:0] TEMP_RD0, TEMP_RD1;
assign TEMP_RD0 = OFFSET_WINDOWS*RD_WINDOW;
assign TEMP_RD1 = TEMP_RD0 + RD_RESULT_ADDR;
assign OUTPUT_RAM_DPRA_FINAL = TEMP_RD1[3:0]; 

wire [3:0] OUTPUT_RAM_WB_ADDR_FINAL;
wire [5:0] TEMP0;
assign TEMP0 = OFFSET_WINDOWS*WB_WINDOW;
wire [5:0] TEMP1;
assign TEMP1 = TEMP0+ WB_RESULT_ADDR;
assign OUTPUT_RAM_WB_ADDR_FINAL = TEMP1[3:0];

wire [117:0] unused_output_ram;

OUTPUT_RDPD_RAM OUTPUT_RDPD_RAM_DP(OUTPUT_RAM_WB_ADDR_FINAL,
												MUX_WB_OUT,
												OUTPUT_RAM_DPRA_FINAL,
												CLK,
												WB_WE,
												unused_output_ram,
												D_OUT_SOP);
												
//OUTPUT_RAM_2 63 bits x 16 locations												
wire [3:0] OUTPUT_RAM_DPRA_FINAL_2;
wire [5:0] TEMP_RD0_2, TEMP_RD1_2;
assign TEMP_RD0_2 = OFFSET_WINDOWS*RD_WINDOW_2;
assign TEMP_RD1_2 = TEMP_RD0_2 + RD_RESULT_ADDR_2;
assign OUTPUT_RAM_DPRA_FINAL_2 = TEMP_RD1_2[3:0]; 

wire [3:0] OUTPUT_RAM_WB_ADDR_FINAL_2; //used also for reading from the internal of the block
wire [5:0] TEMP0_2;
assign TEMP0_2 = OFFSET_WINDOWS*WB_WINDOW_2;
wire [5:0] TEMP1_2;
assign TEMP1_2 = TEMP0_2+ WB_RESULT_ADDR_2; //not the same as 1 because different lenght of addresses.
assign OUTPUT_RAM_WB_ADDR_FINAL_2 = TEMP1_2[3:0];

wire [62:0] OUTPUT_RDPD_RAM_2_internal_out;

wire [62:0] OUTPUT_RAM_2_final_DIN;
assign OUTPUT_RAM_2_final_DIN = (B2_PHASE == 0) ? S2_RS123 : {33'b0,BARR_OUT};

OUTPUT_RDPD_RAM_63 OUTPUT_RDPD_RAM_DP_2(	OUTPUT_RAM_WB_ADDR_FINAL_2,
														OUTPUT_RAM_2_final_DIN,
														OUTPUT_RAM_DPRA_FINAL_2,
														CLK,
														WB_WE_2,
														OUTPUT_RDPD_RAM_2_internal_out,
														D_OUT_SOP_2);

endmodule

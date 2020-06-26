`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *)
module homenc_coprocessor (
    input  wire          clk,

    input  wire          cpu_interrupt,     // This signal is used by ARM to choose a particular processor for reading or writing
    input  wire [  6:0]  cpu_mb_strobe,     // One-hot signal to select target memory block
    input  wire          cpu_mb_all,        // This signal is raised (simultaneously with cpu_interrupt) to enable writing same data in all 6 processors.
    input  wire [  3:0]  cpu_mem_sel,       // It is fixed to 4
    input  wire [ 16:0]  cpu_mem_addr,
    input  wire [511:0]  cpu_mem_wr_data,
    input  wire [ 63:0]  cpu_mem_wr_en,
    output wire [511:0]  cpu_mem_rd_data,

    input  wire [  7:0]  instruction,
    input  wire          modulus_sel,	    // modulus_sel_reg=0 then q0 to q5 else q6 to q12
    input  wire [  3:0]  rdM0,
    input  wire [  3:0]  rdM1,
    input  wire [  3:0]  wtM0,
    input  wire [  3:0]  wtM1,
    output wire          done
);


reg [  7:0]  instruction_reg;
reg          modulus_sel_reg;
reg [  3:0]  rdM0_reg;
reg [  3:0]  rdM1_reg;
reg [  3:0]  wtM0_reg;
reg [  3:0]  wtM1_reg;

always @(posedge clk) begin
  instruction_reg <= instruction;
  modulus_sel_reg <= modulus_sel;
  rdM0_reg        <= rdM0;
  rdM1_reg        <= rdM1;
  wtM0_reg        <= wtM0;
  wtM1_reg        <= wtM1;
end



//////////////////// NTT ROM //////////////////////////

wire [12:0] NTT_core0_addr, NTT_core1_addr;
wire [29:0] NTT_core0_mb0, NTT_core1_mb0;
wire [29:0] NTT_core0_mb1, NTT_core1_mb1;
wire [29:0] NTT_core0_mb2, NTT_core1_mb2;
wire [29:0] NTT_core0_mb3, NTT_core1_mb3;
wire [29:0] NTT_core0_mb4, NTT_core1_mb4;
wire [29:0] NTT_core0_mb5, NTT_core1_mb5;
wire [29:0] NTT_core0_mb6, NTT_core1_mb6;

NTT_ROM  Twiddel (
    clk,
    instruction_reg,
    modulus_sel_reg,

    NTT_core0_addr, NTT_core1_addr,
    NTT_core0_mb0,  NTT_core1_mb0,
    NTT_core0_mb1,  NTT_core1_mb1,
    NTT_core0_mb2,  NTT_core1_mb2,
    NTT_core0_mb3,  NTT_core1_mb3,
    NTT_core0_mb4,  NTT_core1_mb4,
    NTT_core0_mb5,  NTT_core1_mb5,
    NTT_core0_mb6,  NTT_core1_mb6
);

//////////////////// TWO RLWE PROCESSOR CORES  //////////////////////////

wire em_rst = (instruction_reg==8'd0) ? 1'b1 : 1'b0;

wire        data_load;
wire [29:0] in1, in2;
wire        message_bit;
wire [8:0]  random;

wire        rlwe_core0_random_en;
wire        rlwe_core0_initiate_loading;
wire [1:0]  rlwe_core0_mem_rd_sel,  rlwe_core0_mem_wr_sel;	// Memory Index selection
wire [10:0] rlwe_core0_mb0_wr_addr, rlwe_core0_mb1_wr_addr, rlwe_core0_mb2_wr_addr, rlwe_core0_mb3_wr_addr, rlwe_core0_mb4_wr_addr, rlwe_core0_mb5_wr_addr, rlwe_core0_mb6_wr_addr;
wire [10:0] rlwe_core0_mb0_rd_addr, rlwe_core0_mb1_rd_addr, rlwe_core0_mb2_rd_addr, rlwe_core0_mb3_rd_addr, rlwe_core0_mb4_rd_addr, rlwe_core0_mb5_rd_addr, rlwe_core0_mb6_rd_addr;
wire        rlwe_core0_mb0_wr_en,   rlwe_core0_mb1_wr_en,   rlwe_core0_mb2_wr_en,   rlwe_core0_mb3_wr_en,   rlwe_core0_mb4_wr_en,   rlwe_core0_mb5_wr_en,   rlwe_core0_mb6_wr_en;
wire [29:0] rlwe_core0_mb0_din_H,   rlwe_core0_mb1_din_H,   rlwe_core0_mb2_din_H,   rlwe_core0_mb3_din_H,   rlwe_core0_mb4_din_H,   rlwe_core0_mb5_din_H,   rlwe_core0_mb6_din_H;
wire [29:0] rlwe_core0_mb0_din_L,   rlwe_core0_mb1_din_L,   rlwe_core0_mb2_din_L,   rlwe_core0_mb3_din_L,   rlwe_core0_mb4_din_L,   rlwe_core0_mb5_din_L,   rlwe_core0_mb6_din_L;
wire [59:0] rlwe_core0_mb0_dout,    rlwe_core0_mb1_dout,    rlwe_core0_mb2_dout,    rlwe_core0_mb3_dout,    rlwe_core0_mb4_dout,    rlwe_core0_mb5_dout,    rlwe_core0_mb6_dout;
wire        rlwe_core0_done;

wire        rlwe_core1_random_en;
wire        rlwe_core1_initiate_loading;
wire [1:0]  rlwe_core1_mem_rd_sel,  rlwe_core1_mem_wr_sel;	// Memory Index selection
wire [10:0] rlwe_core1_mb0_wr_addr, rlwe_core1_mb1_wr_addr, rlwe_core1_mb2_wr_addr, rlwe_core1_mb3_wr_addr, rlwe_core1_mb4_wr_addr, rlwe_core1_mb5_wr_addr, rlwe_core1_mb6_wr_addr;
wire [10:0] rlwe_core1_mb0_rd_addr, rlwe_core1_mb1_rd_addr, rlwe_core1_mb2_rd_addr, rlwe_core1_mb3_rd_addr, rlwe_core1_mb4_rd_addr, rlwe_core1_mb5_rd_addr, rlwe_core1_mb6_rd_addr;
wire        rlwe_core1_mb0_wr_en,   rlwe_core1_mb1_wr_en,   rlwe_core1_mb2_wr_en,   rlwe_core1_mb3_wr_en,   rlwe_core1_mb4_wr_en,   rlwe_core1_mb5_wr_en,   rlwe_core1_mb6_wr_en;
wire [29:0] rlwe_core1_mb0_din_H,   rlwe_core1_mb1_din_H,   rlwe_core1_mb2_din_H,   rlwe_core1_mb3_din_H,   rlwe_core1_mb4_din_H,   rlwe_core1_mb5_din_H,   rlwe_core1_mb6_din_H;
wire [29:0] rlwe_core1_mb0_din_L,   rlwe_core1_mb1_din_L,   rlwe_core1_mb2_din_L,   rlwe_core1_mb3_din_L,   rlwe_core1_mb4_din_L,   rlwe_core1_mb5_din_L,   rlwe_core1_mb6_din_L;
wire [59:0] rlwe_core1_mb0_dout,    rlwe_core1_mb1_dout,    rlwe_core1_mb2_dout,    rlwe_core1_mb3_dout,    rlwe_core1_mb4_dout,    rlwe_core1_mb5_dout,    rlwe_core1_mb6_dout;
wire        rlwe_core1_done;


rlwe_top #(0) EM (
    clk,
    modulus_sel_reg,
    em_rst,
    instruction_reg,

    data_load,
    in1,
    in2,
    message_bit,
    rlwe_core0_initiate_loading,

    rlwe_core0_mem_rd_sel,
    rlwe_core0_mem_wr_sel,

    rlwe_core0_mb0_wr_en, rlwe_core0_mb0_wr_addr, rlwe_core0_mb0_rd_addr,
    rlwe_core0_mb1_wr_en, rlwe_core0_mb1_wr_addr, rlwe_core0_mb1_rd_addr,
    rlwe_core0_mb2_wr_en, rlwe_core0_mb2_wr_addr, rlwe_core0_mb2_rd_addr,
    rlwe_core0_mb3_wr_en, rlwe_core0_mb3_wr_addr, rlwe_core0_mb3_rd_addr,
    rlwe_core0_mb4_wr_en, rlwe_core0_mb4_wr_addr, rlwe_core0_mb4_rd_addr,
    rlwe_core0_mb5_wr_en, rlwe_core0_mb5_wr_addr, rlwe_core0_mb5_rd_addr,
    rlwe_core0_mb6_wr_en, rlwe_core0_mb6_wr_addr, rlwe_core0_mb6_rd_addr,

    rlwe_core0_random_en,
    random,

    rlwe_core0_mb0_din_H, rlwe_core0_mb0_din_L, rlwe_core0_mb0_dout,
    rlwe_core0_mb1_din_H, rlwe_core0_mb1_din_L, rlwe_core0_mb1_dout,
    rlwe_core0_mb2_din_H, rlwe_core0_mb2_din_L, rlwe_core0_mb2_dout,
    rlwe_core0_mb3_din_H, rlwe_core0_mb3_din_L, rlwe_core0_mb3_dout,
    rlwe_core0_mb4_din_H, rlwe_core0_mb4_din_L, rlwe_core0_mb4_dout,
    rlwe_core0_mb5_din_H, rlwe_core0_mb5_din_L, rlwe_core0_mb5_dout,
    rlwe_core0_mb6_din_H, rlwe_core0_mb6_din_L, rlwe_core0_mb6_dout,

    NTT_core0_addr,
    NTT_core0_mb0,
    NTT_core0_mb1,
    NTT_core0_mb2,
    NTT_core0_mb3,
    NTT_core0_mb4,
    NTT_core0_mb5,
    NTT_core0_mb6,

    rlwe_core0_done
);

rlwe_top #(1) EM_n (
    clk,
    modulus_sel_reg,
    em_rst,
    instruction_reg,

    data_load,
    in1,
    in2,
    message_bit,
    rlwe_core1_initiate_loading,

    rlwe_core1_mem_rd_sel,
    rlwe_core1_mem_wr_sel,

    rlwe_core1_mb0_wr_en, rlwe_core1_mb0_wr_addr, rlwe_core1_mb0_rd_addr,
    rlwe_core1_mb1_wr_en, rlwe_core1_mb1_wr_addr, rlwe_core1_mb1_rd_addr,
    rlwe_core1_mb2_wr_en, rlwe_core1_mb2_wr_addr, rlwe_core1_mb2_rd_addr,
    rlwe_core1_mb3_wr_en, rlwe_core1_mb3_wr_addr, rlwe_core1_mb3_rd_addr,
    rlwe_core1_mb4_wr_en, rlwe_core1_mb4_wr_addr, rlwe_core1_mb4_rd_addr,
    rlwe_core1_mb5_wr_en, rlwe_core1_mb5_wr_addr, rlwe_core1_mb5_rd_addr,
    rlwe_core1_mb6_wr_en, rlwe_core1_mb6_wr_addr, rlwe_core1_mb6_rd_addr,

    rlwe_core1_random_en,
    random,

    rlwe_core1_mb0_din_H, rlwe_core1_mb0_din_L, rlwe_core1_mb0_dout,
    rlwe_core1_mb1_din_H, rlwe_core1_mb1_din_L, rlwe_core1_mb1_dout,
    rlwe_core1_mb2_din_H, rlwe_core1_mb2_din_L, rlwe_core1_mb2_dout,
    rlwe_core1_mb3_din_H, rlwe_core1_mb3_din_L, rlwe_core1_mb3_dout,
    rlwe_core1_mb4_din_H, rlwe_core1_mb4_din_L, rlwe_core1_mb4_dout,
    rlwe_core1_mb5_din_H, rlwe_core1_mb5_din_L, rlwe_core1_mb5_dout,
    rlwe_core1_mb6_din_H, rlwe_core1_mb6_din_L, rlwe_core1_mb6_dout,

    NTT_core1_addr,
    NTT_core1_mb0,
    NTT_core1_mb1,
    NTT_core1_mb2,
    NTT_core1_mb3,
    NTT_core1_mb4,
    NTT_core1_mb5,
    NTT_core1_mb6,

    rlwe_core1_done
);

//////////////////// LIFT  //////////////////////////

wire         lift_rst       = (instruction_reg==8'd5 || instruction_reg==8'd6 || instruction_reg==8'd7) ? 1'b0 : 1'b1;
wire         lift_interrupt = (lift_rst==1'b0);
wire         lift_wr_en;
wire [2:0]   lift_mb_sel;
wire [3:0]   lift_mem_sel;
wire [8:0]   lift_addr;
wire [239:0] lift_rd_data;
wire [239:0] lift_wr_data;
wire         lift_done;

lift_control_wrapper_2core  LC_shoup(
    clk,
    lift_rst,
    instruction_reg,

    rdM0_reg,
    rdM1_reg,
    wtM0_reg,
    wtM1_reg,

    lift_mb_sel,
    lift_mem_sel,
    lift_addr,
    lift_wr_en,
    lift_rd_data,
    lift_wr_data,
    lift_done
);


/////////////////// MEM signals  ///////////////////////////

wire [3:0]  mux_mem_rd_sel        = (rlwe_core0_mem_rd_sel[0]) ? rdM1_reg : rdM0_reg;
wire [3:0]  mux_mem_wr_sel        = (rlwe_core0_mem_wr_sel[0]) ? wtM1_reg : wtM0_reg;

wire [8:0]  mg_lift_address     = (lift_rst==1'b0) ? lift_addr  : 9'd0;
wire        mg_lift_we          = (lift_rst==1'b0) ? lift_wr_en : 1'b0;

assign done = (lift_rst==1'b0) ? lift_done : rlwe_core0_done;

// wire [3:0] mem_sel_new = (lift_rst==1'b0) ? 4'b0 : cpu_mem_sel;

// wire [2:0] mb_sel_new = (lift_rst==1'b0) ? lift_mb_sel : cpu_mb_sel;

// reg  [2:0] mb_sel_new_latched;
// always @(posedge clk)
    // mb_sel_new_latched <= mb_sel_new;

// wire [2:0] mb_sel_to_mg = (cpu_interrupt==1'b1 && cpu_mem_wr_en==1'b0) ? mb_sel_new_latched : mb_sel_new;

MemoryGroup	MG(
    clk,

    mux_mem_rd_sel,     // Used by rlwe
    mux_mem_wr_sel,     // Used by rlwe

    cpu_interrupt,
    cpu_mb_strobe,
    cpu_mb_all,
    cpu_mem_sel,
    cpu_mem_addr,
    cpu_mem_wr_data,
    cpu_mem_wr_en,
    cpu_mem_rd_data,

    rlwe_core0_mb0_wr_addr, rlwe_core0_mb1_wr_addr, rlwe_core0_mb2_wr_addr, rlwe_core0_mb3_wr_addr, rlwe_core0_mb4_wr_addr, rlwe_core0_mb5_wr_addr, rlwe_core0_mb6_wr_addr,
    rlwe_core0_mb0_rd_addr, rlwe_core0_mb1_rd_addr, rlwe_core0_mb2_rd_addr, rlwe_core0_mb3_rd_addr, rlwe_core0_mb4_rd_addr, rlwe_core0_mb5_rd_addr, rlwe_core0_mb6_rd_addr,
    rlwe_core0_mb0_wr_en,   rlwe_core0_mb1_wr_en,   rlwe_core0_mb2_wr_en,   rlwe_core0_mb3_wr_en,   rlwe_core0_mb4_wr_en,   rlwe_core0_mb5_wr_en,   rlwe_core0_mb6_wr_en,
    {rlwe_core0_mb0_din_H, rlwe_core0_mb0_din_L}, {rlwe_core0_mb1_din_H, rlwe_core0_mb1_din_L}, {rlwe_core0_mb2_din_H, rlwe_core0_mb2_din_L}, {rlwe_core0_mb3_din_H, rlwe_core0_mb3_din_L}, {rlwe_core0_mb4_din_H, rlwe_core0_mb4_din_L}, {rlwe_core0_mb5_din_H, rlwe_core0_mb5_din_L}, {rlwe_core0_mb6_din_H, rlwe_core0_mb6_din_L},
    rlwe_core0_mb0_dout, rlwe_core0_mb1_dout, rlwe_core0_mb2_dout, rlwe_core0_mb3_dout, rlwe_core0_mb4_dout, rlwe_core0_mb5_dout, rlwe_core0_mb6_dout,

    rlwe_core1_mb0_wr_addr, rlwe_core1_mb1_wr_addr, rlwe_core1_mb2_wr_addr, rlwe_core1_mb3_wr_addr, rlwe_core1_mb4_wr_addr, rlwe_core1_mb5_wr_addr, rlwe_core1_mb6_wr_addr,
    rlwe_core1_mb0_rd_addr, rlwe_core1_mb1_rd_addr, rlwe_core1_mb2_rd_addr, rlwe_core1_mb3_rd_addr, rlwe_core1_mb4_rd_addr, rlwe_core1_mb5_rd_addr, rlwe_core1_mb6_rd_addr,
    rlwe_core1_mb0_wr_en,   rlwe_core1_mb1_wr_en,   rlwe_core1_mb2_wr_en,   rlwe_core1_mb3_wr_en,   rlwe_core1_mb4_wr_en,   rlwe_core1_mb5_wr_en,   rlwe_core1_mb6_wr_en,
    {rlwe_core1_mb0_din_H, rlwe_core1_mb0_din_L}, {rlwe_core1_mb1_din_H, rlwe_core1_mb1_din_L}, {rlwe_core1_mb2_din_H, rlwe_core1_mb2_din_L}, {rlwe_core1_mb3_din_H, rlwe_core1_mb3_din_L}, {rlwe_core1_mb4_din_H, rlwe_core1_mb4_din_L}, {rlwe_core1_mb5_din_H, rlwe_core1_mb5_din_L}, {rlwe_core1_mb6_din_H, rlwe_core1_mb6_din_L},
    rlwe_core1_mb0_dout, rlwe_core1_mb1_dout, rlwe_core1_mb2_dout, rlwe_core1_mb3_dout, rlwe_core1_mb4_dout, rlwe_core1_mb5_dout, rlwe_core1_mb6_dout,

    lift_interrupt,
    lift_mb_sel,
    lift_mem_sel,
    mg_lift_address,
    mg_lift_we,
    lift_wr_data,
    lift_rd_data
);

endmodule


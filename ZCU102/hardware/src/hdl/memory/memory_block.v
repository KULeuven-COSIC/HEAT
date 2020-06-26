`timescale 1ns / 1ps

module MemoryBlock (
    input  wire         clk,

    input  wire         mem_sel_override,	// Defines if memories will be selected by cpu/lift or emulator
    input  wire [3:0]   mem_sel,		     // If 'mem_sel_override' is high, this is used by the top module to seleact a memory for read/write of cpu and lift
    input  wire [3:0]   mem_rd_sel,          // If 'mem_sel_override' is low,  this is used by the top module to seleact a memory for read of emulator
    input  wire [3:0]   mem_wr_sel,		// If 'mem_sel_override' is low,  this is used by the top module to seleact a memory for write of emulator

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

/// Memory read select

wire [3:0]  doutb_sel_wire =  (mem_sel_override) ? mem_sel : mem_rd_sel;
reg  [3:0]  doutb_sel;

always @(posedge clk)	// Delay by one cycle as data in dout appears after one cycle.
  doutb_sel <= doutb_sel_wire;

wire [59:0]  mem1_core0_rd_data;
wire [59:0]  mem2_core0_rd_data;
wire [59:0]  mem3_core0_rd_data;
wire [59:0]  mem4_core0_rd_data;
wire [59:0]  mem5_core0_rd_data;
wire [59:0]  mem6_core0_rd_data;
wire [59:0]  mem7_core0_rd_data;
wire [59:0]  mem8_core0_rd_data;
wire [59:0]  mem9_core0_rd_data;
wire [59:0]  mem1_core1_rd_data;
wire [59:0]  mem2_core1_rd_data;
wire [59:0]  mem3_core1_rd_data;
wire [59:0]  mem4_core1_rd_data;
wire [59:0]  mem5_core1_rd_data;
wire [59:0]  mem6_core1_rd_data;
wire [59:0]  mem7_core1_rd_data;
wire [59:0]  mem8_core1_rd_data;
wire [59:0]  mem9_core1_rd_data;

assign core0_rd_data =   (doutb_sel==4'd1) ? mem1_core0_rd_data :
					(doutb_sel==4'd2) ? mem2_core0_rd_data :
					(doutb_sel==4'd3) ? mem3_core0_rd_data :
					(doutb_sel==4'd4) ? mem4_core0_rd_data :
					(doutb_sel==4'd5) ? mem5_core0_rd_data :
					(doutb_sel==4'd6) ? mem6_core0_rd_data :
					(doutb_sel==4'd7) ? mem7_core0_rd_data :
					(doutb_sel==4'd8) ? mem8_core0_rd_data :
					(doutb_sel==4'd9) ? mem9_core0_rd_data :
					                    60'd0;

assign core1_rd_data =   (doutb_sel==4'd1) ? mem1_core1_rd_data :
                         (doutb_sel==4'd2) ? mem2_core1_rd_data :
                         (doutb_sel==4'd3) ? mem3_core1_rd_data :
                         (doutb_sel==4'd4) ? mem4_core1_rd_data :
                         (doutb_sel==4'd5) ? mem5_core1_rd_data :
                         (doutb_sel==4'd6) ? mem6_core1_rd_data :
                         (doutb_sel==4'd7) ? mem7_core1_rd_data :
                         (doutb_sel==4'd8) ? mem8_core1_rd_data :
                         (doutb_sel==4'd9) ? mem9_core1_rd_data :
                                             60'd0;

/// Memory write select

wire [3:0]   mux_mem_wr_sel = (mem_sel_override) ? mem_sel : mem_wr_sel;

wire mem1_core0_wr_en = (mux_mem_wr_sel==4'd1) & core0_wr_en;
wire mem2_core0_wr_en = (mux_mem_wr_sel==4'd2) & core0_wr_en;
wire mem3_core0_wr_en = (mux_mem_wr_sel==4'd3) & core0_wr_en;
wire mem4_core0_wr_en = (mux_mem_wr_sel==4'd4) & core0_wr_en;
wire mem5_core0_wr_en = (mux_mem_wr_sel==4'd5) & core0_wr_en;
wire mem6_core0_wr_en = (mux_mem_wr_sel==4'd6) & core0_wr_en;
wire mem7_core0_wr_en = (mux_mem_wr_sel==4'd7) & core0_wr_en;
wire mem8_core0_wr_en = (mux_mem_wr_sel==4'd8) & core0_wr_en;
wire mem9_core0_wr_en = (mux_mem_wr_sel==4'd9) & core0_wr_en;

wire mem1_core1_wr_en = (mux_mem_wr_sel==4'd1) & core1_wr_en;
wire mem2_core1_wr_en = (mux_mem_wr_sel==4'd2) & core1_wr_en;
wire mem3_core1_wr_en = (mux_mem_wr_sel==4'd3) & core1_wr_en;
wire mem4_core1_wr_en = (mux_mem_wr_sel==4'd4) & core1_wr_en;
wire mem5_core1_wr_en = (mux_mem_wr_sel==4'd5) & core1_wr_en;
wire mem6_core1_wr_en = (mux_mem_wr_sel==4'd6) & core1_wr_en;
wire mem7_core1_wr_en = (mux_mem_wr_sel==4'd7) & core1_wr_en;
wire mem8_core1_wr_en = (mux_mem_wr_sel==4'd8) & core1_wr_en;
wire mem9_core1_wr_en = (mux_mem_wr_sel==4'd9) & core1_wr_en;

/// Lift enable

wire mem1_lift_we = (mem_sel==4'd1) & lift_we;
wire mem2_lift_we = (mem_sel==4'd2) & lift_we;
wire mem3_lift_we = (mem_sel==4'd3) & lift_we;
wire mem4_lift_we = (mem_sel==4'd4) & lift_we;
wire mem5_lift_we = (mem_sel==4'd5) & lift_we;
wire mem6_lift_we = (mem_sel==4'd6) & lift_we;
wire mem7_lift_we = (mem_sel==4'd7) & lift_we;
wire mem8_lift_we = (mem_sel==4'd8) & lift_we;
wire mem9_lift_we = (mem_sel==4'd9) & lift_we;

/// Lift output

wire [239:0] mem1_lift_rd_data;
wire [239:0] mem2_lift_rd_data;
wire [239:0] mem3_lift_rd_data;
wire [239:0] mem4_lift_rd_data;
wire [239:0] mem5_lift_rd_data;
wire [239:0] mem6_lift_rd_data;
wire [239:0] mem7_lift_rd_data;
wire [239:0] mem8_lift_rd_data;
wire [239:0] mem9_lift_rd_data;

assign lift_rd_data = (mem_sel==4'd1) ? mem1_lift_rd_data :
                      (mem_sel==4'd2) ? mem2_lift_rd_data :
                      (mem_sel==4'd3) ? mem3_lift_rd_data :
                      (mem_sel==4'd4) ? mem4_lift_rd_data :
                      (mem_sel==4'd5) ? mem5_lift_rd_data :
                      (mem_sel==4'd6) ? mem6_lift_rd_data :
                      (mem_sel==4'd7) ? mem7_lift_rd_data :
                      (mem_sel==4'd8) ? mem8_lift_rd_data :
                                        mem9_lift_rd_data ;

memory2048 ME1(
     clk,

     core0_wr_addr,
     core0_rd_addr,
mem1_core0_wr_en,
     core0_wr_data,
mem1_core0_rd_data,

     core1_wr_addr,
     core1_rd_addr,
mem1_core1_wr_en,
     core1_wr_data,
mem1_core1_rd_data,

     lift_interrupt,
     lift_address,
mem1_lift_we,
     lift_wr_data,
mem1_lift_rd_data
);

memory2048 ME2(
     clk,

     core0_wr_addr,
     core0_rd_addr,
mem2_core0_wr_en,
     core0_wr_data,
mem2_core0_rd_data,

     core1_wr_addr,
     core1_rd_addr,
mem2_core1_wr_en,
     core1_wr_data,
mem2_core1_rd_data,

     lift_interrupt,
     lift_address,
mem2_lift_we,
     lift_wr_data,
mem2_lift_rd_data
);

memory2048 ME3(
     clk,

     core0_wr_addr,
     core0_rd_addr,
mem3_core0_wr_en,
     core0_wr_data,
mem3_core0_rd_data,

     core1_wr_addr,
     core1_rd_addr,
mem3_core1_wr_en,
     core1_wr_data,
mem3_core1_rd_data,

     lift_interrupt,
     lift_address,
mem3_lift_we,
     lift_wr_data,
mem3_lift_rd_data
);

memory2048 ME4(
     clk,

     core0_wr_addr,
     core0_rd_addr,
mem4_core0_wr_en,
     core0_wr_data,
mem4_core0_rd_data,

     core1_wr_addr,
     core1_rd_addr,
mem4_core1_wr_en,
     core1_wr_data,
mem4_core1_rd_data,

     lift_interrupt,
     lift_address,
mem4_lift_we,
     lift_wr_data,
mem4_lift_rd_data
);

memory2048 ME5(
     clk,

     core0_wr_addr,
     core0_rd_addr,
mem5_core0_wr_en,
     core0_wr_data,
mem5_core0_rd_data,

     core1_wr_addr,
     core1_rd_addr,
mem5_core1_wr_en,
     core1_wr_data,
mem5_core1_rd_data,

     lift_interrupt,
     lift_address,
mem5_lift_we,
     lift_wr_data,
mem5_lift_rd_data
);

memory2048 ME6(
     clk,

     core0_wr_addr,
     core0_rd_addr,
mem6_core0_wr_en,
     core0_wr_data,
mem6_core0_rd_data,

     core1_wr_addr,
     core1_rd_addr,
mem6_core1_wr_en,
     core1_wr_data,
mem6_core1_rd_data,

     lift_interrupt,
     lift_address,
mem6_lift_we,
     lift_wr_data,
mem6_lift_rd_data
);

memory2048 ME7(
     clk,

     core0_wr_addr,
     core0_rd_addr,
mem7_core0_wr_en,
     core0_wr_data,
mem7_core0_rd_data,

     core1_wr_addr,
     core1_rd_addr,
mem7_core1_wr_en,
     core1_wr_data,
mem7_core1_rd_data,

     lift_interrupt,
     lift_address,
mem7_lift_we,
     lift_wr_data,
mem7_lift_rd_data
);

memory2048 ME8(
     clk,

     core0_wr_addr,
     core0_rd_addr,
mem8_core0_wr_en,
     core0_wr_data,
mem8_core0_rd_data,

     core1_wr_addr,
     core1_rd_addr,
mem8_core1_wr_en,
     core1_wr_data,
mem8_core1_rd_data,

     lift_interrupt,
     lift_address,
mem8_lift_we,
     lift_wr_data,
mem8_lift_rd_data
);

memory2048 ME9(
     clk,

     core0_wr_addr,
     core0_rd_addr,
mem9_core0_wr_en,
     core0_wr_data,
mem9_core0_rd_data,

     core1_wr_addr,
     core1_rd_addr,
mem9_core1_wr_en,
     core1_wr_data,
mem9_core1_rd_data,

     lift_interrupt,
     lift_address,
mem9_lift_we,
     lift_wr_data,
mem9_lift_rd_data
);

endmodule


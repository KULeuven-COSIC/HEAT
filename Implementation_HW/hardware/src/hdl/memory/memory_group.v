`timescale 1ns / 1ps

module MemoryGroup(
    input  wire          clk,
                                                // These are used by the top module to seleach one of the two internal-memory
    input  wire [2:0]    mb_sel, 	            // To select one of the 7 memory blocks
    input  wire [3:0]    mem_sel,		        // To select a memory within a block to read/write.

    input  wire [3:0]    mem_rd_sel,	        // Memory selection of emulator
    input  wire [3:0]    mem_wr_sel,

    input  wire          cpu_interrupt,	        // This is used by the top module to override memory selection
    input  wire          cpu_mem_sel_all,       // This signal is raised (simultaneously with cpu_interrupt) to enable writing same data in all 6 processors.
    input  wire [59:0]   cpu_din,
    output wire [59:0]   cpu_dout,

    input  wire [10:0]   core0_mb0_wr_addr, core0_mb1_wr_addr, core0_mb2_wr_addr, core0_mb3_wr_addr, core0_mb4_wr_addr, core0_mb5_wr_addr, core0_mb6_wr_addr,
    input  wire [10:0]   core0_mb0_rd_addr, core0_mb1_rd_addr, core0_mb2_rd_addr, core0_mb3_rd_addr, core0_mb4_rd_addr, core0_mb5_rd_addr, core0_mb6_rd_addr,
    input  wire          core0_mb0_wr_en,   core0_mb1_wr_en,   core0_mb2_wr_en,   core0_mb3_wr_en,   core0_mb4_wr_en,   core0_mb5_wr_en,   core0_mb6_wr_en,
    input  wire [59:0]   core0_mb0_din,     core0_mb1_din,     core0_mb2_din,     core0_mb3_din,     core0_mb4_din,     core0_mb5_din,     core0_mb6_din,
    output wire [59:0]   core0_mb0_dout,    core0_mb1_dout,    core0_mb2_dout,    core0_mb3_dout,    core0_mb4_dout,    core0_mb5_dout,    core0_mb6_dout,

    input  wire [10:0]   core1_mb0_wr_addr, core1_mb1_wr_addr, core1_mb2_wr_addr, core1_mb3_wr_addr, core1_mb4_wr_addr, core1_mb5_wr_addr, core1_mb6_wr_addr,
    input  wire [10:0]   core1_mb0_rd_addr, core1_mb1_rd_addr, core1_mb2_rd_addr, core1_mb3_rd_addr, core1_mb4_rd_addr, core1_mb5_rd_addr, core1_mb6_rd_addr,
    input  wire          core1_mb0_wr_en,   core1_mb1_wr_en,   core1_mb2_wr_en,   core1_mb3_wr_en,   core1_mb4_wr_en,   core1_mb5_wr_en,   core1_mb6_wr_en,
    input  wire [59:0]   core1_mb0_din,     core1_mb1_din,     core1_mb2_din,     core1_mb3_din,     core1_mb4_din,     core1_mb5_din,     core1_mb6_din,
    output wire [59:0]   core1_mb0_dout,    core1_mb1_dout,    core1_mb2_dout,    core1_mb3_dout,    core1_mb4_dout,    core1_mb5_dout,    core1_mb6_dout,

    input  wire          lift_interrupt,
    input  wire [8:0]    lift_address,
    input  wire          lift_we,
    input  wire [239:0]  lift_wr_data,
    output wire [239:0]  lift_rd_data
);

// Lift related signals

wire mb0_lift_we  = (lift_interrupt==1'b1 && mb_sel==3'd0) ? lift_we : 1'b0;
wire mb1_lift_we  = (lift_interrupt==1'b1 && mb_sel==3'd1) ? lift_we : 1'b0;
wire mb2_lift_we  = (lift_interrupt==1'b1 && mb_sel==3'd2) ? lift_we : 1'b0;
wire mb3_lift_we  = (lift_interrupt==1'b1 && mb_sel==3'd3) ? lift_we : 1'b0;
wire mb4_lift_we  = (lift_interrupt==1'b1 && mb_sel==3'd4) ? lift_we : 1'b0;
wire mb5_lift_we  = (lift_interrupt==1'b1 && mb_sel==3'd5) ? lift_we : 1'b0;
wire mb6_lift_we  = (lift_interrupt==1'b1 && mb_sel==3'd6) ? lift_we : 1'b0;

wire [239:0] mb0_lift_rd_data;
wire [239:0] mb1_lift_rd_data;
wire [239:0] mb2_lift_rd_data;
wire [239:0] mb3_lift_rd_data;
wire [239:0] mb4_lift_rd_data;
wire [239:0] mb5_lift_rd_data;
wire [239:0] mb6_lift_rd_data;

assign lift_rd_data =   (mb_sel==3'd0) ? ( mb0_lift_rd_data ) :
				        (mb_sel==3'd1) ? ( mb1_lift_rd_data ) :
				        (mb_sel==3'd2) ? ( mb2_lift_rd_data ) :
				        (mb_sel==3'd3) ? ( mb3_lift_rd_data ) :
				        (mb_sel==3'd4) ? ( mb4_lift_rd_data ) :
				        (mb_sel==3'd5) ? ( mb5_lift_rd_data ) :
					                     ( mb6_lift_rd_data ) ;


// These signals are used for enabling the target BRAM.

wire mux_core0_mb0_wr_en = ( !cpu_interrupt || (cpu_interrupt && mb_sel==3'd0) || cpu_mem_sel_all ) ? core0_mb0_wr_en : 1'b0;
wire mux_core0_mb1_wr_en = ( !cpu_interrupt || (cpu_interrupt && mb_sel==3'd1) || cpu_mem_sel_all ) ? core0_mb1_wr_en : 1'b0;
wire mux_core0_mb2_wr_en = ( !cpu_interrupt || (cpu_interrupt && mb_sel==3'd2) || cpu_mem_sel_all ) ? core0_mb2_wr_en : 1'b0;
wire mux_core0_mb3_wr_en = ( !cpu_interrupt || (cpu_interrupt && mb_sel==3'd3) || cpu_mem_sel_all ) ? core0_mb3_wr_en : 1'b0;
wire mux_core0_mb4_wr_en = ( !cpu_interrupt || (cpu_interrupt && mb_sel==3'd4) || cpu_mem_sel_all ) ? core0_mb4_wr_en : 1'b0;
wire mux_core0_mb5_wr_en = ( !cpu_interrupt || (cpu_interrupt && mb_sel==3'd5) || cpu_mem_sel_all ) ? core0_mb5_wr_en : 1'b0;
wire mux_core0_mb6_wr_en = ( !cpu_interrupt || (cpu_interrupt && mb_sel==3'd6)                    ) ? core0_mb6_wr_en : 1'b0;


// These signals are for selecting the input for brams from emulation or cpu source

wire [59:0] mux_core0_mb0_din = (cpu_interrupt) ? cpu_din : core0_mb0_din;
wire [59:0] mux_core0_mb1_din = (cpu_interrupt) ? cpu_din : core0_mb1_din;
wire [59:0] mux_core0_mb2_din = (cpu_interrupt) ? cpu_din : core0_mb2_din;
wire [59:0] mux_core0_mb3_din = (cpu_interrupt) ? cpu_din : core0_mb3_din;
wire [59:0] mux_core0_mb4_din = (cpu_interrupt) ? cpu_din : core0_mb4_din;
wire [59:0] mux_core0_mb5_din = (cpu_interrupt) ? cpu_din : core0_mb5_din;
wire [59:0] mux_core0_mb6_din = (cpu_interrupt) ? cpu_din : core0_mb6_din;


// These signals are to get the output of bram to cpu

assign cpu_dout = (mb_sel==3'd0) ? core0_mb0_dout :
                  (mb_sel==3'd1) ? core0_mb1_dout :
                  (mb_sel==3'd2) ? core0_mb2_dout :
                  (mb_sel==3'd3) ? core0_mb3_dout :
                  (mb_sel==3'd4) ? core0_mb4_dout :
                  (mb_sel==3'd5) ? core0_mb5_dout :
                                   core0_mb6_dout ;


// Instantiate the memory blocks

MemoryBlock MB0(
    clk,
    cpu_interrupt, mem_sel, mem_rd_sel, mem_wr_sel,
    core0_mb0_wr_addr, core0_mb0_rd_addr, mux_core0_mb0_wr_en, mux_core0_mb0_din, core0_mb0_dout,
    core1_mb0_wr_addr, core1_mb0_rd_addr,     core1_mb0_wr_en,     core1_mb0_din, core1_mb0_dout,

    lift_interrupt,
    lift_address,
mb0_lift_we,
    lift_wr_data,
mb0_lift_rd_data);

MemoryBlock MB1(
    clk,
    cpu_interrupt, mem_sel, mem_rd_sel, mem_wr_sel,
    core0_mb1_wr_addr, core0_mb1_rd_addr, mux_core0_mb1_wr_en, mux_core0_mb1_din, core0_mb1_dout,
    core1_mb1_wr_addr, core1_mb1_rd_addr,     core1_mb1_wr_en,     core1_mb1_din, core1_mb1_dout,

    lift_interrupt,
    lift_address,
mb1_lift_we,
    lift_wr_data,
mb1_lift_rd_data);

MemoryBlock MB2(
    clk,
    cpu_interrupt, mem_sel, mem_rd_sel, mem_wr_sel,
    core0_mb2_wr_addr, core0_mb2_rd_addr, mux_core0_mb2_wr_en, mux_core0_mb2_din, core0_mb2_dout,
    core1_mb2_wr_addr, core1_mb2_rd_addr,     core1_mb2_wr_en,     core1_mb2_din, core1_mb2_dout,

    lift_interrupt,
    lift_address,
mb2_lift_we,
    lift_wr_data,
mb2_lift_rd_data);

MemoryBlock MB3(
    clk,
    cpu_interrupt, mem_sel, mem_rd_sel, mem_wr_sel,
    core0_mb3_wr_addr, core0_mb3_rd_addr, mux_core0_mb3_wr_en, mux_core0_mb3_din, core0_mb3_dout,
    core1_mb3_wr_addr, core1_mb3_rd_addr,     core1_mb3_wr_en,     core1_mb3_din, core1_mb3_dout,

    lift_interrupt,
    lift_address,
mb3_lift_we,
    lift_wr_data,
mb3_lift_rd_data);

MemoryBlock MB4(
    clk,
    cpu_interrupt, mem_sel, mem_rd_sel, mem_wr_sel,
    core0_mb4_wr_addr, core0_mb4_rd_addr, mux_core0_mb4_wr_en, mux_core0_mb4_din, core0_mb4_dout,
    core1_mb4_wr_addr, core1_mb4_rd_addr,     core1_mb4_wr_en,     core1_mb4_din, core1_mb4_dout,

    lift_interrupt,
    lift_address,
mb4_lift_we,
    lift_wr_data,
mb4_lift_rd_data);

MemoryBlock MB5(
    clk,
    cpu_interrupt, mem_sel, mem_rd_sel, mem_wr_sel,
    core0_mb5_wr_addr, core0_mb5_rd_addr, mux_core0_mb5_wr_en, mux_core0_mb5_din, core0_mb5_dout,
    core1_mb5_wr_addr, core1_mb5_rd_addr,     core1_mb5_wr_en,     core1_mb5_din, core1_mb5_dout,

    lift_interrupt,
    lift_address,
mb5_lift_we,
    lift_wr_data,
mb5_lift_rd_data);

MemoryBlock MB6(
    clk,
    cpu_interrupt, mem_sel, mem_rd_sel, mem_wr_sel,
    core0_mb6_wr_addr, core0_mb6_rd_addr, mux_core0_mb6_wr_en, mux_core0_mb6_din, core0_mb6_dout,
    core1_mb6_wr_addr, core1_mb6_rd_addr,     core1_mb6_wr_en,     core1_mb6_din, core1_mb6_dout,

    lift_interrupt,
    lift_address,
mb6_lift_we,
    lift_wr_data,
mb6_lift_rd_data);

endmodule
`timescale 1ns / 1ps

module MemoryGroup(
    input  wire          clk,

    input  wire [  3:0]  mem_rd_sel,	        // Memory selection of RLWE
    input  wire [  3:0]  mem_wr_sel,

    input  wire          cpu_interrupt,	        // This is used by the top module to override memory selection
    input  wire [  6:0]  cpu_mb_strobe,         // One-hot signal to select target memory block
    input  wire          cpu_mb_all,            // This signal is raised (simultaneously with cpu_interrupt) to enable writing same data in all 6 processors.
    input  wire [  3:0]  cpu_mem_sel,           // To select a memory within a block to read/write.    
    input  wire [ 16:0]  cpu_mem_addr,
    input  wire [511:0]  cpu_mem_wr_data,
    input  wire [ 63:0]  cpu_mem_wr_en,
    output wire [511:0]  cpu_mem_rd_data,

    input  wire [ 10:0]  core0_mb0_wr_addr, core0_mb1_wr_addr, core0_mb2_wr_addr, core0_mb3_wr_addr, core0_mb4_wr_addr, core0_mb5_wr_addr, core0_mb6_wr_addr,
    input  wire [ 10:0]  core0_mb0_rd_addr, core0_mb1_rd_addr, core0_mb2_rd_addr, core0_mb3_rd_addr, core0_mb4_rd_addr, core0_mb5_rd_addr, core0_mb6_rd_addr,
    input  wire          core0_mb0_wr_en,   core0_mb1_wr_en,   core0_mb2_wr_en,   core0_mb3_wr_en,   core0_mb4_wr_en,   core0_mb5_wr_en,   core0_mb6_wr_en,
    input  wire [ 59:0]  core0_mb0_din,     core0_mb1_din,     core0_mb2_din,     core0_mb3_din,     core0_mb4_din,     core0_mb5_din,     core0_mb6_din,
    output wire [ 59:0]  core0_mb0_dout,    core0_mb1_dout,    core0_mb2_dout,    core0_mb3_dout,    core0_mb4_dout,    core0_mb5_dout,    core0_mb6_dout,

    input  wire [ 10:0]  core1_mb0_wr_addr, core1_mb1_wr_addr, core1_mb2_wr_addr, core1_mb3_wr_addr, core1_mb4_wr_addr, core1_mb5_wr_addr, core1_mb6_wr_addr,
    input  wire [ 10:0]  core1_mb0_rd_addr, core1_mb1_rd_addr, core1_mb2_rd_addr, core1_mb3_rd_addr, core1_mb4_rd_addr, core1_mb5_rd_addr, core1_mb6_rd_addr,
    input  wire          core1_mb0_wr_en,   core1_mb1_wr_en,   core1_mb2_wr_en,   core1_mb3_wr_en,   core1_mb4_wr_en,   core1_mb5_wr_en,   core1_mb6_wr_en,
    input  wire [ 59:0]  core1_mb0_din,     core1_mb1_din,     core1_mb2_din,     core1_mb3_din,     core1_mb4_din,     core1_mb5_din,     core1_mb6_din,
    output wire [ 59:0]  core1_mb0_dout,    core1_mb1_dout,    core1_mb2_dout,    core1_mb3_dout,    core1_mb4_dout,    core1_mb5_dout,    core1_mb6_dout,

    input  wire          lift_interrupt,
    input  wire [  2:0]  lift_mb_sel, 	    // To select one of the 7 memory blocks
    input  wire [  3:0]  lift_mem_sel,
    input  wire [  8:0]  lift_address,
    input  wire          lift_we,
    input  wire [239:0]  lift_wr_data,
    output wire [239:0]  lift_rd_data
);

// Lift related signals

wire mb0_lift_we  = (lift_interrupt==1'b1 && lift_mb_sel==3'd0) ? lift_we : 1'b0;
wire mb1_lift_we  = (lift_interrupt==1'b1 && lift_mb_sel==3'd1) ? lift_we : 1'b0;
wire mb2_lift_we  = (lift_interrupt==1'b1 && lift_mb_sel==3'd2) ? lift_we : 1'b0;
wire mb3_lift_we  = (lift_interrupt==1'b1 && lift_mb_sel==3'd3) ? lift_we : 1'b0;
wire mb4_lift_we  = (lift_interrupt==1'b1 && lift_mb_sel==3'd4) ? lift_we : 1'b0;
wire mb5_lift_we  = (lift_interrupt==1'b1 && lift_mb_sel==3'd5) ? lift_we : 1'b0;
wire mb6_lift_we  = (lift_interrupt==1'b1 && lift_mb_sel==3'd6) ? lift_we : 1'b0;

wire [239:0] mb0_lift_rd_data;
wire [239:0] mb1_lift_rd_data;
wire [239:0] mb2_lift_rd_data;
wire [239:0] mb3_lift_rd_data;
wire [239:0] mb4_lift_rd_data;
wire [239:0] mb5_lift_rd_data;
wire [239:0] mb6_lift_rd_data;

assign lift_rd_data =   (lift_mb_sel==3'd0) ? ( mb0_lift_rd_data ) :
				        (lift_mb_sel==3'd1) ? ( mb1_lift_rd_data ) :
				        (lift_mb_sel==3'd2) ? ( mb2_lift_rd_data ) :
				        (lift_mb_sel==3'd3) ? ( mb3_lift_rd_data ) :
				        (lift_mb_sel==3'd4) ? ( mb4_lift_rd_data ) :
				        (lift_mb_sel==3'd5) ? ( mb5_lift_rd_data ) :
					                          ( mb6_lift_rd_data ) ;


// These signals are for selecting the input for brams from rlwe or cpu sources

wire [59:0] mux_core0_mb0_din     = (cpu_interrupt) ? ( cpu_mb_all ? cpu_mem_wr_data[59:0] : cpu_mem_wr_data[59+  0:  0] ) : core0_mb0_din;
wire [59:0] mux_core0_mb1_din     = (cpu_interrupt) ? ( cpu_mb_all ? cpu_mem_wr_data[59:0] : cpu_mem_wr_data[59+ 64: 64] ) : core0_mb1_din;
wire [59:0] mux_core0_mb2_din     = (cpu_interrupt) ? ( cpu_mb_all ? cpu_mem_wr_data[59:0] : cpu_mem_wr_data[59+128:128] ) : core0_mb2_din;
wire [59:0] mux_core0_mb3_din     = (cpu_interrupt) ? ( cpu_mb_all ? cpu_mem_wr_data[59:0] : cpu_mem_wr_data[59+192:192] ) : core0_mb3_din;
wire [59:0] mux_core0_mb4_din     = (cpu_interrupt) ? ( cpu_mb_all ? cpu_mem_wr_data[59:0] : cpu_mem_wr_data[59+256:256] ) : core0_mb4_din;
wire [59:0] mux_core0_mb5_din     = (cpu_interrupt) ? ( cpu_mb_all ? cpu_mem_wr_data[59:0] : cpu_mem_wr_data[59+320:320] ) : core0_mb5_din;
wire [59:0] mux_core0_mb6_din     = (cpu_interrupt) ? ( cpu_mb_all ? cpu_mem_wr_data[59:0] : cpu_mem_wr_data[59+384:384] ) : core0_mb6_din;

wire [ 7:0] mux_core0_mb0_wr_en   = (cpu_interrupt && (cpu_mb_strobe[0] || cpu_mb_all)) ? cpu_mem_wr_en[ 7: 0] : {8{core0_mb0_wr_en}};
wire [ 7:0] mux_core0_mb1_wr_en   = (cpu_interrupt && (cpu_mb_strobe[1] || cpu_mb_all)) ? cpu_mem_wr_en[15: 8] : {8{core0_mb1_wr_en}};
wire [ 7:0] mux_core0_mb2_wr_en   = (cpu_interrupt && (cpu_mb_strobe[2] || cpu_mb_all)) ? cpu_mem_wr_en[23:16] : {8{core0_mb2_wr_en}};
wire [ 7:0] mux_core0_mb3_wr_en   = (cpu_interrupt && (cpu_mb_strobe[3] || cpu_mb_all)) ? cpu_mem_wr_en[31:24] : {8{core0_mb3_wr_en}};
wire [ 7:0] mux_core0_mb4_wr_en   = (cpu_interrupt && (cpu_mb_strobe[4] || cpu_mb_all)) ? cpu_mem_wr_en[39:32] : {8{core0_mb4_wr_en}};
wire [ 7:0] mux_core0_mb5_wr_en   = (cpu_interrupt && (cpu_mb_strobe[5] || cpu_mb_all)) ? cpu_mem_wr_en[47:40] : {8{core0_mb5_wr_en}};
wire [ 7:0] mux_core0_mb6_wr_en   = (cpu_interrupt && (cpu_mb_strobe[6]              )) ? cpu_mem_wr_en[55:48] : {8{core0_mb6_wr_en}};

wire [10:0] mux_core0_mb0_wr_addr = (cpu_interrupt) ? {cpu_mem_addr[16:6]} : {core0_mb0_wr_addr};
wire [10:0] mux_core0_mb1_wr_addr = (cpu_interrupt) ? {cpu_mem_addr[16:6]} : {core0_mb1_wr_addr};
wire [10:0] mux_core0_mb2_wr_addr = (cpu_interrupt) ? {cpu_mem_addr[16:6]} : {core0_mb2_wr_addr};
wire [10:0] mux_core0_mb3_wr_addr = (cpu_interrupt) ? {cpu_mem_addr[16:6]} : {core0_mb3_wr_addr};
wire [10:0] mux_core0_mb4_wr_addr = (cpu_interrupt) ? {cpu_mem_addr[16:6]} : {core0_mb4_wr_addr};
wire [10:0] mux_core0_mb5_wr_addr = (cpu_interrupt) ? {cpu_mem_addr[16:6]} : {core0_mb5_wr_addr};
wire [10:0] mux_core0_mb6_wr_addr = (cpu_interrupt) ? {cpu_mem_addr[16:6]} : {core0_mb6_wr_addr};

wire [10:0] mux_core0_mb0_rd_addr = (cpu_interrupt) ? {cpu_mem_addr[16:6]} : {core0_mb0_rd_addr};
wire [10:0] mux_core0_mb1_rd_addr = (cpu_interrupt) ? {cpu_mem_addr[16:6]} : {core0_mb1_rd_addr};
wire [10:0] mux_core0_mb2_rd_addr = (cpu_interrupt) ? {cpu_mem_addr[16:6]} : {core0_mb2_rd_addr};
wire [10:0] mux_core0_mb3_rd_addr = (cpu_interrupt) ? {cpu_mem_addr[16:6]} : {core0_mb3_rd_addr};
wire [10:0] mux_core0_mb4_rd_addr = (cpu_interrupt) ? {cpu_mem_addr[16:6]} : {core0_mb4_rd_addr};
wire [10:0] mux_core0_mb5_rd_addr = (cpu_interrupt) ? {cpu_mem_addr[16:6]} : {core0_mb5_rd_addr};
wire [10:0] mux_core0_mb6_rd_addr = (cpu_interrupt) ? {cpu_mem_addr[16:6]} : {core0_mb6_rd_addr};

// These signals are to get the output of bram to cpu

assign cpu_mem_rd_data = { 
    64'h0,
     4'h0, core0_mb6_dout,
     4'h0, core0_mb5_dout,
     4'h0, core0_mb4_dout,
     4'h0, core0_mb3_dout,
     4'h0, core0_mb2_dout,
     4'h0, core0_mb1_dout,
     4'h0, core0_mb0_dout };
     

// Instantiate the memory blocks

MemoryBlock MB0(
    clk,
    cpu_interrupt, cpu_mem_sel, mem_rd_sel, mem_wr_sel,
    mux_core0_mb0_wr_addr, mux_core0_mb0_rd_addr, mux_core0_mb0_wr_en  , mux_core0_mb0_din, core0_mb0_dout,
        core1_mb0_wr_addr,     core1_mb0_rd_addr,  {8{core1_mb0_wr_en}},     core1_mb0_din, core1_mb0_dout,

    lift_interrupt,
    lift_address,
    lift_mem_sel,
mb0_lift_we,
    lift_wr_data,
mb0_lift_rd_data);

MemoryBlock MB1(
    clk,
    cpu_interrupt, cpu_mem_sel, mem_rd_sel, mem_wr_sel,
    mux_core0_mb1_wr_addr, mux_core0_mb1_rd_addr, mux_core0_mb1_wr_en  , mux_core0_mb1_din, core0_mb1_dout,
        core1_mb1_wr_addr,     core1_mb1_rd_addr,  {8{core1_mb1_wr_en}},     core1_mb1_din, core1_mb1_dout,

    lift_interrupt,
    lift_address,
    lift_mem_sel,
mb1_lift_we,
    lift_wr_data,
mb1_lift_rd_data);

MemoryBlock MB2(
    clk,
    cpu_interrupt, cpu_mem_sel, mem_rd_sel, mem_wr_sel,
    mux_core0_mb2_wr_addr, mux_core0_mb2_rd_addr, mux_core0_mb2_wr_en  , mux_core0_mb2_din, core0_mb2_dout,
        core1_mb2_wr_addr,     core1_mb2_rd_addr,  {8{core1_mb2_wr_en}},     core1_mb2_din, core1_mb2_dout,

    lift_interrupt,
    lift_address,
    lift_mem_sel,
mb2_lift_we,
    lift_wr_data,
mb2_lift_rd_data);

MemoryBlock MB3(
    clk,
    cpu_interrupt, cpu_mem_sel, mem_rd_sel, mem_wr_sel,
    mux_core0_mb3_wr_addr, mux_core0_mb3_rd_addr, mux_core0_mb3_wr_en  , mux_core0_mb3_din, core0_mb3_dout,
        core1_mb3_wr_addr,     core1_mb3_rd_addr,  {8{core1_mb3_wr_en}},     core1_mb3_din, core1_mb3_dout,

    lift_interrupt,
    lift_address,
    lift_mem_sel,
mb3_lift_we,
    lift_wr_data,
mb3_lift_rd_data);

MemoryBlock MB4(
    clk,
    cpu_interrupt, cpu_mem_sel, mem_rd_sel, mem_wr_sel,
    mux_core0_mb4_wr_addr, mux_core0_mb4_rd_addr, mux_core0_mb4_wr_en  , mux_core0_mb4_din, core0_mb4_dout,
        core1_mb4_wr_addr,     core1_mb4_rd_addr,  {8{core1_mb4_wr_en}},     core1_mb4_din, core1_mb4_dout,

    lift_interrupt,
    lift_address,
    lift_mem_sel,
mb4_lift_we,
    lift_wr_data,
mb4_lift_rd_data);

MemoryBlock MB5(
    clk,
    cpu_interrupt, cpu_mem_sel, mem_rd_sel, mem_wr_sel,
    mux_core0_mb5_wr_addr, mux_core0_mb5_rd_addr, mux_core0_mb5_wr_en  , mux_core0_mb5_din, core0_mb5_dout,
        core1_mb5_wr_addr,     core1_mb5_rd_addr,  {8{core1_mb5_wr_en}},     core1_mb5_din, core1_mb5_dout,

    lift_interrupt,
    lift_address,
    lift_mem_sel,
mb5_lift_we,
    lift_wr_data,
mb5_lift_rd_data);

MemoryBlock MB6(
    clk,
    cpu_interrupt, cpu_mem_sel, mem_rd_sel, mem_wr_sel,
    mux_core0_mb6_wr_addr, mux_core0_mb6_rd_addr, mux_core0_mb6_wr_en  , mux_core0_mb6_din, core0_mb6_dout,
        core1_mb6_wr_addr,     core1_mb6_rd_addr,  {8{core1_mb6_wr_en}},     core1_mb6_din, core1_mb6_dout,

    lift_interrupt,
    lift_address,
    lift_mem_sel,
mb6_lift_we,
    lift_wr_data,
mb6_lift_rd_data);

endmodule
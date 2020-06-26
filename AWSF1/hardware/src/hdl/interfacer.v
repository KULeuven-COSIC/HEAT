`timescale 1ns / 1ps

module interfacer (

    // IO ports connecting to the AWS Shell

    input  wire [ 16:0]  bram_addr_a      ,
    input  wire          bram_clk_a       ,
    input  wire [511:0]  bram_wrdata_a    ,
    output wire [511:0]  bram_rddata_a    ,
    input  wire          bram_en_a        ,
    input  wire          bram_rst_a       ,
    input  wire [ 63:0]  bram_we_a        ,
                                            // |31     24|23     16|15      8|7       0|
    input  wire [ 31:0]  io32_0_in        , // |wtM1 wtM0|rdM1 rdM0|      mod|     inst|
    output wire [ 31:0]  io32_0_out       , // |                                   done|
    input  wire [ 31:0]  io32_1_in        , // |  mem_sel|  mb_strb|    wr_en|      int|
    output wire [ 31:0]  io32_1_out       , // |                               error_en|

    // IO ports connecting to the hom_enc_coprocessor

    output wire          cpu_interrupt    ,
    output wire [  6:0]  cpu_mb_strobe    ,
    output wire          cpu_mb_all       ,
    output wire [  3:0]  cpu_mem_sel      ,
    output wire [ 16:0]  cpu_mem_addr     ,
    output wire [511:0]  cpu_mem_wr_data  ,
    output wire [ 63:0]  cpu_mem_wr_en    ,
    input  wire [511:0]  cpu_mem_rd_data  ,

    output wire [  7:0]  instruction      ,
    output wire          modulus_sel      ,
    output wire [  3:0]  rdM0             ,
    output wire [  3:0]  rdM1             ,
    output wire [  3:0]  wtM0             ,
    output wire [  3:0]  wtM1             ,
    input  wire          done
);

// Check if all writes are 512-bit words
reg error_en;
always @(posedge bram_clk_a) begin
  if (io32_1_in == 32'h00000000)
    error_en <= 1'b0;
  
  else if ( bram_we_a != 64'h00000000_00000000 && 
            bram_we_a != 64'hffffffff_ffffffff && 
            bram_en_a)
    error_en <= 1'b1;
end

// Check if the data is 512-bit aligned
reg error_addr;
always @(posedge bram_clk_a) begin
  if (io32_1_in == 32'h00000000)
    error_addr <= 1'b0;
  
  else if ( bram_addr_a[5:0] != 6'b000000 &
            bram_en_a)
    error_addr <= 1'b1;
end


////////////////////////////////
//
// Signals for instructions
//

wire [ 31:0] inst;        
reg  [ 31:0] inst_r;
reg          done_r;
reg          state;

always @(posedge bram_clk_a) begin
  
  inst_r  <= io32_0_in;
  done_r  <= done;

  if (bram_rst_a) begin
    state <= 1'b0;
  end
  else begin
    if (!state && inst_r != io32_0_in) begin
      state <= 1'b1;
    end
    else if (state && done_r && !done) begin
      state <= 1'b0;
    end
  end
end

assign inst = (done_r || !state) ? 32'b0 : inst_r;

assign instruction     = inst[7:0];
assign modulus_sel     = inst[8];
assign rdM0            = inst[19:16];
assign rdM1            = inst[23:20];
assign wtM0            = inst[27:24];
assign wtM1            = inst[31:28];

assign io32_0_out      = {31'b0, ((done_r || !state) && (inst_r == io32_0_in))};

////////////////////////////////
//
// Signals for memory accesss
//
assign cpu_mem_wr_data  = bram_wrdata_a;
assign cpu_interrupt    = io32_1_in[0];
assign cpu_mb_strobe    = io32_1_in[22:16];
assign cpu_mb_all       = io32_1_in[23];
assign cpu_mem_sel      = io32_1_in[27:24];
assign cpu_mem_addr     = bram_addr_a;
assign cpu_mem_wr_en    = (io32_1_in[8] && bram_en_a) ? bram_we_a : 64'h0;

assign bram_rddata_a    = cpu_mem_rd_data;

assign io32_1_out       = {1'b1, 28'b0, cpu_interrupt, error_addr, error_en};


endmodule
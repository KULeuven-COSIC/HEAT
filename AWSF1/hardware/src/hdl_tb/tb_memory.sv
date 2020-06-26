`timescale 1ns / 1ps

`define INIT_TIME 100
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_memory();

  // Define internal regs and wires
  reg           clk;

  reg           cpu_interrupt;     // This signal is used by ARM to choose a particular processor for reading or writing
  reg  [  6:0]  cpu_mb_strobe;     // One-hot signal to select target memory block
  reg           cpu_mb_all;        // This signal is raised (simultaneously with cpu_interrupt) to enable writing same data in all 6 processors.
  reg  [  3:0]  cpu_mem_sel;       // It is fixed to 4
  reg  [ 10:0]  cpu_mem_addr;
  reg  [511:0]  cpu_mem_wr_data;
  reg           cpu_mem_wr_en;
  wire [511:0]  cpu_mem_rd_data;

  reg  [7:0]    instruction;
  reg           modulus_sel;
  reg  [3:0]    rdM0;
  reg  [3:0]    rdM1;
  reg  [3:0]    wtM0;
  reg  [3:0]    wtM1;
  wire          done;             // output

  // Instantiating adder
  homenc_coprocessor dut (
    clk               ,
    cpu_interrupt     ,
    cpu_mb_strobe     ,
    cpu_mb_all        ,
    cpu_mem_sel       ,
    cpu_mem_addr      ,
    cpu_mem_wr_data   ,
    cpu_mem_wr_en     ,
    cpu_mem_rd_data   ,
    instruction       ,
    modulus_sel       ,
    rdM0              ,
    rdM1              ,
    wtM0              ,
    wtM1              ,
    done
  );

  // Generate Clock
  initial begin
      clk = 0;
      forever #`CLK_HALF clk = ~clk;
  end

  // Initialize signals to zero
  initial begin
    cpu_interrupt     <=   1'b0;
    cpu_mb_strobe     <=   7'b0;
    cpu_mb_all        <=   1'b0;
    cpu_mem_sel       <=   4'd4; // fixed to 4
    cpu_mem_addr      <=  11'b0;
    cpu_mem_wr_data   <= 512'h0;
    cpu_mem_wr_en     <=   1'b0;

    modulus_sel       <=  1'b0;
    instruction       <=  8'b0;
    rdM0              <=  4'b0;
    rdM1              <=  4'b0;
    wtM0              <=  4'b0;
    wtM1              <=  4'b0;
  end

  initial begin

    #`INIT_TIME;

    cpu_interrupt   <= 1'b1;

    #`CLK_PERIOD;

    cpu_mb_strobe   <= 7'b1010101;
    cpu_mem_wr_en   <= 1'b1;

    for (int i=0; i<2048; i=i+1) begin
      cpu_mem_addr                = i;
      
      // cpu_mem_wr_data             = i;
      cpu_mem_wr_data[59+  0:  0] = i;
      cpu_mem_wr_data[59+ 64: 64] = i;
      cpu_mem_wr_data[59+128:128] = i;
      cpu_mem_wr_data[59+192:192] = i;
      cpu_mem_wr_data[59+256:256] = i;
      cpu_mem_wr_data[59+320:320] = i;
      cpu_mem_wr_data[59+384:384] = i;

      #`CLK_PERIOD;
    end

    cpu_interrupt   <= 1'b0;
    cpu_mem_wr_en   <= 1'b0;

    $finish;

  end

endmodule
`timescale 1ns / 1ps

`define INIT_TIME 100
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_memory();

  // Define internal regs and wires
  reg           clk;
  reg           cpu_interrupt;    
  reg           cpu_interrupt_all;
  reg  [2:0]    cpu_mb_sel;
  reg  [3:0]    cpu_mem_sel;      
  reg  [10:0]   cpu_mem_addr;
  reg  [59:0]   cpu_mem_wr_data;
  reg           cpu_mem_wr_en;
  wire [59:0]   cpu_mem_rd_data;  // output  
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
    cpu_interrupt_all ,
    cpu_mb_sel        ,
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
    modulus_sel       <=  1'b0;
    instruction       <=  8'b0;
    cpu_interrupt     <=  1'b0;
    cpu_interrupt_all <=  1'b0;
    cpu_mb_sel        <=  3'b0;
    cpu_mem_sel       <=  4'd4; // fixed to 4
    cpu_mem_addr      <= 11'b0;
    cpu_mem_wr_data   <= 60'b0;
    cpu_mem_wr_en     <=  1'b0;
    rdM0              <=  4'b0;
    rdM1              <=  4'b0;
    wtM0              <=  4'b0;
    wtM1              <=  4'b0;
  end

  initial begin

    #`INIT_TIME;

    cpu_interrupt   <= 1'b1;
    cpu_mb_sel      <= 3'd0;

    #`CLK_PERIOD;
    
    cpu_mem_wr_en   <= 1'b1;

    for (int i=0; i<2048; i=i+1) begin
      cpu_mem_addr    = i;
      cpu_mem_wr_data = i;
      #`CLK_PERIOD;
    end

    cpu_interrupt   <= 1'b0;
    cpu_mem_wr_en   <= 1'b0;

    $finish;

  end

endmodule
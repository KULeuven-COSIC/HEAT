`timescale 1ns / 1ps

`define INIT_TIME 100
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_interface();

  // Define internal regs and wires
  reg           clk             ;

  reg  [ 16:0]  bram_addr_a     ;
  reg           bram_clk_a      ;
  wire [511:0]  bram_wrdata_a   ;
  wire [511:0]  bram_rddata_a   ;
  reg           bram_en_a       ;
  reg           bram_rst_a      ;
  reg  [ 63:0]  bram_we_a       ;

  reg  [ 31:0]  io32_0_in       ; 
  wire [ 31:0]  io32_1_out      ; 
  reg  [ 31:0]  io32_2_in       ; 
  wire [ 31:0]  io32_3_out      ; 

  wire          cpu_interrupt   ;
  wire [  6:0]  cpu_mb_strobe   ;
  wire          cpu_mb_all      ;
  wire [  3:0]  cpu_mem_sel     ;
  wire [ 16:0]  cpu_mem_addr    ;
  wire [511:0]  cpu_mem_wr_data ;
  wire [ 63:0]  cpu_mem_wr_en   ;
  wire [511:0]  cpu_mem_rd_data ;
  wire [  7:0]  instruction     ;
  wire          modulus_sel     ;
  wire [  3:0]  rdM0            ;
  wire [  3:0]  rdM1            ;
  wire [  3:0]  wtM0            ;
  wire [  3:0]  wtM1            ;
  wire          done            ;

  interfacer dut_interfacer (
    bram_addr_a      ,     
    clk              ,     
    bram_wrdata_a    ,       
    bram_rddata_a    ,       
    bram_en_a        ,   
    bram_rst_a       ,     
    bram_we_a        ,
    io32_0_in        ,   
    io32_1_out       ,     
    io32_2_in        ,   
    io32_3_out       ,

    cpu_interrupt    ,
    cpu_mb_strobe    ,
    cpu_mb_all       ,
    cpu_mem_sel      ,
    cpu_mem_addr     ,
    cpu_mem_wr_data  ,
    cpu_mem_wr_en    ,
    cpu_mem_rd_data  ,    
    instruction      ,
    modulus_sel      ,
    rdM0             ,
    rdM1             ,
    wtM0             ,
    wtM1             ,
    done
  );

  // Instantiating adder
  homenc_coprocessor dut_homenc (
    clk              ,

    cpu_interrupt    ,
    cpu_mb_strobe    ,
    cpu_mb_all       ,
    cpu_mem_sel      ,
    cpu_mem_addr     ,
    cpu_mem_wr_data  ,
    cpu_mem_wr_en    ,
    cpu_mem_rd_data  ,
    instruction      ,
    modulus_sel      ,
    rdM0             ,
    rdM1             ,
    wtM0             ,
    wtM1             ,
    done
  );

  // Generate Clock
  initial begin
    clk = 0;
    forever #`CLK_HALF clk = ~clk;
  end

  // assign bram_clk_a = clk;

  // Initialize signals to zero
  initial begin
    bram_addr_a    <=  17'b0;
    // bram_wrdata_a  <= 512'b0;
    bram_en_a      <=   1'b0;
    bram_rst_a     <=   1'b1;
    bram_we_a      <=  64'b0;
    io32_0_in      <=  32'b0;
    io32_2_in      <=  32'b0;
  end

  integer i,j;

  wire [31:0] row    = i;
  wire [31:0] column = j;

  assign bram_wrdata_a  = {448'h0, row, column} << (j*64);

  initial begin

    #`INIT_TIME;

    bram_rst_a     <= 1'b0;

    #`CLK_PERIOD;
    io32_0_in     <= 32'h00000014;
    #`CLK_PERIOD;
    wait(io32_1_out == 32'd1);
    #`INIT_TIME;
    io32_0_in     <= 32'h10000014;
    #`CLK_PERIOD;
    wait(io32_1_out == 32'd1);
    #`CLK_PERIOD;
    io32_0_in     <= 32'h20000014;
    #`CLK_PERIOD;
    $finish;

    // #`INIT_TIME;

    // io32_0_in     <= 32'h00000000;
    // io32_2_in     <= 32'h047F0101;

    // #`CLK_PERIOD;

    // for (i=508; i<2048; i=i+1) begin
      
    //   for (j=0; j<7; j=j+1) begin
    //     bram_addr_a    <= i*64;
    //     bram_en_a      <=  1'b1;
    //     bram_we_a      <= 64'h00000000_0000000f << (j*8);        
    //     #`CLK_PERIOD;        
    //   end

    //   #`CLK_PERIOD;
    // end

    // bram_en_a     <=  1'b0;
    // bram_we_a     <= 64'h00000000_00000000;
    // io32_2_in     <= 32'h00000000;

    // $finish;

  end

endmodule
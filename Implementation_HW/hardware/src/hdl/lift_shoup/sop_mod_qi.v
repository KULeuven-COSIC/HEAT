`timescale 1ns / 1ps

module sop_mod_qi(
    input  wire         clock,
    input  wire         reset,

    // Mode of operation, should be sampled at data_valid
    input  wire         mode,

    input  wire         data_in_valid,
    input  wire [ 2:0]  data_in_address,
    input  wire [29:0]  data_in,
    
    output wire         data_out_valid,
    output wire [29:0]  data_out

    );

    ////////////////////////////////////////////////////////////////////////////
    //
    // INPUT RAM

    // Write port is the inputs of this module to fill this RAM with input data.
    // After the first data (word) is written, this module starts reading it 
    // from the RAM and processes it
    wire [  2:0] read_address;    
    wire [ 29:0] read_data;
    /*
    lift_in_data_ram data_ram (
        .clka   (clock             ), // input wire clka
        .wea    (data_in_valid     ), // input wire [0 : 0] wea
        .addra  (data_in_address   ), // input wire [2 : 0] addra
        .dina   (data_in           ), // input wire [29 : 0] dina

        .clkb   (clock          ), // input wire clkb
        .addrb  (read_address   ), // input wire [2 : 0] addrb
        .doutb  (read_data      )  // output wire [29 : 0] doutb
        );  */
    dist_mem_30x64 data_ram(
                        .a({3'd0, data_in_address}), 
                        .d(data_in), 
                        .dpra({3'd0, read_address}), 
                        .clk(clock), 
                        .we(data_in_valid),  
                        .qdpo_clk(clock),  
                        .qdpo(read_data)
                        );
    ////////////////////////////////////////////////////////////////////////////
    //
    // INTERNAL REGISTERS: START PULSE, BLOCK DONE AND CYCLE-COUNTER

    // The input data can be read from the RAM, one cycle after it is written
    reg data_valid;

    always @(posedge clock) begin
        data_valid <= data_in_valid;
    end

    wire block_start;     
    wire busy_busy;
    wire block_done;

    reg  [7:0]  counter;

    assign block_start =    (!data_valid && data_in_valid) || 
                            ( block_done && data_in_valid) ;
    
    assign busy_busy = data_valid;
    
    assign block_done = (counter == 8'd6);

    always @ (posedge clock) begin
        counter     <=  (reset       ) ? 8'd0        :
                        (block_start ) ? 8'd0        :
                        (block_done  ) ? 8'd0        :
                                         counter + 1 ;
    end

    ////////////////////////////////////////////////////////////////////////////
    //
    // SAMPLE MODE FROM THE type_of_data
    /*
    reg mode;

    always @(posedge clock) begin

        mode <= (reset       ) ? 1'b0           :
                (block_start ) ? !type_of_data  :
                                 mode          ;
    end
    */    
    ////////////////////////////////////////////////////////////////////////////
    //
    // READ BUFFER

    // Calculate Read Address

    reg  [4:0] read_addr;
    wire [4:0] read_addr_next;

    assign read_addr_next = read_addr + 1;

    always @ (posedge clock) begin
        if      (reset || block_done)   read_addr <= 5'b0;
        else if (busy_busy          )   read_addr <= read_addr_next;
    end

    assign read_address = read_addr ;


    ////////////////////////////////////////////////////////////////////////////
    //
    // INSTANTIATE THE EQUATION 2 MODULE

    wire   [ 29:0]  e2_din;
    wire   [ 29:0]  e2_dout;
    wire            e2_dout_valid;

    assign e2_din   = read_data;

    equation2 eq2(
        .clock          (clock        ),
        .reset          (reset        ),
        .start          (block_start  ),
        .mode           (mode         ),
        .clock_counter  (counter      ),
        .d_in           (e2_din       ),
        .q              (e2_dout      ),
        .q_valid        (e2_dout_valid)
    );

    assign data_out       = e2_dout;
    assign data_out_valid = e2_dout_valid;
    

endmodule

`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:   14:01:32 08/29/2017
// Design Name:   PROCESSOR_POLY
// Module Name:   /volume1/scratch/ssinharo/Neural_network_n4096/networkingtest/tb_processor.v
// Project Name:  networkingtest
// Target Device:
// Tool versions:
// Description:
//
// Verilog Test Fixture created by ISE for module: PROCESSOR_POLY
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////


module tb_NN_improved_crt_dbg;

    // Inputs
    reg reset_outside;
    reg clock_200;

    reg interrupt_eth;
    reg [10:0] address_eth;
    reg web_eth, wep_eth;
    reg [59:0] dinb_eth;
    reg [7:0] instruction_eth, operand_eth;

    // Outputs
    wire [59:0] doutb_eth;
    wire done_ddr;
    wire done_comp;

    // internal variables
    reg [29:0] i;
    reg [29:0] H, L;
    reg clk;        // 100 MHz clock
    reg [2:0] processor_sel;
    reg [3:0] memory_sel;

    dummy_NN_top uut (
        .reset_outside(reset_outside),
        .clock_200(clock_200),

        .interrupt_eth(interrupt_eth),
        .address_eth(address_eth),
        .web_eth(web_eth),
        .wep_eth(wep_eth),
        .dinb_eth(dinb_eth),
        .doutb_eth(doutb_eth),
        .instruction_eth(instruction_eth),
        .operand_eth(operand_eth),

        .done_ddr(done_ddr),
        .done_comp(done_comp)
    );

    initial begin
        // Initialize Inputs
        reset_outside = 1;
        clock_200 = 0;
        interrupt_eth = 0;
        address_eth = 0;
        dinb_eth = 0;
        web_eth = 0;
        wep_eth = 0;
        instruction_eth = 0;
        operand_eth = 0;
        processor_sel=0;
        memory_sel=0;

        i = 30'd0;
       H = 30'd0;
      L = 30'd0;
        clk = 0;
        // Wait 100 ns for global reset to finish
        #100;

        // Add stimulus here
        reset_outside = 0;

/*
        for(processor_sel=0; processor_sel<6; processor_sel=processor_sel+1)
        begin
            // Load P_processor_M0
            memory_sel=4;
            operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1;
            instruction_eth = 1;
            for(i=0; i<30'd2048; i= i+1)
            begin
                address_eth = i;
                H = {i[28:0]+2048*processor_sel,1'b1};
                L = {i[28:0]+2048*processor_sel,1'b0};
                dinb_eth = {H,L};
                web_eth = 1'b1;
                @(posedge clk);
            end
            web_eth = 1'b0;
            interrupt_eth = 0;
            instruction_eth = 0;
            @(posedge clk);
        end
*/




             memory_sel=4; processor_sel=0; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 0;
            dinb_eth = {30'd87381051, 30'd1007649774};
            web_eth = 1'b1;
            @(posedge clk);
             memory_sel=4; processor_sel=0; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 1;
            dinb_eth = {30'd87381051, 30'd1007649774};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=1; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 0;
            dinb_eth = {30'd258812005, 30'd882798562};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=1; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 1;
            dinb_eth = {30'd258812005, 30'd882798562};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=2; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 0;
            dinb_eth = {30'd292876642, 30'd984429559};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=2; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 1;
            dinb_eth = {30'd292876642, 30'd984429559};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=3; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 0;
            dinb_eth = {30'd913327902, 30'd777893800};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=3; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 1;
            dinb_eth = {30'd913327902, 30'd777893800};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=4; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 0;
            dinb_eth = {30'd203221019, 30'd817372628};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=4; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 1;
            dinb_eth = {30'd203221019, 30'd817372628};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=5; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 0;
            dinb_eth = {30'd46769069, 30'd462585748};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=5; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 1;
            dinb_eth = {30'd46769069, 30'd462585748};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=6; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 0;
            dinb_eth = {30'd807999276, 30'd741806817};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=6; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 1;
            dinb_eth = {30'd807999276, 30'd741806817};
            web_eth = 1'b1;
            @(posedge clk);

            web_eth = 1'b0;

         @(posedge clk);
        address_eth = 0; wep_eth = 1;
        dinb_eth = 0;
       @(posedge clk);

        address_eth = address_eth+1;
        dinb_eth = 0+(0<<8)+(0<<16)+(0<<24)+(0<<27)+(0<<31);
        wep_eth = 1;
        @(posedge clk);

        address_eth = address_eth+1;
        dinb_eth = 20+(4<<8)+(5<<16)+(0<<24)+(0<<27)+(0<<31);
        wep_eth = 1;
        @(posedge clk);

        address_eth = address_eth+1;
        dinb_eth = 0+(0<<8)+(0<<16)+(0<<24)+(0<<27)+(0<<31);
        wep_eth = 1;
        @(posedge clk);

        @(posedge clk);
        interrupt_eth = 0;
         @(posedge clk);
        instruction_eth = 65;

        @(posedge clk);
        wait(done_comp);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);





            memory_sel=4; processor_sel=0; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 0;
            dinb_eth = {30'd1015210041, 30'd259092531};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=0; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 1;
            dinb_eth = {30'd1015210041, 30'd259092531};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=1; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 0;
            dinb_eth = {30'd215326808, 30'd975057076};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=1; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 1;
            dinb_eth = {30'd215326808, 30'd975057076};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=2; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 0;
            dinb_eth = {30'd996761720, 30'd1035334068 };
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=2; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 1;
            dinb_eth = {30'd996761720, 30'd1035334068 };
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=3; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 0;
            dinb_eth = {30'd53551254, 30'd443265843};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=3; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 1;
            dinb_eth = {30'd53551254, 30'd443265843};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=4; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 0;
            dinb_eth = {30'd660201653, 30'd925332786};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=4; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 1;
            dinb_eth = {30'd660201653, 30'd925332786};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=5; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 0;
            dinb_eth = {30'd656974035, 30'd634206127};
            web_eth = 1'b1;
            @(posedge clk);
            memory_sel=4; processor_sel=5; operand_eth = (processor_sel<<5) + memory_sel;
            interrupt_eth = 1; instruction_eth = 1;
            address_eth = 1;
            dinb_eth = {30'd656974035, 30'd634206127};
            web_eth = 1'b1;
            @(posedge clk);

            web_eth = 1'b0;
            interrupt_eth = 0;
            instruction_eth = 0;
            @(posedge clk);

            web_eth = 1'b0;
            interrupt_eth = 0;
            instruction_eth = 0;
            @(posedge clk);


        // LOAD PROGRAM MEMORY
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        address_eth = 0; wep_eth = 1;
        dinb_eth = 0;
       @(posedge clk);



        /*
        address_eth = address_eth+1;
        dinb_eth = 20+(0<<8)+(5<<16)+(0<<24)+(0<<27)+(0<<31);
        wep_eth = 1;
        @(posedge clk);
        */
        address_eth = address_eth+1;
        dinb_eth = 0+(0<<8)+(0<<16)+(0<<24)+(0<<27)+(0<<31);
        wep_eth = 1;
        @(posedge clk);

        address_eth = address_eth+1;
        dinb_eth = 7+(84<<8)+(33<<16)+(0<<24)+(0<<27)+(0<<31);
        //dinb_eth = 5+(4<<8)+(5<<16)+(0<<24)+(0<<27)+(0<<31);
        wep_eth = 1;
        @(posedge clk);

        address_eth = address_eth+1;
        dinb_eth = 0+(0<<8)+(0<<16)+(0<<24)+(0<<27)+(0<<31);
        wep_eth = 1;
        @(posedge clk);
        /*
        address_eth = address_eth+1;
        dinb_eth = 20+(1<<8)+(4<<16)+(0<<24)+(0<<27)+(0<<31);
        wep_eth = 1;
        @(posedge clk);
        */
        address_eth = address_eth+1;
        dinb_eth = 255+(0<<8)+(0<<16)+(0<<24)+(0<<27)+(0<<31);
        wep_eth = 1;
        @(posedge clk);




    /*
        address_eth = address_eth+1;
        dinb_eth = 0+(0<<8)+(0<<16)+(0<<24)+(0<<27)+(0<<31);
        wep_eth = 1;
        @(posedge clk);

        address_eth = address_eth+1;
        dinb_eth = 16+(0<<8)+(0<<16)+(0<<24)+(0<<27)+(0<<31);
        wep_eth = 1;
        @(posedge clk);

        address_eth = address_eth+1;
        dinb_eth = 0+(0<<8)+(0<<16)+(0<<24)+(0<<27)+(0<<31);
        wep_eth = 1;
        @(posedge clk);

        address_eth = address_eth+1;
        dinb_eth = 255+(0<<8)+(0<<16)+(0<<24)+(0<<27)+(0<<31);
        wep_eth = 1;
        @(posedge clk);

        address_eth = address_eth+1;
        dinb_eth = 16+(0<<8)+(0<<16)+(0<<24)+(0<<27)+(0<<31);
        wep_eth = 1;
        @(posedge clk);

        address_eth = address_eth+1;
        dinb_eth = 17+(0<<8)+(0<<16)+(0<<24)+(0<<27)+(0<<31);
        wep_eth = 1;
        @(posedge clk);

        address_eth = address_eth+1;
        dinb_eth = 0+(0<<8)+(0<<16)+(0<<24)+(0<<27)+(0<<31);
        wep_eth = 1;
        @(posedge clk);

        address_eth = address_eth+1;
        dinb_eth = 16+(0<<8)+(0<<16)+(0<<24)+(0<<27)+(0<<31);
        wep_eth = 1;
        @(posedge clk);

        address_eth = address_eth+1;
        dinb_eth = 18+(0<<8)+(0<<16)+(0<<24)+(0<<27)+(0<<31);
        wep_eth = 1;
        @(posedge clk);


        for(i=0; i<2; i= i+1)
        begin
            address_eth = address_eth+1;
            dinb_eth = 4+((i+6)<<8)+(0<<16)+(i<<24)+(0<<27)+(0<<31);
            wep_eth = 1;
            @(posedge clk);
            address_eth = address_eth+1;
            dinb_eth = 0;
            wep_eth = 1;
            @(posedge clk);
        end

        address_eth = address_eth+1;
        dinb_eth = 255;
        wep_eth = 1;
        @(posedge clk);
    */

        @(posedge clk);
        instruction_eth = 65;



    end


    always #2.5 clock_200 = ~clock_200;
   always #5 clk = ~clk;

endmodule

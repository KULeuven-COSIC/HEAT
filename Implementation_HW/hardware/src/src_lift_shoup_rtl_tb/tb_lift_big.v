`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2018 06:08:41 PM
// Design Name: 
// Module Name: tb_lift_big
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_lift_big;

    reg clk;
    reg rst;
    reg start;            // This signal is set 1 after input data is ready.
    reg [29:0] coeff_in_q;
    reg [29:0] coeff_in_p;


    wire [2:0] rd_addr_q; 
    wire [2:0] rd_addr_p; 
    wire [29:0] result_mod_pi;
    wire result_mod_pi_we;
    wire [2:0] result_mod_pi_addr;
    
    reg [29:0] coeff_array_q[6:0];
    reg [29:0] coeff_array_p[6:0];
    
    reg [7:0] i;
    wire one_set_read, one_set_written;
    
    lift_big uut(clk, rst, start, rd_addr_q, coeff_in_q, rd_addr_p, coeff_in_p, result_mod_pi, result_mod_pi_addr, result_mod_pi_we);
    
	initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        start = 0;            // This signal is set 1 after input data is ready.
        coeff_in_q = 0;
        coeff_in_p = 0;
        
        // Wait 100 ns for global reset to finish
        #100;
        
        // Add stimulus here

        /*  a_shares modulo q; */
        coeff_array_q[0] = 30'd619584084;
        coeff_array_q[1] = 30'd758639283;
        coeff_array_q[2] = 30'd1026829706;
        coeff_array_q[3] = 30'd778998210;
        coeff_array_q[4] = 30'd302009656;
        coeff_array_q[5] = 30'd836990255;
        coeff_array_q[6] = 30'd0;
        
        /*  a_shares modulo p; */
        coeff_array_p[0] = 30'd478083334;
        coeff_array_p[1] = 30'd787022829;
        coeff_array_p[2] = 30'd684505315;
        coeff_array_p[3] = 30'd93050313;
        coeff_array_p[4] = 30'd137113526;
        coeff_array_p[5] = 30'd809985067;
        coeff_array_p[6] = 30'd102873779;


        /* Computation Starts */
        @(posedge clk);
        rst = 0;
        
        @(posedge clk);    
        #1 start = 1'b1;
        
        for(i=0; i<8; i=i+1)
        begin
            wait(one_set_written);
            @(posedge clk);
            #1;
        end
        /*        
        for(i=0; i<250; i=i+1)
        begin
            @(posedge clk);
        end
        */
        #1 start = 1'b0;  
        #1 rst = 1'b1;  
	end
	
	
    always #5 clk = ~clk;
    
    always @(posedge clk)
    begin
           coeff_in_q <= coeff_array_q[rd_addr_q];
           coeff_in_p <= coeff_array_p[rd_addr_p];
    end
    
    assign one_set_read = (rd_addr_p==3'd6) ? 1'b1 : 1'b0;
    assign one_set_written = (result_mod_pi_addr==3'd6) ? 1'b1 : 1'b0;
            
endmodule

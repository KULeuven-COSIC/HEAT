`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2018 10:39:05 AM
// Design Name: 
// Module Name: tb_lift_small
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


module tb_lift_small;

    reg clk;
    reg rst;
    reg mode;             // If 0 then small lift (6 input coeff); If 1 then big ligt (7 input coeff);
    reg start;            // This signal is set 1 after input data is ready.
    reg [29:0] coeff_in;  // A coefficient arrives one cycle after address.

    wire [2:0] rd_addr;      // Coefficients are assumed to be in a RAM.
    wire [29:0] final_subtraction_result;
    wire final_subtraction_result_we;
    wire [2:0] final_subtraction_result_addr;
    
    reg [29:0] coeff_array_q[6:0];
    reg [29:0] coeff_array_p[6:0];
        
	// Instantiate the Unit Under Test (UUT)
    lift_small uut(clk, rst, mode, start, rd_addr, coeff_in, 
                   final_subtraction_result, final_subtraction_result_addr, final_subtraction_result_we);
    
	initial begin
		// Initialize Inputs
        clk = 0;
        rst = 1;
        mode = 1;             // If 0 then small lift (6 input coeff); If 1 then big ligt (7 input coeff);
        start = 0;            // This signal is set 1 after input data is ready.
        coeff_in = 0; 		

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		
		/*  a_shares modulo q; */
        coeff_array_q[0] = 30'd370922924;
        coeff_array_q[1] = 30'd422943464; 
        coeff_array_q[2] = 30'd164547197; 
        coeff_array_q[3] = 30'd814660070; 
        coeff_array_q[4] = 30'd705611185; 
        coeff_array_q[5] = 30'd887303870;        
        coeff_array_q[6] = 30'd0;
         
		/*  a_shares modulo p; */
		/*
        coeff_array_p[0] = 30'd823955913; 
        coeff_array_p[1] = 30'd958335940; 
        coeff_array_p[2] = 30'd278520605; 
        coeff_array_p[3] = 30'd736485995; 
        coeff_array_p[4] = 30'd765617435; 
        coeff_array_p[5] = 30'd48817392; 
        coeff_array_p[6] = 30'd863290220;    
        */
        
        coeff_array_p[0] = 30'd671786186;
        coeff_array_p[1] = 30'd371403231;
        coeff_array_p[2] = 30'd941041075;
        coeff_array_p[3] = 30'd757388970;
        coeff_array_p[4] = 30'd763397601;
        coeff_array_p[5] = 30'd388890965;
        coeff_array_p[6] = 30'd662959639;


        /* Computation Starts */
        @(posedge clk);
        rst = 0;
        
        @(posedge clk);    
        #1 start = 1'b1;

    
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
        @(posedge clk);
        @(posedge clk);    
        @(posedge clk);
  
        @(posedge clk);    
        #1 start = 1'b0;                                                     
	end
	
	always #5 clk = ~clk;
	
	always @(posedge clk)
	begin
	   if(mode==1'b0)
	       coeff_in <= coeff_array_q[rd_addr];
	   else
	       coeff_in <= coeff_array_p[rd_addr];
	end
	       
endmodule

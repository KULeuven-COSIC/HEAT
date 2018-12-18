`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/27/2018 10:26:25 AM
// Design Name: 
// Module Name: tb_lift_core
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



module tb_lift_core;

    reg clk;
    reg rst;
    reg mode;             // If 0 then small lift (6 input coeff); If 1 then big ligt (7 input coeff);
    reg start;            // This signal is set 1 after input data is ready.
    reg [3:0] ext_addr;      // Coefficients are assumed to be in a RAM.
    reg [239:0] ext_din;
    reg ext_we;
    reg ext_we_done;
    
    wire [239:0] ext_dout;
    wire eight_lift_result_write_done;
    
    reg [29:0] coeff_array_q[5:0], coeff_array0_q[5:0], coeff_array1_q[5:0];
    reg [29:0] coeff_array_p[6:0];
    reg [5:0] i, j;    

	// Instantiate the Unit Under Test (UUT)
    lift_core uut(clk, rst, mode, start, ext_addr, ext_din, ext_we, ext_we_done, ext_dout, eight_lift_result_write_done);
    
	initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        mode = 0;             // If 0 then small lift (6 input coeff); If 1 then big ligt (7 input coeff);
        start = 0;            // This signal is set 1 after input data is ready.
        ext_addr = 0;
        ext_din = 0;
        ext_we = 0;
        ext_we_done = 0;   

        // Wait 100 ns for global reset to finish
        #100;
        
        // Add stimulus here   
		
        /*  a_shares modulo q; */
               
        coeff_array0_q[0] = 30'd370922924;
        coeff_array0_q[1] = 30'd422943464; 
        coeff_array0_q[2] = 30'd164547197; 
        coeff_array0_q[3] = 30'd814660070; 
        coeff_array0_q[4] = 30'd705611185; 
        coeff_array0_q[5] = 30'd887303870;
        coeff_array0_q[6] = 30'd0;
        
        coeff_array1_q[0] = 30'd114350648; 
        coeff_array1_q[1] = 30'd83554958; 
        coeff_array1_q[2] = 30'd1042845872; 
        coeff_array1_q[3] = 30'd333796744; 
        coeff_array1_q[4] = 30'd529306817; 
        coeff_array1_q[5] = 30'd762852148;
        coeff_array1_q[6] = 30'd0;

       /* Computation Starts */
       @(posedge clk);
       rst = 0;
       @(posedge clk);
       @(posedge clk);       

        for(i=0; i<2; i=i+1)
        begin
           /* write in in_buff */
           for(j=0; j<6; j=j+1)
           begin
                @(posedge clk);
                if(i[0]==1'b0) 
                    ext_din = {coeff_array0_q[j],coeff_array0_q[j],coeff_array0_q[j],coeff_array0_q[j],coeff_array0_q[j],coeff_array0_q[j],coeff_array0_q[j],coeff_array0_q[j]};
                else
                    ext_din = {coeff_array1_q[j],coeff_array1_q[j],coeff_array1_q[j],coeff_array1_q[j],coeff_array1_q[j],coeff_array1_q[j],coeff_array1_q[j],coeff_array1_q[j]};                
                ext_addr = j;
                ext_we = 1;
           end

           @(posedge clk);
           ext_we = 0;
           ext_we_done = 1;
           @(posedge clk);
           ext_we_done = 0; 
                     
           #1 start = 1;    
       end      
    

        

        for(i=2; i<20; i=i+1)
        begin
            @(posedge clk);
            #1 ext_we = 0;                    
            #1 ext_we_done = 0;  
                   wait(eight_lift_result_write_done==1'b1);
                   for(j=0; j<7; j=j+1)
                   begin
                        @(posedge clk);
                        #1 ext_addr = j;
                   end     
           /* write in in_buff */
           for(j=0; j<6; j=j+1)
           begin
               @(posedge clk);
               if(i[0]==1'b0) 
                   ext_din = {coeff_array0_q[j],coeff_array0_q[j],coeff_array0_q[j],coeff_array0_q[j],coeff_array0_q[j],coeff_array0_q[j],coeff_array0_q[j],coeff_array0_q[j]};
               else
                   ext_din = {coeff_array1_q[j],coeff_array1_q[j],coeff_array1_q[j],coeff_array1_q[j],coeff_array1_q[j],coeff_array1_q[j],coeff_array1_q[j],coeff_array1_q[j]};                
               ext_addr = j;
               ext_we = 1;
             end

           @(posedge clk);
           ext_we = 0;
           ext_we_done = 1;
           @(posedge clk);
           ext_we_done = 0; 
    
       end      

       @(posedge clk);
       start = 0; 
              

	end
	
	always #5 clk = ~clk;
	

endmodule	                 
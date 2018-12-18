`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2018 06:17:34 PM
// Design Name: 
// Module Name: tb_lift_control
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


module tb_lift_control;
    reg clk; 						// computation clock
    reg rst;						// system reset when 1
    reg [7:0] instruction;	
    reg [3:0] MemR0, MemR1, MemW0, MemW1; // Memory select options for read and write;
    reg [239:0] lift_data_in;	
    
    wire [2:0] processor_sel;
    wire [3:0] memory_sel;            // Memory selected for read or write
    wire [8:0] bram_address;          // 0-511 address of the i/o buffer of Lift unit.
    wire [239:0] lift_data_out;
    wire bram_we;
    wire done;
    
    
    reg [29:0] coeff_array_q[6:0], coeff_array1_q[6:0];
    reg [29:0] coeff_array_p[6:0], coeff_array1_p[6:0];
    reg [5:0] i, j;    


lift_control_1core     LC(clk, rst, instruction, MemR0, MemR1, MemW0, MemW1, 
                          processor_sel, memory_sel, bram_address, bram_we,
						  lift_data_in, lift_data_out,
						  done	
						  );


	initial begin
        // Initialize Inputs
        clk = 0; 						// computation clock
        rst = 1;                        // system reset when 1
        instruction = 0;    
        MemR0 =0; MemR1 =1; MemW0 =2; MemW1 =3; // Memory select options for read and write;
        lift_data_in = {30'd7, 30'd6, 30'd5, 30'd4, 30'd3, 30'd2, 30'd1, 30'd0} ;
        
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
 
        coeff_array1_q[0] = 30'd743557621;
        coeff_array1_q[1] = 30'd1003577746;
        coeff_array1_q[2] = 30'd530484399;
        coeff_array1_q[3] = 30'd114864176;
        coeff_array1_q[4] = 30'd537632623;
        coeff_array1_q[5] = 30'd15491578;
        coeff_array1_q[6] = 30'd0;
        
        coeff_array1_p[0] = 30'd768344644;
        coeff_array1_p[1] = 30'd310329548;
        coeff_array1_p[2] = 30'd954988634;
        coeff_array1_p[3] = 30'd71314739;
        coeff_array1_p[4] = 30'd669333579;
        coeff_array1_p[5] = 30'd682455871;
        coeff_array1_p[6] = 30'd56501608;
                
        @(posedge clk);
        #1;
        rst = 0;

    end
    
    always #5 clk = ~clk;
    
    always @(posedge clk)
    begin
        if(bram_address[0]==1'b1)
        begin
            if(memory_sel==4'd0)
                lift_data_in <= {coeff_array_q[processor_sel],coeff_array_q[processor_sel],coeff_array_q[processor_sel],coeff_array_q[processor_sel],coeff_array_q[processor_sel],coeff_array_q[processor_sel],coeff_array_q[processor_sel],coeff_array_q[processor_sel]};
            else
                lift_data_in <= {coeff_array_p[processor_sel],coeff_array_p[processor_sel],coeff_array_p[processor_sel],coeff_array_p[processor_sel],coeff_array_p[processor_sel],coeff_array_p[processor_sel],coeff_array_p[processor_sel],coeff_array_p[processor_sel]};
        end
        else
        begin
            if(memory_sel==4'd0)
                lift_data_in <= {coeff_array1_q[processor_sel],coeff_array1_q[processor_sel],coeff_array1_q[processor_sel],coeff_array1_q[processor_sel],coeff_array1_q[processor_sel],coeff_array1_q[processor_sel],coeff_array1_q[processor_sel],coeff_array1_q[processor_sel]};
            else
                lift_data_in <= {coeff_array1_p[processor_sel],coeff_array1_p[processor_sel],coeff_array1_p[processor_sel],coeff_array1_p[processor_sel],coeff_array1_p[processor_sel],coeff_array1_p[processor_sel],coeff_array1_p[processor_sel],coeff_array1_p[processor_sel]};
        end

    end
endmodule

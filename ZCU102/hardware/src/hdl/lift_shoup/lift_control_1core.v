`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2018 04:07:08 PM
// Design Name: 
// Module Name: lift_control_1core
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


module lift_control_1core #(parameter number_of_cores=10)
                          (clk, rst, instruction, MemR0, MemR1, MemW0, MemW1, 
                          processor_sel, memory_sel, bram_address, bram_we,
						  lift_data_in, lift_data_out, bram_interrupt,
						  done	
						  );

input clk; 						// computation clock
input rst;						// system reset when 1
input [7:0] instruction;	
input [3:0] MemR0, MemR1, MemW0, MemW1; // Memory select options for read and write;

output [2:0] processor_sel;
output [3:0] memory_sel;			// Memory selected for read or write
output [8:0] bram_address;      	// 0-511 address of the i/o buffer of Lift unit.
input [239:0] lift_data_in;	
output [239:0] lift_data_out;

output bram_we;
output bram_interrupt;
output done;


reg enable_bram_addr, read_write;
reg rst_lift, start_lift;
wire done_bram_addr;
wire lift_mode;
wire last_read_of_buffer;

wire [3:0] ext_addr; 
wire ext_we; 
wire ext_we_done, ext_ctrl_done;
wire result_read_en;

reg rst_ext_ctrl;
reg [4:0] state, nextstate;

wire [239:0] ext_din, ext_dout;
wire eight_lift_result_write_done;
reg [9:0] num_eight_lift_result_write_done;
wire last_bram_write;

assign ext_din = lift_data_in;
assign lift_data_out = ext_dout;
assign bram_interrupt = enable_bram_addr;

assign lift_mode = (instruction==8'd5) ? 1'b0 : 1'b1; // big lift 1

bram_addr_gen bram_addr(clk, rst, enable_bram_addr, lift_mode, read_write, 
                        MemR0, MemR1, MemW0, MemW1,
                        bram_address, bram_we, processor_sel, memory_sel, done_bram_addr);


lift_ext_cntrl ext_ctrl(clk, rst_ext_ctrl, lift_mode, read_write, 
                    ext_addr, ext_we, ext_we_done, result_read_en, ext_ctrl_done);
                    
lift_core      LC(clk, rst_lift, lift_mode, start_lift, ext_addr, ext_din, ext_we, ext_we_done, result_read_en, ext_dout, eight_lift_result_write_done, last_read_of_buffer);                    

always @(posedge clk)
begin
    if(rst)
        num_eight_lift_result_write_done <= 10'd0;
    else if(eight_lift_result_write_done)
        num_eight_lift_result_write_done <= num_eight_lift_result_write_done + 1'b1;   
    else
        num_eight_lift_result_write_done <= num_eight_lift_result_write_done;
end


generate
    if (number_of_cores==4'd1)
        assign last_bram_write = (num_eight_lift_result_write_done==10'd512) ? 1'b1 : 1'b0;
    else if (number_of_cores==4'd2)
        assign last_bram_write = (num_eight_lift_result_write_done==10'd256) ? 1'b1 : 1'b0;
    else if (number_of_cores==4'd4)
        assign last_bram_write = (num_eight_lift_result_write_done==10'd128) ? 1'b1 : 1'b0;
    else if (number_of_cores==4'd8)
        assign last_bram_write = (num_eight_lift_result_write_done==10'd64) ? 1'b1 : 1'b0;
    else
        assign last_bram_write = (num_eight_lift_result_write_done==10'd512) ? 1'b1 : 1'b0;
endgenerate



        
always @(posedge clk)
begin
    if(rst)
        state <= 5'd0;
    else
        state <= nextstate;
end


reg last_read_of_buffer_while_BRAM_we;

always @(posedge clk)
begin
    if(rst)
        last_read_of_buffer_while_BRAM_we<=1'b0;
    else if(bram_we==1'b1 && last_read_of_buffer==1'b1)
         last_read_of_buffer_while_BRAM_we<=1'b1;
    else if(state==5'd17)
         last_read_of_buffer_while_BRAM_we<=1'b0;
    else
        last_read_of_buffer_while_BRAM_we<=last_read_of_buffer_while_BRAM_we;
end                    

/* Pipeline of ibuf load, computation and obuf read */
/**ibuff**//**ibuff**//**********comp**********//**********comp**********//**********comp**********/
                                               /**obuff**//**ibuff**/    /**obuff**//**ibuff**/  
always @(state)
begin
    case(state)
    5'd0: begin
                enable_bram_addr<=1'b0; read_write<=1'b0; rst_ext_ctrl<=1'b1; rst_lift<=1'b1; start_lift<=1'b0;
          end      
    
    /* First coeff set write in ibuff */
    5'd1: begin
                enable_bram_addr<=1'b1; read_write<=1'b0; rst_ext_ctrl<=1'b1; rst_lift<=1'b0; start_lift<=1'b0; 
          end
    5'd2: begin
                enable_bram_addr<=1'b1; read_write<=1'b0; rst_ext_ctrl<=1'b0; rst_lift<=1'b0; start_lift<=1'b0; 
          end                
    5'd3: begin
                enable_bram_addr<=1'b0; read_write<=1'b0; rst_ext_ctrl<=1'b0; rst_lift<=1'b0; start_lift<=1'b0; 
          end
    5'd4: begin
                enable_bram_addr<=1'b0; read_write<=1'b0; rst_ext_ctrl<=1'b1; rst_lift<=1'b0; start_lift<=1'b0; 
          end          


    /* Second coeff set write in ibuff */
    5'd5: begin
                enable_bram_addr<=1'b1; read_write<=1'b0; rst_ext_ctrl<=1'b1; rst_lift<=1'b0; start_lift<=1'b0; 
          end
    5'd6: begin
                enable_bram_addr<=1'b1; read_write<=1'b0; rst_ext_ctrl<=1'b0; rst_lift<=1'b0; start_lift<=1'b0; 
          end                
    5'd7: begin
                enable_bram_addr<=1'b0; read_write<=1'b0; rst_ext_ctrl<=1'b0; rst_lift<=1'b0; start_lift<=1'b0; 
          end
    5'd8: begin // Start Lift calculation
                enable_bram_addr<=1'b0; read_write<=1'b0; rst_ext_ctrl<=1'b1; rst_lift<=1'b0; start_lift<=1'b1; 
          end

    // Start: Special states for small Lift  
    /* Wait for eight_lift_result_write_done to appear */
    5'd9: begin // Start Lift calculation
                enable_bram_addr<=1'b0; read_write<=1'b0; rst_ext_ctrl<=1'b1; rst_lift<=1'b0; start_lift<=1'b1; 
          end
    /*  Start reading Obuff result and writing (1 cycle delay) in BRAM */
    5'd10: begin // Continuet Lift calculation
                enable_bram_addr<=1'b0; read_write<=1'b1; rst_ext_ctrl<=1'b0; rst_lift<=1'b0; start_lift<=1'b1; 
          end
    5'd11: begin // Continue Lift calculation
                enable_bram_addr<=1'b1; read_write<=1'b1; rst_ext_ctrl<=1'b0; rst_lift<=1'b0; start_lift<=1'b1; 
           end
    5'd12: begin // Jump after ext_we_done
                enable_bram_addr<=1'b1; read_write<=1'b1; rst_ext_ctrl<=1'b1; rst_lift<=1'b0; start_lift<=1'b1; 
           end
    5'd13: begin // Jump after done_bram_addr
                enable_bram_addr<=1'b0; read_write<=1'b1; rst_ext_ctrl<=1'b1; rst_lift<=1'b0; start_lift<=1'b1; 
           end

    /* Read next (after second) coeff set from BRAM and write in ibuff */
    5'd14: begin
                enable_bram_addr<=1'b1; read_write<=1'b0; rst_ext_ctrl<=1'b1; rst_lift<=1'b0; start_lift<=1'b1; 
          end
    5'd15: begin
                enable_bram_addr<=1'b1; read_write<=1'b0; rst_ext_ctrl<=1'b0; rst_lift<=1'b0; start_lift<=1'b1; 
          end                
    5'd16: begin
                enable_bram_addr<=1'b0; read_write<=1'b0; rst_ext_ctrl<=1'b0; rst_lift<=1'b0; start_lift<=1'b1; 
          end
    // END: Special states for small Lift  




    // Start: Special states for bigl Lift  
    /* Wait for last_read_of_in_buffer to appear */
    5'd17: begin // Start Lift calculation
                enable_bram_addr<=1'b0; read_write<=1'b0; rst_ext_ctrl<=1'b1; rst_lift<=1'b0; start_lift<=1'b1; 
          end
    /* Read next (after second) coeff set from BRAM and write in ibuff */
    5'd18: begin
               enable_bram_addr<=1'b1; read_write<=1'b0; rst_ext_ctrl<=1'b1; rst_lift<=1'b0; start_lift<=1'b1; 
          end
    5'd19: begin
               enable_bram_addr<=1'b1; read_write<=1'b0; rst_ext_ctrl<=1'b0; rst_lift<=1'b0; start_lift<=1'b1; 
        end                
    5'd20: begin
               enable_bram_addr<=1'b0; read_write<=1'b0; rst_ext_ctrl<=1'b0; rst_lift<=1'b0; start_lift<=1'b1; 
        end

    /*  Start reading Obuff result and writing (1 cycle delay) in BRAM */
    5'd25: begin // wait for eight_lift_result_write_done
                enable_bram_addr<=1'b0; read_write<=1'b1; rst_ext_ctrl<=1'b1; rst_lift<=1'b0; start_lift<=1'b1; 
          end
    5'd21: begin // Continuet Lift calculation
                enable_bram_addr<=1'b0; read_write<=1'b1; rst_ext_ctrl<=1'b0; rst_lift<=1'b0; start_lift<=1'b1; 
          end
    5'd22: begin // Continue Lift calculation
                enable_bram_addr<=1'b1; read_write<=1'b1; rst_ext_ctrl<=1'b0; rst_lift<=1'b0; start_lift<=1'b1; 
           end
    5'd23: begin // Jump after ext_we_done
                enable_bram_addr<=1'b1; read_write<=1'b1; rst_ext_ctrl<=1'b1; rst_lift<=1'b0; start_lift<=1'b1; 
           end
    5'd24: begin // Jump after done_bram_addr
                enable_bram_addr<=1'b0; read_write<=1'b1; rst_ext_ctrl<=1'b1; rst_lift<=1'b0; start_lift<=1'b1; 
           end

    // END: Special states for Big Lift  






    5'd31: begin
                enable_bram_addr<=1'b0; read_write<=1'b0; rst_ext_ctrl<=1'b1; rst_lift<=1'b1; start_lift<=1'b0; 
          end
    default: begin
                enable_bram_addr<=1'b0; read_write<=1'b0; rst_ext_ctrl<=1'b1; rst_lift<=1'b1; start_lift<=1'b0; 
          end
    endcase
end

always @(state or lift_mode or done_bram_addr or ext_ctrl_done or eight_lift_result_write_done 
        or last_read_of_buffer or last_read_of_buffer_while_BRAM_we or last_bram_write)
begin
    case(state)
    5'd0: nextstate <= 5'd1;    

    5'd1: nextstate <= 5'd2;        
    5'd2: begin
            if(done_bram_addr)
                nextstate <= 5'd3; 
            else
                nextstate <= 5'd2;
          end
    5'd3: begin
            if(ext_ctrl_done)
                nextstate <= 5'd4; 
            else
                nextstate <= 5'd3;
          end
 
    5'd4: nextstate <= 5'd5;        
    5'd5: nextstate <= 5'd6;        
    5'd6: begin
            if(done_bram_addr)
                nextstate <= 5'd7; 
            else
                nextstate <= 5'd6;
          end
    5'd7: begin
            if(ext_ctrl_done)
                nextstate <= 5'd8; 
            else
                nextstate <= 5'd7;
          end
    5'd8: begin
            if(lift_mode==1'b0)
                nextstate <= 5'd9;         
            else
                nextstate <= 5'd17;
          end
            
    // Specific states for small Lift
    // Waiting for result to be ready in obuff
    5'd9: begin
            if(eight_lift_result_write_done)
                nextstate <= 5'd10; 
            else
                nextstate <= 5'd9;
          end
    // write in BRAM
    5'd10: nextstate <= 5'd11;         
    5'd11: begin
            if(ext_ctrl_done)
                nextstate <= 5'd12; 
            else
                nextstate <= 5'd11;
          end
    5'd12: begin
            if(done_bram_addr)
                nextstate <= 5'd13; 
            else
                nextstate <= 5'd12;
          end
    5'd13: begin
            if(last_bram_write)
                nextstate <= 5'd31;
            else
                nextstate <= 5'd14;       
           end  
    
    // Read from BRAM
    5'd14: nextstate <= 5'd15;        
    5'd15: begin
            if(done_bram_addr)
                nextstate <= 5'd16; 
            else
                nextstate <= 5'd15;
          end
    5'd16: begin
            if(ext_ctrl_done)
                nextstate <= 5'd9; 
            else
                nextstate <= 5'd16;
          end 
          

    // Specific states for Big Lift
    // Waiting for result to be ready in obuff
    5'd17: begin
            if(last_read_of_buffer==1'b1 || last_read_of_buffer_while_BRAM_we==1'b1)
                nextstate <= 5'd18; 
            else
                nextstate <= 5'd17;
          end

    // Read from BRAM
    5'd18: nextstate <= 5'd19;        
    5'd19: begin
            if(done_bram_addr)
                nextstate <= 5'd20; 
            else
                nextstate <= 5'd19;
          end
    5'd20: begin
            if(ext_ctrl_done)
                nextstate <= 5'd25; 
            else
                nextstate <= 5'd20;
          end 

    // write in BRAM
    5'd25: begin
                if(eight_lift_result_write_done)
                    nextstate <= 5'd21; 
                else
                    nextstate <= 5'd25;
              end
    5'd21: nextstate <= 5'd22;          
    5'd22: begin
            if(ext_ctrl_done)
                nextstate <= 5'd23; 
            else
                nextstate <= 5'd22;
          end
    5'd23: begin
            if(done_bram_addr)
                nextstate <= 5'd24; 
            else
                nextstate <= 5'd23;
          end
    5'd24: begin
            if(last_bram_write)
                nextstate <= 5'd31;
            else
                nextstate <= 5'd17;       
           end  
    
          
          
          
    5'd31: nextstate <= 5'd31;
    default: nextstate <= 5'd0;                     
    endcase
end
    
assign done = (state==5'd31) ? 1'b1 : 1'b0;

endmodule




module lift_control_wrapper_2core
                          (clk, rst, instruction, MemR0, MemR1, MemW0, MemW1, 
                          processor_sel, memory_sel, bram_address, bram_we,
						  lift_data_in, lift_data_out,
						  done	
						  );

input clk; 						// computation clock
input rst;						// system reset when 1
input [7:0] instruction;	
input [3:0] MemR0, MemR1, MemW0, MemW1; // Memory select options for read and write;

output [2:0] processor_sel;
output [3:0] memory_sel;			// Memory selected for read or write
output [8:0] bram_address;      	// 0-511 address of the i/o buffer of Lift unit.
input [239:0] lift_data_in;	
output [239:0] lift_data_out;

output bram_we;
output done;

// Lift core 0 signals
reg rst_lift_core0;
wire [2:0] processor_sel_core0;
wire [3:0] memory_sel_core0;		
wire [8:0] bram_address_core0;      // The first set of address
wire [239:0] lift_data_out_core0;
wire bram_we_core0;
wire bram_interrupt_core0;
reg bram_interrupt_core0_r;         // keeps bram_interrupt_core1 for 1 more cycle extra
wire bram_interrupt_core0_extended;
wire done_core0;

// Lift core 1 signals
reg rst_lift_core1;
wire [2:0] processor_sel_core1;
wire [3:0] memory_sel_core1;		
wire [8:0] bram_address_core1;      // The first set of address
wire [239:0] lift_data_out_core1;
wire bram_we_core1;
wire bram_interrupt_core1;
reg bram_interrupt_core1_r;         // keeps bram_interrupt_core1 for 1 more cycle extra
wire bram_interrupt_core1_extended;
wire done_core1;

reg [3:0] state, nextstate;
reg [6:0] counter;
wire counter_finished;


lift_control_1core  #(2)core0
                         (clk, rst_lift_core0, instruction, MemR0, MemR1, MemW0, MemW1, 
                          processor_sel_core0, memory_sel_core0, bram_address_core0, bram_we_core0,
						  lift_data_in, lift_data_out_core0, bram_interrupt_core0,
                          done_core0	
						  );

lift_control_1core  #(2)core1
                         (clk, rst_lift_core1, instruction, MemR0, MemR1, MemW0, MemW1, 
                          processor_sel_core1, memory_sel_core1, bram_address_core1, bram_we_core1,
						  lift_data_in, lift_data_out_core1, bram_interrupt_core1,
                          done_core1	
						  );

always @(posedge clk)
begin
    bram_interrupt_core0_r<=bram_interrupt_core0;
    bram_interrupt_core1_r<=bram_interrupt_core1;
end

assign bram_interrupt_core0_extended = (bram_interrupt_core0==1'b1 || bram_interrupt_core0_r==1'b1) ? 1'b1 : 1'b0;
assign bram_interrupt_core1_extended = (bram_interrupt_core1==1'b1 || bram_interrupt_core1_r==1'b1) ? 1'b1 : 1'b0;

assign {processor_sel, memory_sel, bram_address, bram_we, lift_data_out} = (bram_interrupt_core1_extended) ? {processor_sel_core1, memory_sel_core1, {1'b1,bram_address_core1[7:0]}, bram_we_core1, lift_data_out_core1}
                                                                                                           : {processor_sel_core0, memory_sel_core0, {1'b0,bram_address_core0[7:0]}, bram_we_core0, lift_data_out_core0};
                                                                                                            

always @(posedge clk)
begin
    if(rst)
        counter <= 7'd0;
    else if(state==4'd2)
        counter <= counter + 1'b1;
    else 
        counter <= 7'd0;      
end

assign counter_finished = ((instruction==8'd6 && counter==7'd32) || (instruction==8'd5 && counter==7'd16)) ? 1'b1 : 1'b0;    
    
always @(posedge clk)
begin
    if(rst)
        state <= 4'd0;
    else
        state <= nextstate; 
end           

always @(state)
begin
    case(state)
    4'd0: begin rst_lift_core0<=1'b1; rst_lift_core1<=1'b1;        end

    // start lift core0
    4'd1: begin rst_lift_core0<=1'b0; rst_lift_core1<=1'b1;        end

    // wait for 32 cycles; (by this time BRAM read of core 0 finishes)
    4'd2: begin rst_lift_core0<=1'b0; rst_lift_core1<=1'b1;        end

    // Now start lift core 1; continue untill done_core0==1
    4'd3: begin rst_lift_core0<=1'b0; rst_lift_core1<=1'b0;        end
    
    // Reset core 0
    4'd4: begin rst_lift_core0<=1'b1; rst_lift_core1<=1'b0;        end

    // continue untill done_core1==1
    4'd5: begin rst_lift_core0<=1'b1; rst_lift_core1<=1'b0;        end


    4'd15: begin rst_lift_core0<=1'b1; rst_lift_core1<=1'b1;        end

    default: begin rst_lift_core0<=1'b1; rst_lift_core1<=1'b1;        end

    endcase
end

always @(state or counter_finished or done_core0 or done_core1)
begin
    case(state)
    4'd0: nextstate <= 4'd1;

    4'd1: nextstate <= 4'd2;

    4'd2: begin
            if(counter_finished)
                nextstate <= 4'd3;
            else  
                nextstate <= 4'd2;
          end        
    4'd3: begin
            if(done_core0)
                nextstate <= 4'd4;
            else
                nextstate <= 4'd3;
          end          
    4'd4: nextstate <= 4'd5;

    4'd5: begin
            if(done_core1)
                nextstate <= 4'd15;
            else
                nextstate <= 4'd5;
          end          

    4'd15: nextstate <= 4'd15;    
        
    default: nextstate <= 4'd0;
    endcase
end
        
assign done = (state==4'd15) ? 1'b1 : 1'b0;        

endmodule
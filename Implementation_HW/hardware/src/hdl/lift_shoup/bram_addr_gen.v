`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2018 05:20:04 PM
// Design Name: 
// Module Name: bram_addr_gen
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


module bram_addr_gen(clk, rst, enable, lift_mode, read_write, 
                     MemR0, MemR1, MemW0, MemW1,
                     bram_address, bram_we, processor_sel_op, memory_sel_op, done);
input clk, rst;
input enable;       // 1 to enable computation
input lift_mode;    // 0 small 1 big
input read_write;   // 1 for obuff read; 0 for ibuff write
input [3:0] MemR0, MemR1, MemW0, MemW1; // Memory select options for read and write;

output [8:0] bram_address;
output bram_we;
output [2:0] processor_sel_op;
output [3:0] memory_sel_op;
output done ;

reg [2:0] processor_sel, processor_sel_r;
reg read_mod_p_shares;
wire rst_processor_sel;

wire [3:0] memory_sel;
reg [3:0] memory_sel_r;

reg [8:0] bram_rd_address, bram_wt_address;;

// During BRAM read, processor select and memory select should come one cycle later than BRAM address
assign processor_sel_op = (read_write==1'b0) ? processor_sel_r : processor_sel;
assign memory_sel_op = (read_write==1'b0) ? memory_sel_r : memory_sel;

always @(posedge clk)
begin
    if(rst)
        processor_sel <= 3'd0;
    else if(rst_processor_sel==1'b1 && enable==1'b1)
        processor_sel <= 3'd0;
    else if(enable)
        processor_sel <= processor_sel + 1'b1;            
end

always @(posedge clk)
begin
    processor_sel_r <= processor_sel;
    memory_sel_r <= memory_sel;
end    

always @(posedge clk)
begin
    if(rst)
        read_mod_p_shares<=1'b0;
    else if(lift_mode==1'b1 && read_write==1'b0 && read_mod_p_shares==1'b0 && processor_sel==3'd5 && enable==1'b1)
        read_mod_p_shares<=1'b1;
    else if(lift_mode==1'b1 && read_write==1'b0 && read_mod_p_shares==1'b1 && processor_sel==3'd6 && enable==1'b1)
        read_mod_p_shares<=1'b0;
    else
        read_mod_p_shares<=read_mod_p_shares;
end
                            

assign rst_processor_sel = (lift_mode==1'b0 && read_write==1'b0 && processor_sel==3'd5 && enable==1'b1) ? 1'b1
                          :(lift_mode==1'b1 && read_write==1'b0 && read_mod_p_shares==1'b0 && processor_sel==3'd5) ? 1'b1   
                          :(lift_mode==1'b1 && read_write==1'b0 && read_mod_p_shares==1'b1 && processor_sel==3'd6) ? 1'b1
                          
                          :(lift_mode==1'b0 && read_write==1'b1 && processor_sel==3'd6 && enable==1'b1) ? 1'b1
                          :(lift_mode==1'b1 && read_write==1'b1 && processor_sel==3'd5 && enable==1'b1) ? 1'b1
                          :1'b0;                                         
                                                                
assign memory_sel = (read_write==1'b0 && read_mod_p_shares==1'b0) ? MemR0
                   :(read_write==1'b0 && read_mod_p_shares==1'b1) ? MemR1
                   :(read_write==1'b1) ? MemW0 : MemR0;   

assign bram_address = (read_write==1'b0) ? bram_rd_address : bram_wt_address;

always @(posedge clk)
begin
    if(rst)
        bram_rd_address <= 9'd0;
    else if(enable==1'b1 && lift_mode==1'b0 && read_write==1'b0 && processor_sel==3'd5)
        bram_rd_address <= bram_rd_address + 1'b1;
    else if(enable==1'b1 && lift_mode==1'b1 && read_write==1'b0 && processor_sel==3'd6)
        bram_rd_address <= bram_rd_address + 1'b1;      
    else            
        bram_rd_address <= bram_rd_address;
end
        
always @(posedge clk)
begin
    if(rst)
        bram_wt_address <= 9'd0;
    else if(enable==1'b1 && lift_mode==1'b0 && read_write==1'b1 && processor_sel==3'd6)    
        bram_wt_address <= bram_wt_address + 1'b1;  
    else if(enable==1'b1 && lift_mode==1'b1 && read_write==1'b1 && processor_sel==3'd5)
        bram_wt_address <= bram_wt_address + 1'b1;              
    else            
        bram_wt_address <= bram_wt_address;
end


assign done = (enable==1'b1 && lift_mode==1'b0 && read_write==1'b0 && processor_sel==3'd5) ? 1'b1 : 
              (enable==1'b1 && lift_mode==1'b0 && read_write==1'b1 && processor_sel==3'd6) ? 1'b1 :
              (enable==1'b1 && lift_mode==1'b1 && read_write==1'b0 && processor_sel==3'd6) ? 1'b1 :
              (enable==1'b1 && lift_mode==1'b1 && read_write==1'b1 && processor_sel==3'd5) ? 1'b1 : 1'b0; 

assign bram_we = enable & read_write;
/*    
always @(posedge clk)
begin
    if(rst)
        bram_we <= 1'b0;
    else if(enable==1'b1 && read_write==1'b1 && done==1'b0)
        bram_we <= 1'b1;
    else
        bram_we <= 1'b0;
end                 
*/
    
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2018 05:05:49 PM
// Design Name: 
// Module Name: lift_ext_cntrl
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


module lift_ext_cntrl(clk, rst, lift_mode, read_write, 
                    ext_addr, ext_we, ext_we_done, result_read_en, ext_ctrl_done);
input clk, rst;
input lift_mode;    // 0 small 1 big
input read_write;   // 1 for obuff read; 0 for ibuff write

output reg [3:0] ext_addr; 
output ext_we; 
output ext_we_done;
output result_read_en;
output ext_ctrl_done;

assign ext_ctrl_done =  (lift_mode==1'b0 && read_write==1'b0 && ext_addr==4'd5) ? 1'b1    // small and ibuff write
              :(lift_mode==1'b1 && read_write==1'b0 && ext_addr==4'd12) ? 1'b1    // large and ibuff write
              :(lift_mode==1'b0 && read_write==1'b1 && ext_addr==4'd6) ? 1'b1     // small and obuff read
              :(lift_mode==1'b1 && read_write==1'b1 && ext_addr==4'd5) ? 1'b1     // large and obuff read
              :1'b0;
                 
always @(posedge clk)
begin
    if(rst)
        ext_addr <= 4'd0;
    else if(ext_ctrl_done)   
        ext_addr <= 4'd0;
    else
        ext_addr <= ext_addr + 1'b1;    
end

assign ext_we = (read_write==1'b0 && rst==1'b0) ? 1'b1 : 1'b0;
assign result_read_en = (rst==1'b0 && read_write==1'b1) ? 1'b1 : 1'b0;
assign ext_we_done = (read_write==1'b0) ? ext_ctrl_done : 1'b0;

endmodule

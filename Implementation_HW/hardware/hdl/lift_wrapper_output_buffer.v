`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:03:07 10/17/2017 
// Design Name: 
// Module Name:    lift_wrapper_output_buffer 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lift_wrapper_output_buffer(clk, din, write_sel, write_address, we, 
                                  read_address, read_out);
input clk;
input [29:0] din;
input [2:0] write_sel;
input we;
input [5:0] write_address;

input [5:0] read_address;
output [239:0] read_out;


wire we0, we1, we2, we3, we4, we5, we6, we7;
wire [29:0] read_data0, read_data1, read_data2, read_data3, read_data4, read_data5, read_data6, read_data7;

assign we0 = (write_sel==3'd0) ? we : 1'b0;
assign we1 = (write_sel==3'd1) ? we : 1'b0;
assign we2 = (write_sel==3'd2) ? we : 1'b0;
assign we3 = (write_sel==3'd3) ? we : 1'b0;
assign we4 = (write_sel==3'd4) ? we : 1'b0;
assign we5 = (write_sel==3'd5) ? we : 1'b0;
assign we6 = (write_sel==3'd6) ? we : 1'b0;
assign we7 = (write_sel==3'd7) ? we : 1'b0;


lift_buffer_ram in_buff0(
  .a(write_address), // input [5 : 0] a
  .d(din), // input [59 : 0] d
  .dpra(read_address), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(we0), // input we
  .qdpo(read_data0) // output [59 : 0] qdpo
);
lift_buffer_ram in_buff1(
  .a(write_address), // input [5 : 0] a
  .d(din), // input [59 : 0] d
  .dpra(read_address), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(we1), // input we
  .qdpo(read_data1) // output [59 : 0] qdpo
);
lift_buffer_ram in_buff2(
  .a(write_address), // input [5 : 0] a
  .d(din), // input [59 : 0] d
  .dpra(read_address), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(we2), // input we
  .qdpo(read_data2) // output [59 : 0] qdpo
);
lift_buffer_ram in_buff3(
  .a(write_address), // input [5 : 0] a
  .d(din), // input [59 : 0] d
  .dpra(read_address), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(we3), // input we
  .qdpo(read_data3) // output [59 : 0] qdpo
);
lift_buffer_ram in_buff4(
  .a(write_address), // input [5 : 0] a
  .d(din), // input [59 : 0] d
  .dpra(read_address), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(we4), // input we
  .qdpo(read_data4) // output [59 : 0] qdpo
);
lift_buffer_ram in_buff5(
  .a(write_address), // input [5 : 0] a
  .d(din), // input [59 : 0] d
  .dpra(read_address), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(we5), // input we
  .qdpo(read_data5) // output [59 : 0] qdpo
);
lift_buffer_ram in_buff6(
  .a(write_address), // input [5 : 0] a
  .d(din), // input [59 : 0] d
  .dpra(read_address), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(we6), // input we
  .qdpo(read_data6) // output [59 : 0] qdpo
);
lift_buffer_ram in_buff7(
  .a(write_address), // input [5 : 0] a
  .d(din), // input [59 : 0] d
  .dpra(read_address), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(we7), // input we
  .qdpo(read_data7) // output [59 : 0] qdpo
);


assign read_out =  {read_data7,read_data6,read_data5,read_data4,read_data3,read_data2,read_data1,read_data0};

					
endmodule

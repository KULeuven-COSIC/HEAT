`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: a
// Engineer: 
// 
// Create Date:    10:47:17 10/17/2017 
// Design Name: 
// Module Name:    lift_wrapper_input_buffer 
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
module lift_wrapper_input_buffer(clk, din, write_address, we, read_address, read_sel, read_out);
input clk;
input [239:0] din;
input [5:0] write_address, read_address;
input we;
input [2:0] read_sel;
output [29:0] read_out;

wire [29:0] read_data0, read_data1, read_data2, read_data3, read_data4, read_data5, read_data6, read_data7;

lift_buffer_ram in_buff0(
  .a(write_address), // input [5 : 0] a
  .d(din[29:0]), // input [59 : 0] d
  .dpra(read_address), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(we), // input we
  .qdpo(read_data0) // output [59 : 0] qdpo
);
lift_buffer_ram in_buff1(
  .a(write_address), // input [5 : 0] a
  .d(din[59:30]), // input [59 : 0] d
  .dpra(read_address), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(we), // input we
  .qdpo(read_data1) // output [59 : 0] qdpo
);
lift_buffer_ram in_buff2(
  .a(write_address), // input [5 : 0] a
  .d(din[89:60]), // input [59 : 0] d
  .dpra(read_address), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(we), // input we
  .qdpo(read_data2) // output [59 : 0] qdpo
);
lift_buffer_ram in_buff3(
  .a(write_address), // input [5 : 0] a
  .d(din[119:90]), // input [59 : 0] d
  .dpra(read_address), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(we), // input we
  .qdpo(read_data3) // output [59 : 0] qdpo
);
lift_buffer_ram in_buff4(
  .a(write_address), // input [5 : 0] a
  .d(din[149:120]), // input [59 : 0] d
  .dpra(read_address), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(we), // input we
  .qdpo(read_data4) // output [59 : 0] qdpo
);
lift_buffer_ram in_buff5(
  .a(write_address), // input [5 : 0] a
  .d(din[179:150]), // input [59 : 0] d
  .dpra(read_address), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(we), // input we
  .qdpo(read_data5) // output [59 : 0] qdpo
);
lift_buffer_ram in_buff6(
  .a(write_address), // input [5 : 0] a
  .d(din[209:180]), // input [59 : 0] d
  .dpra(read_address), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(we), // input we
  .qdpo(read_data6) // output [59 : 0] qdpo
);
lift_buffer_ram in_buff7(
  .a(write_address), // input [5 : 0] a
  .d(din[239:210]), // input [59 : 0] d
  .dpra(read_address), // input [5 : 0] dpra
  .clk(clk), // input clk
  .we(we), // input we
  .qdpo(read_data7) // output [59 : 0] qdpo
);


assign read_out =  (read_sel==3'd0) ? read_data0 :
					(read_sel==3'd1) ? read_data1 :
					(read_sel==3'd2) ? read_data2 :
					(read_sel==3'd3) ? read_data3 :
					(read_sel==3'd4) ? read_data4 :
					(read_sel==3'd5) ? read_data5 :
					(read_sel==3'd6) ? read_data6 :
					 read_data7;
					
endmodule

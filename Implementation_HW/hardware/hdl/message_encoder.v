`timescale 1ns / 1ps
`define	qby2_q0 30'd73728
`define	qby2_q1 30'd124928
`define	qby2_q2 30'd81920
`define	qby2_q3 30'd88064
`define	qby2_q4 30'd92160
`define	qby2_q5 30'd94208
//////////////////////////////////////////////////////////////////////////////////
// Company: a
// Engineer: 
// 
// Create Date:    20:43:35 07/06/2016 
// Design Name: 
// Module Name:    message_encoder 
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
module message_encoder(message, 
									 mencodedH_q0, mencodedL_q0, mencodedH_q1, mencodedL_q1, mencodedH_q2, mencodedL_q2,
                            mencodedH_q3, mencodedL_q3, mencodedH_q4, mencodedL_q4, mencodedH_q5, mencodedL_q5);
input [1:0] message;
output [29:0] mencodedH_q0, mencodedL_q0, mencodedH_q1, mencodedL_q1, mencodedH_q2, mencodedL_q2;
output [29:0] mencodedH_q3, mencodedL_q3, mencodedH_q4, mencodedL_q4, mencodedH_q5, mencodedL_q5;


mux2_30bits mH_q0(30'd0, `qby2_q0, message[1], mencodedH_q0);
mux2_30bits mL_q0(30'd0, `qby2_q0, message[0], mencodedL_q0);

mux2_30bits mH_q1(30'd0, `qby2_q1, message[1], mencodedH_q1);
mux2_30bits mL_q1(30'd0, `qby2_q1, message[0], mencodedL_q1);

mux2_30bits mH_q2(30'd0, `qby2_q2, message[1], mencodedH_q2);
mux2_30bits mL_q2(30'd0, `qby2_q2, message[0], mencodedL_q2);

mux2_30bits mH_q3(30'd0, `qby2_q3, message[1], mencodedH_q3);
mux2_30bits mL_q3(30'd0, `qby2_q3, message[0], mencodedL_q3);

mux2_30bits mH_q4(30'd0, `qby2_q4, message[1], mencodedH_q4);
mux2_30bits mL_q4(30'd0, `qby2_q4, message[0], mencodedL_q4);

mux2_30bits mH_q5(30'd0, `qby2_q5, message[1], mencodedH_q5);
mux2_30bits mL_q5(30'd0, `qby2_q5, message[0], mencodedL_q5);

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:14:21 05/07/2017 
// Design Name: 
// Module Name:    red_alu 
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
module red_alu(clk, mod_q_data_word, 
					barrett_constant, prime, barrett_input_sel,
				   rom_word_core1, rom_word_core2, rom_word_core3, rom_word_core4,
               rst_acc, wen_acc_core1, wen_acc_core2, wen_acc_core3, wen_acc_core4, 
					only_multiply,
					m0sel, m1sel, m2sel, m3sel, addsub, 
					result
					);
input clk;					
input [59:0] mod_q_data_word;
input [30:0] barrett_constant;
input [29:0] prime;
input [1:0] barrett_input_sel;
input [30:0] rom_word_core1, rom_word_core2, rom_word_core3, rom_word_core4;
input m0sel, m3sel, addsub, rst_acc, only_multiply;
input wen_acc_core1, wen_acc_core2, wen_acc_core3, wen_acc_core4;
input [1:0] m1sel, m2sel;

output [29:0] result;

wire [29:0] m0out_core1, m1out_core1, m0out_core2, m1out_core2, m0out_core3, m1out_core3, m0out_core4, m1out_core4;
wire [59:0] multout_core1, multout_core2, multout_core3, multout_core4, m3out_core1, m3out_core2, m3out_core3, m3out_core4;
reg [65:0] acc_core1, acc_core2, acc_core3, acc_core4;
wire [65:0] m2out_core1, m2out_core2, m2out_core3, m2out_core4;
wire [65:0] asout_core1, asout_core2, asout_core3, asout_core4;
wire cout_core1, cout_core2, cout_core3, cout_core4;
wire [29:0] barrett_out;

assign m0out_core1 = (m0sel) ? {1'b0,mod_q_data_word[58:30]} : mod_q_data_word[29:0];
assign m0out_core2 = m0out_core1;
assign m0out_core3 = m0out_core1;
assign m0out_core4 = m0out_core1;

assign m1out_core1 = (m1sel==2'd0) ? m0out_core1 : (m1sel==2'd1) ? {22'd0,acc_core1[65:58]} : acc_core1[59:30];
assign m1out_core2 = (m1sel==2'd0) ? m0out_core2 : (m1sel==2'd1) ? {22'd0,acc_core2[65:58]} : acc_core2[59:30];
assign m1out_core3 = (m1sel==2'd0) ? m0out_core3 : (m1sel==2'd1) ? {22'd0,acc_core3[65:58]} : acc_core3[59:30];
assign m1out_core4 = (m1sel==2'd0) ? m0out_core4 : (m1sel==2'd1) ? {22'd0,acc_core4[65:58]} : acc_core4[59:30];

wire [59:0] barrett_input = (barrett_input_sel==2'd0) ? acc_core1[59:0] :
                            (barrett_input_sel==2'd1) ? acc_core2[59:0] :
									 (barrett_input_sel==2'd2) ? acc_core3[59:0] : acc_core4[59:0];

barrett_red_60by30 br(.clk(clk), .a(barrett_input), .prime(prime), .barrett_const(barrett_constant), 
								 .only_multiply(only_multiply),
								 .ina1(m1out_core1), .inb1(rom_word_core1), .ina2(m1out_core2), .inb2(rom_word_core2), 
								 .ina3(m1out_core3), .inb3(rom_word_core3), .ina4(m1out_core4), .inb4(rom_word_core4),
								 .out1(multout_core1), .out2(multout_core2), .out3(multout_core3), .out4(multout_core4),		
								 .b(barrett_out)); 

assign m2out_core1 = (m2sel==2'd0) ? acc_core1 : (m2sel==2'd1) ? {8'd0,acc_core1[57:0]} : 
					(m2sel==2'd2) ? 66'd0 : {36'd0,rom_word_core1[29:0]};
assign m2out_core2 = (m2sel==2'd0) ? acc_core2 : (m2sel==2'd1) ? {8'd0,acc_core2[57:0]} : 
					(m2sel==2'd2) ? 66'd0 : {36'd0,rom_word_core2[29:0]};
assign m2out_core3 = (m2sel==2'd0) ? acc_core3 : (m2sel==2'd1) ? {8'd0,acc_core3[57:0]} : 
					(m2sel==2'd2) ? 66'd0 : {36'd0,rom_word_core3[29:0]};					
assign m2out_core4 = (m2sel==2'd0) ? acc_core4 : (m2sel==2'd1) ? {8'd0,acc_core4[57:0]} : 
					(m2sel==2'd2) ? 66'd0 : {36'd0,rom_word_core4[29:0]};
					
assign m3out_core1 = (m3sel==1'd0) ? multout_core1 : {30'd0,barrett_out};
assign m3out_core2 = (m3sel==1'd0) ? multout_core2 : {30'd0,barrett_out};
assign m3out_core3 = (m3sel==1'd0) ? multout_core3 : {30'd0,barrett_out};
assign m3out_core4 = (m3sel==1'd0) ? multout_core4 : {30'd0,barrett_out};

addsub_circuit as1(.a(m2out_core1), .b(m3out_core1), .add(addsub), .c_out(), .s(asout_core1));
addsub_circuit as2(.a(m2out_core2), .b(m3out_core2), .add(addsub), .c_out(), .s(asout_core2));
addsub_circuit as3(.a(m2out_core3), .b(m3out_core3), .add(addsub), .c_out(), .s(asout_core3));
addsub_circuit as4(.a(m2out_core4), .b(m3out_core4), .add(addsub), .c_out(), .s(asout_core4));

always @(posedge clk)
begin
	if(rst_acc)
		acc_core1 <= 66'd0;
	else if(wen_acc_core1)
		acc_core1 <= asout_core1;
	else
		acc_core1 <= acc_core1;
end
always @(posedge clk)
begin
	if(rst_acc)
		acc_core2 <= 66'd0;
	else if(wen_acc_core2)
		acc_core2 <= asout_core2;
	else
		acc_core2 <= acc_core2;
end
always @(posedge clk)
begin
	if(rst_acc)
		acc_core3 <= 66'd0;
	else if(wen_acc_core3)
		acc_core3 <= asout_core3;
	else
		acc_core3 <= acc_core3;
end
always @(posedge clk)
begin
	if(rst_acc)
		acc_core4 <= 66'd0;
	else if(wen_acc_core4)
		acc_core4 <= asout_core4;
	else
		acc_core4 <= acc_core4;
end


assign result = (wen_acc_core2) ? acc_core1[29:0] : (wen_acc_core3) ? acc_core2[29:0] : (wen_acc_core4) ? acc_core3[29:0] : acc_core4[29:0];

endmodule


/*
module red_alu_single_core(clk, mod_q_data_word, rom_word,
               rst_acc, wen_acc, only_multiply,
					m0sel, m1sel, m2sel, m3sel, addsub, 
					result, cout
					);
input clk;					
input [59:0] mod_q_data_word;
input [30:0] rom_word;
input m0sel, addsub, rst_acc, wen_acc, only_multiply;
input [1:0] m1sel, m2sel, m3sel;

output [29:0] result;
output cout;

wire [29:0] m0out, m1out;
wire [59:0] multout, m3out;
reg [65:0] acc;
wire [65:0] m2out;
wire [65:0] asout;
wire cout;
wire [29:0] barrett_out;

assign m0out = (m0sel) ? mod_q_data_word[59:30] : mod_q_data_word[29:0];
assign m1out = (m1sel==2'd0) ? m0out : (m1sel==2'd1) ? {22'd0,acc[65:58]} : acc[59:30];

//hibrid_mul30 mult(clk, m1out, rom_word, multout);
barrett_red_60by30 br(.clk(clk), .a(acc[59:0]), .prime(rom_word[29:0]), .barrett_const(rom_word), 
								 .only_multiply(only_multiply),
								 .ina1(m1out), .inb1(rom_word), .ina2(), .inb2(), .ina3(), .inb3(), .ina4(), .inb4(),
								 .out1(multout), .out2(), .out3(), .out4(),		
								 .b(barrett_out)); 

assign m2out = (m2sel==2'd0) ? acc : (m2sel==2'd1) ? {8'd0,acc[57:0]} : 
					(m2sel==2'd2) ? 66'd0 : {36'd0,rom_word[29:0]};
					
assign m3out = (m3sel==2'd0) ? multout : (m3sel==2'd1) ? {30'd0,rom_word[29:0]} : {30'd0,barrett_out};

addsub_circuit as(.a(m2out), .b(m3out), .add(addsub), .c_out(cout), .s(asout));

always @(posedge clk)
begin
	if(rst_acc)
		acc <= 66'd0;
	else if(wen_acc)
		acc <= asout;
	else
		acc <= acc;
end

assign result = acc[29:0];

endmodule
*/
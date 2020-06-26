`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2018 06:10:04 PM
// Design Name: 
// Module Name: NTT_ROM
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
module NTT_ROM(clk, instruction, mod_sel, addra_NTT_ROM_p0_EM, addra_NTT_ROM_p0_EM_n, 
					w_NTT_ROM_p0_EM, w_NTT_ROM_p0_EM_n,
					w_NTT_ROM_p1_EM, w_NTT_ROM_p1_EM_n,
					w_NTT_ROM_p2_EM, w_NTT_ROM_p2_EM_n,
					w_NTT_ROM_p3_EM, w_NTT_ROM_p3_EM_n,
					w_NTT_ROM_p4_EM, w_NTT_ROM_p4_EM_n,
					w_NTT_ROM_p5_EM, w_NTT_ROM_p5_EM_n,
					w_NTT_ROM_p6_EM, w_NTT_ROM_p6_EM_n
					);


input clk;
input [7:0] instruction;
input mod_sel;
input [12:0] addra_NTT_ROM_p0_EM, addra_NTT_ROM_p0_EM_n;

output [29:0] w_NTT_ROM_p0_EM, w_NTT_ROM_p0_EM_n;
output [29:0] w_NTT_ROM_p1_EM, w_NTT_ROM_p1_EM_n;
output [29:0] w_NTT_ROM_p2_EM, w_NTT_ROM_p2_EM_n;
output [29:0] w_NTT_ROM_p3_EM, w_NTT_ROM_p3_EM_n;
output [29:0] w_NTT_ROM_p4_EM, w_NTT_ROM_p4_EM_n;
output [29:0] w_NTT_ROM_p5_EM, w_NTT_ROM_p5_EM_n;
output [29:0] w_NTT_ROM_p6_EM, w_NTT_ROM_p6_EM_n;

wire [29:0] w_NTT_ROM_q0_EM_F, w_NTT_ROM_q0_EM_n_F, w_NTT_ROM_q0_EM_B, w_NTT_ROM_q0_EM_n_B;
wire [29:0] w_NTT_ROM_q1_EM_F, w_NTT_ROM_q1_EM_n_F, w_NTT_ROM_q1_EM_B, w_NTT_ROM_q1_EM_n_B;
wire [29:0] w_NTT_ROM_q2_EM_F, w_NTT_ROM_q2_EM_n_F, w_NTT_ROM_q2_EM_B, w_NTT_ROM_q2_EM_n_B;
wire [29:0] w_NTT_ROM_q3_EM_F, w_NTT_ROM_q3_EM_n_F, w_NTT_ROM_q3_EM_B, w_NTT_ROM_q3_EM_n_B;
wire [29:0] w_NTT_ROM_q4_EM_F, w_NTT_ROM_q4_EM_n_F, w_NTT_ROM_q4_EM_B, w_NTT_ROM_q4_EM_n_B;
wire [29:0] w_NTT_ROM_q5_EM_F, w_NTT_ROM_q5_EM_n_F, w_NTT_ROM_q5_EM_B, w_NTT_ROM_q5_EM_n_B;
wire [29:0] w_NTT_ROM_q6_EM_F, w_NTT_ROM_q6_EM_n_F, w_NTT_ROM_q6_EM_B, w_NTT_ROM_q6_EM_n_B;
wire [29:0] w_NTT_ROM_q7_EM_F, w_NTT_ROM_q7_EM_n_F, w_NTT_ROM_q7_EM_B, w_NTT_ROM_q7_EM_n_B;
wire [29:0] w_NTT_ROM_q8_EM_F, w_NTT_ROM_q8_EM_n_F, w_NTT_ROM_q8_EM_B, w_NTT_ROM_q8_EM_n_B;
wire [29:0] w_NTT_ROM_q9_EM_F, w_NTT_ROM_q9_EM_n_F, w_NTT_ROM_q9_EM_B, w_NTT_ROM_q9_EM_n_B;
wire [29:0] w_NTT_ROM_q10_EM_F, w_NTT_ROM_q10_EM_n_F, w_NTT_ROM_q10_EM_B, w_NTT_ROM_q10_EM_n_B;
wire [29:0] w_NTT_ROM_q11_EM_F, w_NTT_ROM_q11_EM_n_F, w_NTT_ROM_q11_EM_B, w_NTT_ROM_q11_EM_n_B;
wire [29:0] w_NTT_ROM_q12_EM_F, w_NTT_ROM_q12_EM_n_F, w_NTT_ROM_q12_EM_B, w_NTT_ROM_q12_EM_n_B;

wire inv_mod_sel = ~mod_sel;

NTT_rom_q0 NTT_q0(
  .clka(clk),
  .ena(inv_mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q0_EM_F),
  .clkb(clk),			
  .enb(inv_mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q0_EM_n_F)	
);

inv_NTT_ROM_q0 INTT_q0(
  .clka(clk),
  .ena(inv_mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q0_EM_B),
  .clkb(clk),
  .enb(inv_mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q0_EM_n_B)
);

NTT_rom_q6 NTT_q6(
  .clka(clk),
  .ena(mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q6_EM_F),
  .clkb(clk),			
  .enb(mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q6_EM_n_F)	
);

inv_NTT_ROM_q6 INTT_q6(
  .clka(clk),
  .ena(mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q6_EM_B),
  .clkb(clk),
  .enb(mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q6_EM_n_B)
);
/////////////////////////////////
NTT_rom_q1 NTT_q1(
  .clka(clk),
  .ena(inv_mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q1_EM_F),
  .clkb(clk),			
  .enb(inv_mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q1_EM_n_F)	
);

inv_NTT_ROM_q1 INTT_q1(
  .clka(clk),
  .ena(inv_mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q1_EM_B),
  .clkb(clk),
  .enb(inv_mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q1_EM_n_B)
);

NTT_rom_q7 NTT_q7(
  .clka(clk),
  .ena(mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q7_EM_F),
  .clkb(clk),			
  .enb(mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q7_EM_n_F)	
);

inv_NTT_ROM_q7 INTT_q7(
  .clka(clk),
  .ena(mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q7_EM_B),
  .clkb(clk),
  .enb(mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q7_EM_n_B)
);
////////////////////////////////
NTT_rom_q2 NTT_q2(
  .clka(clk),
  .ena(inv_mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q2_EM_F),
  .clkb(clk),			
  .enb(inv_mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q2_EM_n_F)	
);

inv_NTT_ROM_q2 INTT_q2(
  .clka(clk),
  .ena(inv_mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q2_EM_B),
  .clkb(clk),
  .enb(inv_mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q2_EM_n_B)
);

NTT_rom_q8 NTT_q8(
  .clka(clk),
  .ena(mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q8_EM_F),
  .clkb(clk),			
  .enb(mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q8_EM_n_F)	
);

inv_NTT_ROM_q8 INTT_q8(
  .clka(clk),
  .ena(mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q8_EM_B),
  .clkb(clk),
  .enb(mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q8_EM_n_B)
);
////////////////////////////////
NTT_rom_q3 NTT_q3(
  .clka(clk),
  .ena(inv_mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q3_EM_F),
  .clkb(clk),			
  .enb(inv_mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q3_EM_n_F)	
);

inv_NTT_ROM_q3 INTT_q3(
  .clka(clk),
  .ena(inv_mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q3_EM_B),
  .clkb(clk),
  .enb(inv_mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q3_EM_n_B)
);

NTT_rom_q9 NTT_q9(
  .clka(clk),
  .ena(mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q9_EM_F),
  .clkb(clk),			
  .enb(mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q9_EM_n_F)	
);

inv_NTT_ROM_q9 INTT_q9(
  .clka(clk),
  .ena(mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q9_EM_B),
  .clkb(clk),
  .enb(mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q9_EM_n_B)
);
////////////////////////////////
NTT_rom_q4 NTT_q4(
  .clka(clk),
  .ena(inv_mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q4_EM_F),
  .clkb(clk),			
  .enb(inv_mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q4_EM_n_F)	
);

inv_NTT_ROM_q4 INTT_q4(
  .clka(clk),
  .ena(inv_mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q4_EM_B),
  .clkb(clk),
  .enb(inv_mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q4_EM_n_B)
);

NTT_rom_q10 NTT_q10(
  .clka(clk),
  .ena(mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q10_EM_F),
  .clkb(clk),			
  .enb(mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q10_EM_n_F)	
);

inv_NTT_ROM_q10 INTT_q10(
  .clka(clk),
  .ena(mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q10_EM_B),
  .clkb(clk),
  .enb(mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q10_EM_n_B)
);
////////////////////////////////
NTT_rom_q5 NTT_q5(
  .clka(clk),
  .ena(inv_mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q5_EM_F),
  .clkb(clk),			
  .enb(inv_mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q5_EM_n_F)	
);

inv_NTT_ROM_q5 INTT_q5(
  .clka(clk),
  .ena(inv_mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q5_EM_B),
  .clkb(clk),
  .enb(inv_mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q5_EM_n_B)
);

NTT_rom_q11 NTT_q11(
  .clka(clk),
  .ena(mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q11_EM_F),
  .clkb(clk),			
  .enb(mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q11_EM_n_F)	
);

inv_NTT_ROM_q11 INTT_q11(
  .clka(clk),
  .ena(mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q11_EM_B),
  .clkb(clk),
  .enb(mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q11_EM_n_B)
);
////////////////////////////////
NTT_rom_q12 NTT_q12(
  .clka(clk),
  .ena(mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q12_EM_F),
  .clkb(clk),			
  .enb(mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q12_EM_n_F)	
);

inv_NTT_ROM_q12 INTT_q12(
  .clka(clk),
  .ena(mod_sel),
  .addra(addra_NTT_ROM_p0_EM),
  .douta(w_NTT_ROM_q12_EM_B),
  .clkb(clk),
  .enb(mod_sel),
  .addrb(addra_NTT_ROM_p0_EM_n),
  .doutb(w_NTT_ROM_q12_EM_n_B)
);


assign {w_NTT_ROM_p0_EM, w_NTT_ROM_p0_EM_n} = (instruction[0]==1'b0 && mod_sel==1'b0) ? {w_NTT_ROM_q0_EM_B, w_NTT_ROM_q0_EM_n_B}:
                                              (instruction[0]==1'b1 && mod_sel==1'b0) ? {w_NTT_ROM_q0_EM_F, w_NTT_ROM_q0_EM_n_F}:
                                              (instruction[0]==1'b0 && mod_sel==1'b1) ? {w_NTT_ROM_q6_EM_B, w_NTT_ROM_q6_EM_n_B}:
                                              (instruction[0]==1'b1 && mod_sel==1'b1) ? {w_NTT_ROM_q6_EM_F, w_NTT_ROM_q6_EM_n_F}:
                                                                                      {w_NTT_ROM_q6_EM_F, w_NTT_ROM_q6_EM_n_F};

assign {w_NTT_ROM_p1_EM, w_NTT_ROM_p1_EM_n} = (instruction[0]==1'b0 && mod_sel==1'b0) ? {w_NTT_ROM_q1_EM_B, w_NTT_ROM_q1_EM_n_B}:
                                              (instruction[0]==1'b1 && mod_sel==1'b0) ? {w_NTT_ROM_q1_EM_F, w_NTT_ROM_q1_EM_n_F}:
                                              (instruction[0]==1'b0 && mod_sel==1'b1) ? {w_NTT_ROM_q7_EM_B, w_NTT_ROM_q7_EM_n_B}:
                                              (instruction[0]==1'b1 && mod_sel==1'b1) ? {w_NTT_ROM_q7_EM_F, w_NTT_ROM_q7_EM_n_F}:
                                                                                      {w_NTT_ROM_q7_EM_F, w_NTT_ROM_q7_EM_n_F};

assign {w_NTT_ROM_p2_EM, w_NTT_ROM_p2_EM_n} = (instruction[0]==1'b0 && mod_sel==1'b0) ? {w_NTT_ROM_q2_EM_B, w_NTT_ROM_q2_EM_n_B}:
                                              (instruction[0]==1'b1 && mod_sel==1'b0) ? {w_NTT_ROM_q2_EM_F, w_NTT_ROM_q2_EM_n_F}:
                                              (instruction[0]==1'b0 && mod_sel==1'b1) ? {w_NTT_ROM_q8_EM_B, w_NTT_ROM_q8_EM_n_B}:
                                              (instruction[0]==1'b1 && mod_sel==1'b1) ? {w_NTT_ROM_q8_EM_F, w_NTT_ROM_q8_EM_n_F}:
                                                                                      {w_NTT_ROM_q8_EM_F, w_NTT_ROM_q8_EM_n_F};

assign {w_NTT_ROM_p3_EM, w_NTT_ROM_p3_EM_n} = (instruction[0]==1'b0 && mod_sel==1'b0) ? {w_NTT_ROM_q3_EM_B, w_NTT_ROM_q3_EM_n_B}:
                                              (instruction[0]==1'b1 && mod_sel==1'b0) ? {w_NTT_ROM_q3_EM_F, w_NTT_ROM_q3_EM_n_F}:
                                              (instruction[0]==1'b0 && mod_sel==1'b1) ? {w_NTT_ROM_q9_EM_B, w_NTT_ROM_q9_EM_n_B}:
                                              (instruction[0]==1'b1 && mod_sel==1'b1) ? {w_NTT_ROM_q9_EM_F, w_NTT_ROM_q9_EM_n_F}:
                                                                                      {w_NTT_ROM_q9_EM_F, w_NTT_ROM_q9_EM_n_F};

assign {w_NTT_ROM_p4_EM, w_NTT_ROM_p4_EM_n} = (instruction[0]==1'b0 && mod_sel==1'b0) ? {w_NTT_ROM_q4_EM_B, w_NTT_ROM_q4_EM_n_B}:
                                              (instruction[0]==1'b1 && mod_sel==1'b0) ? {w_NTT_ROM_q4_EM_F, w_NTT_ROM_q4_EM_n_F}:
                                              (instruction[0]==1'b0 && mod_sel==1'b1) ? {w_NTT_ROM_q10_EM_B, w_NTT_ROM_q10_EM_n_B}:
                                              (instruction[0]==1'b1 && mod_sel==1'b1) ? {w_NTT_ROM_q10_EM_F, w_NTT_ROM_q10_EM_n_F}:
                                                                                      {w_NTT_ROM_q10_EM_F, w_NTT_ROM_q10_EM_n_F};

assign {w_NTT_ROM_p5_EM, w_NTT_ROM_p5_EM_n} = (instruction[0]==1'b0 && mod_sel==1'b0) ? {w_NTT_ROM_q5_EM_B, w_NTT_ROM_q5_EM_n_B}:
                                              (instruction[0]==1'b1 && mod_sel==1'b0) ? {w_NTT_ROM_q5_EM_F, w_NTT_ROM_q5_EM_n_F}:
                                              (instruction[0]==1'b0 && mod_sel==1'b1) ? {w_NTT_ROM_q11_EM_B, w_NTT_ROM_q11_EM_n_B}:
                                              (instruction[0]==1'b1 && mod_sel==1'b1) ? {w_NTT_ROM_q11_EM_F, w_NTT_ROM_q11_EM_n_F}:
                                                                                      {w_NTT_ROM_q11_EM_F, w_NTT_ROM_q11_EM_n_F};

assign {w_NTT_ROM_p6_EM, w_NTT_ROM_p6_EM_n} = (instruction[0]==1'b0) ? {w_NTT_ROM_q12_EM_B, w_NTT_ROM_q12_EM_n_B}
                                                                     : {w_NTT_ROM_q12_EM_F, w_NTT_ROM_q12_EM_n_F};


endmodule
/*
module NTT_ROM(clk, instruction, addra_NTT_ROM_p0_EM, addra_NTT_ROM_p0_EM_n, 
					w_NTT_ROM_p0_EM, w_NTT_ROM_p0_EM_n);

input clk;
input [7:0] instruction;
input [12:0] addra_NTT_ROM_p0_EM, addra_NTT_ROM_p0_EM_n;
output [29:0] w_NTT_ROM_p0_EM, w_NTT_ROM_p0_EM_n;

wire [29:0] w_NTT_ROM_p0_EM_F, w_NTT_ROM_p0_EM_n_F;
wire [29:0] w_NTT_ROM_p0_EM_B, w_NTT_ROM_p0_EM_n_B;


NTT_rom_q6 NTT_ROM_p0(
  .clka(clk), 							// input clka
  .ena(1'b1),
  .addra(addra_NTT_ROM_p0_EM), 	// input [11 : 0] addra
  .douta(w_NTT_ROM_p0_EM_F), 		// output [29 : 0] douta
  .clkb(clk), 							// input clkb
  .enb(1'b1),
  .addrb(addra_NTT_ROM_p0_EM_n), // input [11 : 0] addrb
  .doutb(w_NTT_ROM_p0_EM_n_F) 		// output [29 : 0] doutb
);

inv_NTT_ROM_q6 inv_NTT_ROM_p0(
  .clka(clk), 							// input clka
  .ena(1'b1),
  .addra(addra_NTT_ROM_p0_EM), 	// input [12 : 0] addra
  .douta(w_NTT_ROM_p0_EM_B), 		// output [29 : 0] douta
  .clkb(clk), 							// input clkb
  .enb(1'b1),
  .addrb(addra_NTT_ROM_p0_EM_n), // input [12 : 0] addrb
  .doutb(w_NTT_ROM_p0_EM_n_B) 	// output [29 : 0] doutb
);

assign {w_NTT_ROM_p0_EM, w_NTT_ROM_p0_EM_n} = (instruction[0]==1'b0) ? {w_NTT_ROM_p0_EM_B, w_NTT_ROM_p0_EM_n_B}
                                                                     : {w_NTT_ROM_p0_EM_F, w_NTT_ROM_p0_EM_n_F};

endmodule
*/

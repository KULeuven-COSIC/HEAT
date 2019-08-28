`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/25/2018 12:15:05 PM
// Design Name: 
// Module Name: scale_a_shares
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


module scale_a_shares(clk, rst, mode, start, rd_addr, coeff_in,
                      wt_addr, we, coeff_out);
input clk;
input rst;
input mode;             // If 0 then small lift (6 input coeff); If 1 then big ligt (7 input coeff);
input start;            // This signal is set 1 after input data is ready.

output [2:0] rd_addr;      // Coefficients are assumed to be in a RAM.
input [29:0] coeff_in;  // A coefficient arrives one cycle after address.

output [2:0] wt_addr;       // write address for output values
output we;                  // write enable for output values
output [29:0] coeff_out;    // output coefficients


reg [3:0] modulus_sel_r0, modulus_sel_r1, modulus_sel_r2, modulus_sel_r3, modulus_sel_r4;
wire [3:0] modulus_sel;
wire [3:0] modulus_sel_base;

reg [2:0] rd_addr;
reg [2:0] wt_addr_r0, wt_addr_r1, wt_addr_r2, wt_addr_r3, wt_addr_r4, wt_addr_r5, wt_addr_r6, wt_addr_r7;
reg we_r0, we_r1, we_r2, we_r3, we_r4, we_r5, we_r6, we_r7;

wire [29:0] scale_constant;
wire [5:0] ROM_addr;

wire [29:0] mul_in1, mul_in2;
wire [59:0] mul_out;
reg [59:0] mul_out_r;
wire [29:0] mod_out;

assign ROM_addr = {mode, 2'b00, rd_addr};  // First 6 constants are in address {0-5} and last 7 are in address {32-38}

ROM_scaling ROM_scale(.a(ROM_addr), .clk(clk), .qspo(scale_constant));

/////////// Modular Multiplier /////////
assign mul_in1 = coeff_in;
assign mul_in2 = scale_constant;
dsp_mult mul(.CLK(clk), .A(mul_in1), .B(mul_in2), .P(mul_out)); 
always @(posedge clk)
mul_out_r <= mul_out;
windowed_reduction60bit_q_select mod(clk, modulus_sel, mul_out_r, mod_out);


always @(posedge clk)
begin
    if(rst)
        rd_addr <= 3'd0;
    else if( rd_addr==3'd6)
        rd_addr <= 3'd0;        
    //else if(mode==1'b1 && rd_addr==3'd6)
    //    rd_addr <= 3'd0;    
    else if(start)
        rd_addr <= rd_addr + 1'b1;
    else    
        rd_addr <= 3'd0;
end


// Pipeline of modulus_sel
assign modulus_sel_base = (mode) ? 3'd6 : 3'd0;
always @(posedge clk)
begin
    modulus_sel_r0 <= rd_addr + modulus_sel_base;
    modulus_sel_r1 <= modulus_sel_r0;
    modulus_sel_r2 <= modulus_sel_r1;
    modulus_sel_r3 <= modulus_sel_r2;
    modulus_sel_r4 <= modulus_sel_r3;
end
assign modulus_sel = modulus_sel_r4;


// Pipeline of wt_addr
always @(posedge clk)
begin
    wt_addr_r0 <= rd_addr;
    wt_addr_r1 <= wt_addr_r0;
    wt_addr_r2 <= wt_addr_r1;
    wt_addr_r3 <= wt_addr_r2;
    wt_addr_r4 <= wt_addr_r3;
    wt_addr_r5 <= wt_addr_r4;
    wt_addr_r6 <= wt_addr_r5;
    wt_addr_r7 <= wt_addr_r6;
end

// Pipeline for write enable
always @(posedge clk)
begin
    we_r0 <= start;
    we_r1 <= we_r0;
    we_r2 <= we_r1;
    we_r3 <= we_r2;    
    we_r4 <= we_r3;
    we_r5 <= we_r4;
    we_r6 <= we_r5;
    we_r7 <= we_r6;
end


assign wt_addr = wt_addr_r7; 
assign we = we_r7; 
assign coeff_out = mod_out;
                        
endmodule

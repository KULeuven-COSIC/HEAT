`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:08:35 09/01/2017 
// Design Name: 
// Module Name:    instruction_gen 
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
module instruction_gen(clk, start_eth, program_data_eth, program_address_eth, program_data_load_eth,
                       instruction, operand1, operand2, processor_sel, memory_sel, modulus_sel,
							  instruction_computation_executed, instruction_ddr_executed);
input clk;
input start_eth;
input [59:0] program_data_eth;
input [10:0] program_address_eth;
input program_data_load_eth;

output [7:0] instruction;
output [7:0] operand1, operand2;
output [2:0] processor_sel;
output [3:0] memory_sel;
output modulus_sel; 
input instruction_computation_executed, instruction_ddr_executed;


reg [10:0] program_address;
wire [31:0] program_word;
reg [31:0] program_word_reg;
reg [2:0] state, nextstate;

// control signals
reg rst_program_address, inc_program_address;
reg instruction_en;
wire instruction_halt;
wire instruction_executed;

//assign instruction = (instruction_en) ? program_word[7:0] : 8'd0;
assign instruction = program_word_reg[7:0];
assign operand1 = program_word_reg[15:8];
assign operand2 = program_word_reg[23:16];
assign processor_sel =  program_word_reg[26:24];
assign memory_sel = program_word_reg[30:27];
assign modulus_sel = program_word_reg[31];

assign instruction_halt = (instruction==8'd255) ? 1'b1 : 1'b0;

assign instruction_executed = (instruction==8'd3 || instruction==8'd4) ? instruction_ddr_executed : instruction_computation_executed;

program_memory PROGRAM(
						  .clka(clk), // input clka
						  .wea(program_data_load_eth), // input [0 : 0] wea
						  .addra(program_address_eth), // input [10 : 0] addra
						  .dina(program_data_eth[31:0]), // input [31 : 0] dina

						  .clkb(clk), // input clkb
						  .addrb(program_address), // input [10 : 0] addrb
						  .doutb(program_word) // output [15 : 0] doutb
						);

always @(posedge clk)
begin
	if(start_eth==1'b0)
		program_word_reg <= 32'd0;
	else if(instruction_en)
		program_word_reg <= program_word;
	else if(state==3'd4 || state==3'd7)
		program_word_reg <= 32'd0;
	else		
		program_word_reg <= program_word;
end
		
always @(posedge clk)
begin
	if(start_eth==1'b0)
		program_address <= 11'd0;
	else if(rst_program_address)
		program_address <= 11'd0;	
	else if(inc_program_address)
		program_address <= program_address + 1'b1;
	else
		program_address <= program_address;
end		
						
always @(posedge clk)
begin
	if(start_eth==1'b0)
		state <= 3'd0;
	else 
		state <= nextstate;
end

always @(state or instruction or instruction_executed or instruction_halt)
begin
	case(state)
	3'd0:begin
			rst_program_address<=1'b1; inc_program_address<=1'b0; instruction_en<=1'b0;	
		end


	3'd1:begin		// Provide program address;
			rst_program_address<=1'b0; inc_program_address<=1'b0; instruction_en<=1'b0;	
		end
	3'd2:begin		// Enable instruction
			rst_program_address<=1'b0; inc_program_address<=1'b0; instruction_en<=1'b1;	
		end
	3'd3:begin		// Wait for instruction to finish
			rst_program_address<=1'b0; instruction_en<=1'b1;
			if(instruction==8'd0 || (instruction_executed==1'b1 && instruction_halt!=1)) 
			inc_program_address<=1'b1; 
			else inc_program_address<=1'b0;  	
		end
	3'd4:begin		// Increment program address
			rst_program_address<=1'b0; inc_program_address<=1'b0; instruction_en<=1'b0;	
		end


	3'd7:begin
			rst_program_address<=1'b1; inc_program_address<=1'b0; instruction_en<=1'b0;	
		end
	default:begin
			rst_program_address<=1'b1; inc_program_address<=1'b0; instruction_en<=1'b0;	
		end		
	endcase
end

always @(state or instruction or instruction_executed or instruction_halt)
begin
	case(state)
	3'd0: nextstate <= 3'd1;
	3'd1: nextstate <= 3'd2;
	3'd2: nextstate <= 3'd3;
	3'd3: begin
				if(instruction_halt)
					nextstate <= 3'd7;	
				else if(instruction==8'd0)
					nextstate <= 3'd4;				
				else if(instruction_executed)
					nextstate <= 3'd4;
				else
					nextstate <= 3'd3;
			end
	3'd4: nextstate <= 3'd1;			

	3'd7: nextstate <= 3'd7;
	default: nextstate <= 3'd0;	
	endcase
end



endmodule

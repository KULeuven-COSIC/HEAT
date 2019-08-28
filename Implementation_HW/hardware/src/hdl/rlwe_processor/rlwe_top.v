`timescale 1ns / 1ps

/*	-----------------DESCRIPTION-------------------------- 

This module emulates a micro-controller in the master mode and interacts with the ring-LWE coprocessor
and an LFSR based PRNG. This module is similar to a test-bench and provides necessary data and 
instructions to the ring-LWE coprocessor. In an actual hardware implementation, the LFSR-based PRNG 
should be replaced by a TRNG or a better PRNG. In this package, we are not providing any HDL codes for 
the TRNG. For area and timing report, please compile the ring-LWE coprocessor part (not the emulator).

A valid public key and a secret key are stored in the NTT format within this module. 
The module requests the following computations:
1) Load the public key in the RAM
2) Load the message in the RAM
3) Generate error polynomials in the RAM
4) Perform the steps of the message encryption

After completion of an encryption operation, the module requests decryption operation using the secret key. 
All of the steps are described in the code.

During compilation of the RLWE_processor module, there will be several warnings. These warnings appear 
due presence of several signals which are kept for increasing the number of pipeline stages. Since these
signals remain unconnected, warnings are displayed by the compiler.

---------------------------------------------------------*/


module rlwe_top #(parameter core_index=1'b1)
					(clk, modulus_sel, rst, instruction,
					 data_load, in1, in2, message_bit,
					 initiate_loading_r2,
					 rdMsel, wtMsel, 

					 ram_write_en_p0, write_address_p0, read_address_p0,
					 ram_write_en_p1, write_address_p1, read_address_p1,
					 ram_write_en_p2, write_address_p2, read_address_p2,
					 ram_write_en_p3, write_address_p3, read_address_p3,
					 ram_write_en_p4, write_address_p4, read_address_p4,
					 ram_write_en_p5, write_address_p5, read_address_p5,
					 ram_write_en_p6, write_address_p6, read_address_p6,
					 
					 random_enable, random,
					 
					 din_high_p0, din_low_p0, doutb_p0,
				 	 din_high_p1, din_low_p1, doutb_p1,
				 	 din_high_p2, din_low_p2, doutb_p2,
					 din_high_p3, din_low_p3, doutb_p3,
				 	 din_high_p4, din_low_p4, doutb_p4,
				 	 din_high_p5, din_low_p5, doutb_p5,
				 	 din_high_p6, din_low_p6, doutb_p6,
					 
					 addra_NTT_ROM_p0, 
					 w_NTT_ROM_p0, w_NTT_ROM_p1, w_NTT_ROM_p2, w_NTT_ROM_p3, w_NTT_ROM_p4, w_NTT_ROM_p5, w_NTT_ROM_p6,					 
					 computation_done
					 
					 /*state, doutH, doutL, message_bit_H, message_bit_L, readon, computation_done*/
					 );
					
input clk, modulus_sel, rst;	//modulus_sel==0 then q0 to q5 else q6 to q12
input [7:0] instruction;
input data_load;
input [29:0] in1, in2;
input message_bit;
output initiate_loading_r2; 			// this signal is used by the rlwe_processor to inform top for loading r2

output [1:0] rdMsel, wtMsel;						
output ram_write_en_p0;
output [10:0] write_address_p0, read_address_p0;
output ram_write_en_p1;
output [10:0] write_address_p1, read_address_p1;
output ram_write_en_p2;
output [10:0] write_address_p2, read_address_p2;
output ram_write_en_p3;
output [10:0] write_address_p3, read_address_p3;
output ram_write_en_p4;
output [10:0] write_address_p4, read_address_p4;
output ram_write_en_p5;
output [10:0] write_address_p5, read_address_p5;
output ram_write_en_p6;
output [10:0] write_address_p6, read_address_p6;

output random_enable;
input [8:0] random;

output [29:0] din_high_p0, din_low_p0;
input  [59:0] doutb_p0; 
output [29:0] din_high_p1, din_low_p1;
input  [59:0] doutb_p1; 
output [29:0] din_high_p2, din_low_p2;
input  [59:0] doutb_p2; 
output [29:0] din_high_p3, din_low_p3;
input  [59:0] doutb_p3; 
output [29:0] din_high_p4, din_low_p4;
input  [59:0] doutb_p4; 
output [29:0] din_high_p5, din_low_p5;
input  [59:0] doutb_p5; 
output [29:0] din_high_p6, din_low_p6;
input  [59:0] doutb_p6; 

output [12:0] addra_NTT_ROM_p0;
input [29:0] w_NTT_ROM_p0, w_NTT_ROM_p1, w_NTT_ROM_p2, w_NTT_ROM_p3, w_NTT_ROM_p4, w_NTT_ROM_p5, w_NTT_ROM_p6;

output computation_done;


wire [29:0] din_ntH, din_ntL;
wire done_nt;

reg wea_em, enable_nc, enable_ac, enable_ld, enable_crt;
wire [29:0] in1, in2;
reg [5:0] state, nextstate;
reg add_conv;
reg load_pause;
reg [1:0] INSTRUCTION_ld, INSTRUCTION_nc, NTT_ITERATION;

reg [2:0] RdQIn, WtQIn;
reg RdQen, WtQen;
wire [1:0] RdQsel, WtQsel;


wire [1:0] rdMsel, wtMsel;						// memory control signals

wire ram_write_en_p0;
wire [10:0] read_address_p0, write_address_p0;
wire ram_write_en_p1;
wire [10:0] read_address_p1, write_address_p1;
wire ram_write_en_p2;
wire [10:0] read_address_p2, write_address_p2;
wire ram_write_en_p3;
wire [10:0] read_address_p3, write_address_p3;
wire ram_write_en_p4;
wire [10:0] read_address_p4, write_address_p4;
wire ram_write_en_p5;
wire [10:0] read_address_p5, write_address_p5;
wire ram_write_en_p6;
wire [10:0] read_address_p6, write_address_p6;

wire [29:0] din_high, din_low;
wire  [59:0] doutb; 

wire random_enable;
wire [8:0] random;



rlwe_processor #(core_index)NT 
				   (
					clk, modulus_sel, ~enable_ld, ~enable_ac, ~enable_nc, ~enable_crt,
					INSTRUCTION_ld, INSTRUCTION_nc, NTT_ITERATION, add_conv,
					
					rdMsel, wtMsel,
					
					ram_write_en_p0, write_address_p0, read_address_p0, 
					ram_write_en_p1, write_address_p1, read_address_p1,
					ram_write_en_p2, write_address_p2, read_address_p2,
					ram_write_en_p3, write_address_p3, read_address_p3,
					ram_write_en_p4, write_address_p4, read_address_p4,
					ram_write_en_p5, write_address_p5, read_address_p5,
					ram_write_en_p6, write_address_p6, read_address_p6,
					
					din_high_p0, din_low_p0, doutb_p0,
					din_high_p1, din_low_p1, doutb_p1,
					din_high_p2, din_low_p2, doutb_p2,
					din_high_p3, din_low_p3, doutb_p3,
				 	din_high_p4, din_low_p4, doutb_p4,
				 	din_high_p5, din_low_p5, doutb_p5,
					din_high_p6, din_low_p6, doutb_p6,
					addra_NTT_ROM_p0, 
					w_NTT_ROM_p0, w_NTT_ROM_p1, w_NTT_ROM_p2, w_NTT_ROM_p3, w_NTT_ROM_p4, w_NTT_ROM_p5, w_NTT_ROM_p6,
					done_nt  
					);

//lfsr	RND_source(clk, ~enable_ld, random_enable, random);


always @(posedge clk)
begin
	if(rst)
		state <= 6'd0;
	else
		state <= nextstate;
end	



assign initiate_loading_r2 = (state==6'd33) ? 1'b1 : 1'b0;

always @(state or data_load)
begin
case(state)
	6'd0: begin 
		enable_ld<=0; enable_nc<=0; enable_ac<=0; add_conv<=0; load_pause<=0; enable_crt<=0;
		INSTRUCTION_ld<=2'd0; INSTRUCTION_nc<=2'd0; NTT_ITERATION<=2'd0;
	end



	6'd1: begin // Rearrange M0
		enable_ld<=0; enable_nc<=1; enable_ac<=0; add_conv<=0; load_pause<=0; enable_crt<=0;
		INSTRUCTION_ld<=2'd0; INSTRUCTION_nc<=2'd2; NTT_ITERATION<=2'd0; 
	end

	6'd2: begin // FFT(M0)
		enable_ld<=0; enable_nc<=1; enable_ac<=0; add_conv<=0; load_pause<=0; enable_crt<=0;
		INSTRUCTION_ld<=2'd0; INSTRUCTION_nc<=2'd0; NTT_ITERATION<=2'd0; 
	end

	6'd3: begin // IFFT(M0)
		enable_ld<=0; enable_nc<=1; enable_ac<=0; add_conv<=0; load_pause<=0; enable_crt<=0;
		INSTRUCTION_ld<=2'd0; INSTRUCTION_nc<=2'd1; NTT_ITERATION<=2'd0; 
	end

	6'd4: begin // coefficientwise multiplication; M0<--M0*M1
		enable_ld<=0; enable_nc<=0; enable_ac<=1; add_conv<=1; load_pause<=0; enable_crt<=0;
		INSTRUCTION_ld<=2'd0; INSTRUCTION_nc<=2'd0; NTT_ITERATION<=2'd0; 
	end

	6'd5: begin // coefficientwise addition; M0<--M0+M1
		enable_ld<=0; enable_nc<=0; enable_ac<=1; add_conv<=0; load_pause<=0; enable_crt<=0;
		INSTRUCTION_ld<=2'd0; INSTRUCTION_nc<=2'd0; NTT_ITERATION<=2'd0; 
	end	


	
	6'd63: begin 	// END State
		enable_ld<=0; enable_nc<=0; enable_ac<=0; add_conv<=0; load_pause<=0; enable_crt<=0;
		INSTRUCTION_ld<=2'd0; INSTRUCTION_nc<=2'd0; NTT_ITERATION<=2'd0;
	end
	default: begin 	// END State
		enable_ld<=0; enable_nc<=0; enable_ac<=0; add_conv<=0; load_pause<=0; enable_crt<=0;
		INSTRUCTION_ld<=2'd0; INSTRUCTION_nc<=2'd0; NTT_ITERATION<=2'd0; 
	end
	endcase
end	
		
always @(state or instruction or done_nt or core_index)
begin
	case(state)
	6'd0 : begin
				if(instruction==8'd16 && core_index==1'b0)
					nextstate <= 6'd1;
				else if(instruction==8'd17)
					nextstate <= 6'd2;
				else if(instruction==8'd18)
					nextstate <= 6'd3;	
				else if(instruction==8'd19)
					nextstate <= 6'd4;
				else if(instruction==8'd20)
					nextstate <= 6'd5;		
				else
					nextstate <= 6'd0;				
			end
			
			
	6'd1 : begin
				if(done_nt)
					nextstate <= 6'd63;
				else
					nextstate <= 6'd1;
			end
	6'd2 : begin
				if(done_nt)
					nextstate <= 6'd63;
				else
					nextstate <= 6'd2;
			end
	6'd3 : begin
				if(done_nt)
					nextstate <= 6'd63;
				else
					nextstate <= 6'd3;
			end
	6'd4 : begin
				if(done_nt)
					nextstate <= 6'd63;
				else
					nextstate <= 6'd4;
			end
	6'd5 : begin
				if(done_nt)
					nextstate <= 6'd63;
				else
					nextstate <= 6'd5;
			end
			
	6'd63 : nextstate <= 6'd63; 
	default : nextstate <= 6'd63; 	
	endcase
end

assign computation_done = (state==6'd63) ? 1'b1 : 1'b0;
	
endmodule

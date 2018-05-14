`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:02:05 02/21/2018 
// Design Name: 
// Module Name:    lift_control 
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
(* keep_hierarchy = "yes" *) 
module lift_control_parallel_cores4(
                            clk, rst, instruction, MemR0, MemR1, MemW0, MemW1,
                     processor_sel, memory_sel, bram_address, bram_we,
                            lift_data_in, lift_data_out,
                            done
                        );

input clk;                         // computation clock
input rst;                        // system reset when 1
input [7:0] instruction;
input [3:0] MemR0, MemR1, MemW0, MemW1; // Memory select options for read and write;

output [2:0] processor_sel;
output [3:0] memory_sel;            // Memory selected for read or write
output [8:0] bram_address;          // 0-511 address of the i/o buffer of Lift unit.
input [239:0] lift_data_in;
output [239:0] lift_data_out;

output bram_we;
output done;


reg [8:0] bram_read_address, bram_write_address;
wire inc_bram_read_address, inc_bram_write_address, bram_write_over;
wire data_loading_ibuff_over, BRAM_read_states, BRAM_write_states;
reg [1:0] lift_core_sel;

reg second_iteration;    // This flag is used during Large CRT data loading. First iteration processor_sel 0 to 5; second iteration 0 to 6;
reg second_iteration2;  // This flag is used during large CRT with decomposition reduction to write back results

wire last_lift_operation;

reg [5:0] state, nextstate;

assign bram_address = (BRAM_read_states) ? bram_read_address : bram_write_address;

assign memory_sel =     (BRAM_read_states==1'b1 && second_iteration==1'b0) ? MemR0 :
                            (BRAM_read_states==1'b1 && second_iteration==1'b1) ? MemR1 :
                            (BRAM_write_states==1'b1 && second_iteration2==1'b0) ? MemW0 : MemW1;

always @(posedge clk)
begin
    if(rst)
        bram_read_address <= 9'd0;
    else if(inc_bram_read_address)
        bram_read_address <= bram_read_address + 1'b1;
    else
        bram_read_address <= bram_read_address;
end
always @(posedge clk)
begin
    if(rst)
        bram_write_address <= 9'd0;
    else if(inc_bram_write_address)
        bram_write_address <= bram_write_address + 1'b1;
    else
        bram_write_address <= bram_write_address;
end


always @(posedge clk)
begin
    if(rst)
        state <= 6'd0;
    else
        state <= nextstate;
end

wire reduction_type = (instruction==8'd7) ? 1'b1 : 1'b0;
wire data_type = (instruction==8'd5) ? 1'b1 : 1'b0;

wire [239:0] lift_data_in, lift_data_out, lift_data_out_core0, lift_data_out_core1, lift_data_out_core2, lift_data_out_core3;
wire lift_done, lift_done_core0, lift_done_core1, lift_done_core2, lift_done_core3;

reg rst_lift, lift_buffer_we, data_valid, inc_processor_sel;
reg [5:0] lift_buffer_address;
reg [2:0] processor_sel;
reg rst_lift_buffer_address, inc_lift_buffer_address, bram_we;
reg lift_done_core0_reg, lift_done_core1_reg, lift_done_core2_reg, lift_done_core3_reg;
reg [3:0] wait_counter;
wire wait_over;

wire lift_buffer_we_core0, lift_buffer_we_core1, lift_buffer_we_core2, lift_buffer_we_core3;

assign lift_data_out = (lift_core_sel==2'd0) ? lift_data_out_core0
                            : (lift_core_sel==2'd1) ? lift_data_out_core1
                            : (lift_core_sel==2'd2) ? lift_data_out_core2
                            : lift_data_out_core3;

assign lift_done = lift_done_core0_reg & lift_done_core1_reg & lift_done_core2_reg & lift_done_core3_reg;
assign lift_buffer_we_core0 = (lift_buffer_we==1'b1 && lift_core_sel==2'd0) ? 1'b1 : 1'b0;
assign lift_buffer_we_core1 = (lift_buffer_we==1'b1 && lift_core_sel==2'd1) ? 1'b1 : 1'b0;
assign lift_buffer_we_core2 = (lift_buffer_we==1'b1 && lift_core_sel==2'd2) ? 1'b1 : 1'b0;
assign lift_buffer_we_core3 = (lift_buffer_we==1'b1 && lift_core_sel==2'd3) ? 1'b1 : 1'b0;

lift_wrapper LW_core0(clk, rst_lift, reduction_type, lift_buffer_address, lift_buffer_we_core0, lift_data_in, data_type, data_valid,
                lift_data_out_core0, lift_done_core0);

lift_wrapper LW_core1(clk, rst_lift, reduction_type, lift_buffer_address, lift_buffer_we_core1, lift_data_in, data_type, data_valid,
                lift_data_out_core1, lift_done_core1);

lift_wrapper LW_core2(clk, rst_lift, reduction_type, lift_buffer_address, lift_buffer_we_core2, lift_data_in, data_type, data_valid,
                lift_data_out_core2, lift_done_core2);

lift_wrapper LW_core3(clk, rst_lift, reduction_type, lift_buffer_address, lift_buffer_we_core3, lift_data_in, data_type, data_valid,
                lift_data_out_core3, lift_done_core3);


always @(posedge clk)
begin
    if(state==6'd5 && lift_done_core0_reg==1'b1)
        lift_done_core0_reg <= 1'b1;
    else if(state==6'd5)
        lift_done_core0_reg <= lift_done_core0;
    else
        lift_done_core0_reg <= 1'b0;
end
always @(posedge clk)
begin
    if(state==6'd5 && lift_done_core1_reg==1'b1)
        lift_done_core1_reg <= 1'b1;
    else if(state==6'd5)
        lift_done_core1_reg <= lift_done_core1;
    else
        lift_done_core1_reg <= 1'b0;
end
always @(posedge clk)
begin
    if(state==6'd5 && lift_done_core2_reg==1'b1)
        lift_done_core2_reg <= 1'b1;
    else if(state==6'd5)
        lift_done_core2_reg <= lift_done_core2;
    else
        lift_done_core2_reg <= 1'b0;
end
always @(posedge clk)
begin
    if(state==6'd5 && lift_done_core3_reg==1'b1)
        lift_done_core3_reg <= 1'b1;
    else if(state==6'd5)
        lift_done_core3_reg <= lift_done_core3;
    else
        lift_done_core3_reg <= 1'b0;
end

always @(posedge clk)
begin
    if(rst_lift_buffer_address)
        lift_buffer_address <= 6'd0;
    else if(inc_lift_buffer_address)
        lift_buffer_address <= lift_buffer_address + 1'b1;
    else
        lift_buffer_address <= lift_buffer_address;
end

always @(posedge clk)
begin
    if(rst)
        processor_sel <= 3'd0;
    else if(data_type==1'b1 && processor_sel==3'd5 && inc_processor_sel==1'b1 && BRAM_read_states==1'b1)
        processor_sel <= 3'd0;
    else if(data_type==1'b1 && processor_sel==3'd6 && inc_processor_sel==1'b1 && BRAM_write_states==1'b1)
        processor_sel <= 3'd0;
    else if(data_type==1'b0 && processor_sel==3'd5 && inc_processor_sel==1'b1 && ((second_iteration==1'b0 && BRAM_read_states==1'b1)|(second_iteration2==1'b0 && BRAM_write_states==1'b1)) )
        processor_sel <= 3'd0;
    else if(data_type==1'b0 && inc_processor_sel==1'b1 && ((processor_sel==3'd6 && second_iteration==1'b1 && BRAM_read_states==1'b1)|(processor_sel==3'd5 && second_iteration2==1'b1 && BRAM_write_states==1'b1)) )
        processor_sel <= 3'd0;
    else if(inc_processor_sel)
        processor_sel <= processor_sel + 1'b1;
    else
        processor_sel <= processor_sel;
end

assign inc_bram_read_address = ((data_type==1'b1 && processor_sel==3'd5 && lift_buffer_we==1'b1 && BRAM_read_states==1'b1) ||
                               (data_type==1'b0 && processor_sel==3'd6 && lift_buffer_we==1'b1 && BRAM_read_states==1'b1)) ? 1'b1 : 1'b0;

assign inc_bram_write_address = ((data_type==1'b1 && processor_sel==3'd6 && bram_we==1'b1 && BRAM_write_states==1'b1) ||
                                 (data_type==1'b0 && processor_sel==3'd5 && bram_we==1'b1 && BRAM_write_states==1'b1 && ((second_iteration2==1'b0&&reduction_type==1'b0) || (second_iteration2==1'b1&&reduction_type==1'b1))  )) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
    if(rst)
        second_iteration <= 1'b0;
    else if(data_type==1'b0 && second_iteration==1'b0 && processor_sel==3'd5 && lift_buffer_we==1'b1)
        second_iteration <= 1'b1;
    else if(data_type==1'b0 && second_iteration==1'b1 && processor_sel==3'd6 && lift_buffer_we==1'b1)
        second_iteration <= 1'b0;
    else
        second_iteration <= second_iteration;
end

always @(posedge clk)
begin
    if(rst)
        second_iteration2 <= 1'b0;
    else if(reduction_type==1'b1 && second_iteration2==1'b0 && processor_sel==3'd5 && bram_we==1'b1)
        second_iteration2 <= 1'b1;
    else if(reduction_type==1'b1 && second_iteration2==1'b1 && processor_sel==3'd5 && bram_we==1'b1)
        second_iteration2 <= 1'b0;
    else
        second_iteration2 <= second_iteration2;
end

always @(posedge clk)
begin
    if(rst)
        lift_core_sel <= 2'd0;
    else if(data_loading_ibuff_over==1'b1 || bram_write_over==1'b1)
        lift_core_sel <= lift_core_sel+1'b1;
    else
        lift_core_sel <= lift_core_sel;
end

assign data_loading_ibuff_over = ((data_type==1'b1 && processor_sel==3'd5 && lift_buffer_we==1'b1) || (data_type==1'b0 && processor_sel==3'd6 && lift_buffer_we==1'b1)) ? 1'b1 : 1'b0;
assign BRAM_read_states = (state<6'd4) ? 1'b1 : 1'b0;
assign BRAM_write_states = (state==6'd6 || state==6'd7) ? 1'b1 : 1'b0;
assign bram_write_over = ((data_type==1'b1 && processor_sel==3'd6 && bram_we==1'b1) || (data_type==1'b0 && processor_sel==3'd5 && bram_we==1'b1 && reduction_type==1'b0) || (data_type==1'b0 && processor_sel==3'd5 && bram_we==1'b1 && reduction_type==1'b1 && second_iteration2==1'b1)) ? 1'b1 : 1'b0;

assign last_lift_operation = (bram_write_address==9'd511 && bram_write_over==1'b1) ? 1'b1 : 1'b0;
//assign last_lift_operation = (bram_write_address==9'd15 && bram_write_over==1'b1) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
    if(rst)
        wait_counter <= 4'd0;
    else if(state !=    6'd61)
        wait_counter <= 4'd0;
    else if(state==6'd61)
        wait_counter <= wait_counter + 1'b1;
    else
        wait_counter <= wait_counter;
end

//assign wait_over = (wait_counter==4'd15) ? 1'b1 : 1'b0;
assign wait_over = 1'b1;

always @(state)
begin
    case(state)
    6'd0: begin    // rst
            inc_processor_sel<=1'b0;
            rst_lift_buffer_address<=1'b1; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0;
            rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
            end

    ///////// Step 1: Read data (8 coeffs) from BRAMs of the cores and copy in the input buffer of Lift///////
    6'd1: begin    // Set BRAM address
            inc_processor_sel<=1'b0;
            rst_lift_buffer_address<=1'b1; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0;
            rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
            end
    6'd2: begin    // Fetch BRAM data
            inc_processor_sel<=1'b0;
            rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0;
            rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
            end
    6'd3: begin    // Write BRAM data in Lift-InBuff; Increment Processor_sel
            inc_processor_sel<=1'b1;
            rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b1; lift_buffer_we<=1'b1;
            rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
            end

    //////// Step 2: Compute Lift operation /////////////////////////////////////////////////////////////////
    6'd4: begin
            inc_processor_sel<=1'b0;
            rst_lift_buffer_address<=1'b1; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0;
            rst_lift<=1'b0; data_valid<=1'b0; bram_we<=1'b0;
            end
    6'd62: begin    // Provide data valid
            inc_processor_sel<=1'b0;
            rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0;
            rst_lift<=1'b0; data_valid<=1'b1; bram_we<=1'b0;
            end
    6'd5: begin    // Wait for the completion of lift
            inc_processor_sel<=1'b0;
            rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0;
            rst_lift<=1'b0; data_valid<=1'b0; bram_we<=1'b0;
            end
    6'd61: begin    // Just wait 16 clock cycles
            inc_processor_sel<=1'b0;
            rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0;
            rst_lift<=1'b0; data_valid<=1'b0; bram_we<=1'b0;
            end

    //////// Step 3: Write Lift operation results /////////////////////////////////////////////////////////////////
    6'd6: begin    // set address
            inc_processor_sel<=1'b0;
            rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0;
            rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
            end
    6'd7: begin    // fetch data; write data in BRAMs; increment lift OutputBuff address; increment Processor Sel
            inc_processor_sel<=1'b1;
            rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b1; lift_buffer_we<=1'b0;
            rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b1;
            end
    6'd8: begin    // Reset lift_address
            inc_processor_sel<=1'b0;
            rst_lift_buffer_address<=1'b1; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0;
            rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
            end




    6'd63: begin    // Finish
            inc_processor_sel<=1'b0;
            rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0;
            rst_lift<=1'b0; data_valid<=1'b0; bram_we<=1'b0;
            end
    default: begin
            inc_processor_sel<=1'b0;
            rst_lift_buffer_address<=1'b1; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0;
            rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
            end

    endcase
end


always @(state or data_loading_ibuff_over or lift_done or bram_write_over or last_lift_operation or lift_core_sel or wait_over)
begin
    case(state)
    6'd0: nextstate <= 6'd1;
    6'd1: nextstate <= 6'd2;
    6'd2: nextstate <= 6'd3;
    6'd3: begin
                if(data_loading_ibuff_over==1'b1 && lift_core_sel==2'd3)
                    nextstate <= 6'd4;
                else if(data_loading_ibuff_over==1'b1 /*&& lift_core_sel==2'd0*/)
                    nextstate <= 6'd1;
                else
                    nextstate <= 6'd2;
            end

    // Lift computation
    6'd4: nextstate <= 6'd62;
    6'd62: nextstate <= 6'd5;
    6'd5: begin
                if(lift_done)
                    nextstate <= 6'd61;    // previously nextstate <= 6'd6;
                else
                    nextstate <= 6'd5;
            end
    6'd61: begin
                if(wait_over)
                    nextstate <= 6'd6;
                else
                    nextstate <= 6'd61;
            end


    // Write Lift result to BRAM
    6'd6: nextstate <= 6'd7;
    6'd7: begin
                if(last_lift_operation==1'b1 && lift_core_sel==2'd3)
                    nextstate <= 6'd63;
                else if(bram_write_over && lift_core_sel==2'd3)
                    nextstate <= 6'd1;
                else if(bram_write_over /*&& (lift_core_sel==2'd0||lift_core_sel==2'd1||lift_core_sel==2'd2)*/)
                    nextstate <= 6'd8;
                else
                    nextstate <= 6'd6;
            end
    6'd8: nextstate <= 6'd6;

    6'd63: nextstate <= 6'd63;
    default: nextstate <= 6'd0;
    endcase
end

assign done = (state==6'd63) ? 1'b1 : 1'b0;


endmodule


/*
module lift_control_parallel_cores(
							clk, rst, instruction, MemR0, MemR1, MemW0, MemW1, 
                     processor_sel, memory_sel, bram_address, bram_we,
							lift_data_in, lift_data_out,
							done	
						);

input clk; 						// computation clock
input rst;						// system reset when 1
input [7:0] instruction;	
input [3:0] MemR0, MemR1, MemW0, MemW1; // Memory select options for read and write;

output [2:0] processor_sel;
output [3:0] memory_sel;			// Memory selected for read or write
output [8:0] bram_address;      	// 0-511 address of the i/o buffer of Lift unit.
input [239:0] lift_data_in;	
output [239:0] lift_data_out;

output bram_we;
output done;


reg [8:0] bram_read_address, bram_write_address, bram_write_address_d;
wire inc_bram_read_address, inc_bram_write_address, bram_write_over;
wire data_loading_ibuff_over, BRAM_read_states, BRAM_write_states;
reg lift_core_sel;

reg second_iteration;	// This flag is used during Large CRT data loading. First iteration processor_sel 0 to 5; second iteration 0 to 6; 
reg second_iteration2;  // This flag is used during large CRT with decomposition reduction to write back results

wire reduction_type = (instruction==8'd7) ? 1'b1 : 1'b0;
wire data_type = (instruction==8'd5) ? 1'b1 : 1'b0;

wire [239:0] lift_data_in, lift_data_out, lift_data_out_core0, lift_data_out_core1;
wire lift_done, lift_done_core0, lift_done_core1;

reg rst_lift, lift_buffer_we, data_valid, inc_processor_sel;
reg [5:0] lift_buffer_address;
reg [2:0] processor_sel;
reg rst_lift_buffer_address, inc_lift_buffer_address, bram_we, bram_we_d;
reg lift_done_core0_reg, lift_done_core1_reg;
reg [3:0] wait_counter;
wire wait_over;

wire lift_buffer_we_core0, lift_buffer_we_core1;

wire last_lift_operation;

reg [5:0] state, nextstate;

assign bram_address = (BRAM_read_states) ? bram_read_address : bram_write_address;

assign memory_sel = 	(BRAM_read_states==1'b1 && second_iteration==1'b0) ? MemR0 : 
							(BRAM_read_states==1'b1 && second_iteration==1'b1) ? MemR1 : 
							(BRAM_write_states==1'b1 && second_iteration2==1'b0) ? MemW0 : MemW1;

always @(posedge clk)
begin
	if(rst)
		bram_read_address <= 9'd0;
	else if(inc_bram_read_address)
		bram_read_address <= bram_read_address + 1'b1;
	else
		bram_read_address <= bram_read_address;
end
always @(posedge clk)
begin
	if(rst)
		bram_write_address <= 9'd0;
	else if(inc_bram_write_address)
		bram_write_address <= bram_write_address + 1'b1;
	else
		bram_write_address <= bram_write_address;
end	

always @(posedge clk)
bram_write_address_d<= bram_write_address;

always @(posedge clk)
bram_we_d <= bram_we;


always @(posedge clk)
begin		
	if(rst)
		state <= 6'd0;
	else
		state <= nextstate;
end



assign lift_data_out = (lift_core_sel) ? lift_data_out_core1 : lift_data_out_core0;
assign lift_done = lift_done_core0_reg & lift_done_core1_reg;
assign lift_buffer_we_core0 = (lift_buffer_we==1'b1 && lift_core_sel==1'b0) ? 1'b1 : 1'b0;
assign lift_buffer_we_core1 = (lift_buffer_we==1'b1 && lift_core_sel==1'b1) ? 1'b1 : 1'b0;

lift_wrapper LW_core0(clk, rst_lift, reduction_type, lift_buffer_address, lift_buffer_we_core0, lift_data_in, data_type, data_valid,
                lift_data_out_core0, lift_done_core0);

lift_wrapper LW_core1(clk, rst_lift, reduction_type, lift_buffer_address, lift_buffer_we_core1, lift_data_in, data_type, data_valid,
                lift_data_out_core1, lift_done_core1);					 

always @(posedge clk)
begin
	if(state==6'd5 && lift_done_core0_reg==1'b1)
		lift_done_core0_reg <= 1'b1;
	else if(state==6'd5)
		lift_done_core0_reg <= lift_done_core0;		
	else
		lift_done_core0_reg <= 1'b0;
end	
always @(posedge clk)
begin
	if(state==6'd5 && lift_done_core1_reg==1'b1)
		lift_done_core1_reg <= 1'b1;
	else if(state==6'd5)
		lift_done_core1_reg <= lift_done_core1;		
	else
		lift_done_core1_reg <= 1'b0;
end


always @(posedge clk)
begin
	if(rst_lift_buffer_address)
		lift_buffer_address <= 6'd0;
	else if(inc_lift_buffer_address)
		lift_buffer_address <= lift_buffer_address + 1'b1;
	else 
		lift_buffer_address <= lift_buffer_address;
end
		
always @(posedge clk)
begin
	if(rst)
		processor_sel <= 3'd0;
	else if(data_type==1'b1 && processor_sel==3'd5 && inc_processor_sel==1'b1 && BRAM_read_states==1'b1)
		processor_sel <= 3'd0;
	else if(data_type==1'b1 && processor_sel==3'd6 && inc_processor_sel==1'b1 && BRAM_write_states==1'b1)
		processor_sel <= 3'd0;
	else if(data_type==1'b0 && processor_sel==3'd5 && inc_processor_sel==1'b1 && ((second_iteration==1'b0 && BRAM_read_states==1'b1)|(second_iteration2==1'b0 && BRAM_write_states==1'b1)) )
		processor_sel <= 3'd0;
	else if(data_type==1'b0 && inc_processor_sel==1'b1 && ((processor_sel==3'd6 && second_iteration==1'b1 && BRAM_read_states==1'b1)|(processor_sel==3'd5 && second_iteration2==1'b1 && BRAM_write_states==1'b1)) )
		processor_sel <= 3'd0;		
	else if(inc_processor_sel)
		processor_sel <= processor_sel + 1'b1;
	else
		processor_sel <= processor_sel;
end		

assign inc_bram_read_address = ((data_type==1'b1 && processor_sel==3'd5 && lift_buffer_we==1'b1 && BRAM_read_states==1'b1) || 
                               (data_type==1'b0 && processor_sel==3'd6 && lift_buffer_we==1'b1 && BRAM_read_states==1'b1)) ? 1'b1 : 1'b0;
										 
assign inc_bram_write_address = ((data_type==1'b1 && processor_sel==3'd6 && bram_we==1'b1 && BRAM_write_states==1'b1) || 
                                 (data_type==1'b0 && processor_sel==3'd5 && bram_we==1'b1 && BRAM_write_states==1'b1 && ((second_iteration2==1'b0&&reduction_type==1'b0) || (second_iteration2==1'b1&&reduction_type==1'b1))  )) ? 1'b1 : 1'b0;										 

always @(posedge clk)
begin
	if(rst)
		second_iteration <= 1'b0;
	else if(data_type==1'b0 && second_iteration==1'b0 && processor_sel==3'd5 && lift_buffer_we==1'b1)
		second_iteration <= 1'b1;
	else if(data_type==1'b0 && second_iteration==1'b1 && processor_sel==3'd6 && lift_buffer_we==1'b1)
		second_iteration <= 1'b0;		
	else
		second_iteration <= second_iteration;
end

always @(posedge clk)
begin
	if(rst)
		second_iteration2 <= 1'b0;
	else if(reduction_type==1'b1 && second_iteration2==1'b0 && processor_sel==3'd5 && bram_we==1'b1)
		second_iteration2 <= 1'b1;
	else if(reduction_type==1'b1 && second_iteration2==1'b1 && processor_sel==3'd5 && bram_we==1'b1)
		second_iteration2 <= 1'b0;		
	else
		second_iteration2 <= second_iteration2;
end

always @(posedge clk)
begin
	if(rst)
		lift_core_sel <= 1'b0;
	else if(data_loading_ibuff_over==1'b1 || bram_write_over==1'b1)
		lift_core_sel <= lift_core_sel+1'b1;	
	else
		lift_core_sel <= lift_core_sel;
end

assign data_loading_ibuff_over = ((data_type==1'b1 && processor_sel==3'd5 && lift_buffer_we==1'b1) || (data_type==1'b0 && processor_sel==3'd6 && lift_buffer_we==1'b1)) ? 1'b1 : 1'b0;
assign BRAM_read_states = (state<6'd4) ? 1'b1 : 1'b0;
assign BRAM_write_states = (state==6'd6 || state==6'd7) ? 1'b1 : 1'b0;
assign bram_write_over = ((data_type==1'b1 && processor_sel==3'd6 && bram_we==1'b1) || (data_type==1'b0 && processor_sel==3'd5 && bram_we==1'b1 && reduction_type==1'b0) || (data_type==1'b0 && processor_sel==3'd5 && bram_we==1'b1 && reduction_type==1'b1 && second_iteration2==1'b1)) ? 1'b1 : 1'b0;

assign last_lift_operation = (bram_write_address==9'd511 && bram_write_over==1'b1) ? 1'b1 : 1'b0;
//assign last_lift_operation = (bram_write_address==9'd15 && bram_write_over==1'b1) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
	if(rst)
		wait_counter <= 4'd0;
	else if(state !=	6'd61)
		wait_counter <= 4'd0;
	else if(state==6'd61)
		wait_counter <= wait_counter + 1'b1;
	else
		wait_counter <= wait_counter;
end

assign wait_over = (wait_counter==4'd15) ? 1'b1 : 1'b0;		

always @(state)
begin
	case(state)
	6'd0: begin	// rst
			inc_processor_sel<=1'b0;
			rst_lift_buffer_address<=1'b1; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
			end

	///////// Step 1: Read data (8 coeffs) from BRAMs of the cores and copy in the input buffer of Lift///////
	6'd1: begin	// Set BRAM address
			inc_processor_sel<=1'b0;	
			rst_lift_buffer_address<=1'b1; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
			end
	6'd2: begin	// Fetch BRAM data
			inc_processor_sel<=1'b0;	
			rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
			end
	6'd3: begin	// Write BRAM data in Lift-InBuff; Increment Processor_sel
			inc_processor_sel<=1'b1;	
			rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b1; lift_buffer_we<=1'b1; 
			rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
			end
			
	//////// Step 2: Compute Lift operation /////////////////////////////////////////////////////////////////		
	6'd4: begin	
			inc_processor_sel<=1'b0;	
			rst_lift_buffer_address<=1'b1; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b0; data_valid<=1'b0; bram_we<=1'b0;
			end
	6'd62: begin	// Provide data valid	
			inc_processor_sel<=1'b0;	
			rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b0; data_valid<=1'b1; bram_we<=1'b0;
			end
	6'd5: begin	// Wait for the completion of lift	
			inc_processor_sel<=1'b0;	
			rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b0; data_valid<=1'b0; bram_we<=1'b0;
			end
	6'd61: begin	// Just wait 16 clock cycles 	
			inc_processor_sel<=1'b0;	
			rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b0; data_valid<=1'b0; bram_we<=1'b0;
			end			
			
	//////// Step 3: Write Lift operation results /////////////////////////////////////////////////////////////////			
	6'd6: begin	// set address
			inc_processor_sel<=1'b0;
			rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
			end
	6'd7: begin	// fetch data; write data in BRAMs; increment lift OutputBuff address; increment Processor Sel
			inc_processor_sel<=1'b1;
			rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b1; lift_buffer_we<=1'b0; 
			rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b1;
			end
	6'd8: begin	// Reset lift_address
			inc_processor_sel<=1'b0;
			rst_lift_buffer_address<=1'b1; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
			end


			

	6'd63: begin	// Finish	
			inc_processor_sel<=1'b0;	
			rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b0; data_valid<=1'b0; bram_we<=1'b0;
			end
	default: begin
			inc_processor_sel<=1'b0;	
			rst_lift_buffer_address<=1'b1; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
			end
		
	endcase	
end


always @(state or data_loading_ibuff_over or lift_done or bram_write_over or last_lift_operation or lift_core_sel or wait_over)
begin
	case(state)
	6'd0: nextstate <= 6'd1;
	6'd1: nextstate <= 6'd2;
	6'd2: nextstate <= 6'd3;
	6'd3: begin
				if(data_loading_ibuff_over==1'b1 && lift_core_sel==1'b1)
					nextstate <= 6'd4;
				else if(data_loading_ibuff_over==1'b1 && lift_core_sel==1'b0)
					nextstate <= 6'd1;					
				else
					nextstate <= 6'd2;
			end
	
	// Lift computation
	6'd4: nextstate <= 6'd62;
	6'd62: nextstate <= 6'd5;	
	6'd5: begin
				if(lift_done)
					nextstate <= 6'd61;	// previously nextstate <= 6'd6;
				else
					nextstate <= 6'd5;
			end
	6'd61: begin
				if(wait_over)
					nextstate <= 6'd6;	
				else
					nextstate <= 6'd61;
			end


	// Write Lift result to BRAM
	6'd6: nextstate <= 6'd7;
	6'd7: begin
				if(last_lift_operation==1'b1 && lift_core_sel==1'b1)
					nextstate <= 6'd63;
				else if(bram_write_over && lift_core_sel==1'b1)
					nextstate <= 6'd1;
				else if(bram_write_over && lift_core_sel==1'b0)
					nextstate <= 6'd8;					
				else
					nextstate <= 6'd6;
			end			
	6'd8: nextstate <= 6'd6;
	
	6'd63: nextstate <= 6'd63;			
	default: nextstate <= 6'd0;	
	endcase
end
	
assign done = (state==6'd63) ? 1'b1 : 1'b0;


endmodule
*/



/*
module lift_control_single_core(
							clk, rst, instruction, MemR0, MemR1, MemW0, MemW1, 
                     processor_sel, memory_sel, bram_address, bram_we,
							lift_data_in, lift_data_out,
							done	
						);

input clk; 						// computation clock
input rst;						// system reset when 1
input [7:0] instruction;	
input [3:0] MemR0, MemR1, MemW0, MemW1; // Memory select options for read and write;

output [2:0] processor_sel;
output [3:0] memory_sel;			// Memory selected for read or write
output [8:0] bram_address;      	// 0-511 address of the i/o buffer of Lift unit.
input [239:0] lift_data_in;	
output [239:0] lift_data_out;

output bram_we;
output done;


reg [8:0] bram_read_address, bram_write_address;
wire inc_bram_read_address, inc_bram_write_address, bram_write_over;
wire data_loading_ibuff_over, BRAM_read_states, BRAM_write_states;

reg second_iteration;	// This flag is used during Large CRT data loading. First iteration processor_sel 0 to 5; second iteration 0 to 6; 
reg second_iteration2;  // This flag is used during large CRT with decomposition reduction to write back results

wire reduction_type = (instruction==8'd7) ? 1'b1 : 1'b0;
wire data_type = (instruction==8'd5) ? 1'b1 : 1'b0;

wire [239:0] lift_data_in, lift_data_out;
wire lift_done;

reg rst_lift, lift_buffer_we, data_valid, inc_processor_sel;
reg [5:0] lift_buffer_address;
reg [2:0] processor_sel;
reg rst_lift_buffer_address, inc_lift_buffer_address, bram_we;

wire last_lift_operation;

reg [5:0] state, nextstate;

assign bram_address = (BRAM_read_states) ? bram_read_address : bram_write_address;

assign memory_sel = 	(BRAM_read_states==1'b1 && second_iteration==1'b0) ? MemR0 : 
							(BRAM_read_states==1'b1 && second_iteration==1'b1) ? MemR1 : 
							(BRAM_write_states==1'b1 && second_iteration2==1'b0) ? MemW0 : MemW1;

always @(posedge clk)
begin
	if(rst)
		bram_read_address <= 9'd0;
	else if(inc_bram_read_address)
		bram_read_address <= bram_read_address + 1'b1;
	else
		bram_read_address <= bram_read_address;
end
always @(posedge clk)
begin
	if(rst)
		bram_write_address <= 9'd0;
	else if(inc_bram_write_address)
		bram_write_address <= bram_write_address + 1'b1;
	else
		bram_write_address <= bram_write_address;
end	

always @(posedge clk)
begin		
	if(rst)
		state <= 6'd0;
	else
		state <= nextstate;
end



lift_wrapper LW(clk, rst_lift, reduction_type, lift_buffer_address, lift_buffer_we, lift_data_in, data_type, data_valid,
                lift_data_out, lift_done);

always @(posedge clk)
begin
	if(rst_lift_buffer_address)
		lift_buffer_address <= 6'd0;
	else if(inc_lift_buffer_address)
		lift_buffer_address <= lift_buffer_address + 1'b1;
	else 
		lift_buffer_address <= lift_buffer_address;
end
		
always @(posedge clk)
begin
	if(rst)
		processor_sel <= 3'd0;
	else if(data_type==1'b1 && processor_sel==3'd5 && inc_processor_sel==1'b1 && BRAM_read_states==1'b1)
		processor_sel <= 3'd0;
	else if(data_type==1'b1 && processor_sel==3'd6 && inc_processor_sel==1'b1 && BRAM_write_states==1'b1)
		processor_sel <= 3'd0;
	else if(data_type==1'b0 && processor_sel==3'd5 && inc_processor_sel==1'b1 && ((second_iteration==1'b0 && BRAM_read_states==1'b1)|(second_iteration2==1'b0 && BRAM_write_states==1'b1)) )
		processor_sel <= 3'd0;
	else if(data_type==1'b0 && inc_processor_sel==1'b1 && ((processor_sel==3'd6 && second_iteration==1'b1 && BRAM_read_states==1'b1)|(processor_sel==3'd5 && second_iteration2==1'b1 && BRAM_write_states==1'b1)) )
		processor_sel <= 3'd0;		
	else if(inc_processor_sel)
		processor_sel <= processor_sel + 1'b1;
	else
		processor_sel <= processor_sel;
end		

assign inc_bram_read_address = ((data_type==1'b1 && processor_sel==3'd5 && lift_buffer_we==1'b1 && BRAM_read_states==1'b1) || 
                               (data_type==1'b0 && processor_sel==3'd6 && lift_buffer_we==1'b1 && BRAM_read_states==1'b1)) ? 1'b1 : 1'b0;
										 
assign inc_bram_write_address = ((data_type==1'b1 && processor_sel==3'd6 && bram_we==1'b1 && BRAM_write_states==1'b1) || 
                                 (data_type==1'b0 && processor_sel==3'd5 && bram_we==1'b1 && BRAM_write_states==1'b1 && ((second_iteration2==1'b0&&reduction_type==1'b0) || (second_iteration2==1'b1&&reduction_type==1'b1))  )) ? 1'b1 : 1'b0;										 

always @(posedge clk)
begin
	if(rst)
		second_iteration <= 1'b0;
	else if(data_type==1'b0 && second_iteration==1'b0 && processor_sel==3'd5 && lift_buffer_we==1'b1)
		second_iteration <= 1'b1;
	else if(data_type==1'b0 && second_iteration==1'b1 && processor_sel==3'd6 && lift_buffer_we==1'b1)
		second_iteration <= 1'b0;		
	else
		second_iteration <= second_iteration;
end

always @(posedge clk)
begin
	if(rst)
		second_iteration2 <= 1'b0;
	else if(reduction_type==1'b1 && second_iteration2==1'b0 && processor_sel==3'd5 && bram_we==1'b1)
		second_iteration2 <= 1'b1;
	else if(reduction_type==1'b1 && second_iteration2==1'b1 && processor_sel==3'd5 && bram_we==1'b1)
		second_iteration2 <= 1'b0;		
	else
		second_iteration2 <= second_iteration2;
end

assign data_loading_ibuff_over = ((data_type==1'b1 && processor_sel==3'd5 && lift_buffer_we==1'b1) || (data_type==1'b0 && processor_sel==3'd6 && lift_buffer_we==1'b1)) ? 1'b1 : 1'b0;
assign BRAM_read_states = (state<6'd4) ? 1'b1 : 1'b0;
assign BRAM_write_states = (state==6'd6 || state==6'd7) ? 1'b1 : 1'b0;
assign bram_write_over = ((data_type==1'b1 && processor_sel==3'd6 && bram_we==1'b1) || (data_type==1'b0 && processor_sel==3'd5 && bram_we==1'b1 && reduction_type==1'b0) || (data_type==1'b0 && processor_sel==3'd5 && bram_we==1'b1 && reduction_type==1'b1 && second_iteration2==1'b1)) ? 1'b1 : 1'b0;

assign last_lift_operation = (bram_write_address==9'd511 && bram_write_over==1'b1) ? 1'b1 : 1'b0;
//assign last_lift_operation = (bram_write_address==9'd5 && bram_write_over==1'b1) ? 1'b1 : 1'b0;

always @(state)
begin
	case(state)
	6'd0: begin	// rst
			inc_processor_sel<=1'b0;
			rst_lift_buffer_address<=1'b1; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
			end

	///////// Step 1: Read data (8 coeffs) from BRAMs of the cores and copy in the input buffer of Lift///////
	6'd1: begin	// Set BRAM address
			inc_processor_sel<=1'b0;	
			rst_lift_buffer_address<=1'b1; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
			end
	6'd2: begin	// Fetch BRAM data
			inc_processor_sel<=1'b0;	
			rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
			end
	6'd3: begin	// Write BRAM data in Lift-InBuff; Increment Processor_sel
			inc_processor_sel<=1'b1;	
			rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b1; lift_buffer_we<=1'b1; 
			rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
			end
			
	//////// Step 2: Compute Lift operation /////////////////////////////////////////////////////////////////		
	6'd4: begin	
			inc_processor_sel<=1'b0;	
			rst_lift_buffer_address<=1'b1; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b0; data_valid<=1'b0; bram_we<=1'b0;
			end
	6'd62: begin	// Provide data valid	
			inc_processor_sel<=1'b0;	
			rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b0; data_valid<=1'b1; bram_we<=1'b0;
			end			
	6'd5: begin	// Wait for the completion of lift	
			inc_processor_sel<=1'b0;	
			rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b0; data_valid<=1'b0; bram_we<=1'b0;
			end
	//////// Step 3: Write Lift operation results /////////////////////////////////////////////////////////////////			
	6'd6: begin	// set address
			inc_processor_sel<=1'b0;
			rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
			end
	6'd7: begin	// fetch data; write data in BRAMs; increment lift OutputBuff address; increment Processor Sel
			inc_processor_sel<=1'b1;
			rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b1; lift_buffer_we<=1'b0; 
			rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b1;
			end



			

	6'd63: begin	// Finish	
			inc_processor_sel<=1'b0;	
			rst_lift_buffer_address<=1'b0; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b0; data_valid<=1'b0; bram_we<=1'b0;
			end
	default: begin
			inc_processor_sel<=1'b0;	
			rst_lift_buffer_address<=1'b1; inc_lift_buffer_address<=1'b0; lift_buffer_we<=1'b0; 
			rst_lift<=1'b1; data_valid<=1'b0; bram_we<=1'b0;
			end
		
	endcase	
end


always @(state or data_loading_ibuff_over or lift_done or bram_write_over or last_lift_operation)
begin
	case(state)
	6'd0: nextstate <= 6'd1;
	6'd1: nextstate <= 6'd2;
	6'd2: nextstate <= 6'd3;
	6'd3: begin
				if(data_loading_ibuff_over)
					nextstate <= 6'd4;
				else
					nextstate <= 6'd2;
			end
	
	// Lift computation
	6'd4: nextstate <= 6'd62;
	6'd62: nextstate <= 6'd5;	
	6'd5: begin
				if(lift_done)
					nextstate <= 6'd6;
				else
					nextstate <= 6'd5;
			end

	// Write Lift result to BRAM
	6'd6: nextstate <= 6'd7;
	6'd7: begin
				if(last_lift_operation)
					nextstate <= 6'd63;
				else if(bram_write_over)
					nextstate <= 6'd1;
				else
					nextstate <= 6'd6;
			end			
				
	6'd63: nextstate <= 6'd63;			
	default: nextstate <= 6'd0;	
	endcase
end
	
assign done = (state==6'd63) ? 1'b1 : 1'b0;


endmodule
*/

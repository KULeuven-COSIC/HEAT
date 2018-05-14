`timescale 1ns / 1ps
`define m 64'd69782261541   // m = floor(2^216/qs);
`define qsby2_word2 59'd541342731485958612
`define qsby2_word3 59'd3
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    10:27:38 05/20/2017
// Design Name:
// Module Name:    barrett_reduction_1228bit
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
module barrett_reduction_180bit(clk, rst, read_input_data, input_data_ready,
                                 sign_large_red_in, div_start_new,
                                            sample_CF_INFO_OUT,
                                 dout0, sign, bram_write, bram_write_address,
                                            bram_core_index, done_four_lcrts,
                                            done_for_testing
                                            );
input clk;
input rst;
input [117:0] read_input_data;
input input_data_ready;        // will be connected to the division word ready signal
input sign_large_red_in, div_start_new;
input sample_CF_INFO_OUT;

output [58:0] dout0;
output sign;                                // Sign of the result
output reg bram_write;                    // write enable signal for BRAM
output reg [10:0] bram_write_address;    // write address for BRAM
output [2:0] bram_core_index;                // used to write in the BRAM of either core3 or core 4
output reg done_four_lcrts;                // This is a done signal; goes 1 after finishing a burst of 4 large CRTs
output done_for_testing;            // SHOULD BE REMOVED


wire [58:0] din_ext;
reg rst_mult, rst_add, mode_add;
wire [63:0] in0_mult, in1_mult;
wire [64:0] in0_add, out_add;
wire [122:0] in1_add;
wire [127:0] out_mult;
wire done_mult;


reg [5:0] waddr0, raddr0;
wire [58:0] din0, dout0, qs_word;
reg we0, rst_waddr0, inc_waddr0, rst_raddr0, inc_raddr0, dec_raddr0, clear_R;
reg [4:0] state, nextstate;
wire data_loaded, quotient_ready, subtraction_done, raddr0_20, raddr0_21;
reg [63:0] quotient;
reg sel_in_mult;
reg flag;    // this is 1 after state 12 is visited.
reg [1:0] number_of_reductions;
reg [4:0] wait_counter;
wire wait_counter_full;
// Sub59bit.
wire [58:0] in0_sub, in1_sub, out_sub;
wire borrow_wire;
reg en_sub, en_sub_d, clear_borrow, borrow, borrow_save;
reg [58:0] out_sub_reg;

/*
reg [5:0] wait_to_sample_sign_counter;
wire sample_sign;
reg input_data_ready_reg;
*/
assign din_ext = (state==5'd1) ? read_input_data[58:0] : read_input_data[117:59];

assign din0 = (flag) ? out_sub_reg : din_ext;

data_RAM data(.a(waddr0), .d(din0), .dpra(raddr0), .clk(clk), .we(we0), .qdpo(dout0));
qs_array_q180bit qs(clk, raddr0, qs_word);

assign in0_mult = (sel_in_mult) ? quotient : `m;
assign in1_mult = (sel_in_mult) ? qs_word : {5'd0, dout0};

mult64x64  mult(clk, rst_mult, in0_mult, in1_mult, out_mult, done_mult);

assign in0_add = out_add;
assign in1_add = out_mult[122:0];
add_65_by_123 add(clk, rst_add, clear_R, mode_add, in0_add, in1_add, out_add, result_word_ready);


// Sub59bit.
assign in0_sub = (state>5'd21 && (state!=5'd28&&state!=5'd29&&state!=5'd30) ) ? qs_word : dout0;
assign in1_sub = (state>5'd21 && (state!=5'd28&&state!=5'd29&&state!=5'd30) ) ? dout0 : (state==5'd13||state==5'd14||state==5'd17||state==5'd18) ? qs_word : (state==5'd30) ? `qsby2_word2 : (state==5'd20) ? `qsby2_word3 : out_add[58:0];
assign {borrow_wire, out_sub} = in0_sub - in1_sub - borrow;
always @(posedge clk)
begin
    en_sub_d <= en_sub;
    out_sub_reg <= out_sub;
end
always @(posedge clk)
begin
    if(clear_borrow)
        borrow <= 1'b0;
    else if(en_sub_d)
        borrow <= borrow_wire;
end

always @(posedge clk)
begin
    if(state==5'd14 || state==5'd20)
        borrow_save <= borrow_wire;
    else if(en_sub_d)
        borrow_save <= borrow_save;
end

always @(posedge clk)
begin
    if(rst)
        flag<=0;
    else if(state==5'd12)
        flag<=1;
    else if(state==5'd0)
        flag<=0;
    else
        flag<=flag;
end

always @(posedge clk)
begin
    if(rst)
        quotient <= 65'd0;
    else if(result_word_ready==1'b1 && raddr0==6'd4 && state==5'd4)
        quotient[19:0] <= out_add[58:39];
    else if(result_word_ready==1'b1 && raddr0==6'd4 && state==5'd5)
        quotient[63:20] <= out_add[56:0];
    else
        quotient <= quotient;
end
assign quotient_ready = (result_word_ready==1'b1 && raddr0==6'd4) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
    if(rst)
        raddr0 <= 6'd0;
    else if(rst_raddr0)
        raddr0 <= 6'd0;
    else if(inc_raddr0)
        raddr0 <= raddr0 + 1'b1;
    else if(dec_raddr0)            //(state==5'd28)
        raddr0 <= raddr0 - 1'b1;
    else
        raddr0 <= raddr0;
end

always @(posedge clk)
begin
    if(rst)
        waddr0 <= 6'd0;
    else if(rst_waddr0)
        waddr0 <= 6'd0;
    else if(inc_waddr0)
        waddr0 <= waddr0 + 1'b1;
    else
        waddr0 <= waddr0;
end

always @(posedge clk)
begin
    if(state==5'd25)
        wait_counter<=wait_counter + 1'b1;
    else
        wait_counter<=5'd0;
end
assign wait_counter_full = (wait_counter==5'd21) ? 1'b1 : 1'b0;

assign data_loaded = (waddr0==6'd4) ? 1'b1 : 1'b0;
assign subtraction_done = (waddr0==6'd3) ? 1'b1 : 1'b0; ///TTTTTTTTTT from 20 to 3
assign raddr0_20 = (raddr0==6'd3) ? 1'b1 : 1'b0;
assign raddr0_21 = (raddr0==6'd4) ? 1'b1 : 1'b0;

wire fifo_rd_en, sign_large_red_out;
assign fifo_rd_en = (state==6'd26) ? 1'b1 : 1'b0;
/*
always @(posedge clk)
begin
    if(rst)
        input_data_ready_reg <= 1'b0;
    else if(input_data_ready)
        input_data_ready_reg <= 1'b1;
    else if(sample_sign)
        input_data_ready_reg <= 1'b0;
    else
        input_data_ready_reg <= input_data_ready_reg;
end

always @(posedge clk)
begin
    if(rst)
        wait_to_sample_sign_counter<=5'd0;
    else if(input_data_ready_reg)
        wait_to_sample_sign_counter<=wait_to_sample_sign_counter+1'b1;
    else
        wait_to_sample_sign_counter<=5'd0;
end
assign sample_sign = (wait_to_sample_sign_counter==5'd14) ? 1'b1 : 1'b0;
*/
sign_large_reduction_fifo sign_fifo(
  .clk(clk), // input clk
  .srst(rst), // input srst
  .din(sign_large_red_in), // input [0 : 0] din
  //.wr_en(sample_sign), // input wr_en; previously div_start_new
  .wr_en(sample_CF_INFO_OUT),
  .rd_en(fifo_rd_en), // input rd_en
  .dout(sign_large_red_out), // output [0 : 0] dout
  .full(), // output full
  .empty() // output empty
);

always @(posedge clk)
begin
    if(rst)
        state <= 5'd0;
    else
        state <= nextstate;
end

always @(state or done_mult or flag or subtraction_done or borrow_save or raddr0_20 or input_data_ready)
begin
    case(state)
    5'd0: begin //idle
                rst_waddr0<=1; inc_waddr0<=0; we0<=0; rst_raddr0<=1; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=1; sel_in_mult<=0;
                en_sub<=0; clear_borrow<=1;
            end

    5'd1: begin //Load input data
                rst_waddr0<=0; inc_waddr0<=0; we0<=0; rst_raddr0<=1; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=0; clear_borrow<=1;
                if(input_data_ready) begin inc_waddr0<=1; we0<=1; end
                else begin inc_waddr0<=0; we0<=0; end
            end
    5'd2: begin //Load input data
                rst_waddr0<=0; inc_waddr0<=1; we0<=1; rst_raddr0<=1; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=0; clear_borrow<=1;
            end


    // Multiply m*data
    5'd3: begin
                rst_waddr0<=1; inc_waddr0<=0; we0<=0; rst_raddr0<=1; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=0; clear_borrow<=1;
            end
    5'd4: begin // Fetch data[word]
                rst_waddr0<=1; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=1; rst_add<=~done_mult; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=0; clear_borrow<=1;
            end

    5'd5: begin // start multiplication m*data[word]
                rst_waddr0<=1; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=0; rst_add<=~done_mult; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=0; clear_borrow<=1;
            end
    5'd6: begin // wait for multiplication m*data[word] to finish
                rst_waddr0<=1; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=0; rst_add<=~done_mult; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=0; clear_borrow<=1;
            end
    5'd7: begin // Increment address to Fetch next data[word]
                rst_waddr0<=1; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=1; dec_raddr0<=0;
                rst_mult<=0; rst_add<=~done_mult; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=0; clear_borrow<=1;
            end

    // a <-- a - quo*q
    5'd8: begin
                rst_waddr0<=0; inc_waddr0<=0; we0<=0; rst_raddr0<=1; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=1; sel_in_mult<=1;
                en_sub<=0; clear_borrow<=1;
            end
    5'd9: begin // Fetch qs[word]
                rst_waddr0<=0; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=1; rst_add<=~done_mult; mode_add<=0; clear_R<=0; sel_in_mult<=1;
                en_sub<=0; clear_borrow<=0;
            end

    5'd10: begin // start multiplication quotient*qs[word]
                rst_waddr0<=0; rst_raddr0<=0; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=0; rst_add<=~done_mult; mode_add<=0; clear_R<=0; sel_in_mult<=1;
                en_sub<=0; clear_borrow<=0;
                if(flag==1 && subtraction_done==1'b0) inc_waddr0<=1; else inc_waddr0<=0;
                if(flag==1) we0<=1; else we0<=0;

            end
    5'd11: begin // wait for multiplication quotient*qs[word] to finish
                rst_waddr0<=0; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=0; rst_add<=~done_mult; mode_add<=0; clear_R<=0; sel_in_mult<=1;
                en_sub<=0; clear_borrow<=0;
            end
    5'd12: begin // Increment address to fetch next qs[word]
                rst_waddr0<=0; inc_waddr0<=0; we0<=0; rst_raddr0<=0; dec_raddr0<=0;
                rst_mult<=0; rst_add<=~done_mult; mode_add<=0; clear_R<=0; sel_in_mult<=1;
                en_sub<=1; clear_borrow<=0;
                if(subtraction_done) inc_raddr0<=0; else inc_raddr0<=1;
            end



    5'd28: begin // Decrement address to fetch qs[2] and data[2]
                rst_waddr0<=0; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=0; dec_raddr0<=1;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=0; clear_borrow<=1;
            end
    5'd29: begin // Subtract data[2]-qs[2]; Inn address to fetch qs[3] and data[3]
                rst_waddr0<=0; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=1; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=1; clear_borrow<=0;
            end
    // check if data>qs; address is already 3. so data[3]-qs[3] and check carry.
    5'd13: begin     //fetch data
                rst_waddr0<=0; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=1; clear_borrow<=0;
            end
    5'd14: begin     //subtract; store the borrow
                rst_waddr0<=0; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=0; clear_borrow<=1;
            end



    // based on the borrow_save, compute subtraction data<--data-qs or data<-data.
    5'd15: begin     // reset read address.
                rst_waddr0<=1; inc_waddr0<=0; we0<=0; rst_raddr0<=1; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=1; sel_in_mult<=1;
                en_sub<=0; clear_borrow<=1;
            end
    5'd16: begin     //fetch data
                rst_waddr0<=0; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=1; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=1; clear_borrow<=0;
            end
    5'd17: begin     //subtract; fetch data
                rst_waddr0<=0; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=1; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=1; clear_borrow<=0;
            end
    5'd18: begin     //write result; subtract; fetch data
                rst_waddr0<=0; inc_waddr0<=1; rst_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=1; clear_borrow<=0;
                if(borrow_save) we0<=0; else we0<=1;
                if(raddr0_20) inc_raddr0<=0; else inc_raddr0<=1;
                if(raddr0_20) dec_raddr0<=1; else dec_raddr0<=0;
            end



    // check if data>qs; address is already 20. so data[20]-qs[20] and check carry.
    5'd19: begin     //fetch data[2], qsby2[2]; Inc address to fetch qs[3] and data[3]
                rst_waddr0<=0; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=1; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=1; clear_borrow<=1;
            end
    5'd30: begin // Subtract data[2]-qsby2[2];
                rst_waddr0<=0; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=1; clear_borrow<=0;
            end
    5'd20: begin     //subtract data[3]-qsby2[3]; store the borrow
                rst_waddr0<=0; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=0; clear_borrow<=1;
            end



    // based on the borrow_save, compute subtraction data<--data-qs or data<-data.
    5'd21: begin     // reset read address.
                rst_waddr0<=1; inc_waddr0<=0; we0<=0; rst_raddr0<=1; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=1; sel_in_mult<=1;
                en_sub<=0; clear_borrow<=1;
            end
    5'd22: begin     //fetch data
                rst_waddr0<=0; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=1; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=1; clear_borrow<=0;
            end
    5'd23: begin     //subtract; fetch data
                rst_waddr0<=0; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=1; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=1; clear_borrow<=0;
            end
    5'd24: begin     //write result; subtract; fetch data
                rst_waddr0<=0; inc_waddr0<=1; rst_raddr0<=0; inc_raddr0<=1; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=0; sel_in_mult<=0;
                en_sub<=1; clear_borrow<=0;
                if(borrow_save) we0<=0; else we0<=1;
            end

    // output the result
    5'd25: begin     // reset read address and wait till wait_counter_full
                rst_waddr0<=1; inc_waddr0<=0; we0<=0; rst_raddr0<=1; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=1; sel_in_mult<=1;
                en_sub<=0; clear_borrow<=1;
            end
    5'd26: begin     // Fetch result data.
                rst_waddr0<=1; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=1; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=1; sel_in_mult<=1;
                en_sub<=0; clear_borrow<=1;
            end
    5'd27: begin     // output result data.
                rst_waddr0<=1; inc_waddr0<=0; we0<=0; rst_raddr0<=0; inc_raddr0<=1; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=1; sel_in_mult<=1;
                en_sub<=0; clear_borrow<=1;
            end



    5'd31: begin //idle
                rst_waddr0<=1; inc_waddr0<=0; we0<=0; rst_raddr0<=1; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=1; sel_in_mult<=0;
                en_sub<=0; clear_borrow<=0;
            end
    default: begin //idle
                rst_waddr0<=1; inc_waddr0<=0; we0<=0; rst_raddr0<=1; inc_raddr0<=0; dec_raddr0<=0;
                rst_mult<=1; rst_add<=1; mode_add<=0; clear_R<=1; sel_in_mult<=0;
                en_sub<=0; clear_borrow<=0;
            end
    endcase
end


always @(state or input_data_ready or data_loaded or done_mult or quotient_ready
         or subtraction_done or raddr0_21 or wait_counter_full)
begin
    case(state)
    5'd0: nextstate <= 5'd1;

    5'd1: begin
                if(data_loaded)
                    nextstate <= 5'd3;
                else if(input_data_ready)
                    nextstate <= 5'd2;
                else
                    nextstate <= 5'd1;
            end
    5'd2: begin
                if(data_loaded)
                    nextstate <= 5'd3;
                else
                    nextstate <= 5'd1;
            end


    5'd3: nextstate <= 5'd4;
    5'd4: nextstate <= 5'd5;
    5'd5: begin
                if(quotient_ready)
                    nextstate <= 5'd8;
                else
                    nextstate <= 5'd6;
            end
    5'd6: begin
                if(done_mult)
                    nextstate <= 5'd7;
                else
                    nextstate <= 5'd6;
            end
    5'd7: nextstate <= 5'd4;

    // quotient*qs
    5'd8: nextstate <= 5'd9;
    5'd9: nextstate <= 5'd10;
    5'd10: begin
                if(subtraction_done)
                    nextstate <= 5'd28; //nextstate <= 5'd13;
                else
                    nextstate <= 5'd11;
            end
    5'd11: begin
                if(done_mult)
                    nextstate <= 5'd12;
                else
                    nextstate <= 5'd11;
            end
    5'd12: nextstate <= 5'd9;

    // data[2,3] - qs[2,3]
    5'd28: nextstate <= 5'd29;
    5'd29: nextstate <= 5'd13;
    5'd13: nextstate <= 5'd14;
    5'd14: nextstate <= 5'd15;

    // data[i] - qs[i]
    5'd15: nextstate <= 5'd16;
    5'd16: nextstate <= 5'd17;
    5'd17: nextstate <= 5'd18;
    5'd18: begin
                if(subtraction_done)
                    nextstate <= 5'd19;
                else
                    nextstate <= 5'd18;
            end

    // data[2,3] - qsby2[2,3]
    5'd19: nextstate <= 5'd30;
    5'd30: nextstate <= 5'd20;
    5'd20: nextstate <= 5'd21;

    // data<--qs[i] - data[i]
    5'd21: nextstate <= 5'd22;
    5'd22: nextstate <= 5'd23;
    5'd23: nextstate <= 5'd24;
    5'd24: begin
                if(subtraction_done)
                    nextstate <= 5'd25;
                else
                    nextstate <= 5'd24;
            end


    // output result
    5'd25: begin
                if(wait_counter_full)
                    nextstate <= 5'd26;
                else
                    nextstate <= 5'd25;
            end
    5'd26: nextstate <= 5'd27;
    5'd27: begin
                if(raddr0_21)
                    nextstate <= 5'd31;
                else
                    nextstate <= 5'd27;
            end



    5'd31: nextstate <= 5'd0;
    default: nextstate <= 5'd0;
    endcase
end

always @(posedge clk)
begin
    if(rst)
        bram_write<=0;
    else if((state==6'd26 || state==6'd27) && raddr0_21==1'b0)
        bram_write<=1;
    else
        bram_write<=0;
end

always @(posedge clk)
begin
    if(state==5'd26 && number_of_reductions<2'd2)
        bram_write_address<=11'd1024;
    else if(state==5'd26 && number_of_reductions>2'd1)
        bram_write_address<=11'd1045;                        // as there are 21 words to be written in each modular reduction
    else if(bram_write)
        bram_write_address<=bram_write_address+1'b1;
    else
        bram_write_address<=bram_write_address;
end

always @(posedge clk)
begin
    if(rst)
        number_of_reductions<=2'd0;
    else if(state==5'd31)
        number_of_reductions<=number_of_reductions+1'b1;
    else
        number_of_reductions<=number_of_reductions;
end
assign bram_core_index = (number_of_reductions[0]) ? 3'd4 : 3'd3;

always @(posedge clk)
begin
    if(rst)
        done_four_lcrts<=1'b0;
    else if(state==6'd31 && number_of_reductions==2'd3)
        done_four_lcrts<=1'b1;
    else
        done_four_lcrts<=1'b0;
end

assign sign = (~borrow_save) ^ sign_large_red_out;

assign done_for_testing = (state==5'd31) ? 1'b1 : 1'b0;

endmodule
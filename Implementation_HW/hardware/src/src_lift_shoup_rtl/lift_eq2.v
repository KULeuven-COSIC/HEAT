`timescale 1ns / 1ps

module equation2(
    input  wire         clock        ,
    input  wire         reset        ,
    input  wire         start        ,
    input  wire         mode         ,
    input  wire [  3:0] clock_counter,
    input  wire [ 29:0] d_in         ,
    output wire [ 29:0] q            ,
    output wire         q_valid      
    );

    wire [29:0] const0;
    wire [29:0] const1;
    wire [29:0] const2;
    wire [29:0] const3;
    wire [29:0] const4;
    wire [29:0] const5;
    wire [29:0] const6;

    wire [223:0] constants;

    eq2_constants_all const (
        .clk  (clock                      ),
        .a ({mode, clock_counter[2:0]} ), 
        .qspo (constants                  ) 
    );

    assign const0 = constants[ 29:  0];
    assign const1 = constants[ 61: 32];
    assign const2 = constants[ 93: 64];
    assign const3 = constants[125: 96];
    assign const4 = constants[157:128];
    assign const5 = constants[189:160];
    assign const6 = constants[221:192];


 
    ////////////////////////////////////////////////////////////////////////////

    wire [29:0] mul0_a; wire [29:0] mul0_b; wire [59:0] mul0_c; reg [59:0] mul0_c_reg;
    wire [29:0] mul1_a; wire [29:0] mul1_b; wire [59:0] mul1_c; reg [59:0] mul1_c_reg;
    wire [29:0] mul2_a; wire [29:0] mul2_b; wire [59:0] mul2_c; reg [59:0] mul2_c_reg;
    wire [29:0] mul3_a; wire [29:0] mul3_b; wire [59:0] mul3_c; reg [59:0] mul3_c_reg;
    wire [29:0] mul4_a; wire [29:0] mul4_b; wire [59:0] mul4_c; reg [59:0] mul4_c_reg;
    wire [29:0] mul5_a; wire [29:0] mul5_b; wire [59:0] mul5_c; reg [59:0] mul5_c_reg;
    wire [29:0] mul6_a; wire [29:0] mul6_b; wire [59:0] mul6_c; reg [59:0] mul6_c_reg;

    dsp_mult mul0 ( .CLK (clock), .A (mul0_a), .B (mul0_b), .P (mul0_c) );
    dsp_mult mul1 ( .CLK (clock), .A (mul1_a), .B (mul1_b), .P (mul1_c) );
    dsp_mult mul2 ( .CLK (clock), .A (mul2_a), .B (mul2_b), .P (mul2_c) );
    dsp_mult mul3 ( .CLK (clock), .A (mul3_a), .B (mul3_b), .P (mul3_c) );
    dsp_mult mul4 ( .CLK (clock), .A (mul4_a), .B (mul4_b), .P (mul4_c) );
    dsp_mult mul5 ( .CLK (clock), .A (mul5_a), .B (mul5_b), .P (mul5_c) );
    dsp_mult mul6 ( .CLK (clock), .A (mul6_a), .B (mul6_b), .P (mul6_c) );

    assign mul0_a = const0;
    assign mul1_a = const1;
    assign mul2_a = const2;
    assign mul3_a = const3;
    assign mul4_a = const4;
    assign mul5_a = const5;
    assign mul6_a = const6;

    assign mul0_b = d_in;
    assign mul1_b = d_in;
    assign mul2_b = d_in;
    assign mul3_b = d_in;
    assign mul4_b = d_in;
    assign mul5_b = d_in;
    assign mul6_b = d_in;
    
    always @ (posedge clock) begin
        mul0_c_reg <= mul0_c;
        mul1_c_reg <= mul1_c;
        mul2_c_reg <= mul2_c;
        mul3_c_reg <= mul3_c;
        mul4_c_reg <= mul4_c;
        mul5_c_reg <= mul5_c;
        mul6_c_reg <= mul6_c;
    end

    ////////////////////////////////////////////////////////////////////////////

    wire add_clr;

    wire [59:0] add0_a; wire [62:0] add0_b; wire [62:0] add0_s; reg [62:0] add0_s_reg;
    wire [59:0] add1_a; wire [62:0] add1_b; wire [62:0] add1_s; reg [62:0] add1_s_reg;
    wire [59:0] add2_a; wire [62:0] add2_b; wire [62:0] add2_s; reg [62:0] add2_s_reg;
    wire [59:0] add3_a; wire [62:0] add3_b; wire [62:0] add3_s; reg [62:0] add3_s_reg;
    wire [59:0] add4_a; wire [62:0] add4_b; wire [62:0] add4_s; reg [62:0] add4_s_reg;
    wire [59:0] add5_a; wire [62:0] add5_b; wire [62:0] add5_s; reg [62:0] add5_s_reg;
    wire [59:0] add6_a; wire [62:0] add6_b; wire [62:0] add6_s; reg [62:0] add6_s_reg;

    lift_eq_add add0 ( .CLK(clock), .A(add0_a), .B(add0_b), .S(add0_s), .SCLR(add_clr) );
    lift_eq_add add1 ( .CLK(clock), .A(add1_a), .B(add1_b), .S(add1_s), .SCLR(add_clr) );
    lift_eq_add add2 ( .CLK(clock), .A(add2_a), .B(add2_b), .S(add2_s), .SCLR(add_clr) );
    lift_eq_add add3 ( .CLK(clock), .A(add3_a), .B(add3_b), .S(add3_s), .SCLR(add_clr) );
    lift_eq_add add4 ( .CLK(clock), .A(add4_a), .B(add4_b), .S(add4_s), .SCLR(add_clr) );
    lift_eq_add add5 ( .CLK(clock), .A(add5_a), .B(add5_b), .S(add5_s), .SCLR(add_clr) );
    lift_eq_add add6 ( .CLK(clock), .A(add6_a), .B(add6_b), .S(add6_s), .SCLR(add_clr) );
    
    assign add0_a   = mul0_c_reg;
    assign add1_a   = mul1_c_reg;
    assign add2_a   = mul2_c_reg;
    assign add3_a   = mul3_c_reg;
    assign add4_a   = mul4_c_reg;
    assign add5_a   = mul5_c_reg;
    assign add6_a   = mul6_c_reg;

    assign add0_b   = (clock_counter == 3'd5) ? 62'h0 : add0_s;
    assign add1_b   = (clock_counter == 3'd5) ? 62'h0 : add1_s;
    assign add2_b   = (clock_counter == 3'd5) ? 62'h0 : add2_s;
    assign add3_b   = (clock_counter == 3'd5) ? 62'h0 : add3_s;
    assign add4_b   = (clock_counter == 3'd5) ? 62'h0 : add4_s;
    assign add5_b   = (clock_counter == 3'd5) ? 62'h0 : add5_s;
    assign add6_b   = (clock_counter == 3'd5) ? 62'h0 : add6_s;
    
    always @ (posedge clock) begin
        if (clock_counter == 3'd5) begin
            add0_s_reg <= add0_s;
            add1_s_reg <= add1_s;
            add2_s_reg <= add2_s;
            add3_s_reg <= add3_s;
            add4_s_reg <= add4_s;
            add5_s_reg <= add5_s;
            add6_s_reg <= add6_s;
        end
    end

    assign add_clr  = reset;

    ////////////////////////////////////////////////////////////////////////////

    wire [62:0] red0_in; wire [29:0] red0_out; wire [ 3:0] red0_sel;

    windowed_reduction64bit_q_select red ( 
        .clk    (clock    ), 
        .q_sel  (red0_sel ), 
        .in     ({1'b0,red0_in}), 
        .out    (red0_out )
        );
    
    assign  red0_in =   (clock_counter == 3'd6) ?   add0_s_reg :
                        (clock_counter == 3'd0) ?   add1_s_reg :
                        (clock_counter == 3'd1) ?   add2_s_reg :
                        (clock_counter == 3'd2) ?   add3_s_reg :
                        (clock_counter == 3'd3) ?   add4_s_reg :
                        (clock_counter == 3'd4) ?   add5_s_reg :
                                                    add6_s_reg ;

    assign  red0_sel =  ( mode && clock_counter == 3'd6) ? 4'd00 :
                        ( mode && clock_counter == 3'd0) ? 4'd01 :
                        ( mode && clock_counter == 3'd1) ? 4'd02 :
                        ( mode && clock_counter == 3'd2) ? 4'd03 :
                        ( mode && clock_counter == 3'd3) ? 4'd04 :
                        ( mode && clock_counter == 3'd4) ? 4'd05 :
                        
                        (!mode && clock_counter == 3'd6) ? 4'd06 :
                        (!mode && clock_counter == 3'd0) ? 4'd07 :
                        (!mode && clock_counter == 3'd1) ? 4'd08 :
                        (!mode && clock_counter == 3'd2) ? 4'd09 :
                        (!mode && clock_counter == 3'd3) ? 4'd10 :
                        (!mode && clock_counter == 3'd4) ? 4'd11 :
                                                           4'd12 ;


    ////////////////////////////////////////////////////////////////////////////

    assign q = red0_out;

    reg [2:0] out_ready_pipe;

    always @ (posedge clock) begin
        if      (reset                 )  out_ready_pipe <= 3'b0;
        else if (start                 )  out_ready_pipe <= {1'b1, out_ready_pipe[2:1]};
        else if (clock_counter == 3'd6 )  out_ready_pipe <= {1'b0, out_ready_pipe[2:1]};
    end

    reg [3:0] q_valid_counter;

    always @ (posedge clock) begin
        if      (reset)                     
            q_valid_counter <= 3'd0;
        else if (out_ready_pipe[0] && clock_counter[2:0] == 3'd1 && mode)
            q_valid_counter <= 3'd6;
        else if (out_ready_pipe[0] && clock_counter[2:0] == 3'd1 && !mode)
            q_valid_counter <= 3'd7;
        else if (q_valid_counter > 4'd0)
            q_valid_counter <= q_valid_counter - 1;
    end
    
    assign q_valid = (q_valid_counter != 4'd0) ;

endmodule
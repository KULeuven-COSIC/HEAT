/*================================================================================
-This HDL-source code of the Ring-LWE Encryption Scheme is released under the 
MPL 1.1/GPL 2.0/LGPL 2.1 triple license.

------------------------------------------------------------------------------
Copyright (c) 2014, KU Leuven. All rights reserved.

The initial developer of this source code is Sujoy Sinha Roy, KU Leuven.
Contact Sujoy.SinhaRoy@esat.kuleuven.be for comments & questions.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright 
     notice, this list of conditions and the following disclaimer in 
     the documentation and/or other materials provided with the distribution.

  3. The names of the authors may not be used to endorse or promote products
     derived from this HDL-source code without specific prior written permission.

THIS HDL-SOURCE CODE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED 
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL KU LEUVEN OR 
ANY CONTRIBUTORS TO THIS HDL-SOURCE CODE BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT 
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

================================================================================*/


module NTT_control #(parameter core_index=1'b1)
		 (clk, rst, INSTRUCTION, NTT_ITERATION,
        m, primout_mask, addressin_nc, s, prim_counter, c4, c5_muxed,
        sel1, sel2, sel3, sel7, sel9, rdsel, wtsel1, wtsel2, wtsel3, mz_sel, addin_sel,
        wq_en, wea_pipelined, done,
        //j, k, wqeue_comp, wea_qeue, 
		  rdMsel, wtMsel, addra_NTT_ROM);

input clk, rst;
input [1:0] INSTRUCTION;	// 0 for forward NTT; 1 for backward NTT; 2 for coefficient re-arrangement
input [1:0] NTT_ITERATION;	// 2-bit consecutive NTT execution counter; 0 for one NTT, 1 for two consecutive NTTs...
									// In case of rearrangement, NTT_ITERATION=0; Rearrangement is inplace on the input memory  

output [12:0] m;
output  primout_mask;
output [10:0] addressin_nc;    // This is input to the address qeue in the data-path
output [3:0] s;
output [3:0] prim_counter;
output [2:0] c4;
output [1:0] c5_muxed;

output reg sel7, wq_en;
output reg [2:0] sel1;
output reg [1:0] sel2, rdsel, wtsel1, wtsel2, wtsel3;
output reg sel3;
output reg mz_sel;
output sel9;
output reg [1:0] addin_sel;
output wea_pipelined;
output done;
output [1:0] rdMsel, wtMsel;
output [12:0] addra_NTT_ROM;
////////////////////////////////////////////////////////////

assign {sel9} = 1'd0;

// counters
reg [3:0] prim_counter;
reg [4:0] c1;
reg [2:0] c4;    // this counter is used during loading of \si, \si*w, \si*w^2, \si*w^3 in FWD NTT
reg [1:0] c5;  // this counter is used to select one of wque1,..., wque4
wire c1_eq, c4_eq;
 
// Controls
reg k_inc, j_inc, m_inc, k_rst, j_rst, m_rst, c1_rst, c1_inc;
reg c4_inc, c4_rst, c5_rst, c5_inc, c5sel;
reg c4qen;
reg [1:0] c5qen;
reg wqeue_comp;        // when this is 1, the statemachine jumps to intermediate w^i, w^(i+1) .. computation
reg [1:0] c4q_inc;
reg [2:0] c5q_inc;
wire c4q_inc_out;
wire c5_inc_out;    // this is either c5_inc or c5q_inc[2]
reg jump1;	// this flag is 1 for 1 cycle after an intermediate jump from state wq-comp to state 9;
reg jump1_delayed; // delay of jump1 
reg jump2;  // this flag remains 1 after an intermediate jump to state 11; it is reset by state 30 during a new 'm' 
reg [2:0] last_write;	// last_write[0] and last_write[1] are used for LAST-1 and LAST RAM write after the intermediate jump from wq-comp to state9
reg wea;
reg [15:0] wea_qeue;

//// address generation block
reg [12:0] m;
reg [10:0] j;
reg [10:0] k;
reg [3:0] s;
wire primout_mask;
reg [5:0] state, nextstate;

reg [12:0] addra_NTT_ROM;
reg addra_NTT_ROM_inc_r0, addra_NTT_ROM_inc_r1, addra_NTT_ROM_inc_r2;

reg [3:0] wait_counter_befor_completion;
wire wait_counter_befor_completion_done;
reg wait_counter_befor_completion_done_r;

wire addra_NTT_ROM_inc = (((state==6'd9||state==6'd18) && c5_inc==1'b1) || (state==6'd35 && j_inc==1'b1)) ? 1'b1 : 1'b0;
wire addra_NTT_ROM_inc512 = (m==13'd4096 && state==6'd2) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
	wait_counter_befor_completion_done_r <= wait_counter_befor_completion_done;
	if(rst)
		wait_counter_befor_completion <= 4'd0;
	else if(state==6'd60 || state==6'd61 || state==6'd62)
		wait_counter_befor_completion <= wait_counter_befor_completion + 1'b1;
	else
		wait_counter_befor_completion <= 4'd0;
end

assign wait_counter_befor_completion_done = (wait_counter_befor_completion==4'd10) ? 1'b1 : 1'b0;		

always @(posedge clk)
begin
	if(rst) 
	begin
		addra_NTT_ROM_inc_r0<=1'b0; addra_NTT_ROM_inc_r1<=1'b0; addra_NTT_ROM_inc_r2<=1'b0;
	end
	else
	begin
		addra_NTT_ROM_inc_r0<=addra_NTT_ROM_inc;  addra_NTT_ROM_inc_r1<=addra_NTT_ROM_inc_r0; 
		addra_NTT_ROM_inc_r2<=addra_NTT_ROM_inc_r1;
	end
end

/*		
generate
   if (core_index==1'b0)
	begin
		always @(posedge clk)
		begin
			if(rst)
				addra_NTT_ROM <= 13'b0;
			else if(addra_NTT_ROM_inc512)
				addra_NTT_ROM <= addra_NTT_ROM + 13'd512;	
			else if((state>=6'd18 && addra_NTT_ROM_inc_r1==1'b1) || (state <=6'd18 && addra_NTT_ROM_inc_r2==1'b1))
				addra_NTT_ROM <= addra_NTT_ROM + 1'b1;
			else
				addra_NTT_ROM <= addra_NTT_ROM;	
		end		
	end

	else
	begin
		wire addra_NTT_ROM_inc_EM_n = (m==13'd2048 && state==6'd2) ? 1'b1 : 1'b0;
		always @(posedge clk)
		begin
			if(rst)
				addra_NTT_ROM <= 13'b0;
			else if(addra_NTT_ROM_inc_EM_n==1'b1)
				addra_NTT_ROM <= addra_NTT_ROM + 13'd512;	
			else if(addra_NTT_ROM_inc512==1'b1)
				addra_NTT_ROM <= addra_NTT_ROM + 13'd1024;					
			else if((state>=6'd18 && addra_NTT_ROM_inc_r1==1'b1) || (state <=6'd18 && addra_NTT_ROM_inc_r2==1'b1))
				addra_NTT_ROM <= addra_NTT_ROM + 1'b1;
			else
				addra_NTT_ROM <= addra_NTT_ROM;	
		end	
	end
endgenerate
*/

generate
   if (core_index==1'b0)
	begin
		always @(posedge clk)
		begin
			if(rst)
				addra_NTT_ROM <= 13'b0;
			else if(INSTRUCTION[0]==1'b1 && state==6'd33)
				addra_NTT_ROM <= 13'd4096;				
			else if(addra_NTT_ROM_inc512)
				addra_NTT_ROM <= addra_NTT_ROM + 13'd512;
			else if(state==6'd36 || state==6'd37 || state==6'd60)
				addra_NTT_ROM <= addra_NTT_ROM + 1'b1;				
			else if((state>=6'd18 && addra_NTT_ROM_inc_r1==1'b1) || (state <=6'd18 && addra_NTT_ROM_inc_r2==1'b1))
				addra_NTT_ROM <= addra_NTT_ROM + 1'b1;
			else
				addra_NTT_ROM <= addra_NTT_ROM;	
		end		
	end

	else
	begin
		wire addra_NTT_ROM_inc_EM_n = (m==13'd2048 && state==6'd2) ? 1'b1 : 1'b0;
		always @(posedge clk)
		begin
			if(rst)
				addra_NTT_ROM <= 13'b0;
			else if(INSTRUCTION[0]==1'b1 && state==6'd33)
				addra_NTT_ROM <= 13'd6144;				
			else if(addra_NTT_ROM_inc_EM_n==1'b1)
				addra_NTT_ROM <= addra_NTT_ROM + 13'd512;	
			else if(state==6'd36 || state==6'd37 || state==6'd60)
				addra_NTT_ROM <= addra_NTT_ROM + 1'b1;				
			else if(addra_NTT_ROM_inc512==1'b1)
				addra_NTT_ROM <= addra_NTT_ROM + 13'd1024;					
			else if((state>=6'd18 && addra_NTT_ROM_inc_r1==1'b1) || (state <=6'd18 && addra_NTT_ROM_inc_r2==1'b1))
				addra_NTT_ROM <= addra_NTT_ROM + 1'b1;
			else
				addra_NTT_ROM <= addra_NTT_ROM;	
		end	
	end
endgenerate


wire [12:0] k_add_m;
wire [11:0] j_add_1;
wire k_equal_w, j_equal_w;
reg k_equal, j_equal;
wire [10:0] j_bitrev;
wire bitrev_compare;

assign k_add_m = k + m;
assign j_add_1 = j + 1'd1;
assign j_bitrev = {j[0], j[1], j[2], j[3], j[4], j[5], j[6], j[7], j[8], j[9], j[10]};
assign bitrev_compare = (j_bitrev > j) ? 1'b1 : 1'b0;

assign primout_mask = (state==6'd7 || state==6'd8) ? 1'b1 : 1'b0;
 
always @(posedge clk)
begin
    if(k_rst==1'b1 && core_index==1'd0) k <= 11'd0;
	 else if(k_rst==1'b1 && core_index==1'd1 && m==13'd2048) k <= 11'd512;
	 else if(k_rst==1'b1 && core_index==1'd1) k <= 11'd1024;	 
    else if(k_inc) k <= k_add_m[10:0];
    else k <= k;
end
   
always @(posedge clk)
begin
    if(j_rst) j <= 11'd0;
    else if(j_inc) j <= j_add_1[10:0];
    else j <= j;
end

always @(posedge clk)
begin
    if(m_rst)
    begin m <= 13'd1; prim_counter <= 4'd0; end
    else if(m_inc)
    begin m <= {m[11:0],1'b0}; prim_counter <= prim_counter - 1'd1; end
    else
    begin m <= m; prim_counter <= prim_counter; end
end
   
       
//assign k_equal_w = (k_add_m[12] || k_add_m[11]) ? 1'b1 : 1'b0;
//assign k_equal_w = ( ((k_add_m[12] || k_add_m[11]) && (core_index==1'b1 || INSTRUCTION==2'd2)) || ((k_add_m[11] || k_add_m[10]) && core_index==1'b0) ) ? 1'b1 : 1'b0;
assign k_equal_w = ( ((k_add_m[12] || k_add_m[11]) && (core_index==1'b1 || INSTRUCTION==2'd2)) || ((k_add_m[11] || k_add_m[10]) && core_index==1'b0 && m[12]==1'b0) || ((k_add_m[12] || k_add_m[11]) && core_index==1'b0 && m[12]==1'b1)) ? 1'b1 : 1'b0;

//assign j_equal_w = (j_add_1[11:0]==(m[12:1])) ? 1'b1 : 1'b0;
assign j_equal_w =  ((m[11]==1'b1) && (j_add_1[10:0]==m[12:2])) ? 1'b1
						 :((m[12]==1'b1) && (j_add_1[10:0]==m[12:2])) ? 1'b1 
						 :(j_add_1[11:0]==m[12:1]) ? 1'b1
						 : 1'b0;

wire wqeue_comp_wire = (k_equal_w && (j[1:0]==2'd3 || j_equal_w)) ? 1'b1 : 1'b0;

    always @(posedge clk)
		j_equal <= j_equal_w;
    always @(posedge clk)
		k_equal <= k_equal_w;

    always @(posedge clk)
		wqeue_comp <= wqeue_comp_wire;





/// Counter defenitions
always @(posedge clk)
begin
    if(c1_rst)
        c1 <= 5'd0;
    else if (c1_inc)
        c1 <= c1 + 1'b1;
    else
        c1 <= c1;
end


always @(posedge clk)
	c4q_inc <= {c4q_inc[0],c4_inc & c4qen};

assign c4_inc_out = (c4qen) ? c4q_inc[0] : c4_inc;

always @(posedge clk)
begin
    if(c4_rst)
        c4 <= 3'd0;
    else if(c4_inc_out)
        c4 <= c4 + 1'd1;
    else
        c4 <= c4;
end       

always @(posedge clk)
c5q_inc <= {c5q_inc[1:0],c5_inc & (c5qen[0]|c5qen[1])};
   
assign c5_inc_out = (c5qen==2'd0) ? c5_inc 
                  : (c5qen==2'd1) ? c5q_inc[2] 
						: c5q_inc[1];

always @(posedge clk)
begin
    if(c5_rst)
        c5 <= 2'd0;
    else if(c5_inc_out && state==6'd35)
        c5 <= c5 + 2'd2;
	else if(c5_inc_out)
        c5 <= c5 + 1'd1;
    else
        c5 <= c5;
end
wire [1:0] c5_add1;	
assign c5_add1 = c5+1'b1 ;  
assign c5_muxed = (c5sel) ? c5_add1 : c5;

/* //Old values
assign c1_eq = (c1==5'd5) ? 1'b1 : 1'b0;
assign c4_eq = (c4==3'd04) ? 1'b1 : 1'b0;
*/

assign c1_eq = (c1==5'd6) ? 1'b1 : 1'b0;
assign c4_eq = (c4==3'd04) ? 1'b1 : 1'b0;	
	
	
always @(posedge clk)
begin
	if(state==5'd13 || state==5'd22)
		jump1 <= 1'b1;
	else
		jump1 <= 1'b0;
end		

always @(posedge clk)
begin
	{jump1_delayed, last_write[0], last_write[1], last_write[2]} <= {jump1, jump1_delayed, last_write[0], last_write[1]};	
end

always @(posedge clk)
begin
	if(state==6'd1 || state==6'd33)
		jump2 <= 1'b0;
	else if(state==6'd11 || state==6'd19 || state==6'd36)
		jump2 <= 1'b1;
	else 
		jump2 <= jump2;
end	

assign m_msb = m[12];


wire s_input;
assign s_input = (s[0]|s[1]) ? 1'b0 : bitrev_compare;

always @(posedge clk)
begin
    if(state==6'd41)
        s <= 4'd0;
    else   
        s <= {s[2:0],s_input};
end

assign done = (state == 6'd63) ? 1'b1 : 1'b0;   
assign addressin_nc = k + j;

always @(posedge clk)
begin
	if(rst)
		wea_qeue <= 16'd0;
	else
		wea_qeue <= {wea_qeue[14:0], wea};
end		
assign wea_pipelined = (state==6'd43) ? wea : wea_qeue[11];

//////////////////////////////////////////////////////////////
always @(posedge clk)
begin
    if(rst)
    state <= 6'd0;
    else
    state <= nextstate;
end   


////////////////////////////////////////////////////////////////////////
////////////		 READ and WRITE Memory Select Logic 			////
reg [1:0] rdMsel, wtMsel;
reg rdMsel_inc;
reg [1:0] wtMsel_inc_shift;	// 2-bit shift register to enable increment at a gap of 1 cycle
wire wtMsel_inc;
wire rdMsel_eq;

always @(posedge clk)
begin
	if(rst)
		rdMsel <= 2'd0;
	else if(rdMsel_inc && rdMsel==NTT_ITERATION)	
		rdMsel <= 2'd0; 		
	else if(rdMsel_inc)	
		rdMsel <= rdMsel + 1'b1;
	else
		rdMsel <= rdMsel;
end
assign rdMsel_eq = (rdMsel==NTT_ITERATION) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
	if(rst)
		wtMsel_inc_shift <=2'd1;
	else if(wea_pipelined)	
		wtMsel_inc_shift <= {wtMsel_inc_shift[0], wtMsel_inc_shift[1]};		//circular shift
	else 
		wtMsel_inc_shift <= wtMsel_inc_shift;
end
assign wtMsel_inc = (m_msb) ? wea_pipelined : wtMsel_inc_shift[1];
always @(posedge clk)
begin
	if(rst)
		wtMsel <= 2'd0;
	else if(wtMsel_inc && wtMsel==NTT_ITERATION)
		wtMsel <= 2'd0;
	else if(wtMsel_inc)
		wtMsel <= wtMsel + 1'b1;
	else
		wtMsel <= wtMsel;
end
//////////////////////////////////////////////////////////////////

always @(state or k_equal or j_equal or j_equal_w or c1_eq or c4_eq or j[1:0] or m_msb or s 
         or bitrev_compare or jump1 or jump2 or last_write or rdMsel_eq)			
begin
    case(state)
    6'd0: begin
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; m_inc<=0; k_rst<=1; j_rst<=1; m_rst<=1; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=0;  c4_rst<=1; c4_inc<=0; c5_rst<=1; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
            end
    //// Loading of the Omega-qeue
    6'd1: begin // increment m;
                sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=1; j_rst<=1; m_rst<=0; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=0;  c4_rst<=1; c4_inc<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
                if(m_msb) m_inc<=1'd0; else m_inc<=1'd1;        // This is for the rearrangement of coefficients after the last loop.           
            end


    6'd2: begin // load 1; qeue={x,x,x,1}
                sel1<=3'd3; sel2<=2'd1; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=0;  c4_rst<=0; c4_inc<=1; c5_rst<=1; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
            end
    6'd3: begin // load w; qeue={x,x,w,1}
                sel1<=3'd0; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=0;  c4_rst<=0; c4_inc<=1; c5_rst<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
            end
    6'd4: begin // load w^2 in wq0;
                sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=1; j_rst<=1; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=1;  c1_inc<=0;  c4_rst<=0; c4_inc<=1; c5_rst<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
            end
    6'd5: begin // Start Mult and continue: w^3=w*w^2; qeue={w^2,1,w,w^2}; c4=2'd3
                sel1<=3'd0; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c4_rst<=0; c5_rst<=0; c1_inc<=1;  c4_inc<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0;  rdMsel_inc<=0; 
              end
    6'd6: begin // load w^3; qeue={1,w,w^2,w^3}; RESET k and j and counter;
                sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=0;
                k_inc<=0; k_rst<=1; j_rst<=1; m_inc<=0; m_rst<=0; c4qen<=0;  addin_sel<=2'd0;
                c1_rst<=1;  c1_inc<=0;  c4_rst<=0; c4_inc<=0; c5_rst<=1; c5_inc<=0; c5sel<=1'd0;    // c4 and c5 are zero after this increment
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
	     			 j_inc<=0; c5qen<=2'd0; c5_inc<=0;				
            end


////////////////////////////////////////////////////////////////////////////////////
///////////////        Specific to the Forward NTT    //////////////////////////////
    6'd7: begin // Start Mult: \si*\qeue and stay in this state until c1 reaches limit; 
                sel1<=3'd3; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=1;  c4_rst<=1; c4_inc<=0; c5_rst<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
            end
    6'd8: begin // load \si*\qeue; qeue={1,w,w^2,w^3};
                sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wea<=0;
                k_inc<=0; k_rst<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=1;  c1_inc<=0;  c4_rst<=0; c5_rst<=1; c5_inc<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
			       if(c4_eq) begin c4_inc<=0; wq_en<=0; end
				    else begin c4_inc<=1; wq_en<=1; end
            end
/////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////
///////////////    Butterfly States (not for the last m-loop) NTT    ///////////////
    6'd9: begin // Fetch Rd1; 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wea<=1; 
                j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd1; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=1;  c4_rst<=0; c5_rst<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0; 
				
				if(k_equal && rdMsel_eq)
				begin
					c5_inc<=1;	k_inc<=0; // To select the w^(i+1)
					if(j_equal) begin k_rst<=0; j_inc<=0; end  //if(j[1:0]==2'd3 || j_equal)
					else begin k_rst<=1; j_inc<=1; end
				end		
				else if(rdMsel_eq) begin c5_inc<=0; k_rst<=0; k_inc<=1; j_inc<=0; end
				else begin c5_inc<=0; k_rst<=0; k_inc<=0; j_inc<=0; end
				
				if (jump1==1'b0 && jump2 && c4_eq==1'b0) begin c4_inc<=1; wq_en<=1; end	
				else begin c4_inc<=0; wq_en<=0; end
			end
    6'd10:begin // Fetch Rd2; 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd1;  wea<=1;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd1; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=1;  c4_rst<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=1;  
				
				if (jump1==1'b0 && jump2 && c4_eq==1'b0) begin c4_inc<=1; wq_en<=1; end
				else begin c4_inc<=0; wq_en<=0; end
			end
////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////
///////////////                w-qeue updation states                ///////////////
    6'd11: begin // Data of (last) Rd1 is now in (t1,u1); so start multiplication for the last butterfly. 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_rst<=0; k_inc<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=1;  c1_inc<=0;  c4_inc<=0; c4_rst<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
			end
    6'd12: begin // Data of last Rd2 is now in (t1,u1); so start multiplication for the last butterfly. 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=1;  c4_inc<=0; c4_rst<=0; c5_rst<=1; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  

				if(k_equal && j_equal==1'b0) 
				begin k_rst<=1; j_inc<=1; end
				else 
				begin k_rst<=0; j_inc<=0; end
			end			
    6'd13: begin // Multiplication loop w^4 * w^i; Stay in this state until (c1_eq) the first w-multiplication is over. 
                sel1<=3'd2; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=1;  c4_inc<=0; c4_rst<=1; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
				if(c1_eq) begin c1_rst<=1;  c5_rst<=1; end  // perform these operations before jump
				else begin c1_rst<=0;  c5_rst<=0; end 
			end
    6'd14: begin // Two state before the (Last-1) RAM write;  
                sel1<=3'd2; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=1; c1_rst<=0;   c4_inc<=0; c4_rst<=1; c5_rst<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
			end
    6'd15: begin // One state before the (Last-1) RAM write;  
                sel1<=3'd2; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=0; c1_rst<=0;   c4_inc<=0; c4_rst<=1; c5_rst<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
			end			
    6'd16:begin // RAM write for the(Last-1) of the previous butterfly; 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd1; wq_en<=0; wea<=0; 
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=0; c1_rst<=0;   c4_inc<=0; c4_rst<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
			end
    6'd17:begin // RAM write for the(Last) of the previous butterfly; 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd1; wq_en<=0; wea<=0; 
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=0; c1_rst<=0;   c4_inc<=0; c4_rst<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
			end
////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////
///////////////    Butterfly States (for the last m-loop) NTT    ///////////////
    6'd18:begin // Fetch J; 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; 
                k_rst<=0; k_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd2; addin_sel<=2'd0;
                c1_rst<=1;  c1_inc<=1; c4_rst<=0; c5_rst<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=1;
			
				if(j_equal_w || rdMsel_eq==1'b0) j_inc<=0; else j_inc<=1;
				if(j_equal) wea<=0; else wea<=1;  
				if(rdMsel_eq) c5_inc<=1; else c5_inc<=0;
				if(jump2==1'b1 && c4_eq==1'b0) begin c4_inc<=1; wq_en<=1; c4qen<=1; end
				else begin c4_inc<=0; wq_en<=0; c4qen<=0; end
//				if (c4_eq) begin c4_inc<=0; wq_en<=0; end 
//				else begin c4_inc<=1; wq_en<=1; end 	
			end

////////////////////////////////////////////////////////////////////////////////////
///////////////                w-qeue updation states (Last Loop)    ///////////////
    6'd19: begin // Data of (last) Rd1 is now in (t1,u1); so start multiplication for the last butterfly. 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wea<=0;
                k_rst<=0; k_inc<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd2; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=1; c4_rst<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=0;  
				if(jump2==1'b1 && c4_eq==1'b0) begin c4_inc<=1; wq_en<=1; c4qen<=1; end
				else begin c4_inc<=0; wq_en<=0; c4qen<=0; end
				//c4_inc<=0; wq_en<=0; c4qen<=1; 
			end
    6'd20: begin // Data of last Rd is now in (t1,u1); so start multiplication for the last butterfly. 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_rst<=0; k_inc<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd2; c4qen<=1; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=1; c4_inc<=0; c4_rst<=0; c5_rst<=1; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=0;  
			end			
    6'd21: begin // Multiplication loop w^4 * w^i; Stay in this state until (c1_eq) the first w-multiplication is over. 
                sel1<=3'd2; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=1; addin_sel<=2'd0;
                c1_inc<=1; c1_rst<=0;  c4_inc<=0; c4_rst<=1; c5_rst<=0; c5_inc<=1; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=0;
			end
    6'd22: begin // This state is visited two cycles before before the first of w^4*w^i result appears  
                sel1<=3'd2; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=0; c1_rst<=1;  c4_inc<=0; c4_rst<=1; c5_rst<=1; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=0;
			end			
    6'd23: begin // Three states before the Last RAM write;  
                sel1<=3'd2; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=1; c1_rst<=0;   c4_inc<=0; c4_rst<=1; c5_rst<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=0;  
			end
    6'd24: begin // Two states before the Last RAM write;  
                sel1<=3'd2; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0;  wea<=0;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=0; c1_rst<=0;   c4_inc<=0; c4_rst<=1; c5_rst<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=0;  
			end			
    6'd25:begin // One state before the Last RAM write; 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd1; wq_en<=0;  wea<=0;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=0; c1_rst<=0;   c4_inc<=0; c4_rst<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=0;  
			end
    6'd26:begin // RAM write for the(Last) of the previous butterfly; 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd1; wq_en<=0; wea<=0;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=0; c1_rst<=0;   c4_inc<=0; c4_rst<=1; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=0;  
			end
			
    6'd62: begin // END
                sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=0;  c4_rst<=0; c4_inc<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=0;              
            end			
////////////////////////////////////////////////////////////////////////////////////
			
			
////////////////////////////////////////////////////////////////////////////////////
///////////////                Scaling in backward NTT			     ///////////////
    6'd27: begin // load 1; qeue={x,x,x,1}; Reset j;
                sel1<=3'd3; sel2<=2'd1; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=1; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=0;  c4_rst<=0; c4_inc<=1; c5_rst<=1; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
            end
    6'd28: begin // load si^128=w^64; qeue={x,x,w^64,1}
                sel1<=3'd4; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=0;  c4_rst<=0; c4_inc<=1; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
            end
    6'd29: begin // load si; qeue={x,si,w^64,1}
                sel1<=3'd3; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=1; j_rst<=1; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=1;  c1_inc<=0;  c4_rst<=0; c4_inc<=1; c5_rst<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
            end
    6'd30: begin // Start Mult and continue: si^129=si*si^128;  c4=3; c5=2;
                sel1<=3'd3; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c4_rst<=0; c5_rst<=0; c1_inc<=1;  c4_inc<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0;  rdMsel_inc<=0; 
              end			
    6'd31: begin // load si^129; qeue={si^129,si,w^64,1}; RESET k and j and counter;
                sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=0;
                k_inc<=0; k_rst<=1; j_rst<=1; m_inc<=0; m_rst<=0; c4qen<=0;  addin_sel<=2'd0;
                c1_rst<=1;  c1_inc<=0;  c4_rst<=0; c4_inc<=0; c5_rst<=1; c5_inc<=0; c5sel<=1'd0;    // c4 and c5 are zero after this increment
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
					 j_inc<=0; c5qen<=2'd0; c5_inc<=0;				
            end			
    6'd32: begin // Start Mult: n_inverse*\qeue and stay in this state until c1 reaches limit; 
                sel1<=3'd3; sel2<=2'd1; sel3<=1'b1; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=1;  c4_rst<=1; c4_inc<=0; c5_rst<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
            end
    6'd33: begin // load n_inverse*\qeue;
                sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wea<=0;
                k_inc<=0; k_rst<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0; c5qen<=2'd0; addin_sel<=2'd0;  
                c1_rst<=1;  c1_inc<=0;  c4_rst<=0; c5_rst<=1; c5_inc<=0; c4qen<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
			    if(c4_eq) begin c4_inc<=0; wq_en<=0; end
				else begin c4_inc<=1; wq_en<=1; end
            end
			
	// The loop starts
	6'd34:begin // Fetch J; 
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wea<=1; 
                k_rst<=0; k_inc<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd1; addin_sel<=2'd2;
                c1_rst<=1;  c1_inc<=1; c4_rst<=0; c5_rst<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;

				if(rdMsel_eq) c5_inc<=1; else c5_inc<=0;	// increment c5 by 2
//				if(c4_eq) c4_inc<=0; else c4_inc<=1;	

				if(jump2==1'b1 && c4_eq==1'b0) begin c4_inc<=1; wq_en<=1; c4qen<=1; end
				else begin c4_inc<=0; wq_en<=0; c4qen<=0; end
			end
    6'd35:begin // Inc J; 
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b1; rdsel<=2'd0; wea<=0; 
                k_rst<=0; k_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd1; addin_sel<=2'd2;
                c1_rst<=1;  c1_inc<=1; c4_rst<=0; c5_rst<=0; c5sel<=1'd1; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=1;
				
				c5_inc<=0;
				if(j[0] || rdMsel_eq==1'b0) j_inc<=0; else j_inc<=1;
				if(jump2==1'b1 && c4_eq==1'b0) begin c4_inc<=1; wq_en<=1; c4qen<=1; end
				else begin c4_inc<=0; wq_en<=0; c4qen<=0; end

			end

	// The calculation of new powers of \si starts
	6'd36:begin // Trigger previous mult1; 
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=1; 
                k_rst<=0; k_inc<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=1; addin_sel<=2'd2;
                c1_rst<=1;  c1_inc<=1; c4_rst<=0; c4_inc<=0; c5_rst<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0; c5_inc<=0;
//				if(rdMsel_eq) c5_inc<=1; else c5_inc<=0;
			end
    6'd37:begin // Trigger previous mult2; 
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b1; rdsel<=2'd0; wq_en<=1; wea<=0; 
                k_rst<=0; k_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=1; addin_sel<=2'd2;
                c1_rst<=0;  c1_inc<=1; c4_rst<=1; c5_rst<=1; c5sel<=1'd1; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
					 c5_inc<=0; c4_inc<=0;
					 if(j_equal) j_inc<=0; else j_inc<=1;  // To detect end condition of the scaling
			end			

    6'd60: begin // Dummy Start Mult: si^2*\qeue and stay in this state until two cycles before the multiplication result
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=0; 
                k_rst<=0; k_inc<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=1; addin_sel<=2'd2;
                c1_rst<=1;  c1_inc<=1; c4_rst<=0; c4_inc<=0; c5_rst<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0; c5_inc<=0; 
            end
    6'd61:begin // Trigger previous mult2; 
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b1; rdsel<=2'd0; wq_en<=0; wea<=0; 
                k_rst<=0; k_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=1; addin_sel<=2'd2;
                c1_rst<=0;  c1_inc<=1; c4_rst<=1; c5_rst<=1; c5sel<=1'd1; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
					 c5_inc<=0; c4_inc<=0;
					 j_inc<=0;
			end				
	 /*				
    6'd61: begin // Dummy Start Mult: si^2*\qeue and stay in this state until two cycles before the multiplication result
                sel1<=3'd0; sel2<=2'd2; sel3<=1'b1; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd2;
                c1_rst<=0;  c1_inc<=1;  c4_rst<=1; c4_inc<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
					 if(c1_eq) c5_rst<=1; else c5_rst<=0;  
            end
	 */
    6'd38:begin // Trigger previous mult2; 
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b1; rdsel<=2'd0; wq_en<=1; wea<=0; 
                k_rst<=0; k_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=1; addin_sel<=2'd2;
                c1_rst<=0;  c1_inc<=1; c4_rst<=1; c5_rst<=1; c5sel<=1'd1; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
					 c5_inc<=0; c4_inc<=0; j_inc<=0;
			end
	6'd39:begin // End transition 1
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0; 
                k_rst<=0; k_inc<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd2; c4qen<=1; addin_sel<=2'd2;
                c1_rst<=1;  c1_inc<=1; c4_inc<=0; c4_rst<=0; c5_inc<=0; c5_rst<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=1;
			end			
	6'd40:begin // End transition 2
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0; 
                k_rst<=0; k_inc<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd2; c4qen<=1; addin_sel<=2'd2;
                c1_rst<=1;  c1_inc<=1; c4_inc<=0; c4_rst<=0; c5_inc<=0; c5_rst<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=1;
			end				
	


/////////////// Rearrangement State after (forward/backward) NTT  ////////////////			
	6'd41:begin // End transition 2
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0; 
                k_rst<=0; k_inc<=0; j_rst<=1; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd2; c4qen<=1; addin_sel<=2'd2;
                c1_rst<=1;  c1_inc<=1; c4_inc<=0; c4_rst<=0; c5_inc<=0; c5_rst<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=1;
			end	
	6'd42:begin // End transition 2
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0; 
                k_rst<=0; k_inc<=0; j_rst<=1; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd2; c4qen<=1; addin_sel<=2'd2;
                c1_rst<=1;  c1_inc<=1; c4_inc<=0; c4_rst<=0; c5_inc<=0; c5_rst<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=1;
			end				
	6'd43: begin 
					 sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd2; wq_en<=0;
					 k_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0; c5qen<=2'd2; c4qen<=1; addin_sel<=2'd2;
					 c1_rst<=1;  c1_inc<=1; c4_inc<=0; c4_rst<=0; c5_inc<=0; c5_rst<=0; c5sel<=1'd0; 
					 wtsel1<=3'd2; wtsel2<=2'd2; wtsel3<=2'd2; rdMsel_inc<=0;
					 if(s[2]|s[3]) wea<=1; else wea<=0;
				    if((s[0]|s[1]) & bitrev_compare) j_inc<=0; else j_inc<=1;  
			end	

			
			
    6'd63: begin // END
                sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=0;  c4_rst<=0; c4_inc<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;              
            end
    default: begin // END
                sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=0;  c4_rst<=0; c4_inc<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;              
            end   
   endcase
end   
   


always @(state or INSTRUCTION or k_equal or j_equal or c1_eq or c4_eq or wqeue_comp 
			or wqeue_comp_wire or m_msb or j[1:0] or rdMsel_eq or j_add_1[11] 
			or wait_counter_befor_completion_done or wait_counter_befor_completion_done_r)
begin
    case(state)
    6'd0: begin
					if(INSTRUCTION==2'd2)	// Rearrangement
						nextstate <= 6'd40;
					else							// forward or backward NTT
						nextstate <= 6'd01;
			end			
    6'd1: begin
                if(m_msb)    // This is the condition when run for m=256 finishes
                nextstate <= 6'd63;
                else
                nextstate <= 6'd2;   
            end
	 				
	//6'd2: begin
	//				if(m_msb==1'd0)    // Not the last loop
   //                 nextstate <= 6'd9;
   //             else   					// Jump to the loop for m=256
   //                 nextstate <= 6'd18;
   //         end
	

    6'd2: nextstate <= 6'd3;   
    6'd3: nextstate <= 6'd4;
    6'd4: nextstate <= 6'd5;
    6'd5: begin				// computation of w^3
                if(c1_eq)
                    nextstate <= 6'd6;
                else   
                    nextstate <= 6'd5;
            end       
    6'd6: begin
                if(INSTRUCTION[0]==1'd0 || INSTRUCTION[0]==1'd1) // Forward NTT and Inverse NTT
                    nextstate <= 6'd7;
                else if(m_msb==1'd0)    // Not the last loop
                    nextstate <= 6'd9;
                else   					// Jump to the loop for m=256
                    nextstate <= 6'd18;
            end
///// specific to FWD NTT /////
    6'd7: begin
                if(c1_eq)
                    nextstate <= 6'd8;
                else   
                    nextstate <= 6'd7;
            end
    6'd8: begin
                if(c4_eq==1'd0)
                    nextstate <= 6'd8;
                else if(m_msb==1'd0)    // Not the last loop
                    nextstate <= 6'd9;
                else					// Jump to the loop for m=256
                    nextstate <= 6'd18;
            end
////////////////////////////////// 
    6'd9: nextstate <= 6'd10;
    6'd10: begin
					if(k_equal && j_equal)
                  nextstate <= 6'd11;	
               else
						nextstate <= 6'd9;
            end
///////////////////////////////////   
    6'd11: nextstate <= 6'd12;
    6'd12: nextstate <= 6'd13;	
    6'd13: begin
				if(c1_eq && j_equal)
                    nextstate <= 6'd14;						
            else if(c1_eq)
                    nextstate <= 6'd09;
            else   
                    nextstate <= 6'd13;
            end	
///////////////////////////////////
    6'd14: nextstate <= 6'd15;
    6'd15: nextstate <= 6'd16;	
    6'd16: nextstate <= 6'd17;
    6'd17: nextstate <= 6'd01;
///////////////////////////////////
	
////// Butterfly Operations for m = 256 //////
    6'd18: begin 
					if(j_equal)
						nextstate <= 6'd26;
               else
						nextstate <= 6'd18;
            end
///////////////////////////////////   
    6'd19: nextstate <= 6'd20;
    6'd20: nextstate <= 6'd21;	
	 6'd21: begin
				if(c1_eq)
                    nextstate <= 6'd22;						
                else   
                    nextstate <= 6'd21;
            end	
///////////////////////////////////
    6'd22: begin
				if(j_equal)
					nextstate <= 6'd23;
				else
					nextstate <= 6'd18;
			end	
    6'd23: nextstate <= 6'd24;	
    6'd24: nextstate <= 6'd25;
    6'd25: nextstate <= 6'd26;
    6'd26: nextstate <= 6'd62;	 
    /*
	 6'd26: begin
				if(INSTRUCTION[0])
					nextstate <= 6'd62;
				else
					nextstate <= 6'd63;
			end		
	 */
//////// scaling for backward NTT ///////	
    6'd62: begin
					if(wait_counter_befor_completion_done & INSTRUCTION[0])
						nextstate <= 6'd27;
					else if(wait_counter_befor_completion_done)
						nextstate <= 6'd63;
					else
						nextstate <= 6'd62;
				end		
    6'd27: nextstate <= 6'd28;	
    6'd28: nextstate <= 6'd29;
    6'd29: nextstate <= 6'd30;	
    6'd30:  begin
				if(c1_eq)
                    nextstate <= 6'd31;						
                else   
                    nextstate <= 6'd30;
            end
    6'd31: nextstate <= 6'd32;		
    6'd32:  begin
				if(c1_eq)
                    nextstate <= 6'd33;						
                else   
                    nextstate <= 6'd32;
            end			
    6'd33:  begin
				if(c4_eq)
                    nextstate <= 6'd34;						
                else   
                    nextstate <= 6'd33;
            end			
    6'd34: nextstate <= 6'd35;
    6'd35: nextstate <= 6'd36;	 
	 /*
    6'd35: begin
				if(j[0] && rdMsel_eq)
					nextstate <= 6'd36;	
				else
					nextstate <= 6'd34;
			end		
	 */		
    6'd36: nextstate <= 6'd37;
    6'd37: begin
					if(j_equal)
						nextstate <= 6'd60;
					else
						nextstate <= 6'd36;	
				end

	 6'd60: nextstate <= 6'd61; 							
    6'd61: begin
					if(wait_counter_befor_completion_done_r)
						nextstate <= 6'd63;
					else
						nextstate <= 6'd60;
				end	
	 /* 			
    6'd60: begin
					if(wait_counter_befor_completion_done)
						nextstate <= 6'd61;
					else
						nextstate <= 6'd60;
				end	
	 6'd61: nextstate <= 6'd63; 			
	 */
    6'd38:  begin
				if(j_equal && c1_eq)		// jump to end transition
					nextstate <= 6'd39;
				else if(c1_eq)
                    nextstate <= 6'd34;						
                else   
                    nextstate <= 6'd38;
            end			
    6'd39: nextstate <= 6'd40;

//// Rearrangement states
    6'd40: begin
				if(INSTRUCTION==2'd1)
				nextstate <= 6'd63;
				else
				nextstate <= 6'd41;
			end	
    6'd41: nextstate <= 6'd42;	 
	 6'd42: nextstate <= 6'd43;
	 6'd43: begin
				if(j_add_1[11])
					nextstate <= 6'd63;
				else
					nextstate <= 6'd43;
			end			
			
    6'd63: nextstate <= 6'd63;
	
    default: nextstate <= 6'd0;
	endcase
end

   
	
endmodule



/*
module NTT_control #(parameter core_index=1'b1)
		 (clk, rst, INSTRUCTION, NTT_ITERATION,
        m, primout_mask, addressin_nc, s, prim_counter, c4, c5_muxed,
        sel1, sel2, sel3, sel7, sel9, rdsel, wtsel1, wtsel2, wtsel3, mz_sel, addin_sel,
        wq_en, wea_pipelined, done,
        //j, k, wqeue_comp, wea_qeue, 
		  rdMsel, wtMsel);

input clk, rst;
input [1:0] INSTRUCTION;	// 0 for forward NTT; 1 for backward NTT; 2 for coefficient re-arrangement
input [1:0] NTT_ITERATION;	// 2-bit consecutive NTT execution counter; 0 for one NTT, 1 for two consecutive NTTs...
									// In case of rearrangement, NTT_ITERATION=0; Rearrangement is inplace on the input memory  

output [12:0] m;
output  primout_mask;
output [10:0] addressin_nc;    // This is input to the address qeue in the data-path
output [3:0] s;
output [3:0] prim_counter;
output [2:0] c4;
output [1:0] c5_muxed;

output reg sel7, wq_en;
output reg [2:0] sel1;
output reg [1:0] sel2, rdsel, wtsel1, wtsel2, wtsel3;
output reg sel3;
output reg mz_sel;
output sel9;
output reg [1:0] addin_sel;
output wea_pipelined;
output done;
output [1:0] rdMsel, wtMsel;
////////////////////////////////////////////////////////////

assign {sel9} = 1'd0;

// counters
reg [3:0] prim_counter;
reg [4:0] c1;
reg [2:0] c4;    // this counter is used during loading of \si, \si*w, \si*w^2, \si*w^3 in FWD NTT
reg [1:0] c5;  // this counter is used to select one of wque1,..., wque4
wire c1_eq, c4_eq;
 
// Controls
reg k_inc, j_inc, m_inc, k_rst, j_rst, m_rst, c1_rst, c1_inc;
reg c4_inc, c4_rst, c5_rst, c5_inc, c5sel;
reg c4qen;
reg [1:0] c5qen;
reg wqeue_comp;        // when this is 1, the statemachine jumps to intermediate w^i, w^(i+1) .. computation
reg [1:0] c4q_inc;
reg [2:0] c5q_inc;
wire c4q_inc_out;
wire c5_inc_out;    // this is either c5_inc or c5q_inc[2]
reg jump1;	// this flag is 1 for 1 cycle after an intermediate jump from state wq-comp to state 9;
reg jump1_delayed; // delay of jump1 
reg jump2;  // this flag remains 1 after an intermediate jump to state 11; it is reset by state 30 during a new 'm' 
reg [2:0] last_write;	// last_write[0] and last_write[1] are used for LAST-1 and LAST RAM write after the intermediate jump from wq-comp to state9
reg wea;
reg [15:0] wea_qeue;

//// address generation block
reg [12:0] m;
reg [10:0] j;
reg [10:0] k;
reg [3:0] s;
wire primout_mask;
reg [5:0] state, nextstate;

wire [12:0] k_add_m;
wire [11:0] j_add_1;
wire k_equal_w, j_equal_w;
reg k_equal, j_equal;
wire [10:0] j_bitrev;
wire bitrev_compare;

assign k_add_m = k + m;
assign j_add_1 = j + 1'd1;
assign j_bitrev = {j[0], j[1], j[2], j[3], j[4], j[5], j[6], j[7], j[8], j[9], j[10]};
assign bitrev_compare = (j_bitrev > j) ? 1'b1 : 1'b0;

assign primout_mask = (state==6'd7 || state==6'd8) ? 1'b1 : 1'b0;
 
always @(posedge clk)
begin
    if(k_rst==1'b1 && core_index==1'd0) k <= 11'd0;
	 else if(k_rst==1'b1 && core_index==1'd1 && m==13'd2048) k <= 11'd512;
	 else if(k_rst==1'b1 && core_index==1'd1) k <= 11'd1024;	 
    else if(k_inc) k <= k_add_m[10:0];
    else k <= k;
end
   
always @(posedge clk)
begin
    if(j_rst) j <= 11'd0;
    else if(j_inc) j <= j_add_1[10:0];
    else j <= j;
end

always @(posedge clk)
begin
    if(m_rst)
    begin m <= 13'd1; prim_counter <= 4'd0; end
    else if(m_inc)
    begin m <= {m[11:0],1'b0}; prim_counter <= prim_counter - 1'd1; end
    else
    begin m <= m; prim_counter <= prim_counter; end
end
   
       
//assign k_equal_w = (k_add_m[12] || k_add_m[11]) ? 1'b1 : 1'b0;
//assign k_equal_w = ( ((k_add_m[12] || k_add_m[11]) && (core_index==1'b1 || INSTRUCTION==2'd2)) || ((k_add_m[11] || k_add_m[10]) && core_index==1'b0) ) ? 1'b1 : 1'b0;
assign k_equal_w = ( ((k_add_m[12] || k_add_m[11]) && (core_index==1'b1 || INSTRUCTION==2'd2)) || ((k_add_m[11] || k_add_m[10]) && core_index==1'b0 && m[12]==1'b0) || ((k_add_m[12] || k_add_m[11]) && core_index==1'b0 && m[12]==1'b1)) ? 1'b1 : 1'b0;

//assign j_equal_w = (j_add_1[11:0]==(m[12:1])) ? 1'b1 : 1'b0;
assign j_equal_w =  ((m[11]==1'b1) && (j_add_1[10:0]==m[12:2])) ? 1'b1
						 :((m[12]==1'b1) && (j_add_1[10:0]==m[12:2])) ? 1'b1 
						 :(j_add_1[11:0]==m[12:1]) ? 1'b1
						 : 1'b0;

assign wqeue_comp_wire = (k_equal_w && (j[1:0]==2'd3 || j_equal_w)) ? 1'b1 : 1'b0;

    always @(posedge clk)
		j_equal <= j_equal_w;
    always @(posedge clk)
		k_equal <= k_equal_w;

    always @(posedge clk)
		wqeue_comp <= wqeue_comp_wire;





/// Counter defenitions
always @(posedge clk)
begin
    if(c1_rst)
        c1 <= 5'd0;
    else if (c1_inc)
        c1 <= c1 + 1'b1;
    else
        c1 <= c1;
end


always @(posedge clk)
	c4q_inc <= {c4q_inc[0],c4_inc & c4qen};

assign c4_inc_out = (c4qen) ? c4q_inc[0] : c4_inc;

always @(posedge clk)
begin
    if(c4_rst)
        c4 <= 3'd0;
    else if(c4_inc_out)
        c4 <= c4 + 1'd1;
    else
        c4 <= c4;
end       

always @(posedge clk)
c5q_inc <= {c5q_inc[1:0],c5_inc & (c5qen[0]|c5qen[1])};
   
assign c5_inc_out = (c5qen==2'd0) ? c5_inc 
                  : (c5qen==2'd1) ? c5q_inc[2] 
						: c5q_inc[1];

always @(posedge clk)
begin
    if(c5_rst)
        c5 <= 2'd0;
    else if(c5_inc_out && state==6'd35)
        c5 <= c5 + 2'd2;
	else if(c5_inc_out)
        c5 <= c5 + 1'd1;
    else
        c5 <= c5;
end
wire [1:0] c5_add1;	
assign c5_add1 = c5+1'b1 ;  
assign c5_muxed = (c5sel) ? c5_add1 : c5;

//Old values
//assign c1_eq = (c1==5'd5) ? 1'b1 : 1'b0;
//assign c4_eq = (c4==3'd04) ? 1'b1 : 1'b0;


assign c1_eq = (c1==5'd6) ? 1'b1 : 1'b0;
assign c4_eq = (c4==3'd04) ? 1'b1 : 1'b0;	
	
	
always @(posedge clk)
begin
	if(state==5'd13 || state==5'd22)
		jump1 <= 1'b1;
	else
		jump1 <= 1'b0;
end		

always @(posedge clk)
begin
	{jump1_delayed, last_write[0], last_write[1], last_write[2]} <= {jump1, jump1_delayed, last_write[0], last_write[1]};	
end

always @(posedge clk)
begin
	if(state==6'd1 || state==6'd33)
		jump2 <= 1'b0;
	else if(state==6'd11 || state==6'd19 || state==6'd36)
		jump2 <= 1'b1;
	else 
		jump2 <= jump2;
end	

assign m_msb = m[12];


wire s_input;
assign s_input = (s[0]|s[1]) ? 1'b0 : bitrev_compare;

always @(posedge clk)
begin
    if(state==6'd41)
        s <= 4'd0;
    else   
        s <= {s[2:0],s_input};
end

assign done = (state == 6'd63) ? 1'b1 : 1'b0;   
assign addressin_nc = k + j;

always @(posedge clk)
begin
	if(rst)
		wea_qeue <= 16'd0;
	else
		wea_qeue <= {wea_qeue[14:0], wea};
end		
assign wea_pipelined = (state==6'd43) ? wea : wea_qeue[11];

//////////////////////////////////////////////////////////////
always @(posedge clk)
begin
    if(rst)
    state <= 6'd0;
    else
    state <= nextstate;
end   


////////////////////////////////////////////////////////////////////////
////////////		 READ and WRITE Memory Select Logic 			////
reg [1:0] rdMsel, wtMsel;
reg rdMsel_inc;
reg [1:0] wtMsel_inc_shift;	// 2-bit shift register to enable increment at a gap of 1 cycle
wire wtMsel_inc;
wire rdMsel_eq;

always @(posedge clk)
begin
	if(rst)
		rdMsel <= 2'd0;
	else if(rdMsel_inc && rdMsel==NTT_ITERATION)	
		rdMsel <= 2'd0; 		
	else if(rdMsel_inc)	
		rdMsel <= rdMsel + 1'b1;
	else
		rdMsel <= rdMsel;
end
assign rdMsel_eq = (rdMsel==NTT_ITERATION) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
	if(rst)
		wtMsel_inc_shift <=2'd1;
	else if(wea_pipelined)	
		wtMsel_inc_shift <= {wtMsel_inc_shift[0], wtMsel_inc_shift[1]};		//circular shift
	else 
		wtMsel_inc_shift <= wtMsel_inc_shift;
end
assign wtMsel_inc = (m_msb) ? wea_pipelined : wtMsel_inc_shift[1];
always @(posedge clk)
begin
	if(rst)
		wtMsel <= 2'd0;
	else if(wtMsel_inc && wtMsel==NTT_ITERATION)
		wtMsel <= 2'd0;
	else if(wtMsel_inc)
		wtMsel <= wtMsel + 1'b1;
	else
		wtMsel <= wtMsel;
end
//////////////////////////////////////////////////////////////////



		
always @(state or k_equal or j_equal or j_equal_w or c1_eq or c4_eq or j[1:0] or m_msb or s 
         or bitrev_compare or jump1 or jump2 or last_write or rdMsel_eq)			
begin
    case(state)
    6'd0: begin
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; m_inc<=0; k_rst<=1; j_rst<=1; m_rst<=1; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=0;  c4_rst<=1; c4_inc<=0; c5_rst<=1; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
            end
    //// Loading of the Omega-qeue
    6'd1: begin // increment m;
                sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=1; j_rst<=1; m_rst<=0; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=0;  c4_rst<=1; c4_inc<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
                if(m_msb) m_inc<=1'd0; else m_inc<=1'd1;        // This is for the rearrangement of coefficients after the last loop.           
            end


    6'd2: begin // load 1; qeue={x,x,x,1}
                sel1<=3'd3; sel2<=2'd1; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=0;  c4_rst<=0; c4_inc<=1; c5_rst<=1; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
            end
    6'd3: begin // load w; qeue={x,x,w,1}
                sel1<=3'd0; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=0;  c4_rst<=0; c4_inc<=1; c5_rst<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
            end
    6'd4: begin // load w^2 in wq0;
                sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=1; j_rst<=1; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=1;  c1_inc<=0;  c4_rst<=0; c4_inc<=1; c5_rst<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
            end
    6'd5: begin // Start Mult and continue: w^3=w*w^2; qeue={w^2,1,w,w^2}; c4=2'd3
                sel1<=3'd0; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c4_rst<=0; c5_rst<=0; c1_inc<=1;  c4_inc<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0;  rdMsel_inc<=0; 
              end
    6'd6: begin // load w^3; qeue={1,w,w^2,w^3}; RESET k and j and counter;
                sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=0;
                k_inc<=0; k_rst<=1; j_rst<=1; m_inc<=0; m_rst<=0; c4qen<=0;  addin_sel<=2'd0;
                c1_rst<=1;  c1_inc<=0;  c4_rst<=0; c4_inc<=0; c5_rst<=1; c5_inc<=0; c5sel<=1'd0;    // c4 and c5 are zero after this increment
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
	     			 j_inc<=0; c5qen<=2'd0; c5_inc<=0;				
            end


////////////////////////////////////////////////////////////////////////////////////
///////////////        Specific to the Forward NTT    //////////////////////////////
    6'd7: begin // Start Mult: \si*\qeue and stay in this state until c1 reaches limit; 
                sel1<=3'd3; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=1;  c4_rst<=1; c4_inc<=0; c5_rst<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
            end
    6'd8: begin // load \si*\qeue; qeue={1,w,w^2,w^3};
                sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wea<=0;
                k_inc<=0; k_rst<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=1;  c1_inc<=0;  c4_rst<=0; c5_rst<=1; c5_inc<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
			       if(c4_eq) begin c4_inc<=0; wq_en<=0; end
				    else begin c4_inc<=1; wq_en<=1; end
            end
/////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////
///////////////    Butterfly States (not for the last m-loop) NTT    ///////////////
    6'd9: begin // Fetch Rd1; 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wea<=1; 
                j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd1; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=1;  c4_rst<=0; c5_rst<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0; 
				
				if(k_equal && rdMsel_eq)
				begin
					c5_inc<=1;	k_inc<=0; // To select the w^(i+1)
					if(j[1:0]==2'd3 || j_equal) begin k_rst<=0; j_inc<=0; end
					else begin k_rst<=1; j_inc<=1; end
				end		
				else if(rdMsel_eq) begin c5_inc<=0; k_rst<=0; k_inc<=1; j_inc<=0; end
				else begin c5_inc<=0; k_rst<=0; k_inc<=0; j_inc<=0; end
				
				if (jump1==1'b0 && jump2 && c4_eq==1'b0) begin c4_inc<=1; wq_en<=1; end	
				else begin c4_inc<=0; wq_en<=0; end
			end
    6'd10:begin // Fetch Rd2; 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd1;  wea<=1;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd1; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=1;  c4_rst<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=1;  
				
				if (jump1==1'b0 && jump2 && c4_eq==1'b0) begin c4_inc<=1; wq_en<=1; end
				else begin c4_inc<=0; wq_en<=0; end
			end
////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////
///////////////                w-qeue updation states                ///////////////
    6'd11: begin // Data of (last) Rd1 is now in (t1,u1); so start multiplication for the last butterfly. 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_rst<=0; k_inc<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=1;  c1_inc<=0;  c4_inc<=0; c4_rst<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
			end
    6'd12: begin // Data of last Rd2 is now in (t1,u1); so start multiplication for the last butterfly. 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=1;  c4_inc<=0; c4_rst<=0; c5_rst<=1; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  

				if(k_equal && j_equal==1'b0) 
				begin k_rst<=1; j_inc<=1; end
				else 
				begin k_rst<=0; j_inc<=0; end
			end			
    6'd13: begin // Multiplication loop w^4 * w^i; Stay in this state until (c1_eq) the first w-multiplication is over. 
                sel1<=3'd2; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=1;  c4_inc<=0; c4_rst<=1; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
				if(c1_eq) begin c1_rst<=1;  c5_rst<=1; end  // perform these operations before jump
				else begin c1_rst<=0;  c5_rst<=0; end 
			end
    6'd14: begin // Two state before the (Last-1) RAM write;  
                sel1<=3'd2; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=1; c1_rst<=0;   c4_inc<=0; c4_rst<=1; c5_rst<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
			end
    6'd15: begin // One state before the (Last-1) RAM write;  
                sel1<=3'd2; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=0; c1_rst<=0;   c4_inc<=0; c4_rst<=1; c5_rst<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
			end			
    6'd16:begin // RAM write for the(Last-1) of the previous butterfly; 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd1; wq_en<=0; wea<=0; 
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=0; c1_rst<=0;   c4_inc<=0; c4_rst<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
			end
    6'd17:begin // RAM write for the(Last) of the previous butterfly; 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd1; wq_en<=0; wea<=0; 
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=0; c1_rst<=0;   c4_inc<=0; c4_rst<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
			end
////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////
///////////////    Butterfly States (for the last m-loop) NTT    ///////////////
    6'd18:begin // Fetch J; 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wea<=1; 
                k_rst<=0; k_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd2; addin_sel<=2'd0;
                c1_rst<=1;  c1_inc<=1; c4_rst<=0; c5_rst<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=1;
			
				if(j_equal_w || rdMsel_eq==1'b0) j_inc<=0; else j_inc<=1;
				if(rdMsel_eq) c5_inc<=1; else c5_inc<=0;
				if(jump2==1'b1 && c4_eq==1'b0) begin c4_inc<=1; wq_en<=1; c4qen<=1; end
				else begin c4_inc<=0; wq_en<=0; c4qen<=0; end
//				if (c4_eq) begin c4_inc<=0; wq_en<=0; end 
//				else begin c4_inc<=1; wq_en<=1; end 	
			end

////////////////////////////////////////////////////////////////////////////////////
///////////////                w-qeue updation states (Last Loop)    ///////////////
    6'd19: begin // Data of (last) Rd1 is now in (t1,u1); so start multiplication for the last butterfly. 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wea<=0;
                k_rst<=0; k_inc<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd2; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=1; c4_rst<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=0;  
				if(jump2==1'b1 && c4_eq==1'b0) begin c4_inc<=1; wq_en<=1; c4qen<=1; end
				else begin c4_inc<=0; wq_en<=0; c4qen<=0; end
				//c4_inc<=0; wq_en<=0; c4qen<=1; 
			end
    6'd20: begin // Data of last Rd is now in (t1,u1); so start multiplication for the last butterfly. 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_rst<=0; k_inc<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd2; c4qen<=1; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=1; c4_inc<=0; c4_rst<=0; c5_rst<=1; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=0;  
			end			
    6'd21: begin // Multiplication loop w^4 * w^i; Stay in this state until (c1_eq) the first w-multiplication is over. 
                sel1<=3'd2; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=1; addin_sel<=2'd0;
                c1_inc<=1; c1_rst<=0;  c4_inc<=0; c4_rst<=1; c5_rst<=0; c5_inc<=1; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=0;
			end
    6'd22: begin // This state is visited two cycles before before the first of w^4*w^i result appears  
                sel1<=3'd2; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=0; c1_rst<=1;  c4_inc<=0; c4_rst<=1; c5_rst<=1; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=0;
			end			
    6'd23: begin // Three states before the Last RAM write;  
                sel1<=3'd2; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=1; c1_rst<=0;   c4_inc<=0; c4_rst<=1; c5_rst<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=0;  
			end
    6'd24: begin // Two states before the Last RAM write;  
                sel1<=3'd2; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0;  wea<=0;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=0; c1_rst<=0;   c4_inc<=0; c4_rst<=1; c5_rst<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=0;  
			end			
    6'd25:begin // One state before the Last RAM write; 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd1; wq_en<=0;  wea<=0;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=0; c1_rst<=0;   c4_inc<=0; c4_rst<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=0;  
			end
    6'd26:begin // RAM write for the(Last) of the previous butterfly; 
                sel1<=3'd0; sel2<=2'd0; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd1; wea<=1; wq_en<=0; wea<=0;
                k_inc<=0; k_rst<=0; j_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_inc<=0; c1_rst<=0;   c4_inc<=0; c4_rst<=1; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd1; rdMsel_inc<=0;  
			end
////////////////////////////////////////////////////////////////////////////////////
			
			
////////////////////////////////////////////////////////////////////////////////////
///////////////                Scaling in backward NTT			     ///////////////
    6'd27: begin // load 1; qeue={x,x,x,1}; Reset j;
                sel1<=3'd3; sel2<=2'd1; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=1; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=0;  c4_rst<=0; c4_inc<=1; c5_rst<=1; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
            end
    6'd28: begin // load si^128=w^64; qeue={x,x,w^64,1}
                sel1<=3'd4; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=0;  c4_rst<=0; c4_inc<=1; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
            end
    6'd29: begin // load si; qeue={x,si,w^64,1}
                sel1<=3'd3; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=1; j_rst<=1; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=1;  c1_inc<=0;  c4_rst<=0; c4_inc<=1; c5_rst<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
            end
    6'd30: begin // Start Mult and continue: si^129=si*si^128;  c4=3; c5=2;
                sel1<=3'd3; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c4_rst<=0; c5_rst<=0; c1_inc<=1;  c4_inc<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0;  rdMsel_inc<=0; 
              end			
    6'd31: begin // load si^129; qeue={si^129,si,w^64,1}; RESET k and j and counter;
                sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=0;
                k_inc<=0; k_rst<=1; j_rst<=1; m_inc<=0; m_rst<=0; c4qen<=0;  addin_sel<=2'd0;
                c1_rst<=1;  c1_inc<=0;  c4_rst<=0; c4_inc<=0; c5_rst<=1; c5_inc<=0; c5sel<=1'd0;    // c4 and c5 are zero after this increment
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
					 j_inc<=0; c5qen<=2'd0; c5_inc<=0;				
            end			
    6'd32: begin // Start Mult: n_inverse*\qeue and stay in this state until c1 reaches limit; 
                sel1<=3'd3; sel2<=2'd1; sel3<=1'b1; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=1;  c4_rst<=1; c4_inc<=0; c5_rst<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
            end
    6'd33: begin // load n_inverse*\qeue;
                sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wea<=0;
                k_inc<=0; k_rst<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0; c5qen<=2'd0; addin_sel<=2'd0;  
                c1_rst<=1;  c1_inc<=0;  c4_rst<=0; c5_rst<=1; c5_inc<=0; c4qen<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
			    if(c4_eq) begin c4_inc<=0; wq_en<=0; end
				else begin c4_inc<=1; wq_en<=1; end
            end
			
	// The loop starts
	6'd34:begin // Fetch J; 
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wea<=1; 
                k_rst<=0; k_inc<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd1; addin_sel<=2'd2;
                c1_rst<=1;  c1_inc<=1; c4_rst<=0; c5_rst<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;

				if(rdMsel_eq) c5_inc<=1; else c5_inc<=0;	// increment c5 by 2
//				if(c4_eq) c4_inc<=0; else c4_inc<=1;	

				if(jump2==1'b1 && c4_eq==1'b0) begin c4_inc<=1; wq_en<=1; c4qen<=1; end
				else begin c4_inc<=0; wq_en<=0; c4qen<=0; end
			end
    6'd35:begin // Inc J; 
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b1; rdsel<=2'd0; wea<=0; 
                k_rst<=0; k_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd1; addin_sel<=2'd2;
                c1_rst<=1;  c1_inc<=1; c4_rst<=0; c5_rst<=0; c5sel<=1'd1; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=1;
				
				c5_inc<=0;
				if(j[0] || rdMsel_eq==1'b0) j_inc<=0; else j_inc<=1;
				if(jump2==1'b1 && c4_eq==1'b0) begin c4_inc<=1; wq_en<=1; c4qen<=1; end
				else begin c4_inc<=0; wq_en<=0; c4qen<=0; end

			end

	// The calculation of new powers of \si starts
	6'd36:begin // Trigger previous mult1; 
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=1; wea<=0; 
                k_rst<=0; k_inc<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=1; addin_sel<=2'd2;
                c1_rst<=1;  c1_inc<=1; c4_rst<=0; c4_inc<=0; c5_rst<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0; c5_inc<=0;
//				if(rdMsel_eq) c5_inc<=1; else c5_inc<=0;
			end
    6'd37:begin // Trigger previous mult2; 
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b1; rdsel<=2'd0; wq_en<=1; wea<=0; 
                k_rst<=0; k_inc<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=1; addin_sel<=2'd2;
                c1_rst<=0;  c1_inc<=1; c4_rst<=1; c5_rst<=1; c5sel<=1'd1; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;
			    c5_inc<=0; c4_inc<=0;
				if(j_equal) j_inc<=0; else j_inc<=1;  // To detect end condition of the scaling
			end			

    6'd38: begin // Start Mult: si^2*\qeue and stay in this state until two cycles before the multiplication result
                sel1<=3'd0; sel2<=2'd2; sel3<=1'b1; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd0; c4qen<=0; addin_sel<=2'd2;
                c1_rst<=0;  c1_inc<=1;  c4_rst<=1; c4_inc<=0; c5_inc<=1; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;  
				if(c1_eq) c5_rst<=1; else c5_rst<=0;  
            end

	6'd39:begin // End transition 1
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0; 
                k_rst<=0; k_inc<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd2; c4qen<=1; addin_sel<=2'd2;
                c1_rst<=1;  c1_inc<=1; c4_inc<=0; c4_rst<=0; c5_inc<=0; c5_rst<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=1;
			end			
	6'd40:begin // End transition 2
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0; 
                k_rst<=0; k_inc<=0; j_rst<=0; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd2; c4qen<=1; addin_sel<=2'd2;
                c1_rst<=1;  c1_inc<=1; c4_inc<=0; c4_rst<=0; c5_inc<=0; c5_rst<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=1;
			end				
	


/////////////// Rearrangement State after (forward/backward) NTT  ////////////////			
	6'd41:begin // End transition 2
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0; 
                k_rst<=0; k_inc<=0; j_rst<=1; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd2; c4qen<=1; addin_sel<=2'd2;
                c1_rst<=1;  c1_inc<=1; c4_inc<=0; c4_rst<=0; c5_inc<=0; c5_rst<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=1;
			end	
	6'd42:begin // End transition 2
                sel1<=3'd0; sel2<=2'd3; sel3<=1'b0; sel7<=1'd1; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0; 
                k_rst<=0; k_inc<=0; j_rst<=1; j_inc<=0; m_inc<=0; m_rst<=0;  c5qen<=2'd2; c4qen<=1; addin_sel<=2'd2;
                c1_rst<=1;  c1_inc<=1; c4_inc<=0; c4_rst<=0; c5_inc<=0; c5_rst<=0; c5sel<=1'd0; 
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=1;
			end				
	6'd43: begin 
					 sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd2; wq_en<=0;
					 k_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0; c5qen<=2'd2; c4qen<=1; addin_sel<=2'd2;
					 c1_rst<=1;  c1_inc<=1; c4_inc<=0; c4_rst<=0; c5_inc<=0; c5_rst<=0; c5sel<=1'd0; 
					 wtsel1<=3'd2; wtsel2<=2'd2; wtsel3<=2'd2; rdMsel_inc<=0;
					 if(s[2]|s[3]) wea<=1; else wea<=0;
				    if((s[0]|s[1]) & bitrev_compare) j_inc<=0; else j_inc<=1;  
			end	

			
			
    6'd63: begin // END
                sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=0;  c4_rst<=0; c4_inc<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;              
            end
    default: begin // END
                sel1<=3'd1; sel2<=2'd2; sel3<=1'b0; sel7<=1'd0; mz_sel<=1'b0; rdsel<=2'd0; wq_en<=0; wea<=0;
                k_inc<=0; j_inc<=0; k_rst<=0; j_rst<=0; m_inc<=0; m_rst<=0; c5qen<=2'd0; c4qen<=0; addin_sel<=2'd0;
                c1_rst<=0;  c1_inc<=0;  c4_rst<=0; c4_inc<=0; c5_rst<=0; c5_inc<=0; c5sel<=1'd0;
                wtsel1<=3'd0; wtsel2<=2'd0; wtsel3<=2'd0; rdMsel_inc<=0;              
            end   
   endcase
end   
   


always @(state or INSTRUCTION or j_equal or c1_eq or c4_eq or wqeue_comp 
			or wqeue_comp_wire or m_msb or j[1:0] or rdMsel_eq or j_add_1[11])
begin
    case(state)
    6'd0: begin
					if(INSTRUCTION==2'd2)	// Rearrangement
						nextstate <= 6'd40;
					else							// forward or backward NTT
						nextstate <= 6'd01;
			end			
    6'd1: begin
                if(m_msb)    // This is the condition when run for m=256 finishes
                nextstate <= 6'd63;
                else
                nextstate <= 6'd2;   
            end   
    6'd2: nextstate <= 6'd3;   
    6'd3: nextstate <= 6'd4;
    6'd4: nextstate <= 6'd5;
    6'd5: begin				// computation of w^3
                if(c1_eq)
                    nextstate <= 6'd6;
                else   
                    nextstate <= 6'd5;
            end       
    6'd6: begin
                if(INSTRUCTION[0]==1'd0 || INSTRUCTION[0]==1'd1) // Forward NTT and Inverse NTT
                    nextstate <= 6'd7;
                else if(m_msb==1'd0)    // Not the last loop
                    nextstate <= 6'd9;
                else   					// Jump to the loop for m=256
                    nextstate <= 6'd18;
            end
///// specific to FWD NTT /////
    6'd7: begin
                if(c1_eq)
                    nextstate <= 6'd8;
                else   
                    nextstate <= 6'd7;
            end
    6'd8: begin
                if(c4_eq==1'd0)
                    nextstate <= 6'd8;
                else if(m_msb==1'd0)    // Not the last loop
                    nextstate <= 6'd9;
                else					// Jump to the loop for m=256
                    nextstate <= 6'd18;
            end
////////////////////////////////// 
    6'd9: nextstate <= 6'd10;
    6'd10: begin
                if(wqeue_comp && rdMsel_eq)
                nextstate <= 6'd11;
                else
                nextstate <= 6'd9;
            end   
///////////////////////////////////   
    6'd11: nextstate <= 6'd12;
    6'd12: nextstate <= 6'd13;	
    6'd13: begin
				if(c1_eq && j_equal)
                    nextstate <= 6'd14;						
                else if(c1_eq)
                    nextstate <= 6'd09;
                else   
                    nextstate <= 6'd13;
            end	
///////////////////////////////////
    6'd14: nextstate <= 6'd15;
    6'd15: nextstate <= 6'd16;	
    6'd16: nextstate <= 6'd17;
    6'd17: nextstate <= 6'd01;
///////////////////////////////////
	
////// Butterfly Operations for m = 256 //////
    6'd18: begin 
                if(wqeue_comp_wire && rdMsel_eq)
                nextstate <= 6'd19;
                else
                nextstate <= 6'd18;
            end
///////////////////////////////////   
    6'd19: nextstate <= 6'd20;
    6'd20: nextstate <= 6'd21;	
	6'd21: begin
				if(c1_eq)
                    nextstate <= 6'd22;						
                else   
                    nextstate <= 6'd21;
            end	
///////////////////////////////////
    6'd22: begin
				if(j_equal)
					nextstate <= 6'd23;
				else
					nextstate <= 6'd18;
			end	
    6'd23: nextstate <= 6'd24;	
    6'd24: nextstate <= 6'd25;
    6'd25: nextstate <= 6'd26;
    6'd26: begin
				if(INSTRUCTION[0])
					nextstate <= 6'd27;
				else
					nextstate <= 6'd63;
			end		

//////// scaling for backward NTT ///////	
    6'd27: nextstate <= 6'd28;	
    6'd28: nextstate <= 6'd29;
    6'd29: nextstate <= 6'd30;	
    6'd30:  begin
				if(c1_eq)
                    nextstate <= 6'd31;						
                else   
                    nextstate <= 6'd30;
            end
    6'd31: nextstate <= 6'd32;		
    6'd32:  begin
				if(c1_eq)
                    nextstate <= 6'd33;						
                else   
                    nextstate <= 6'd32;
            end			
    6'd33:  begin
				if(c4_eq)
                    nextstate <= 6'd34;						
                else   
                    nextstate <= 6'd33;
            end			
    6'd34: nextstate <= 6'd35;
    6'd35: begin
				if(j[0] && rdMsel_eq)
					nextstate <= 6'd36;	
				else
					nextstate <= 6'd34;
			end		
    6'd36: nextstate <= 6'd37;
    6'd37: nextstate <= 6'd38;
    6'd38:  begin
				if(j_equal && c1_eq)		// jump to end transition
					nextstate <= 6'd39;
				else if(c1_eq)
                    nextstate <= 6'd34;						
                else   
                    nextstate <= 6'd38;
            end			
    6'd39: nextstate <= 6'd40;

//// Rearrangement states
    6'd40: begin
				if(INSTRUCTION==2'd1)
				nextstate <= 6'd63;
				else
				nextstate <= 6'd41;
			end	
    6'd41: nextstate <= 6'd42;	 
	 6'd42: nextstate <= 6'd43;
	 6'd43: begin
				if(j_add_1[11])
					nextstate <= 6'd63;
				else
					nextstate <= 6'd43;
			end			
			
    6'd63: nextstate <= 6'd63;
	
    default: nextstate <= 6'd0;
	endcase
end
   
	
endmodule

*/
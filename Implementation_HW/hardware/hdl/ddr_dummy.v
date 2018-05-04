`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:13:48 04/05/2017 
// Design Name: 
// Module Name:    ddr_dummy 
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
module ddr_dummy(clk, rst, 
						app_rdy, app_rd_dv, app_rd_dl, app_wdf_rdy, 
						app_en, app_cmd, app_wr_dl, app_wr_dv, address_ddr,
						ddr_din, ddr_dout
						);
input clk, rst;
output reg app_rdy, app_rd_dv, app_rd_dl, app_wdf_rdy;

input [27:0] address_ddr;
input app_en, app_wr_dl, app_wr_dv;
input [2:0] app_cmd;
input [255:0] ddr_din;
output [255:0] ddr_dout;



reg wea;
reg [3:0] state, nextstate;
wire read_write;

reg [2:0] read_counter;
wire read_counter_finish;
assign read_write = app_cmd[0];

//wire [12:0] addra;
//assign addra = address_ddr[15:3];
//ddr_element_256bit ddr_element(clk, wea, addra, ddr_din, ddr_dout);

wire [8:0] addra;
assign addra = address_ddr[11:3];

wire [3:0] ddr_select;
assign ddr_select = address_ddr[15:12];

wire wea0, wea1, wea2, wea3, wea4, wea5, wea6, wea7, wea8, wea9, wea10, wea11, wea12, wea13, wea14, wea15;
wire [255:0] ddr_dout0, ddr_dout1, ddr_dout2, ddr_dout3, ddr_dout4, ddr_dout5, ddr_dout6, ddr_dout7;
wire [255:0] ddr_dout8, ddr_dout9, ddr_dout10, ddr_dout11, ddr_dout12, ddr_dout13, ddr_dout14, ddr_dout15;

assign wea0 = (wea==1'b1 && ddr_select==4'd0) ? 1'b1 : 1'b0;
assign wea1 = (wea==1'b1 && ddr_select==4'd1) ? 1'b1 : 1'b0;
assign wea2 = (wea==1'b1 && ddr_select==4'd2) ? 1'b1 : 1'b0;
assign wea3 = (wea==1'b1 && ddr_select==4'd3) ? 1'b1 : 1'b0;
assign wea4 = (wea==1'b1 && ddr_select==4'd4) ? 1'b1 : 1'b0;
assign wea5 = (wea==1'b1 && ddr_select==4'd5) ? 1'b1 : 1'b0;
assign wea6 = (wea==1'b1 && ddr_select==4'd6) ? 1'b1 : 1'b0;
assign wea7 = (wea==1'b1 && ddr_select==4'd7) ? 1'b1 : 1'b0;
assign wea8 = (wea==1'b1 && ddr_select==4'd8) ? 1'b1 : 1'b0;
assign wea9 = (wea==1'b1 && ddr_select==4'd9) ? 1'b1 : 1'b0;
assign wea10 = (wea==1'b1 && ddr_select==4'd10) ? 1'b1 : 1'b0;
assign wea11 = (wea==1'b1 && ddr_select==4'd11) ? 1'b1 : 1'b0;
assign wea12 = (wea==1'b1 && ddr_select==4'd12) ? 1'b1 : 1'b0;
assign wea13 = (wea==1'b1 && ddr_select==4'd13) ? 1'b1 : 1'b0;
assign wea14 = (wea==1'b1 && ddr_select==4'd14) ? 1'b1 : 1'b0;
assign wea15 = (wea==1'b1 && ddr_select==4'd15) ? 1'b1 : 1'b0;


ddr_element256x512 ddr_element0(clk, wea0, addra, ddr_din, ddr_dout0);
ddr_element256x512 ddr_element1(clk, wea1, addra, ddr_din, ddr_dout1);
ddr_element256x512 ddr_element2(clk, wea2, addra, ddr_din, ddr_dout2);
ddr_element256x512 ddr_element3(clk, wea3, addra, ddr_din, ddr_dout3);
ddr_element256x512 ddr_element4(clk, wea4, addra, ddr_din, ddr_dout4);
ddr_element256x512 ddr_element5(clk, wea5, addra, ddr_din, ddr_dout5);
ddr_element256x512 ddr_element6(clk, wea6, addra, ddr_din, ddr_dout6);
ddr_element256x512 ddr_element7(clk, wea7, addra, ddr_din, ddr_dout7);
ddr_element256x512 ddr_element8(clk, wea8, addra, ddr_din, ddr_dout8);
ddr_element256x512 ddr_element9(clk, wea9, addra, ddr_din, ddr_dout9);
ddr_element256x512 ddr_element10(clk, wea10, addra, ddr_din, ddr_dout10);
ddr_element256x512 ddr_element11(clk, wea11, addra, ddr_din, ddr_dout11);
ddr_element256x512 ddr_element12(clk, wea12, addra, ddr_din, ddr_dout12);
ddr_element256x512 ddr_element13(clk, wea13, addra, ddr_din, ddr_dout13);
ddr_element256x512 ddr_element14(clk, wea14, addra, ddr_din, ddr_dout14);
ddr_element256x512 ddr_element15(clk, wea15, addra, ddr_din, ddr_dout15);

assign ddr_dout = (ddr_select==4'd0) ? ddr_dout0 :
						(ddr_select==4'd1) ? ddr_dout1 :
						(ddr_select==4'd2) ? ddr_dout2 :
						(ddr_select==4'd3) ? ddr_dout3 :
						(ddr_select==4'd4) ? ddr_dout4 :
						(ddr_select==4'd5) ? ddr_dout5 :
						(ddr_select==4'd6) ? ddr_dout6 :
						(ddr_select==4'd7) ? ddr_dout7 :
						(ddr_select==4'd8) ? ddr_dout8 :
						(ddr_select==4'd9) ? ddr_dout9 :
						(ddr_select==4'd10) ? ddr_dout10 :
						(ddr_select==4'd11) ? ddr_dout11 :
						(ddr_select==4'd12) ? ddr_dout12 :
						(ddr_select==4'd13) ? ddr_dout13 :
						(ddr_select==4'd14) ? ddr_dout14 :
						ddr_dout15;
						
always @(posedge clk)
begin
	if(rst)
		read_counter <= 3'd0;
	else if(state==4'd5)
		read_counter <= read_counter + 1'b1;
	else
		read_counter <= 3'd0;
end

assign read_counter_finish = (read_counter==3'd4) ? 1'b1 : 1'b0;
		

always @(posedge clk)
begin
	if(rst)
		state <= 4'd0;
	else
		state <= nextstate;
end


always @(state)
begin
	case(state)
	4'd0: begin
				wea<=1'b0; app_rdy<=1'b0; app_rd_dv<=1'b0; app_rd_dl<=1'b0; app_wdf_rdy<=1'b0;
			end	

	// ddr write states;
	4'd1: begin
				wea<=1'b0; app_rdy<=1'b1; app_rd_dv<=1'b0; app_rd_dl<=1'b0; app_wdf_rdy<=1'b0;
			end
	4'd2: begin
				wea<=1'b1; app_rdy<=1'b1; app_rd_dv<=1'b0; app_rd_dl<=1'b0; app_wdf_rdy<=1'b1;
			end	
	4'd3: begin
				wea<=1'b0; app_rdy<=1'b1; app_rd_dv<=1'b0; app_rd_dl<=1'b0; app_wdf_rdy<=1'b1;
			end	


	// ddr read states;
	4'd4: begin
				wea<=1'b0; app_rdy<=1'b1; app_rd_dv<=1'b0; app_rd_dl<=1'b0; app_wdf_rdy<=1'b0;
			end
	4'd5: begin	// stay in this state for 4 cycles
				wea<=1'b0; app_rdy<=1'b1; app_rd_dv<=1'b0; app_rd_dl<=1'b0; app_wdf_rdy<=1'b0;
			end
	4'd6: begin
				wea<=1'b0; app_rdy<=1'b1; app_rd_dv<=1'b1; app_rd_dl<=1'b1; app_wdf_rdy<=1'b0;
			end


	default: begin
				wea<=1'b0; app_rdy<=1'b0; app_rd_dv<=1'b0; app_rd_dl<=1'b0; app_wdf_rdy<=1'b0;
			end
	endcase
end

always @(state or app_en or read_write or app_wr_dl or app_wr_dv or read_counter_finish)
begin
	case(state)
	4'd0: begin
				if(app_en==1'b1 && read_write==1'b0)
					nextstate <= 4'd1;
				else if(app_en==1'b1 && read_write==1'b1)
					nextstate <= 4'd4;					
				else	
					nextstate <= 4'd0;
			end


	// ddr write 
	4'd1: begin
				if(app_en)
					nextstate <= 4'd2;
				else
					nextstate <= 4'd1;
			end
	4'd2: begin
				if(app_wr_dv)
					nextstate <= 4'd3;
				else
					nextstate <= 4'd2;
			end			
	4'd3: begin
				if(app_wr_dl)
					nextstate <= 4'd0;
				else
					nextstate <= 4'd3;
			end
		
	// ddr read
	4'd4: nextstate <= 4'd5;
	4'd5: begin
				if(read_counter_finish)
					nextstate <= 4'd6;	
				else
					nextstate <= 4'd5;
			end
	4'd6: nextstate <= 4'd0;			

	default: nextstate <= 4'd0;	
	endcase
end	

endmodule

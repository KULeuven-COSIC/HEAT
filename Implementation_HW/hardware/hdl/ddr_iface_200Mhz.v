`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:09:05 06/16/2017 
// Design Name: 
// Module Name:    ddr_iface_200Mhz 
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
module ddr_iface_200Mhz(clk_200, rst, 
							 fifo_read_en, fifo_read_empty, 
							 fifo_write_en, fifo_write_almost_full, 
							 ddr_wen,
							 app_rdy, app_rd_dl, app_wdf_rdy,
							 app_en, app_wr_dv, app_wr_dl, app_cmd
							 );
input clk_200;
input rst;

output reg fifo_read_en;
input fifo_read_empty;

output reg fifo_write_en;
input fifo_write_almost_full;

input ddr_wen; // 1 for DDR write and 0 for DDR read

input app_rdy, app_rd_dl, app_wdf_rdy;
output reg app_en, app_wr_dv, app_wr_dl;
output [2:0] app_cmd;



reg [3:0] state, nextstate;


assign app_cmd = {2'b0, ~ddr_wen}; // app_cmp is 1 for DDR read and 0 for DDR write.

always @(posedge clk_200)
begin
	if(rst)
		state <= 4'd0;
	else
		state <= nextstate;
end

always @(state or fifo_read_empty or app_rd_dl)
begin
	case(state)
   4'd0: begin // Idle
            app_en<=0; app_wr_dv<=1'b0; app_wr_dl<=1'b0;
            fifo_read_en<=0; fifo_write_en<=0;
         end	

   4'd1: begin // Read the fifo to know DDR read or write
            app_en<=0; app_wr_dv<=1'b0; app_wr_dl<=1'b0;
            fifo_read_en<=0; fifo_write_en<=0;  /*fifo_read_en<=0;*/
         end
	
	
	/////////// DDR Write  ///////////////////////////////
   4'd2: begin // Issue DDR write
            app_en<=1; app_wr_dv<=1'b1; app_wr_dl<=1'b0;
            fifo_read_en<=0; fifo_write_en<=0;
          end
   4'd3: begin // Write first word
             app_en<=0; app_wr_dv<=1'b1; app_wr_dl<=1'b0;
             fifo_read_en<=0; fifo_write_en<=0;
          end
   4'd4: begin // Write next word
             app_en<=0; app_wr_dv<=1'b1; app_wr_dl<=1'b1;
             fifo_read_en<=0; fifo_write_en<=0;
          end
   4'd5: begin // Read next fifo entry
             app_en<=0; app_wr_dv<=1'b0; app_wr_dl<=1'b0;
             fifo_write_en<=0;
				 if(fifo_read_empty) fifo_read_en<=0; else fifo_read_en<=1; 
          end	
	
	/////////    Read from DDR and Write in BRAM state   ////////////////////
   4'd8: begin  // Issue read
				app_en<=1; app_wr_dv<=1'b0; app_wr_dl<=1'b0;
				fifo_read_en<=0; fifo_write_en<=0;
         end
   4'd9: begin  // Wait for read done
				app_en<=0; app_wr_dv<=1'b0; app_wr_dl<=1'b0;
				fifo_read_en<=0; 
				if(app_rd_dl==1'b1) fifo_write_en<=1; else fifo_write_en<=0;
			end
   4'd10: begin  // read next instruction; just to empty the fifo for next Memory operation;
				app_en<=0; app_wr_dv<=1'b0; app_wr_dl<=1'b0;
				fifo_write_en<=0;
				if(fifo_read_empty) fifo_read_en<=0; else fifo_read_en<=1;
			end			
   4'd11: begin  // Wait for write fifo to be read by the other side
				app_en<=0; app_wr_dv<=1'b0; app_wr_dl<=1'b0;
				fifo_read_en<=0; fifo_write_en<=0;
         end			

   default: begin // Idle
            app_en<=0; app_wr_dv<=1'b0; app_wr_dl<=1'b0;
            fifo_read_en<=0; fifo_write_en<=0;
         end	
	endcase
end


	
always @(state or fifo_read_empty or fifo_write_almost_full or ddr_wen or app_rdy or app_rd_dl or app_wdf_rdy)
begin
   case(state)
   4'd0: begin
				if(fifo_read_empty==1'b0)
					nextstate <= 4'd1;
            else
					nextstate <= 4'd0;
         end

   4'd1: begin
				if(ddr_wen)
					nextstate <= 4'd2;
            else
					nextstate <= 4'd8;
         end
		

   // DDR writing
   4'd2: begin
				if(ddr_wen==1'b0)	// Added 22 Nov, 2017: after a DDR write if there is a consecutive DDR read, then the FSM was hanging in state2-3: because 'wen' has changed to 0
					nextstate <= 4'd0;	
				else if(app_rdy==1'b1 && app_wdf_rdy==1'b0)
					nextstate <= 4'd3;
            else if(app_rdy==1'b1 && app_wdf_rdy==1'b1)
					nextstate <= 4'd4;
            else
               nextstate <= 4'd2;
          end
   4'd3: begin
				if(app_wdf_rdy==1'b1)
					nextstate <= 4'd4;
            else
               nextstate <= 4'd2;
          end
   4'd4: begin
				if(app_wdf_rdy==1'b1)
					nextstate <= 4'd5;
            else
					nextstate <= 4'd4;
          end
   4'd5: begin
				if(fifo_read_empty)
					nextstate <= 4'd0;
            else
					nextstate <= 4'd2;
          end		
		
	// DDR Reading
   4'd8: begin
            if(app_rdy==1'b1)
					nextstate <= 4'd9;
            else
					nextstate <= 4'd8;
         end
   4'd9: begin
				if(fifo_write_almost_full==1'b1 && app_rd_dl==1'b1)
					nextstate <= 4'd11;
            else if(app_rd_dl==1'b1)
               nextstate <= 4'd10;
            else
               nextstate <= 4'd9;
         end
   4'd10: begin
            if(fifo_read_empty)
               nextstate <= 4'd0;
            else
               nextstate <= 4'd8;
         end
   4'd11: begin
				if(fifo_write_almost_full)
					nextstate <= 4'd11;
            else
               nextstate <= 4'd10;
         end
			
	default: nextstate <= 4'd0;
	endcase
end
	
endmodule

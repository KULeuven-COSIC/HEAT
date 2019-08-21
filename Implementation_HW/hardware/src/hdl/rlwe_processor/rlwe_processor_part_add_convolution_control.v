`timescale 1ns / 1ps

module rlwe_processor_part_add_convolution_control #(parameter core_index=1'b1)
										(clk, rst, add_conv,
										 addressin_ac, wea, MZsel, sel2, sel9, addin_sel, RdQsel, WtQsel, 
										 wtsel1, wtsel2, wtsel3, done);
input clk, rst;
input add_conv;	// This is 0 for addition and 1 for coefficient-wise multiplication;
output [10:0] addressin_ac;
output [1:0] sel2;
output wea, MZsel, sel9;
output [1:0] addin_sel, RdQsel, WtQsel, wtsel1, wtsel2, wtsel3;
output reg done;

reg [10:0] j;
reg [1:0] x;
reg [18:0] Q;
wire xen, done_wire;

assign addressin_ac = {3'd0, j};
assign wea = (add_conv==1'b0) ? Q[7] : Q[14];	// change for pipeline stages in the multiplier
assign MZsel = 1'b1 ^ Q[4];
assign addin_sel = (add_conv==1'b0) ? 2'd1 : 2'd2;			 
assign sel2 = 2'd3;
assign sel9 = 1'd1;					// Later will change
assign RdQsel = {1'b0,1'b1 ^ Q[2]};
assign WtQsel = 2'd0;				// Fixed since only one memory is written;
assign wtsel1 = (add_conv==1'b0) ? 2'd3 : 2'd1;
assign wtsel2 = 2'd0;
assign wtsel3 = 2'd0;
//assign done_wire = wea & (x==2'd0) & (  ((add_conv==1'd0) & (Q[5]==1'd0)) | (add_conv & (Q[18]^Q[16]))  );
assign done_wire = wea & (x==2'd0) & (  ((add_conv==1'd0) & (Q[5]==1'd0)) | (add_conv & (Q[14]^Q[12]))  );  // change for pipeline stages

always @(posedge clk)
	done	<= done_wire;


generate
   if (core_index==1'b0)
	begin
			always @(posedge clk)
			begin
				if(rst)
					j <= 11'b11111111111;
				else if(x[0])
					j <= j + 1'b1;
				else
					j <= j;
			end
			assign xen = (j==11'd1023 && x[1]==1'd1)	? 1'd0 : 1'd1;	// This is low in the last iteration of j loop
	end
   else
	begin
			always @(posedge clk)
			begin
				if(rst)
					j <= 11'd1023;
				else if(x[0])
					j <= j + 1'b1;
				else
					j <= j;
			end
			assign xen = (j==11'd2047 && x[1]==1'd1)	? 1'd0 : 1'd1;	// This is low in the last iteration of j loop
	end
endgenerate	
	
always @(posedge clk)
begin
	if(rst)
		x <= 2'b01;
	else if(xen)
		x <= {x[0],x[1]};
	else
		x <= 2'b00;
end


always @(posedge clk)
begin
	if(rst)
		Q <= 18'd0;
	else
		Q <= {Q[17:0],x[0]};
end

endmodule

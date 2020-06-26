
module uram1024 #(
  parameter AWIDTH  = 10, // Address Width
  parameter CWIDTH  =  8, // Data Width, (Byte * NUM_COL) 
  parameter NUM_COL =  9, // Number of columns
  parameter DWIDTH  = 72  // Data Width, (Byte * NUM_COL) 
) 
(
  input wire                clk,      // Clock 

  // Port A
  input  wire [NUM_COL-1:0] wea,      // Write Enable
  input  wire [ DWIDTH-1:0] dina,     // Data Input 
  input  wire [ AWIDTH-1:0] addra,    // Address Input
  output reg  [ DWIDTH-1:0] douta,    // Data Output

  // Port B
  input  wire [NUM_COL-1:0] web,      // Write Enable
  input  wire [ DWIDTH-1:0] dinb,     // Data Input 
  input  wire [ AWIDTH-1:0] addrb,    // Address Input
  output reg  [ DWIDTH-1:0] doutb     // Data Output
);

(* ram_style = "ultra" *)
reg [DWIDTH-1:0] mem[(1<<AWIDTH)-1:0];        // Memory Declaration

integer          i;

// RAM : Both READ and WRITE have a latency of one
always @ (posedge clk) begin
  for(i = 0;i<NUM_COL;i=i+1) 
	  if(wea[i])
      mem[addra][i*CWIDTH +: CWIDTH] <= dina[i*CWIDTH +: CWIDTH];
end

always @ (posedge clk) begin
  if(~|wea)
    douta <= mem[addra];
end

/////////////////////

always @ (posedge clk) begin
   for(i = 0;i<NUM_COL;i=i+1) 
	 if(web[i])
    mem[addrb][i*CWIDTH +: CWIDTH] <= dinb[i*CWIDTH +: CWIDTH];
end

always @ (posedge clk) begin
  if(~|web)
    doutb <= mem[addrb];
end

endmodule
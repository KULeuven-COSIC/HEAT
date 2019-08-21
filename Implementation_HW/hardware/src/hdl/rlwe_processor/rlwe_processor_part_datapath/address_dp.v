`timescale 1ns / 1ps

module address_dp_c1(clk, addressin_w, rdsel_w, wtsel1_w, m_w, s_w,
						read_address, write_address, wtsel_11);
input clk;
input [10:0] addressin_w;
input [1:0] rdsel_w;
input [2:0] wtsel1_w;
input [12:0] m_w;
input [3:0] s_w;

output [10:0] read_address, write_address;
output wtsel_11;

reg [10:0] addressin;
reg [1:0] rdsel;
reg [2:0] wtsel1; 
reg [12:0] m;
reg [3:0] s;

wire [12:0] m_new;
assign m_new = (rdsel==2'd2) ? 13'd0 : m; 
 
always @(posedge clk)
begin
{addressin, rdsel, wtsel1, m, s} <= {addressin_w+ m_new[11:1], rdsel_w, wtsel1_w, m_w, s_w};
end


reg [10:0] rdaddress1, rdaddress2, wtaddress1, wtaddress2;
wire [10:0] rdaddress3, wtaddress3;
reg [10:0] adress_pipe1,adress_pipe2,adress_pipe3,adress_pipe4,adress_pipe5,adress_pipe6,adress_pipe7,adress_pipe8,adress_pipe9,adress_pipe10,adress_pipe11,adress_pipe12,adress_pipe13,adress_pipe14;  
reg  wtsel_0, wtsel_1, wtsel_2, wtsel_3, wtsel_4, wtsel_5, wtsel_6, wtsel_7, wtsel_8, wtsel_9, wtsel_10, wtsel_11, wtsel_12, wtsel_13, wtsel_14, wtsel_15; 
wire [2:0] wtaddress_sel;

always @(posedge clk)
begin
	rdaddress1 	 <= addressin;				rdaddress2 <= rdaddress1 - m_new[11:1];
	adress_pipe1 <= rdaddress1;
	adress_pipe2 <= adress_pipe1;
	adress_pipe3 <= adress_pipe2;
	adress_pipe4 <= adress_pipe3;
	adress_pipe5 <= adress_pipe4;
	adress_pipe6 <= adress_pipe5;
	adress_pipe7 <= adress_pipe6;
	adress_pipe8 <= adress_pipe7;
	adress_pipe9 <= adress_pipe8;	
	adress_pipe10 <= adress_pipe9;
	wtaddress1 <= adress_pipe10;		wtaddress2 <= wtaddress1 - m_new[11:1];	
end


assign rdaddress3 = (s[0]) ? rdaddress1 : {adress_pipe1[0], adress_pipe1[1], adress_pipe1[2], adress_pipe1[3], 
														 adress_pipe1[4], adress_pipe1[5], adress_pipe1[6], adress_pipe1[7], adress_pipe1[8], adress_pipe1[9] , adress_pipe1[10]};
wire [10:0] rdaddress1_modified, rev_pipe1, rev_pipe2, rev_addressin;

assign rdaddress1_modified = (m[12]) ? (addressin - m_new[11:1]) : rdaddress1;

assign read_address = (rdsel==2'd0) ? rdaddress1_modified 
					: (rdsel==2'd1) ? rdaddress2
					: (rdsel==2'd2) ? rdaddress3
					: addressin;
assign wtaddress_sel = (wtsel1==3'd0) ? {2'b0,wtsel_11} : wtsel1;

assign rev_pipe2 = {adress_pipe2[0], adress_pipe2[1], adress_pipe2[2], adress_pipe2[3], 
                    adress_pipe2[4], adress_pipe2[5], adress_pipe2[6], adress_pipe2[7], 
						  adress_pipe2[8], adress_pipe2[9], adress_pipe2[10]};
assign wtaddress3 = (s[2]) ? rev_pipe2 : adress_pipe3; 
assign write_address =   (wtaddress_sel==3'd0) ? wtaddress1		// this m[8] is introduced to delay address by 1 cycle for the last loop;
						:(wtaddress_sel==3'd1) ? wtaddress2
						:(wtaddress_sel==3'd2) ? wtaddress3
						:(wtaddress_sel==3'd3) ? adress_pipe5
						:(wtaddress_sel==3'd4) ? addressin
						:adress_pipe1;
						
always @(posedge clk)
begin 
	wtsel_0 <= rdsel[0]; wtsel_1 <= wtsel_0; wtsel_2 <= wtsel_1; wtsel_3 <= wtsel_2;
	wtsel_4 <= wtsel_3; wtsel_5 <= wtsel_4; wtsel_6 <= wtsel_5; wtsel_7 <= wtsel_6;
	wtsel_8 <= wtsel_7; wtsel_9 <= wtsel_8; wtsel_10 <= wtsel_9; wtsel_11 <=  wtsel_10;
	wtsel_12 <= wtsel_11; wtsel_13 <= wtsel_12; wtsel_14 <= wtsel_13; wtsel_15 <= wtsel_14; 
end	


endmodule


module address_dp_c0(clk, addressin_w, rdsel_w, wtsel1_w, m_w, s_w,
						read_address, write_address, wtsel_11);
input clk;
input [10:0] addressin_w;
input [1:0] rdsel_w;
input [2:0] wtsel1_w;
input [12:0] m_w;
input [3:0] s_w;

output [10:0] read_address, write_address;
output wtsel_11;

reg [10:0] addressin;
reg [1:0] rdsel;
reg [2:0] wtsel1; 
reg [12:0] m;
reg [3:0] s;


 
always @(posedge clk)
begin
{addressin, rdsel, wtsel1, m, s} <= {addressin_w, rdsel_w, wtsel1_w, m_w, s_w};
end


reg [10:0] rdaddress1, rdaddress2, wtaddress1, wtaddress2;
wire [10:0] rdaddress3, wtaddress3;
reg [10:0] adress_pipe1,adress_pipe2,adress_pipe3,adress_pipe4,adress_pipe5,adress_pipe6,adress_pipe7,adress_pipe8,adress_pipe9,adress_pipe10,adress_pipe11,adress_pipe12,adress_pipe13,adress_pipe14;  
reg  wtsel_0, wtsel_1, wtsel_2, wtsel_3, wtsel_4, wtsel_5, wtsel_6, wtsel_7, wtsel_8, wtsel_9, wtsel_10, wtsel_11, wtsel_12, wtsel_13, wtsel_14, wtsel_15; 
wire [2:0] wtaddress_sel;

always @(posedge clk)
begin
	rdaddress1 	 <= addressin;				rdaddress2 <= rdaddress1 + m[11:1];
	adress_pipe1 <= rdaddress1;
	adress_pipe2 <= adress_pipe1;
	adress_pipe3 <= adress_pipe2;
	adress_pipe4 <= adress_pipe3;
	adress_pipe5 <= adress_pipe4;
	adress_pipe6 <= adress_pipe5;
	adress_pipe7 <= adress_pipe6;
	adress_pipe8 <= adress_pipe7;
	adress_pipe9 <= adress_pipe8;	
	adress_pipe10 <= adress_pipe9;
	wtaddress1 <= adress_pipe10;		wtaddress2 <= wtaddress1 + m[11:1];	
end


assign rdaddress3 = (s[0]) ? rdaddress1 : {adress_pipe1[0], adress_pipe1[1], adress_pipe1[2], adress_pipe1[3], 
														 adress_pipe1[4], adress_pipe1[5], adress_pipe1[6], adress_pipe1[7], adress_pipe1[8], adress_pipe1[9] , adress_pipe1[10]};
wire [10:0] rdaddress1_modified, rev_pipe1, rev_pipe2, rev_addressin;

assign rdaddress1_modified = (m[12]) ? addressin : rdaddress1;

assign read_address = (rdsel==2'd0) ? rdaddress1_modified 
					: (rdsel==2'd1) ? rdaddress2
					: (rdsel==2'd2) ? rdaddress3
					: addressin;
assign wtaddress_sel = (wtsel1==3'd0) ? {2'b0,wtsel_11} : wtsel1;

assign rev_pipe2 = {adress_pipe2[0], adress_pipe2[1], adress_pipe2[2], adress_pipe2[3], 
                    adress_pipe2[4], adress_pipe2[5], adress_pipe2[6], adress_pipe2[7], 
						  adress_pipe2[8], adress_pipe2[9], adress_pipe2[10]};
assign wtaddress3 = (s[2]) ? rev_pipe2 : adress_pipe3; 
assign write_address =   (wtaddress_sel==3'd0) ? wtaddress1		// this m[8] is introduced to delay address by 1 cycle for the last loop;
						:(wtaddress_sel==3'd1) ? wtaddress2
						:(wtaddress_sel==3'd2) ? wtaddress3
						:(wtaddress_sel==3'd3) ? adress_pipe5
						:(wtaddress_sel==3'd4) ? addressin
						:adress_pipe1;
						
always @(posedge clk)
begin 
	wtsel_0 <= rdsel[0]; wtsel_1 <= wtsel_0; wtsel_2 <= wtsel_1; wtsel_3 <= wtsel_2;
	wtsel_4 <= wtsel_3; wtsel_5 <= wtsel_4; wtsel_6 <= wtsel_5; wtsel_7 <= wtsel_6;
	wtsel_8 <= wtsel_7; wtsel_9 <= wtsel_8; wtsel_10 <= wtsel_9; wtsel_11 <=  wtsel_10;
	wtsel_12 <= wtsel_11; wtsel_13 <= wtsel_12; wtsel_14 <= wtsel_13; wtsel_15 <= wtsel_14; 
end	


endmodule

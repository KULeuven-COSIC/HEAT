`timescale 1ns / 1ps

module datapath #(parameter modular_index=6, parameter core_index=1'b1) 
		(clk, modulus_sel, mode, m, w_NTT_ROM, primout_mask,
		dout_high, dout_low, load1, load2,
		prim_counter, c4, c5, 
		sel1, sel2, sel3, sel7, sel9, sel10, wtsel2, wtsel3, mz_sel, addin_sel, wtsel_10,
		wq_en, rst_ac, crt_rom_address,
		
		din_high, din_low, crt_sum_for_accumulation
		);


input clk;
input modulus_sel;	// If 0 then first set of modulus [q0 to q5] else [q6 to q12]
input [1:0] mode;		// 0 for fwd NTT, 1 for invNTT; 2 for rearrange
input [12:0] m;
input [29:0] w_NTT_ROM;
input primout_mask;
input [29:0] dout_high, dout_low, load1, load2;
input [3:0] prim_counter;
input [2:0] c4;
input [1:0] c5;


input sel3, sel7, sel10, mz_sel, wq_en;
input [1:0] sel9;
input rst_ac;	// This is used to set wtqsel2=0, wtqsel3=0 during coefficient add/ mult operation
input [2:0] sel1;
input [1:0] sel2, wtsel2, wtsel3, addin_sel;
input wtsel_10;
input [2:0] crt_rom_address; 
output [29:0] din_high, din_low;
output [29:0] crt_sum_for_accumulation;

// pipelines 
reg [29:0] t1, t2, t3, u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, u11, u12;
reg [29:0] wque1, wque2, wque3, wque4;
reg [29:0] R1, R2, R3, R4, R5, R6;
wire [1:0] din_high_sel, din_low_sel; 
//reg [1:0] din_high_sel, din_low_sel; 
wire [29:0] crt_rom_data;
wire [60:0] crt_reg_input;
reg [60:0] crt_reg;

wire [3:0] primsel;
wire [29:0] primout_F_S, primout_B_S, primout_F_L, primout_B_L, primout_F, primout_B, primout;
wire [29:0] primout_F_S_temp, primout_B_S_temp, primout_F_L_temp, primout_B_L_temp;
wire [29:0] rom_data, WQ_out, mod_mult_out, sub_out, add_out, M3_out, M7_out, MZ1_out, MZ2_out, M9_out, MADD1_out, MADD2_out;
wire [59:0] M10_out;
wire [3:0] primsel_minus1, primsel_minus2;
wire [29:0] n_inverse_S, n_inverse_L, n_inverse;

assign primsel_minus1 = prim_counter - 1'd1;
assign primsel_minus2 = prim_counter - 2'd2;
assign primsel = 	(sel1==3'd0) ? prim_counter : 
						(sel1==3'd1) ? prim_counter + 1'd1 : 
						(sel1==3'd2) ? prim_counter + 2'd2 :
						(sel1==3'd3) ? {1'b0,primsel_minus1} :
						{1'b0,primsel_minus2};

mux2_30bits MZ1(u1, t2, mz_sel, MZ1_out);
mux2_30bits MZ2(u2, t3, mz_sel, MZ2_out);

generate
   if (modular_index==3'd0 && core_index==1'b0)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd444976, 30'd319211591, 30'd551548925, 30'd87766572, 30'd769366155, 
					 30'd266787309, 30'd627853310, 30'd975425846, 30'd119911759, 30'd823032590, 30'd852336940, 
					 30'd913406407, 30'd444976, primsel[3:0], primout_F_S_temp);
					 
		assign primout_F_S = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd319211591 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd444976 :	primout_F_S_temp;	

		mux16_30bits MB(30'd0, 30'd0, 30'd155158074, 30'd42723272, 30'd1003649986, 30'd150330158, 30'd710477484, 30'd125398397, 
					 30'd289088391, 30'd1006947991, 30'd404523277, 30'd717304516, 30'd1013178094, 30'd924391754, 
					 30'd155158074, 30'd42723272, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = 		(primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;	
	
	
		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd231132, 30'd330974, 30'd563580958, 30'd234005231, 30'd815092557, 
					 30'd704299835, 30'd544065806, 30'd395612431, 30'd94884056, 30'd911418076, 30'd224579501, 
					 30'd817491548, 30'd231132, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd330974 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd231132 :	primout_F_L_temp;						 

		mux16_30bits MB_L(30'd0, 30'd0, 30'd250941861, 30'd93667974, 30'd538710288, 30'd770999838, 30'd561180715, 30'd413078757, 
					 30'd196193677, 30'd1016538878, 30'd381788193, 30'd914395578, 30'd691354142, 30'd528186748, 
					 30'd250941861, 30'd93667974, primsel[3:0], primout_B_L_temp);					 

		assign primout_B_L = 		(primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;	
	end
   else if (modular_index==3'd0 && core_index==1'b1)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd444976, 30'd319211591, 30'd551548925, 30'd87766572, 30'd769366155, 
					 30'd266787309, 30'd627853310, 30'd975425846, 30'd119911759, 30'd823032590, 30'd852336940, 
					 30'd913406407, 30'd444976, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd822982060 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd469110148 :	primout_F_S_temp;

		mux16_30bits MB(30'd0, 30'd0, 30'd155158074, 30'd42723272, 30'd1003649986, 30'd150330158, 30'd710477484, 30'd125398397, 
					 30'd289088391, 30'd1006947991, 30'd404523277, 30'd717304516, 30'd1013178094, 30'd924391754, 
					 30'd155158074, 30'd42723272, primsel[3:0], primout_B_S_temp);	

		assign primout_B_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd155158074 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd155158074 :(primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd231132, 30'd330974, 30'd563580958, 30'd234005231, 30'd815092557, 
					 30'd704299835, 30'd544065806, 30'd395612431, 30'd94884056, 30'd911418076, 30'd224579501, 
					 30'd817491548, 30'd231132, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd507979410 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd281824322 : primout_F_L_temp;					 

		mux16_30bits MB_L(30'd0, 30'd0, 30'd250941861, 30'd93667974, 30'd538710288, 30'd770999838, 30'd561180715, 30'd413078757, 
					 30'd196193677, 30'd1016538878, 30'd381788193, 30'd914395578, 30'd691354142, 30'd528186748, 
					 30'd250941861, 30'd93667974, primsel[3:0], primout_B_L_temp);					 

		assign primout_B_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd250941861 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd250941861 : (primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;
					 
	end	
	
///////
   else if (modular_index==3'd1 && core_index==1'b0)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd336036, 30'd652109991, 30'd387542263, 30'd294190876, 30'd979282603, 30'd944032230, 30'd1026867084, 30'd743644219, 30'd896665182, 30'd128160371, 30'd286914778, 30'd1038766166, 30'd336036, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd652109991 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd336036 :	primout_F_S_temp;	

		mux16_30bits MB(30'd0, 30'd0, 30'd30453675, 30'd1006546725, 30'd315436785, 30'd807372739, 30'd754300434, 30'd748150142, 30'd1068297522, 30'd642564166, 30'd21873183, 30'd886057947, 30'd371536267, 30'd460688882, 30'd30453675, 30'd1006546725, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = 		(primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;	

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd25582, 30'd654438724, 30'd909074033, 30'd709400045, 30'd924928891, 30'd121854815, 30'd785814528, 30'd755204846, 30'd954720360, 30'd1014126830, 30'd374995180, 30'd61436824, 30'd25582, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd654438724 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd25582 :	primout_F_L_temp;	

		mux16_30bits MB_L(30'd0, 30'd0, 30'd1006799977, 30'd919121266, 30'd828919538, 30'd73508884, 30'd879825469, 30'd788098188, 30'd859215920, 30'd433571644, 30'd34678426, 30'd13428502, 30'd952771199, 30'd659506540, 30'd1006799977, 30'd919121266, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = 		(primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;	
	end
   else if (modular_index==3'd1 && core_index==1'b1)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd336036, 30'd652109991, 30'd387542263, 30'd294190876, 30'd979282603, 30'd944032230, 30'd1026867084, 30'd743644219, 30'd896665182, 30'd128160371, 30'd286914778, 30'd1038766166, 30'd336036, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd432887847 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd1041185752 : primout_F_S_temp;

		mux16_30bits MB(30'd0, 30'd0, 30'd30453675, 30'd1006546725, 30'd315436785, 30'd807372739, 30'd754300434, 30'd748150142, 30'd1068297522, 30'd642564166, 30'd21873183, 30'd886057947, 30'd371536267, 30'd460688882, 30'd30453675, 30'd1006546725, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd30453675 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd30453675 : (primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd25582, 30'd654438724, 30'd909074033, 30'd709400045, 30'd924928891, 30'd121854815, 30'd785814528, 30'd755204846, 30'd954720360, 30'd1014126830, 30'd374995180, 30'd61436824, 30'd25582, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd289831858 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd300497297 : primout_F_L_temp;

		mux16_30bits MB_L(30'd0, 30'd0, 30'd1006799977, 30'd919121266, 30'd828919538, 30'd73508884, 30'd879825469, 30'd788098188, 30'd859215920, 30'd433571644, 30'd34678426, 30'd13428502, 30'd952771199, 30'd659506540, 30'd1006799977, 30'd919121266, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd1006799977 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd1006799977 : (primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;

	end	
	
///////
   else if (modular_index==3'd2 && core_index==1'b0)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd961955, 30'd249148009, 30'd536187058, 30'd70625433, 30'd320738890, 30'd330351693, 30'd802210960, 30'd747095967, 30'd191524138, 30'd495455403, 30'd989608748, 30'd508629812, 30'd961955, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd249148009 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd961955 :	primout_F_S_temp;	

		mux16_30bits MB(30'd0, 30'd0, 30'd562097357, 30'd226500556, 30'd440266667, 30'd749497381, 30'd767155781, 30'd717141519, 30'd716847576, 30'd683461883, 30'd637149258, 30'd167465049, 30'd948311613, 30'd677433188, 30'd562097357, 30'd226500556, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = 		(primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;	

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd246147, 30'd902875345, 30'd64525337, 30'd330714868, 30'd1013891573, 30'd216152217, 30'd120415734, 30'd283865449, 30'd453917989, 30'd837736347, 30'd368594555, 30'd607722190, 30'd246147, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd902875345 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd246147 :	primout_F_L_temp;	

		mux16_30bits MB_L(30'd0, 30'd0, 30'd458089779, 30'd180490951, 30'd380056204, 30'd604442456, 30'd161798952, 30'd960932704, 30'd25662206, 30'd654132840, 30'd827596419, 30'd1025396464, 30'd779690137, 30'd91050157, 30'd458089779, 30'd180490951, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = 		(primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;	

	end
   else if (modular_index==3'd2 && core_index==1'b1)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd961955, 30'd249148009, 30'd536187058, 30'd70625433, 30'd320738890, 30'd330351693, 30'd802210960, 30'd747095967, 30'd191524138, 30'd495455403, 30'd989608748, 30'd508629812, 30'd961955, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd419764918 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd574383389 : primout_F_S_temp;

		mux16_30bits MB(30'd0, 30'd0, 30'd562097357, 30'd226500556, 30'd440266667, 30'd749497381, 30'd767155781, 30'd717141519, 30'd716847576, 30'd683461883, 30'd637149258, 30'd167465049, 30'd948311613, 30'd677433188, 30'd562097357, 30'd226500556, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd562097357 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd562097357 : (primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd246147, 30'd902875345, 30'd64525337, 30'd330714868, 30'd1013891573, 30'd216152217, 30'd120415734, 30'd283865449, 30'd453917989, 30'd837736347, 30'd368594555, 30'd607722190, 30'd246147, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd123427067 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd152428842 : primout_F_L_temp;

		mux16_30bits MB_L(30'd0, 30'd0, 30'd458089779, 30'd180490951, 30'd380056204, 30'd604442456, 30'd161798952, 30'd960932704, 30'd25662206, 30'd654132840, 30'd827596419, 30'd1025396464, 30'd779690137, 30'd91050157, 30'd458089779, 30'd180490951, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd458089779 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd458089779 : (primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;

	end	
///////
   else if (modular_index==3'd3 && core_index==1'b0)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd143907, 30'd350466230, 30'd797812658, 30'd854040739, 30'd887318665, 30'd1050518287, 30'd730238413, 30'd180341400, 30'd415831590, 30'd991439124, 30'd551143544, 30'd677515442, 30'd143907, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd350466230 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd143907 :	primout_F_S_temp;	

		mux16_30bits MB(30'd0, 30'd0, 30'd393998159, 30'd711691669, 30'd701801046, 30'd119354467, 30'd490176955, 30'd758409004, 30'd242848814, 30'd406807121, 30'd422015267, 30'd267632320, 30'd483758184, 30'd572299474, 30'd393998159, 30'd711691669, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = 		(primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;	

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd10327, 30'd106646929, 30'd17017513, 30'd315407836, 30'd10348144, 30'd782231658, 30'd278231670, 30'd1018170734, 30'd650391915, 30'd502413334, 30'd696827271, 30'd334941153, 30'd10327, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd106646929 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd10327 :	primout_F_L_temp;	

		mux16_30bits MB_L(30'd0, 30'd0, 30'd730543136, 30'd985627134, 30'd935579711, 30'd614540189, 30'd258988186, 30'd1028499587, 30'd517294893, 30'd1040527341, 30'd168138263, 30'd23337371, 30'd1001510690, 30'd321377791, 30'd730543136, 30'd985627134, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = 		(primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;	
	end
   else if (modular_index==3'd3 && core_index==1'b1)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd143907, 30'd350466230, 30'd797812658, 30'd854040739, 30'd887318665, 30'd1050518287, 30'd730238413, 30'd180341400, 30'd415831590, 30'd991439124, 30'd551143544, 30'd677515442, 30'd143907, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd261286316 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd49129702 : primout_F_S_temp;

		mux16_30bits MB(30'd0, 30'd0, 30'd393998159, 30'd711691669, 30'd701801046, 30'd119354467, 30'd490176955, 30'd758409004, 30'd242848814, 30'd406807121, 30'd422015267, 30'd267632320, 30'd483758184, 30'd572299474, 30'd393998159, 30'd711691669, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd393998159 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd393998159 : (primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;
		
		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd10327, 30'd106646929, 30'd17017513, 30'd315407836, 30'd10348144, 30'd782231658, 30'd278231670, 30'd1018170734, 30'd650391915, 30'd502413334, 30'd696827271, 30'd334941153, 30'd10327, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd401185306 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd375284937 : primout_F_L_temp;

		mux16_30bits MB_L(30'd0, 30'd0, 30'd730543136, 30'd985627134, 30'd935579711, 30'd614540189, 30'd258988186, 30'd1028499587, 30'd517294893, 30'd1040527341, 30'd168138263, 30'd23337371, 30'd1001510690, 30'd321377791, 30'd730543136, 30'd985627134, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd730543136 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd730543136 : (primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;
	end	
///////
   else if (modular_index==3'd4 && core_index==1'b0)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd27507, 30'd756635049, 30'd10325248, 30'd290159540, 30'd54435894, 30'd163865235, 30'd1052498090, 30'd537194214, 30'd1056687229, 30'd745573822, 30'd800531529, 30'd652017833, 30'd27507, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd756635049 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd27507 :	primout_F_S_temp;	

		mux16_30bits MB(30'd0, 30'd0, 30'd420478808, 30'd85699917, 30'd543795992, 30'd345364396, 30'd739532327, 30'd723753985, 30'd348038677, 30'd130735712, 30'd832796700, 30'd322101308, 30'd907213382, 30'd630860515, 30'd420478808, 30'd85699917, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = 		(primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;	

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd24888, 30'd619412544, 30'd137458013, 30'd101347675, 30'd191250939, 30'd826488760, 30'd132049762, 30'd450439865, 30'd952985626, 30'd857700401, 30'd288158969, 30'd387420792, 30'd24888, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd619412544 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd24888 : primout_F_L_temp;

		mux16_30bits MB_L(30'd0, 30'd0, 30'd677277065, 30'd611191670, 30'd935442564, 30'd758850379, 30'd852669545, 30'd483008514, 30'd934214709, 30'd176842940, 30'd974591893, 30'd200380827, 30'd403407151, 30'd687087282, 30'd677277065, 30'd611191670, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = 		(primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;	
	end
   else if (modular_index==3'd4 && core_index==1'b1)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd27507, 30'd756635049, 30'd10325248, 30'd290159540, 30'd54435894, 30'd163865235, 30'd1052498090, 30'd537194214, 30'd1056687229, 30'd745573822, 30'd800531529, 30'd652017833, 30'd27507, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd462922245 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd765701529 : primout_F_S_temp;

		mux16_30bits MB(30'd0, 30'd0, 30'd420478808, 30'd85699917, 30'd543795992, 30'd345364396, 30'd739532327, 30'd723753985, 30'd348038677, 30'd130735712, 30'd832796700, 30'd322101308, 30'd907213382, 30'd630860515, 30'd420478808, 30'd85699917, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd420478808 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd420478808 : (primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd24888, 30'd619412544, 30'd137458013, 30'd101347675, 30'd191250939, 30'd826488760, 30'd132049762, 30'd450439865, 30'd952985626, 30'd857700401, 30'd288158969, 30'd387420792, 30'd24888, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd719293560 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd224878304 : primout_F_L_temp;

		mux16_30bits MB_L(30'd0, 30'd0, 30'd677277065, 30'd611191670, 30'd935442564, 30'd758850379, 30'd852669545, 30'd483008514, 30'd934214709, 30'd176842940, 30'd974591893, 30'd200380827, 30'd403407151, 30'd687087282, 30'd677277065, 30'd611191670, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd677277065 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd677277065 : (primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;
	end	
///////
   else if (modular_index==3'd5 && core_index==1'b0)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd769236, 30'd236719465, 30'd944984352, 30'd300675133, 30'd1029398733, 30'd789447622, 30'd71006940, 30'd680182259, 30'd744493664, 30'd35327516, 30'd542201251, 30'd103343005, 30'd769236, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd236719465 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd769236 :	primout_F_S_temp;	


		mux16_30bits MB(30'd0, 30'd0, 30'd970136676, 30'd430609598, 30'd852528494, 30'd429347072, 30'd547143474, 30'd659315896, 30'd534631925, 30'd980465242, 30'd1063497884, 30'd181277513, 30'd674025485, 30'd8612253, 30'd970136676, 30'd430609598, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = 		(primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;	

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd124688, 30'd658759922, 30'd967161808, 30'd545099760, 30'd973512736, 30'd162640568, 30'd525785482, 30'd682468151, 30'd151791783, 30'd1042154549, 30'd728967264, 30'd353207912, 30'd124688, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd658759922 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd124688 : primout_F_L_temp;

		mux16_30bits MB_L(30'd0, 30'd0, 30'd710244761, 30'd209597952, 30'd309635213, 30'd526039964, 30'd287823023, 30'd309897716, 30'd215030053, 30'd53202756, 30'd819621124, 30'd1008500125, 30'd194536158, 30'd688895908, 30'd710244761, 30'd209597952, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = 		(primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;	

	end
   else if (modular_index==3'd5 && core_index==1'b1)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd769236, 30'd236719465, 30'd944984352, 30'd300675133, 30'd1029398733, 30'd789447622, 30'd71006940, 30'd680182259, 30'd744493664, 30'd35327516, 30'd542201251, 30'd103343005, 30'd769236, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd1055955378 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd768977087 : primout_F_S_temp;

		mux16_30bits MB(30'd0, 30'd0, 30'd970136676, 30'd430609598, 30'd852528494, 30'd429347072, 30'd547143474, 30'd659315896, 30'd534631925, 30'd980465242, 30'd1063497884, 30'd181277513, 30'd674025485, 30'd8612253, 30'd970136676, 30'd430609598, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd970136676 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd970136676 : (primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd124688, 30'd658759922, 30'd967161808, 30'd545099760, 30'd973512736, 30'd162640568, 30'd525785482, 30'd682468151, 30'd151791783, 30'd1042154549, 30'd728967264, 30'd353207912, 30'd124688, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd1057783385 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd22584507 : primout_F_L_temp;

		mux16_30bits MB_L(30'd0, 30'd0, 30'd710244761, 30'd209597952, 30'd309635213, 30'd526039964, 30'd287823023, 30'd309897716, 30'd215030053, 30'd53202756, 30'd819621124, 30'd1008500125, 30'd194536158, 30'd688895908, 30'd710244761, 30'd209597952, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd710244761 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd710244761 : (primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;

	end	
///////
   else if (modular_index==3'd6 && core_index==1'b0)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd334620, 30'd321776295, 30'd115992925, 30'd504256884, 30'd303037519, 30'd922211473, 30'd623907695, 30'd843233788, 30'd710189682, 30'd288274516, 30'd290084058, 30'd768228926, 30'd334620, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd321776295 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd334620 :	primout_F_S_temp;	

		mux16_30bits MB(30'd0, 30'd0, 30'd295092675, 30'd542493576, 30'd587316640, 30'd478851851, 30'd685304440, 30'd791030970, 30'd737028797, 30'd409889212, 30'd980668051, 30'd908608119, 30'd147231085, 30'd203593514, 30'd295092675, 30'd542493576, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = 		(primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;	

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd334620, 30'd321776295, 30'd115992925, 30'd504256884, 30'd303037519, 30'd922211473, 30'd623907695, 30'd843233788, 30'd710189682, 30'd288274516, 30'd290084058, 30'd768228926, 30'd334620, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd321776295 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd334620 : primout_F_L_temp;

		mux16_30bits MB_L(30'd0, 30'd0, 30'd295092675, 30'd542493576, 30'd587316640, 30'd478851851, 30'd685304440, 30'd791030970, 30'd737028797, 30'd409889212, 30'd980668051, 30'd908608119, 30'd147231085, 30'd203593514, 30'd295092675, 30'd542493576, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = 		(primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;	
	end
   else
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd334620, 30'd321776295, 30'd115992925, 30'd504256884, 30'd303037519, 30'd922211473, 30'd623907695, 30'd843233788, 30'd710189682, 30'd288274516, 30'd290084058, 30'd768228926, 30'd334620, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd214889731 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd386246764 : primout_F_S_temp;

		mux16_30bits MB(30'd0, 30'd0, 30'd295092675, 30'd542493576, 30'd587316640, 30'd478851851, 30'd685304440, 30'd791030970, 30'd737028797, 30'd409889212, 30'd980668051, 30'd908608119, 30'd147231085, 30'd203593514, 30'd295092675, 30'd542493576, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd295092675 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd295092675 : (primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd334620, 30'd321776295, 30'd115992925, 30'd504256884, 30'd303037519, 30'd922211473, 30'd623907695, 30'd843233788, 30'd710189682, 30'd288274516, 30'd290084058, 30'd768228926, 30'd334620, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd214889731 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd386246764 : primout_F_L_temp;

		mux16_30bits MB_L(30'd0, 30'd0, 30'd295092675, 30'd542493576, 30'd587316640, 30'd478851851, 30'd685304440, 30'd791030970, 30'd737028797, 30'd409889212, 30'd980668051, 30'd908608119, 30'd147231085, 30'd203593514, 30'd295092675, 30'd542493576, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd295092675 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd295092675 : (primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;
	end	
endgenerate	





generate
   if (modular_index==3'd0 && core_index==1'b0)
		assign n_inverse_S = 30'd1068303601;
   else if (modular_index==3'd0 && core_index==1'b1)
		assign n_inverse_S = 30'd448417522;		
   else if (modular_index==3'd1 && core_index==1'b0)
		assign n_inverse_S = 30'd1068958801;
   else if (modular_index==3'd1 && core_index==1'b1)
		assign n_inverse_S = 30'd137419513;
   else if (modular_index==3'd2 && core_index==1'b0)
		assign n_inverse_S = 30'd1070465761;
   else if (modular_index==3'd2 && core_index==1'b1)
		assign n_inverse_S = 30'd40945037;
   else if (modular_index==3'd3 && core_index==1'b0)
		assign n_inverse_S = 30'd1071252001;
   else if (modular_index==3'd3 && core_index==1'b1)
		assign n_inverse_S = 30'd480960522;		
   else if (modular_index==3'd4 && core_index==1'b0)
		assign n_inverse_S = 30'd1072234801;
   else if (modular_index==3'd4 && core_index==1'b1)
		assign n_inverse_S = 30'd342902579;
   else if (modular_index==3'd5 && core_index==1'b0)
		assign n_inverse_S = 30'd1073217601;
   else if (modular_index==3'd5 && core_index==1'b1)
		assign n_inverse_S = 30'd428502903;		
   else if (modular_index==3'd6 && core_index==1'b0)
		assign n_inverse_S = 30'd1063062001;
   else 
		assign n_inverse_S = 30'd587264906;		
endgenerate

generate
   if (modular_index==3'd0 && core_index==1'b0)
		assign n_inverse_L = 30'd1068172561;
   else if (modular_index==3'd0 && core_index==1'b1)
		assign n_inverse_L = 30'd168115064;
   else if (modular_index==3'd1  && core_index==1'b0)
		assign n_inverse_L = 30'd1067976001;
   else if (modular_index==3'd1  && core_index==1'b1)
		assign n_inverse_L = 30'd706407413;
   else if (modular_index==3'd2 && core_index==1'b0)
		assign n_inverse_L = 30'd1065551761;
   else if (modular_index==3'd2 && core_index==1'b1)
		assign n_inverse_L = 30'd1020818214;		
   else if (modular_index==3'd3 && core_index==1'b0)
		assign n_inverse_L = 30'd1065224161;
   else if (modular_index==3'd3 && core_index==1'b1)
		assign n_inverse_L = 30'd666266270;		
   else if (modular_index==3'd4 && core_index==1'b0)
		assign n_inverse_L = 30'd1064437921;
   else if (modular_index==3'd4 && core_index==1'b1)
		assign n_inverse_L = 30'd86986370;
	else if (modular_index==3'd5 && core_index==1'b0)	 
		assign n_inverse_L = 30'd1063193041;
	else if (modular_index==3'd5 && core_index==1'b1)	 
		assign n_inverse_L = 30'd555780668;
	else if (modular_index==3'd6 && core_index==1'b0) 
		assign n_inverse_L = 30'd1063062001;
	else  
		assign n_inverse_L = 30'd587264906;		
endgenerate

mux2_30bits MP_ninv(n_inverse_S, n_inverse_L, modulus_sel, n_inverse);
mux2_30bits MP_F(primout_F_S, primout_F_L, modulus_sel, primout_F);
mux2_30bits MP_B(primout_B_S, primout_B_L, modulus_sel, primout_B);
mux2_30bits MP(primout_F, primout_B, mode[0], primout);
mux2_30bits M3(30'd1, n_inverse, sel3, M3_out);
mux4_30bits_special M4(t1, M3_out, primout, MZ1_out, sel2, primsel[3], rom_data);

crt_rom	#(modular_index) CROM(crt_rom_address, crt_rom_data);
mux4_30bits M9(/*WQ_out,*/ w_NTT_ROM, MZ2_out, crt_rom_data, 30'd0, sel9, M9_out);
coefficient_multiplier30bit	#(modular_index) CM(clk, modulus_sel, rom_data, M9_out, mod_mult_out);
mux2_30bits M7(rom_data, mod_mult_out, sel7, M7_out);
sub_mod30bit #(modular_index) SM(clk, modulus_sel, u8, mod_mult_out, sub_out);

mux2_30bits MADD1(mod_mult_out, MZ1_out, addin_sel[0], MADD1_out);
mux3_30bits MADD3(u8, MZ2_out, 30'd0, addin_sel, MADD2_out);
add_mod30bit #(modular_index) AM(clk, modulus_sel, MADD1_out, MADD2_out, add_out);


wire [29:0] din_low_L, din_high_L, din_low_H, din_high_H;

assign din_low_sel = (wtsel2==2'd0 && rst_ac==1'b1) ? {1'b0,wtsel_10} : wtsel2;
assign din_high_sel = (wtsel3==2'd0 && rst_ac==1'b1) ? {1'b0,wtsel_10} : wtsel3;

/*
always @(posedge clk)
begin
	{din_high_sel, din_low_sel} <= {din_high_sel_wire, din_high_sel_wire};
end
*/

generate
   if (core_index==1'b0)
	begin
		mux4_30bits M5_L(R5, R3, u1, load2, din_low_sel, din_low);
		mux4_30bits M6_L(R4, R2, t1, load1, din_high_sel, din_high);
	end
	else
	begin
		mux4_30bits M5_L(R5, R3, u1, load2, din_low_sel, din_low_L);
		mux4_30bits M6_L(R4, R2, t1, load1, din_high_sel, din_high_L);		

		mux4_30bits M5_H(R1, R5, u1, load2, din_low_sel, din_low_H);
		mux4_30bits M6_H(R2, R6, t1, load1, din_high_sel, din_high_H);		

		assign din_low = (mode[1]==1'b0 && rst_ac==1'b1 && m[12]==1'b0) ? din_low_H : din_low_L;
		assign din_high = (mode[1]==1'b0 && rst_ac==1'b1 && m[12]==1'b0) ? din_high_H : din_high_L;
	end
endgenerate	

always @(posedge clk)
begin
	t1 <= dout_high; t2 <= t1; t3 <= t2; u1 <= dout_low;
	u2 <= u1; u3 <= u2; u4 <= u3; u5 <= u4; u6 <= u5; u7 <= u6; u8 <= u7; u9 <= u8; u10 <= u9; u11 <= u10; u12 <= u11;         
end


always @(posedge clk) 
begin
	if(wq_en && c4==2'd0) wque1 <= M7_out; else wque1 <= wque1;
	if(wq_en && c4==2'd1) wque2 <= M7_out; else wque2 <= wque2;
	if(wq_en && c4==2'd2) wque3 <= M7_out; else wque3 <= wque3;	
	if(wq_en && c4==2'd3) wque4 <= M7_out; else wque4 <= wque4;	
end



assign WQ_out = (c5==2'd0) ? wque1 : (c5==2'd1) ? wque2 : (c5==2'd2) ? wque3 : wque4;

always @(posedge clk)
begin
	R1 <= sub_out; R2 <= R1; R3 <= R2;
	R4 <= add_out; R5 <= R4; R6 <= R5;
end

endmodule




/*
module datapath #(parameter modular_index=6, parameter core_index=1'b1) 
		(clk, modulus_sel, mode, m, w_NTT_ROM, primout_mask,
		dout_high, dout_low, load1, load2,
		prim_counter, c4, c5, 
		sel1, sel2, sel3, sel7, sel9, sel10, wtsel2, wtsel3, mz_sel, addin_sel, wtsel_10,
		wq_en, rst_ac, crt_rom_address,
		
		din_high, din_low, crt_sum_for_accumulation
		);


input clk;
input modulus_sel;	// If 0 then first set of modulus [q0 to q5] else [q6 to q12]
input [1:0] mode;		// 0 for fwd NTT, 1 for invNTT; 2 for rearrange
input [12:0] m;
input [29:0] w_NTT_ROM;
input primout_mask;
input [29:0] dout_high, dout_low, load1, load2;
input [3:0] prim_counter;
input [2:0] c4;
input [1:0] c5;


input sel3, sel7, sel10, mz_sel, wq_en;
input [1:0] sel9;
input rst_ac;	// This is used to set wtqsel2=0, wtqsel3=0 during coefficient add/ mult operation
input [2:0] sel1;
input [1:0] sel2, wtsel2, wtsel3, addin_sel;
input wtsel_10;
input [2:0] crt_rom_address; 
output [29:0] din_high, din_low;
output [29:0] crt_sum_for_accumulation;

// pipelines 
reg [29:0] t1, t2, t3, u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, u11, u12;
reg [29:0] wque1, wque2, wque3, wque4;
reg [29:0] R1, R2, R3, R4, R5, R6;
wire [1:0] din_high_sel, din_low_sel; 
//reg [1:0] din_high_sel, din_low_sel; 
wire [29:0] crt_rom_data;
wire [60:0] crt_reg_input;
reg [60:0] crt_reg;

wire [3:0] primsel;
wire [29:0] primout_F_S, primout_B_S, primout_F_L, primout_B_L, primout_F, primout_B, primout;
wire [29:0] primout_F_S_temp, primout_B_S_temp, primout_F_L_temp, primout_B_L_temp;
wire [29:0] rom_data, WQ_out, mod_mult_out, sub_out, add_out, M3_out, M7_out, MZ1_out, MZ2_out, M9_out, MADD1_out, MADD2_out;
wire [59:0] M10_out;
wire [3:0] primsel_minus1, primsel_minus2;
wire [29:0] n_inverse_S, n_inverse_L, n_inverse;

assign primsel_minus1 = prim_counter - 1'd1;
assign primsel_minus2 = prim_counter - 2'd2;
assign primsel = 	(sel1==3'd0) ? prim_counter : 
						(sel1==3'd1) ? prim_counter + 1'd1 : 
						(sel1==3'd2) ? prim_counter + 2'd2 :
						(sel1==3'd3) ? {1'b0,primsel_minus1} :
						{1'b0,primsel_minus2};

mux2_30bits MZ1(u1, t2, mz_sel, MZ1_out);
mux2_30bits MZ2(u2, t3, mz_sel, MZ2_out);

generate
   if (modular_index==3'd0 && core_index==1'b0)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd444976, 30'd319211591, 30'd551548925, 30'd87766572, 30'd769366155, 
					 30'd266787309, 30'd627853310, 30'd975425846, 30'd119911759, 30'd823032590, 30'd852336940, 
					 30'd913406407, 30'd444976, primsel[3:0], primout_F_S_temp);
					 
		assign primout_F_S = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd319211591 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd444976 :	primout_F_S_temp;	

		mux16_30bits MB(30'd0, 30'd0, 30'd155158074, 30'd42723272, 30'd1003649986, 30'd150330158, 30'd710477484, 30'd125398397, 
					 30'd289088391, 30'd1006947991, 30'd404523277, 30'd717304516, 30'd1013178094, 30'd924391754, 
					 30'd155158074, 30'd42723272, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = 		(primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;	
	
	
		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd231132, 30'd330974, 30'd563580958, 30'd234005231, 30'd815092557, 
					 30'd704299835, 30'd544065806, 30'd395612431, 30'd94884056, 30'd911418076, 30'd224579501, 
					 30'd817491548, 30'd231132, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd330974 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd231132 :	primout_F_L_temp;						 

		mux16_30bits MB_L(30'd0, 30'd0, 30'd250941861, 30'd93667974, 30'd538710288, 30'd770999838, 30'd561180715, 30'd413078757, 
					 30'd196193677, 30'd1016538878, 30'd381788193, 30'd914395578, 30'd691354142, 30'd528186748, 
					 30'd250941861, 30'd93667974, primsel[3:0], primout_B_L_temp);					 

		assign primout_B_L = 		(primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;	
	end
   else if (modular_index==3'd0 && core_index==1'b1)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd444976, 30'd319211591, 30'd551548925, 30'd87766572, 30'd769366155, 
					 30'd266787309, 30'd627853310, 30'd975425846, 30'd119911759, 30'd823032590, 30'd852336940, 
					 30'd913406407, 30'd444976, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd822982060 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd469110148 :	primout_F_S_temp;

		mux16_30bits MB(30'd0, 30'd0, 30'd155158074, 30'd42723272, 30'd1003649986, 30'd150330158, 30'd710477484, 30'd125398397, 
					 30'd289088391, 30'd1006947991, 30'd404523277, 30'd717304516, 30'd1013178094, 30'd924391754, 
					 30'd155158074, 30'd42723272, primsel[3:0], primout_B_S_temp);	

		assign primout_B_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd155158074 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd155158074 :(primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd231132, 30'd330974, 30'd563580958, 30'd234005231, 30'd815092557, 
					 30'd704299835, 30'd544065806, 30'd395612431, 30'd94884056, 30'd911418076, 30'd224579501, 
					 30'd817491548, 30'd231132, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd507979410 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd281824322 : primout_F_L_temp;					 

		mux16_30bits MB_L(30'd0, 30'd0, 30'd250941861, 30'd93667974, 30'd538710288, 30'd770999838, 30'd561180715, 30'd413078757, 
					 30'd196193677, 30'd1016538878, 30'd381788193, 30'd914395578, 30'd691354142, 30'd528186748, 
					 30'd250941861, 30'd93667974, primsel[3:0], primout_B_L_temp);					 

		assign primout_B_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd250941861 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd250941861 : (primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;
					 
	end	
	
///////
   else if (modular_index==3'd1 && core_index==1'b0)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd336036, 30'd652109991, 30'd387542263, 30'd294190876, 30'd979282603, 30'd944032230, 30'd1026867084, 30'd743644219, 30'd896665182, 30'd128160371, 30'd286914778, 30'd1038766166, 30'd336036, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd652109991 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd336036 :	primout_F_S_temp;	

		mux16_30bits MB(30'd0, 30'd0, 30'd30453675, 30'd1006546725, 30'd315436785, 30'd807372739, 30'd754300434, 30'd748150142, 30'd1068297522, 30'd642564166, 30'd21873183, 30'd886057947, 30'd371536267, 30'd460688882, 30'd30453675, 30'd1006546725, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = 		(primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;	

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd25582, 30'd654438724, 30'd909074033, 30'd709400045, 30'd924928891, 30'd121854815, 30'd785814528, 30'd755204846, 30'd954720360, 30'd1014126830, 30'd374995180, 30'd61436824, 30'd25582, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd654438724 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd25582 :	primout_F_L_temp;	

		mux16_30bits MB_L(30'd0, 30'd0, 30'd1006799977, 30'd919121266, 30'd828919538, 30'd73508884, 30'd879825469, 30'd788098188, 30'd859215920, 30'd433571644, 30'd34678426, 30'd13428502, 30'd952771199, 30'd659506540, 30'd1006799977, 30'd919121266, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = 		(primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;	
	end
   else if (modular_index==3'd1 && core_index==1'b1)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd336036, 30'd652109991, 30'd387542263, 30'd294190876, 30'd979282603, 30'd944032230, 30'd1026867084, 30'd743644219, 30'd896665182, 30'd128160371, 30'd286914778, 30'd1038766166, 30'd336036, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd432887847 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd1041185752 : primout_F_S_temp;

		mux16_30bits MB(30'd0, 30'd0, 30'd30453675, 30'd1006546725, 30'd315436785, 30'd807372739, 30'd754300434, 30'd748150142, 30'd1068297522, 30'd642564166, 30'd21873183, 30'd886057947, 30'd371536267, 30'd460688882, 30'd30453675, 30'd1006546725, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd30453675 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd30453675 : (primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd25582, 30'd654438724, 30'd909074033, 30'd709400045, 30'd924928891, 30'd121854815, 30'd785814528, 30'd755204846, 30'd954720360, 30'd1014126830, 30'd374995180, 30'd61436824, 30'd25582, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd289831858 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd300497297 : primout_F_L_temp;

		mux16_30bits MB_L(30'd0, 30'd0, 30'd1006799977, 30'd919121266, 30'd828919538, 30'd73508884, 30'd879825469, 30'd788098188, 30'd859215920, 30'd433571644, 30'd34678426, 30'd13428502, 30'd952771199, 30'd659506540, 30'd1006799977, 30'd919121266, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd1006799977 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd1006799977 : (primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;

	end	
	
///////
   else if (modular_index==3'd2 && core_index==1'b0)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd961955, 30'd249148009, 30'd536187058, 30'd70625433, 30'd320738890, 30'd330351693, 30'd802210960, 30'd747095967, 30'd191524138, 30'd495455403, 30'd989608748, 30'd508629812, 30'd961955, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd249148009 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd961955 :	primout_F_S_temp;	

		mux16_30bits MB(30'd0, 30'd0, 30'd562097357, 30'd226500556, 30'd440266667, 30'd749497381, 30'd767155781, 30'd717141519, 30'd716847576, 30'd683461883, 30'd637149258, 30'd167465049, 30'd948311613, 30'd677433188, 30'd562097357, 30'd226500556, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = 		(primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;	

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd246147, 30'd902875345, 30'd64525337, 30'd330714868, 30'd1013891573, 30'd216152217, 30'd120415734, 30'd283865449, 30'd453917989, 30'd837736347, 30'd368594555, 30'd607722190, 30'd246147, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd902875345 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd246147 :	primout_F_L_temp;	

		mux16_30bits MB_L(30'd0, 30'd0, 30'd458089779, 30'd180490951, 30'd380056204, 30'd604442456, 30'd161798952, 30'd960932704, 30'd25662206, 30'd654132840, 30'd827596419, 30'd1025396464, 30'd779690137, 30'd91050157, 30'd458089779, 30'd180490951, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = 		(primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;	

	end
   else if (modular_index==3'd2 && core_index==1'b1)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd961955, 30'd249148009, 30'd536187058, 30'd70625433, 30'd320738890, 30'd330351693, 30'd802210960, 30'd747095967, 30'd191524138, 30'd495455403, 30'd989608748, 30'd508629812, 30'd961955, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd419764918 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd574383389 : primout_F_S_temp;

		mux16_30bits MB(30'd0, 30'd0, 30'd562097357, 30'd226500556, 30'd440266667, 30'd749497381, 30'd767155781, 30'd717141519, 30'd716847576, 30'd683461883, 30'd637149258, 30'd167465049, 30'd948311613, 30'd677433188, 30'd562097357, 30'd226500556, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd562097357 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd562097357 : (primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd246147, 30'd902875345, 30'd64525337, 30'd330714868, 30'd1013891573, 30'd216152217, 30'd120415734, 30'd283865449, 30'd453917989, 30'd837736347, 30'd368594555, 30'd607722190, 30'd246147, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd123427067 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd152428842 : primout_F_L_temp;

		mux16_30bits MB_L(30'd0, 30'd0, 30'd458089779, 30'd180490951, 30'd380056204, 30'd604442456, 30'd161798952, 30'd960932704, 30'd25662206, 30'd654132840, 30'd827596419, 30'd1025396464, 30'd779690137, 30'd91050157, 30'd458089779, 30'd180490951, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd458089779 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd458089779 : (primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;

	end	
///////
   else if (modular_index==3'd3 && core_index==1'b0)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd143907, 30'd350466230, 30'd797812658, 30'd854040739, 30'd887318665, 30'd1050518287, 30'd730238413, 30'd180341400, 30'd415831590, 30'd991439124, 30'd551143544, 30'd677515442, 30'd143907, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd350466230 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd143907 :	primout_F_S_temp;	

		mux16_30bits MB(30'd0, 30'd0, 30'd393998159, 30'd711691669, 30'd701801046, 30'd119354467, 30'd490176955, 30'd758409004, 30'd242848814, 30'd406807121, 30'd422015267, 30'd267632320, 30'd483758184, 30'd572299474, 30'd393998159, 30'd711691669, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = 		(primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;	

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd10327, 30'd106646929, 30'd17017513, 30'd315407836, 30'd10348144, 30'd782231658, 30'd278231670, 30'd1018170734, 30'd650391915, 30'd502413334, 30'd696827271, 30'd334941153, 30'd10327, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd106646929 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd10327 :	primout_F_L_temp;	

		mux16_30bits MB_L(30'd0, 30'd0, 30'd730543136, 30'd985627134, 30'd935579711, 30'd614540189, 30'd258988186, 30'd1028499587, 30'd517294893, 30'd1040527341, 30'd168138263, 30'd23337371, 30'd1001510690, 30'd321377791, 30'd730543136, 30'd985627134, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = 		(primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;	
	end
   else if (modular_index==3'd3 && core_index==1'b1)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd143907, 30'd350466230, 30'd797812658, 30'd854040739, 30'd887318665, 30'd1050518287, 30'd730238413, 30'd180341400, 30'd415831590, 30'd991439124, 30'd551143544, 30'd677515442, 30'd143907, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd261286316 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd49129702 : primout_F_S_temp;

		mux16_30bits MB(30'd0, 30'd0, 30'd393998159, 30'd711691669, 30'd701801046, 30'd119354467, 30'd490176955, 30'd758409004, 30'd242848814, 30'd406807121, 30'd422015267, 30'd267632320, 30'd483758184, 30'd572299474, 30'd393998159, 30'd711691669, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd393998159 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd393998159 : (primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;
		
		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd10327, 30'd106646929, 30'd17017513, 30'd315407836, 30'd10348144, 30'd782231658, 30'd278231670, 30'd1018170734, 30'd650391915, 30'd502413334, 30'd696827271, 30'd334941153, 30'd10327, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd401185306 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd375284937 : primout_F_L_temp;

		mux16_30bits MB_L(30'd0, 30'd0, 30'd730543136, 30'd985627134, 30'd935579711, 30'd614540189, 30'd258988186, 30'd1028499587, 30'd517294893, 30'd1040527341, 30'd168138263, 30'd23337371, 30'd1001510690, 30'd321377791, 30'd730543136, 30'd985627134, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd730543136 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd730543136 : (primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;
	end	
///////
   else if (modular_index==3'd4 && core_index==1'b0)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd27507, 30'd756635049, 30'd10325248, 30'd290159540, 30'd54435894, 30'd163865235, 30'd1052498090, 30'd537194214, 30'd1056687229, 30'd745573822, 30'd800531529, 30'd652017833, 30'd27507, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd756635049 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd27507 :	primout_F_S_temp;	

		mux16_30bits MB(30'd0, 30'd0, 30'd420478808, 30'd85699917, 30'd543795992, 30'd345364396, 30'd739532327, 30'd723753985, 30'd348038677, 30'd130735712, 30'd832796700, 30'd322101308, 30'd907213382, 30'd630860515, 30'd420478808, 30'd85699917, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = 		(primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;	

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd24888, 30'd619412544, 30'd137458013, 30'd101347675, 30'd191250939, 30'd826488760, 30'd132049762, 30'd450439865, 30'd952985626, 30'd857700401, 30'd288158969, 30'd387420792, 30'd24888, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd619412544 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd24888 : primout_F_L_temp;

		mux16_30bits MB_L(30'd0, 30'd0, 30'd677277065, 30'd611191670, 30'd935442564, 30'd758850379, 30'd852669545, 30'd483008514, 30'd934214709, 30'd176842940, 30'd974591893, 30'd200380827, 30'd403407151, 30'd687087282, 30'd677277065, 30'd611191670, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = 		(primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;	
	end
   else if (modular_index==3'd4 && core_index==1'b1)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd27507, 30'd756635049, 30'd10325248, 30'd290159540, 30'd54435894, 30'd163865235, 30'd1052498090, 30'd537194214, 30'd1056687229, 30'd745573822, 30'd800531529, 30'd652017833, 30'd27507, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd462922245 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd765701529 : primout_F_S_temp;

		mux16_30bits MB(30'd0, 30'd0, 30'd420478808, 30'd85699917, 30'd543795992, 30'd345364396, 30'd739532327, 30'd723753985, 30'd348038677, 30'd130735712, 30'd832796700, 30'd322101308, 30'd907213382, 30'd630860515, 30'd420478808, 30'd85699917, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd420478808 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd420478808 : (primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd24888, 30'd619412544, 30'd137458013, 30'd101347675, 30'd191250939, 30'd826488760, 30'd132049762, 30'd450439865, 30'd952985626, 30'd857700401, 30'd288158969, 30'd387420792, 30'd24888, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd719293560 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd224878304 : primout_F_L_temp;

		mux16_30bits MB_L(30'd0, 30'd0, 30'd677277065, 30'd611191670, 30'd935442564, 30'd758850379, 30'd852669545, 30'd483008514, 30'd934214709, 30'd176842940, 30'd974591893, 30'd200380827, 30'd403407151, 30'd687087282, 30'd677277065, 30'd611191670, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd677277065 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd677277065 : (primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;
	end	
///////
   else if (modular_index==3'd5 && core_index==1'b0)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd769236, 30'd236719465, 30'd944984352, 30'd300675133, 30'd1029398733, 30'd789447622, 30'd71006940, 30'd680182259, 30'd744493664, 30'd35327516, 30'd542201251, 30'd103343005, 30'd769236, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd236719465 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd769236 :	primout_F_S_temp;	


		mux16_30bits MB(30'd0, 30'd0, 30'd970136676, 30'd430609598, 30'd852528494, 30'd429347072, 30'd547143474, 30'd659315896, 30'd534631925, 30'd980465242, 30'd1063497884, 30'd181277513, 30'd674025485, 30'd8612253, 30'd970136676, 30'd430609598, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = 		(primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;	

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd124688, 30'd658759922, 30'd967161808, 30'd545099760, 30'd973512736, 30'd162640568, 30'd525785482, 30'd682468151, 30'd151791783, 30'd1042154549, 30'd728967264, 30'd353207912, 30'd124688, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd658759922 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd124688 : primout_F_L_temp;

		mux16_30bits MB_L(30'd0, 30'd0, 30'd710244761, 30'd209597952, 30'd309635213, 30'd526039964, 30'd287823023, 30'd309897716, 30'd215030053, 30'd53202756, 30'd819621124, 30'd1008500125, 30'd194536158, 30'd688895908, 30'd710244761, 30'd209597952, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = 		(primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;	

	end
   else if (modular_index==3'd5 && core_index==1'b1)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd769236, 30'd236719465, 30'd944984352, 30'd300675133, 30'd1029398733, 30'd789447622, 30'd71006940, 30'd680182259, 30'd744493664, 30'd35327516, 30'd542201251, 30'd103343005, 30'd769236, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd1055955378 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd768977087 : primout_F_S_temp;

		mux16_30bits MB(30'd0, 30'd0, 30'd970136676, 30'd430609598, 30'd852528494, 30'd429347072, 30'd547143474, 30'd659315896, 30'd534631925, 30'd980465242, 30'd1063497884, 30'd181277513, 30'd674025485, 30'd8612253, 30'd970136676, 30'd430609598, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd970136676 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd970136676 : (primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd124688, 30'd658759922, 30'd967161808, 30'd545099760, 30'd973512736, 30'd162640568, 30'd525785482, 30'd682468151, 30'd151791783, 30'd1042154549, 30'd728967264, 30'd353207912, 30'd124688, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd1057783385 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd22584507 : primout_F_L_temp;

		mux16_30bits MB_L(30'd0, 30'd0, 30'd710244761, 30'd209597952, 30'd309635213, 30'd526039964, 30'd287823023, 30'd309897716, 30'd215030053, 30'd53202756, 30'd819621124, 30'd1008500125, 30'd194536158, 30'd688895908, 30'd710244761, 30'd209597952, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd710244761 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd710244761 : (primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;

	end	
///////
   else if (modular_index==3'd6 && core_index==1'b0)
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd334620, 30'd321776295, 30'd115992925, 30'd504256884, 30'd303037519, 30'd922211473, 30'd623907695, 30'd843233788, 30'd710189682, 30'd288274516, 30'd290084058, 30'd768228926, 30'd334620, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd321776295 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd334620 :	primout_F_S_temp;	

		mux16_30bits MB(30'd0, 30'd0, 30'd295092675, 30'd542493576, 30'd587316640, 30'd478851851, 30'd685304440, 30'd791030970, 30'd737028797, 30'd409889212, 30'd980668051, 30'd908608119, 30'd147231085, 30'd203593514, 30'd295092675, 30'd542493576, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = 		(primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;	

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd334620, 30'd321776295, 30'd115992925, 30'd504256884, 30'd303037519, 30'd922211473, 30'd623907695, 30'd843233788, 30'd710189682, 30'd288274516, 30'd290084058, 30'd768228926, 30'd334620, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = 		(m[11]==1'b1 && primout_mask==1'b1) ? 30'd321776295 : 		
											(m[12]==1'b1 && primout_mask==1'b1) ? 30'd334620 : primout_F_L_temp;

		mux16_30bits MB_L(30'd0, 30'd0, 30'd295092675, 30'd542493576, 30'd587316640, 30'd478851851, 30'd685304440, 30'd791030970, 30'd737028797, 30'd409889212, 30'd980668051, 30'd908608119, 30'd147231085, 30'd203593514, 30'd295092675, 30'd542493576, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = 		(primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;	
	end
   else
	begin
		mux16_30bits MF(30'd0, 30'd0, 30'd0, 30'd334620, 30'd321776295, 30'd115992925, 30'd504256884, 30'd303037519, 30'd922211473, 30'd623907695, 30'd843233788, 30'd710189682, 30'd288274516, 30'd290084058, 30'd768228926, 30'd334620, primsel[3:0], primout_F_S_temp);

		assign primout_F_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd214889731 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd386246764 : primout_F_S_temp;

		mux16_30bits MB(30'd0, 30'd0, 30'd295092675, 30'd542493576, 30'd587316640, 30'd478851851, 30'd685304440, 30'd791030970, 30'd737028797, 30'd409889212, 30'd980668051, 30'd908608119, 30'd147231085, 30'd203593514, 30'd295092675, 30'd542493576, primsel[3:0], primout_B_S_temp);

		assign primout_B_S = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd295092675 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd295092675 : (primout_mask==1'b1) ? 30'd1 : primout_B_S_temp;

		mux16_30bits MF_L(30'd0, 30'd0, 30'd0, 30'd334620, 30'd321776295, 30'd115992925, 30'd504256884, 30'd303037519, 30'd922211473, 30'd623907695, 30'd843233788, 30'd710189682, 30'd288274516, 30'd290084058, 30'd768228926, 30'd334620, primsel[3:0], primout_F_L_temp);

		assign primout_F_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd214889731 : (m[12]==1'b1 && primout_mask==1'b1) ? 30'd386246764 : primout_F_L_temp;

		mux16_30bits MB_L(30'd0, 30'd0, 30'd295092675, 30'd542493576, 30'd587316640, 30'd478851851, 30'd685304440, 30'd791030970, 30'd737028797, 30'd409889212, 30'd980668051, 30'd908608119, 30'd147231085, 30'd203593514, 30'd295092675, 30'd542493576, primsel[3:0], primout_B_L_temp);

		assign primout_B_L = (m[11]==1'b1 && primout_mask==1'b1) ? 30'd295092675 :(m[12]==1'b1 && primout_mask==1'b1) ? 30'd295092675 : (primout_mask==1'b1) ? 30'd1 : primout_B_L_temp;
	end	
endgenerate	





generate
   if (modular_index==3'd0 && core_index==1'b0)
		assign n_inverse_S = 30'd1068303601;
   else if (modular_index==3'd0 && core_index==1'b1)
		assign n_inverse_S = 30'd448417522;		
   else if (modular_index==3'd1 && core_index==1'b0)
		assign n_inverse_S = 30'd1068958801;
   else if (modular_index==3'd1 && core_index==1'b1)
		assign n_inverse_S = 30'd137419513;
   else if (modular_index==3'd2 && core_index==1'b0)
		assign n_inverse_S = 30'd1070465761;
   else if (modular_index==3'd2 && core_index==1'b1)
		assign n_inverse_S = 30'd40945037;
   else if (modular_index==3'd3 && core_index==1'b0)
		assign n_inverse_S = 30'd1071252001;
   else if (modular_index==3'd3 && core_index==1'b1)
		assign n_inverse_S = 30'd480960522;		
   else if (modular_index==3'd4 && core_index==1'b0)
		assign n_inverse_S = 30'd1072234801;
   else if (modular_index==3'd4 && core_index==1'b1)
		assign n_inverse_S = 30'd342902579;
   else if (modular_index==3'd5 && core_index==1'b0)
		assign n_inverse_S = 30'd1073217601;
   else if (modular_index==3'd5 && core_index==1'b1)
		assign n_inverse_S = 30'd428502903;		
   else if (modular_index==3'd6 && core_index==1'b0)
		assign n_inverse_S = 30'd1063062001;
   else 
		assign n_inverse_S = 30'd587264906;		
endgenerate

generate
   if (modular_index==3'd0 && core_index==1'b0)
		assign n_inverse_L = 30'd1068172561;
   else if (modular_index==3'd0 && core_index==1'b1)
		assign n_inverse_L = 30'd168115064;
   else if (modular_index==3'd1  && core_index==1'b0)
		assign n_inverse_L = 30'd1067976001;
   else if (modular_index==3'd1  && core_index==1'b1)
		assign n_inverse_L = 30'd706407413;
   else if (modular_index==3'd2 && core_index==1'b0)
		assign n_inverse_L = 30'd1065551761;
   else if (modular_index==3'd2 && core_index==1'b1)
		assign n_inverse_L = 30'd1020818214;		
   else if (modular_index==3'd3 && core_index==1'b0)
		assign n_inverse_L = 30'd1065224161;
   else if (modular_index==3'd3 && core_index==1'b1)
		assign n_inverse_L = 30'd666266270;		
   else if (modular_index==3'd4 && core_index==1'b0)
		assign n_inverse_L = 30'd1064437921;
   else if (modular_index==3'd4 && core_index==1'b1)
		assign n_inverse_L = 30'd86986370;
	else if (modular_index==3'd5 && core_index==1'b0)	 
		assign n_inverse_L = 30'd1063193041;
	else if (modular_index==3'd5 && core_index==1'b1)	 
		assign n_inverse_L = 30'd555780668;
	else if (modular_index==3'd6 && core_index==1'b0) 
		assign n_inverse_L = 30'd1063062001;
	else  
		assign n_inverse_L = 30'd587264906;		
endgenerate

mux2_30bits MP_ninv(n_inverse_S, n_inverse_L, modulus_sel, n_inverse);
mux2_30bits MP_F(primout_F_S, primout_F_L, modulus_sel, primout_F);
mux2_30bits MP_B(primout_B_S, primout_B_L, modulus_sel, primout_B);
mux2_30bits MP(primout_F, primout_B, mode[0], primout);
mux2_30bits M3(30'd1, n_inverse, sel3, M3_out);
mux4_30bits_special M4(t1, M3_out, primout, MZ1_out, sel2, primsel[3], rom_data);

crt_rom	#(modular_index) CROM(crt_rom_address, crt_rom_data);
mux4_30bits M9(WQ_out, MZ2_out, crt_rom_data, 30'd0, sel9, M9_out);
coefficient_multiplier30bit	#(modular_index) CM(clk, modulus_sel, rom_data, M9_out, mod_mult_out);
mux2_30bits M7(rom_data, mod_mult_out, sel7, M7_out);
sub_mod30bit #(modular_index) SM(clk, modulus_sel, u8, mod_mult_out, sub_out);

mux2_30bits MADD1(mod_mult_out, MZ1_out, addin_sel[0], MADD1_out);
mux3_30bits MADD3(u8, MZ2_out, 30'd0, addin_sel, MADD2_out);
add_mod30bit #(modular_index) AM(clk, modulus_sel, MADD1_out, MADD2_out, add_out);


wire [29:0] din_low_L, din_high_L, din_low_H, din_high_H;

assign din_low_sel = (wtsel2==2'd0 && rst_ac==1'b1) ? {1'b0,wtsel_10} : wtsel2;
assign din_high_sel = (wtsel3==2'd0 && rst_ac==1'b1) ? {1'b0,wtsel_10} : wtsel3;


//always @(posedge clk)
//begin
//	{din_high_sel, din_low_sel} <= {din_high_sel_wire, din_high_sel_wire};
//end


generate
   if (core_index==1'b0)
	begin
		mux4_30bits M5_L(R5, R3, u1, load2, din_low_sel, din_low);
		mux4_30bits M6_L(R4, R2, t1, load1, din_high_sel, din_high);
	end
	else
	begin
		mux4_30bits M5_L(R5, R3, u1, load2, din_low_sel, din_low_L);
		mux4_30bits M6_L(R4, R2, t1, load1, din_high_sel, din_high_L);		

		mux4_30bits M5_H(R1, R5, u1, load2, din_low_sel, din_low_H);
		mux4_30bits M6_H(R2, R6, t1, load1, din_high_sel, din_high_H);		

		assign din_low = (mode[1]==1'b0 && rst_ac==1'b1 && m[12]==1'b0) ? din_low_H : din_low_L;
		assign din_high = (mode[1]==1'b0 && rst_ac==1'b1 && m[12]==1'b0) ? din_high_H : din_high_L;
	end
endgenerate	

always @(posedge clk)
begin
	t1 <= dout_high; t2 <= t1; t3 <= t2; u1 <= dout_low;
	u2 <= u1; u3 <= u2; u4 <= u3; u5 <= u4; u6 <= u5; u7 <= u6; u8 <= u7; u9 <= u8; u10 <= u9; u11 <= u10; u12 <= u11;         
end


always @(posedge clk) 
begin
	if(wq_en && c4==2'd0) wque1 <= M7_out; else wque1 <= wque1;
	if(wq_en && c4==2'd1) wque2 <= M7_out; else wque2 <= wque2;
	if(wq_en && c4==2'd2) wque3 <= M7_out; else wque3 <= wque3;	
	if(wq_en && c4==2'd3) wque4 <= M7_out; else wque4 <= wque4;	
end


assign WQ_out = (c5==2'd0) ? wque1 : (c5==2'd1) ? wque2 : (c5==2'd2) ? wque3 : wque4;

always @(posedge clk)
begin
	R1 <= sub_out; R2 <= R1; R3 <= R2;
	R4 <= add_out; R5 <= R4; R6 <= R5;
end

endmodule
*/

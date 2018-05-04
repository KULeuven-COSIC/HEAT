LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- 

ENTITY LIFT_STG1_MAIN_CU IS

	port (clk : IN std_logic;
			rst : IN std_logic;
			type_of_data : IN std_logic;
			data_valid : IN std_logic;
			bank_sel : OUT std_logic_vector(2 downto 0); --assigned with a dedicated 3bit counter bank_sel <= COUNTER_8COEFF;
			rd_addr : OUT std_logic_vector(4 downto 0); --TO GO OUT OF BLOCK
			Done_rd_8 : OUT std_logic;
			SOP_done  : OUT std_logic;
			SOP_done2 : OUT std_logic;
			go_signal : IN std_logic;
	 
		BCONST_QI_ADDR : OUT std_logic_vector(4 downto 0);
		MUX_MUL1_IN1_SEL : OUT std_logic;
		MUX_MUL1_IN2_SEL : OUT std_logic;
		BRR_ADDR : OUT std_logic_vector(3 downto 0);
		BRR_WE : OUT std_logic;
		MUX_MANY_MUL_SEL : OUT std_logic;
		MAIN_ROM_ADDR : OUT std_logic_vector(5 downto 0);
		AUX2_ROM_ADDR : OUT std_logic_vector(5 downto 0);
		AUX_ROM_ADDR : OUT std_logic_vector(5 downto 0);
		ONLY_MUL_CU : OUT std_logic;
		MUX_SB_TOP_SEL : OUT std_logic;
		S2_RS_EN : OUT std_logic;
		S2_RS_RST : OUT std_logic;
		MUX_SOP_SEL : OUT std_logic;
		REG_ADD_L_EN : OUT std_logic;
		REG_ADD_L_RST : OUT std_logic;
		REG_ADD_H_EN : OUT std_logic;
		REG_ADD_H_RST : OUT std_logic;
		REG_62_CB_EN : OUT std_logic;
		REG_62_CB_RST : OUT std_logic;
		MUX_WB_SEL : OUT std_logic_vector(2 downto 0);
		WB_WINDOW : OUT std_logic;
		RD_WINDOW : OUT std_logic;
		WB_RESULT_ADDR : OUT std_logic_vector(1 downto 0);
		WB_WE : OUT std_logic;

		SEL_60_63 : OUT  std_logic;
		COMB_EN : OUT  std_logic;
		COMB_RST : OUT  std_logic;
		B2_SOP_TRANSFORM : OUT  std_logic;
		B2_PHASE: OUT std_logic;
		WB_WINDOW_2 : OUT  std_logic;
      RD_WINDOW_2 : OUT  std_logic;
		WB_RESULT_ADDR_2 : OUT  std_logic_vector(2 downto 0);
		WB_WE_2 : OUT  std_logic;
		ToD_SAMPLED : OUT std_logic);       
			


END LIFT_STG1_MAIN_CU;


ARCHITECTURE behavior_FSM OF LIFT_STG1_MAIN_CU IS 
--signals here:
	type TYPE_STATE is (RST_STATE, WAIT_FOR_data_valid,BIG_start_L_setup, BIG_start_L, BIG_start_H, BIG_1_L, BIG_1_H, BIG_1_BRR_L, BIG_1_BRR_H, BIG_2_start, BIG_2_continue, BIG_2_partial_WB_continue1, BIG_2_partial_WB_end, BIG_2_FINAL_WB_continue1, BIG_2_FINAL_WB_END, WAIT_FOR_go_BIG, SMALL_start_setup, SMALL_start_continue_comb,SMALL_start_continue_2, SMALL_start_WB,SMALL_start_WB_END, SMALL_B2_P0_start,SMALL_B2_P0_continue_and_wb, SMALL_B2_P0_continue_and_wb_END,SMALL_B2_P1_start, SMALL_B2_P1_WB_final,SMALL_B2_P1_WB_final_END,WAIT_FOR_go_SMALL); --fill with state names


	signal CURRENT_STATE : TYPE_STATE := RST_STATE;
	signal NEXT_STATE : TYPE_STATE;
	
	signal COUNT_MAX: std_logic_vector(5 downto 0);

	signal COUNTER_8COEFF		: std_logic_vector(2 downto 0):= "000";
	signal COUNTER_8COEFF_NEXT  : std_logic_vector(2 downto 0):= "000";

	signal COUNTER_1: std_logic_vector(5 downto 0):= "000000";
	signal COUNTER_2: std_logic_vector(5 downto 0):= "000000";
	signal COUNTER_3: std_logic_vector(5 downto 0):= "000000";
	signal COUNTER_RD : std_logic_vector(4 downto 0):= "00000";

	signal COUNTER_1plusSECOND_PART_FLAG_vw : std_logic_vector(5 downto 0):= "000000"; 

	signal COUNTER_1_NEXT: std_logic_vector(5 downto 0):= "000000";
	signal COUNTER_2_NEXT: std_logic_vector(5 downto 0):= "000000";
	signal COUNTER_3_NEXT: std_logic_vector(5 downto 0):= "000000";
	signal COUNTER_RD_NEXT : std_logic_vector(4 downto 0):= "00000";

	signal SECOND_PART_FLAG: std_logic:='0';
	signal SECOND_PART_FLAG_NEXT: std_logic:= '0';

	signal SECOND_PART_FLAG_vw : std_logic_vector (0 downto 0);

	signal switch_windows 	: std_logic := '0';
	signal switch_windows_2 : std_logic := '0';
	signal mwp_temp : std_logic :='0';
	signal mwp_temp_2 : std_logic :='0';

	signal conv_temp: std_logic_vector(5 downto 0):= "000000";
	

--CONSTANTS 		
	constant N_qj_inv_OFFSET : std_logic_vector(5 downto 0):= "101001"; -- 41

	constant N_qj_list_OFFSET : std_logic_vector(5 downto 0):= "001001"; -- 9
	constant MUL30_PIPE_DEPTH : std_logic_vector(5 downto 0):= "000100"; -- 4 -------MODIFIED .....  --- se lo modifiche devi modificare gli address.
	constant MUL30_PIPE_DEPTH_BY2 : std_logic_vector(5 downto 0):= "000010"; -- 2

	constant BIG_length : std_logic_vector(5 downto 0):= "001101"; -- 13

	constant MUX_WB_SEL_BIG_OFFSET : std_logic_vector(2 downto 0):= "011"; -- 3
	constant WB_BIG_CYCLES : std_logic_vector(5 downto 0):= "000011"; -- 3

--CONSTANTS Small SOP 
	constant BCONST_QI_B2_PHASE1_OFFSET : std_logic_vector(5 downto 0):= "001101"; -- 13
	constant MUL_PLUS_S2_DEPTH : std_logic_vector(5 downto 0):= "000110"; -- 6
	constant MAIN_ROM_Biqj_OFFSET : std_logic_vector(5 downto 0):= "110000"; -- 48
    constant AUX_ROM_Biqj_OFFSET :  std_logic_vector(5 downto 0):= "101001"; -- 41


BEGIN
	SECOND_PART_FLAG_vw(0) <= SECOND_PART_FLAG;

	--P_combinational_stuff: process (COUNTER_1,SECOND_PART_FLAG_vw)
	--begin
	COUNTER_1plusSECOND_PART_FLAG_vw <= std_logic_vector(unsigned(COUNTER_1) + unsigned(SECOND_PART_FLAG_vw));
	--end process P_combinational_stuff;
	
	bank_sel <= COUNTER_8COEFF;

	conv_temp <= std_logic_vector(unsigned(COUNTER_3)+unsigned(BCONST_QI_B2_PHASE1_OFFSET));

	--Update next state process
   	P_StateUpdate: process (CLK, RST) --CLOCKED PROCESS
	begin
		if RST = '1' then
			CURRENT_STATE <= RST_STATE;
		elsif (CLK = '1' and CLK'EVENT) then
			CURRENT_STATE <= NEXT_STATE;
		end if;
	end process P_StateUpdate;


	P_counters: process(CLK)
	begin
		if (CLK = '1' and CLK'EVENT) then
			COUNTER_1 <= COUNTER_1_NEXT;
			COUNTER_2 <= COUNTER_2_NEXT;
			COUNTER_3 <= COUNTER_3_NEXT;
			COUNTER_8COEFF <= COUNTER_8COEFF_NEXT;
			COUNTER_RD <= COUNTER_RD_NEXT;
		end if;
	end process P_counters;


	P_flags: process(CLK)
	begin
		if (CLK = '1' and CLK'EVENT) then
			SECOND_PART_FLAG <= SECOND_PART_FLAG_NEXT;
		else
			SECOND_PART_FLAG <= SECOND_PART_FLAG;
		end if;
	end process P_flags;


	memory_window_process: process (CLK, RST)
	begin
		if RST = '1' then
			mwp_temp <= '0';
		elsif (CLK = '1' and CLK'EVENT) then
 			if (switch_windows = '0') then
				mwp_temp <= mwp_temp;
			elsif (switch_windows = '1') then
				mwp_temp <= not(mwp_temp);
			end if;
		end if;
	end process memory_window_process;

	WB_WINDOW <= mwp_temp;
	RD_WINDOW <= not (mwp_temp);


	memory_window_process_2: process (CLK, RST)
	begin
		if RST = '1' then
			mwp_temp_2 <= '0';
		elsif (CLK = '1' and CLK'EVENT) then
 			if (switch_windows_2 = '0') then
				mwp_temp_2 <= mwp_temp_2;
			elsif (switch_windows_2 = '1') then
				mwp_temp_2 <= not(mwp_temp_2);
			end if;
		end if;
	end process memory_window_process_2;

	WB_WINDOW_2 <= mwp_temp_2;
	RD_WINDOW_2 <= not (mwp_temp_2);
	
	
	P_ToD_Sampler: process (CLK, RST)
	begin
		if RST = '1' then
			ToD_SAMPLED <= '0';
		elsif (CLK = '1' and CLK'EVENT) then
 			if (DATA_VALID = '1') then
				ToD_SAMPLED <= type_of_data;
			end if;
		end if;
	end process P_ToD_Sampler;




   	P_NEXT_STATE : process(CURRENT_STATE, DATA_VALID, type_of_data, go_signal, counter_1, counter_2, counter_3, second_part_flag, COUNTER_1plusSECOND_PART_FLAG_vw,conv_temp) --COMBINATIONAL PROCESS
	begin
		case CURRENT_STATE is 
			when RST_STATE =>

				 Done_rd_8 			<= '0';
				 rd_addr			<= (others => '0');
				 COUNTER_RD_NEXT 	<= (others => '0');
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0'; --new
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0');
				 MUX_MUL1_IN1_SEL 	<= '0';
				 MUX_MUL1_IN2_SEL 	<= '0';
				 BRR_ADDR           <= (others => '0');
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '0';
				 MAIN_ROM_ADDR 		<= (others => '0');
				 AUX2_ROM_ADDR 		<= (others => '0');
				 AUX_ROM_ADDR 		<= (others => '0');
				 ONLY_MUL_CU 		<= '0';
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0';--new
				 S2_RS_RST 			<= '1';--new
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '0';
 				 REG_ADD_L_RST 		<= '1';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '1';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '1';
				 MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= (others => '0');
				 COUNTER_1_NEXT <= (others => '0');
				 COUNTER_2_NEXT <= (others => '0');
				 COUNTER_3_NEXT <= (others => '0');
				 NEXT_STATE 	<= WAIT_FOR_data_valid;

				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0'; --new
				 COMB_EN 		  <= '0'; --new
				 COMB_RST 		  <= '1'; --new
				 B2_SOP_TRANSFORM <= '0'; --new
				 B2_PHASE 		  <= '0'; --new
				 switch_windows_2 	<= '0'; --new
    			 WB_RESULT_ADDR_2 <= (others => '0');--new
				 WB_WE_2 		  <= '0';--new
				 


			when WAIT_FOR_data_valid =>

				 Done_rd_8 			<= '1';
				 rd_addr			<= (others => '0');
				 COUNTER_RD_NEXT 	<= (others => '0');
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0';

				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0');
				 MUX_MUL1_IN1_SEL 	<= '0';
				 MUX_MUL1_IN2_SEL 	<= '0';
				 BRR_ADDR           <= (others => '0');
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '0';
				 MAIN_ROM_ADDR 		<= (others => '0');
				 AUX2_ROM_ADDR 		<= (others => '0');
				 AUX_ROM_ADDR 		<= (others => '0');
				 ONLY_MUL_CU 		<= '0';
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0';
				 S2_RS_RST 			<= '0';
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '0';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '0';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '0';
				 MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;
				 COUNTER_1_NEXT <= (others => '0');
				 COUNTER_2_NEXT <= (others => '0');
				 COUNTER_3_NEXT <= (others => '0');
				
				 if (DATA_VALID = '0') then
					NEXT_STATE <= WAIT_FOR_data_valid;
				 else
					if (type_of_data = '0') then -- BIG SOP
						NEXT_STATE <= BIG_start_L_setup;
					else 						 --SMALL SOPss
						NEXT_STATE <= SMALL_start_setup;
					end if;
				 end if;

				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0';
				 COMB_EN 		  <= '0'; 
				 COMB_RST 		  <= '0'; 
				 B2_SOP_TRANSFORM <= '0'; 
				 B2_PHASE 		  <= '0';
				 switch_windows_2 	<= '0';
    			 WB_RESULT_ADDR_2 <= (others => '0');
				 WB_WE_2 		  <= '0';
				 

 
			when BIG_start_L_setup => --fill MUL1 pipe calculating [a]qj * N_qj_inv
								-- BEWARE to N_qj_inv_OFFSET = 35, 
								-- N_qj_inv RD_MODE: sequential x 13 from MAIN_ROM only

				 Done_rd_8 			<= '0';
				 rd_addr			<= COUNTER_RD;
				 COUNTER_RD_NEXT 	<= std_logic_vector(unsigned(COUNTER_RD) + to_unsigned(1,5));
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0'; --new
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0');
				 MUX_MUL1_IN1_SEL 	<= '1'; --D_IN_SOP
				 MUX_MUL1_IN2_SEL 	<= '0'; --LOW
				 BRR_ADDR           <= (others => '0');
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '0';
				 MAIN_ROM_ADDR 		<=  std_logic_vector (unsigned(N_qj_inv_OFFSET) + unsigned(COUNTER_1));
				 AUX2_ROM_ADDR 		<= (others => '0');
				 AUX_ROM_ADDR 		<= (others => '0');
				 ONLY_MUL_CU 		<= '0';
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0'; --new
				 S2_RS_RST 			<= '0'; --new
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '0';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '0';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '0';
				 MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;
				 COUNTER_1_NEXT <= COUNTER_1; -- stay same location
				 COUNTER_2_NEXT <= COUNTER_2; -- unsused
				 COUNTER_3_NEXT <= (others => '0'); 
				
				 NEXT_STATE <= BIG_start_L;
				
				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0';--new
				 COMB_EN 		  <= '0'; --new
				 COMB_RST 		  <= '0';--new
				 B2_SOP_TRANSFORM <= '0'; --new
				 B2_PHASE 		  <= '0';--new
				 switch_windows_2 	<= '0';--new
    			 WB_RESULT_ADDR_2 <= (others => '0');--new
				 WB_WE_2 		  <= '0';--new
				 


			when BIG_start_L => --fill MUL1 pipe calculating [a]qj * N_qj_inv
								-- BEWARE to N_qj_inv_OFFSET = 35, 
								-- N_qj_inv RD_MODE: sequential x 13 from MAIN_ROM only
				 Done_rd_8 			<= '0';
				 rd_addr			<= COUNTER_RD;
				 COUNTER_RD_NEXT 	<= std_logic_vector(unsigned(COUNTER_RD) + to_unsigned(1,5));
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0';
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0');
				 MUX_MUL1_IN1_SEL 	<= '1'; --D_IN_SOP
				 MUX_MUL1_IN2_SEL 	<= '0'; --LOW
				 BRR_ADDR           <= (others => '0');
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '0';
				 MAIN_ROM_ADDR 		<=  std_logic_vector (unsigned(N_qj_inv_OFFSET) + unsigned(COUNTER_1));
				 AUX2_ROM_ADDR 		<= (others => '0');
				 AUX_ROM_ADDR 		<= (others => '0');
				 ONLY_MUL_CU 		<= '0';
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0';
				 S2_RS_RST 			<= '0';
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '0';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '0';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '0';
				 MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;
				 --COUNTER_1_NEXT <= COUNTER_1; -- stay same location
				 COUNTER_1_NEXT <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,6)); -- +1
				 COUNTER_2_NEXT <= COUNTER_2; -- unsused 
				 COUNTER_3_NEXT <= (others => '0'); 
				
				 if (COUNTER_1 = std_logic_vector(unsigned(MUL30_PIPE_DEPTH_BY2)-to_unsigned(1,6))) then
					NEXT_STATE <= BIG_1_H;
				 else
					NEXT_STATE <= BIG_start_H;
				 end if;

				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0';
				 COMB_EN 		  <= '0'; 
				 COMB_RST 		  <= '0';
				 B2_SOP_TRANSFORM <= '0';
				 B2_PHASE 		  <= '0';
				 switch_windows_2 	<= '0';
    			 WB_RESULT_ADDR_2 <= (others => '0');
				 WB_WE_2 		  <= '0';
				 

			when BIG_start_H => --fill MUL1 pipe calculating [a]qj * N_qj_inv
								-- BEWARE to N_qj_inv_OFFSET = 35, 
								-- N_qj_inv RD_MODE: sequential x 13 from MAIN_ROM only
				 Done_rd_8 			<= '0';
				 rd_addr			<= COUNTER_RD;
				 COUNTER_RD_NEXT 	<= std_logic_vector(unsigned(COUNTER_RD) + to_unsigned(1,5));
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0';
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0');
				 MUX_MUL1_IN1_SEL 	<= '1'; --D_IN_SOP
				 MUX_MUL1_IN2_SEL 	<= '1'; --HIGH
				 BRR_ADDR           <= (others => '0');
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '0';
				 MAIN_ROM_ADDR 		<=  std_logic_vector(unsigned(N_qj_inv_OFFSET) + unsigned(COUNTER_1));
				 AUX2_ROM_ADDR 		<= (others => '0');
				 AUX_ROM_ADDR 		<= (others => '0');
				 ONLY_MUL_CU 		<= '0';
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0';
				 S2_RS_RST 			<= '0';
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '0';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '0';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '0';
				 MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;
				 COUNTER_1_NEXT <= COUNTER_1; -- stay same location
				 --COUNTER_1_NEXT <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,6)); -- +1
				 COUNTER_2_NEXT <= COUNTER_2; -- unsused
				 COUNTER_3_NEXT <= (others => '0'); 
				
				 if (COUNTER_1 = std_logic_vector(unsigned(MUL30_PIPE_DEPTH_BY2))) then
					NEXT_STATE <= BIG_1_L;
				 else
					NEXT_STATE <= BIG_start_L;
				 end if;			
			
				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;	

				 SEL_60_63 		  <= '0';
				 COMB_EN 		  <= '0'; 
				 COMB_RST 		  <= '0';
				 B2_SOP_TRANSFORM <= '0';
				 B2_PHASE 		  <= '0';
				 switch_windows_2 	<= '0';
    			 WB_RESULT_ADDR_2 <= (others => '0');
				 WB_WE_2 		  <= '0';			
				 

			when BIG_1_L => -- pipe of MUL1 is filled
						  -- the first Bconst_qi has been fed to the barret reduction circuit, continue feeding
						  -- finish computing [a]qj * N_qj_inv and save them in the B_regs
				 Done_rd_8 			<= '0';
				 rd_addr			<= COUNTER_RD;
				 COUNTER_RD_NEXT 	<= std_logic_vector(unsigned(COUNTER_RD) + to_unsigned(1,5));
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0';
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= 	COUNTER_2(4 downto 0);
				 MUX_MUL1_IN1_SEL 	<= '1'; --D_IN_SOP
				 MUX_MUL1_IN2_SEL 	<= '0'; --LOW
				 BRR_ADDR           <= (others => '0');
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '0';
				 --B_EN 				<= '1'; --enabled
				 --B_RST 				<= '0';
				 MAIN_ROM_ADDR 		<=  std_logic_vector(unsigned(N_qj_inv_OFFSET) + unsigned(COUNTER_1));
				 AUX2_ROM_ADDR 		<= (others => '0');
				 AUX_ROM_ADDR 		<= (others => '0');
				 ONLY_MUL_CU 		<= '0';
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0';
				 S2_RS_RST 			<= '0';
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '0';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '0';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '0';
				 MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;

				 COUNTER_1_NEXT <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,6)); -- +1
				 COUNTER_2_NEXT <= std_logic_vector(unsigned(COUNTER_2) + to_unsigned(1,6)); --go on on BCONST_QI_ADDR
				 COUNTER_3_NEXT <= (others => '0'); 

				 if (COUNTER_2 = std_logic_vector(to_unsigned(9,6))) then --pipe depth of barret -1
					NEXT_STATE <= BIG_1_BRR_L;
				 else
					NEXT_STATE <= BIG_1_H;
					--COUNTER_1_NEXT <= COUNTER_1; --stay same location
				 end if;

				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0';
				 COMB_EN 		  <= '0'; 
				 COMB_RST 		  <= '0';
				 B2_SOP_TRANSFORM <= '0';
				 B2_PHASE 		  <= '0';
				 switch_windows_2 	<= '0';
    			 WB_RESULT_ADDR_2 <= (others => '0');
				 WB_WE_2 		  <= '0';
				 

			when BIG_1_H => -- pipe of MUL1 is filled
						  -- the first Bconst_qi has been fed to the barret reduction circuit, continue feeding
						  -- finish computing [a]qj * N_qj_inv and save them in the B_regs
				 Done_rd_8 			<= '0';
				 rd_addr			<= COUNTER_RD;
				 COUNTER_RD_NEXT 	<= std_logic_vector(unsigned(COUNTER_RD) + to_unsigned(1,5));
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0';
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= 	COUNTER_2(4 downto 0);
				 MUX_MUL1_IN1_SEL 	<= '1'; --D_IN_SOP
				 MUX_MUL1_IN2_SEL 	<= '1'; --HIGH
				 BRR_ADDR           <= (others => '0');
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '0';
				 --B_EN 				<= '1'; --enabled
				 --B_RST 				<= '0';
				 MAIN_ROM_ADDR 		<=  std_logic_vector(unsigned(N_qj_inv_OFFSET) + unsigned(COUNTER_1));
				 AUX2_ROM_ADDR 		<= (others => '0');
				 AUX_ROM_ADDR 		<= (others => '0');
				 ONLY_MUL_CU 		<= '0';
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0';
				 S2_RS_RST 			<= '0';
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '0';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '0';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '0';
				 MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;
			 	COUNTER_1_NEXT <= COUNTER_1; --stay same location
			 	COUNTER_2_NEXT <= std_logic_vector(unsigned(COUNTER_2) + to_unsigned(1,6)); -- +1
			 	COUNTER_3_NEXT <= (others => '0'); 

				 if (COUNTER_2 = std_logic_vector(to_unsigned(9,6))) then --BIG_1_BRR_L --BIG_1_BRR_H
					NEXT_STATE <= BIG_1_BRR_L;
				 else
					NEXT_STATE <= BIG_1_L;
					--COUNTER_1_NEXT <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,6)); -- +1
				 end if;

				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0';
				 COMB_EN 		  <= '0'; 
				 COMB_RST 		  <= '0';
				 B2_SOP_TRANSFORM <= '0';
				 B2_PHASE 		  <= '0';
				 switch_windows_2 	<= '0';
    			 WB_RESULT_ADDR_2 <= (others => '0');
				 WB_WE_2 		  <= '0';
				 

			when BIG_1_BRR_L => -- pipe of MUL1 is filled
						  -- the first Bconst_qi has been fed to the barret reduction circuit, continue feeding
						  -- finish computing [a]qj * N_qj_inv and save them in the B_regs
				 Done_rd_8 			<= '0';
				 rd_addr			<= COUNTER_RD;
				 COUNTER_RD_NEXT 	<= std_logic_vector(unsigned(COUNTER_RD) + to_unsigned(1,5));
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0';
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= 	COUNTER_2(4 downto 0);
				 MUX_MUL1_IN1_SEL 	<= '1'; --D_IN_SOP
				 MUX_MUL1_IN2_SEL 	<= '0'; --LOW
				 BRR_ADDR           <= COUNTER_3(3 downto 0); --put correct address
				 BRR_WE				<= '1'; --enable writing
				 MUX_MANY_MUL_SEL 	<= '0';
				 --B_EN 				<= '1'; --enabled
				 --B_RST 				<= '0';
				 MAIN_ROM_ADDR 		<=  std_logic_vector(unsigned(N_qj_inv_OFFSET) + unsigned(COUNTER_1));
				 AUX2_ROM_ADDR 		<= (others => '0');
				 AUX_ROM_ADDR 		<= (others => '0');
				 ONLY_MUL_CU 		<= '0';
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0';
				 S2_RS_RST 			<= '0';
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '0';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '0';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '0';
				 MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;

				 if (COUNTER_3 = std_logic_vector(to_unsigned(12,6))) then
					NEXT_STATE <= BIG_2_start;
					COUNTER_1_NEXT <= (others => '0');
				 	COUNTER_2_NEXT <= (others => '0');
					COUNTER_3_NEXT <= (others => '0'); 
				 else
					NEXT_STATE <= BIG_1_BRR_H;
					COUNTER_1_NEXT <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,6)); -- +1
				 	COUNTER_2_NEXT <= std_logic_vector(unsigned(COUNTER_2) + to_unsigned(1,6)); --go on on BCONST_QI_ADDR
				 	COUNTER_3_NEXT <= std_logic_vector(unsigned(COUNTER_3) + to_unsigned(1,6)); -- go on on BRR_ADDR
				 end if;

				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0';
				 COMB_EN 		  <= '0'; 
				 COMB_RST 		  <= '0';
				 B2_SOP_TRANSFORM <= '0';
				 B2_PHASE 		  <= '0';
				 switch_windows_2 	<= '0';
    			 WB_RESULT_ADDR_2 <= (others => '0');
				 WB_WE_2 		  <= '0';
				 

			when BIG_1_BRR_H => -- pipe of MUL1 is filled
						  -- the first Bconst_qi has been fed to the barret reduction circuit, continue feeding
						  -- finish computing [a]qj * N_qj_inv and save them in the B_regs
				 Done_rd_8 			<= '0';
				 rd_addr			<= COUNTER_RD;
				 COUNTER_RD_NEXT 	<= std_logic_vector(unsigned(COUNTER_RD) + to_unsigned(1,5));
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0';
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= 	COUNTER_2(4 downto 0);
				 MUX_MUL1_IN1_SEL 	<= '1'; --D_IN_SOP
				 MUX_MUL1_IN2_SEL 	<= '1'; --HIGH
				 BRR_ADDR           <= COUNTER_3(3 downto 0); --put correct address
				 BRR_WE				<= '1'; --enable writing
				 MUX_MANY_MUL_SEL 	<= '0';
				 --B_EN 				<= '1'; --enabled
				 --B_RST 				<= '0';
				 MAIN_ROM_ADDR 		<=  std_logic_vector(unsigned(N_qj_inv_OFFSET) + unsigned(COUNTER_1));
				 AUX2_ROM_ADDR 		<= (others => '0');
				 AUX_ROM_ADDR 		<= (others => '0');
				 ONLY_MUL_CU 		<= '0';
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0';
				 S2_RS_RST 			<= '0';
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '0';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '0';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '0';
				 MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;

				 if (COUNTER_3 = std_logic_vector(to_unsigned(12,6))) then --BIG_1_BRR_L --BIG_1_BRR_H
					NEXT_STATE <= BIG_2_start;
					COUNTER_1_NEXT <= (others => '0');
				 	COUNTER_2_NEXT <= (others => '0');
					COUNTER_3_NEXT <= (others => '0'); 
				 else
					NEXT_STATE <= BIG_1_BRR_L;
					COUNTER_1_NEXT <= COUNTER_1; --stay same location
				 	COUNTER_2_NEXT <= std_logic_vector(unsigned(COUNTER_2) + to_unsigned(1,6)); -- go on on BCONST_QI_ADDR
				 	COUNTER_3_NEXT <= std_logic_vector(unsigned(COUNTER_3) + to_unsigned(1,6)); -- go on on BRR_ADDR
				 end if;
 
				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0';
				 COMB_EN 		  <= '0'; 
				 COMB_RST 		  <= '0';
				 B2_SOP_TRANSFORM <= '0';
				 B2_PHASE 		  <= '0';
				 switch_windows_2 	<= '0';
    			 WB_RESULT_ADDR_2 <= (others => '0');
				 WB_WE_2 		  <= '0';
				 

			when BIG_2_start => -- [a]qj * N_qj_inv are saved in the B_regs
						  -- start computing B_regs[12:0]*Nqj_list[12:0][5:0]
						  -- fill MUL1 to MUL6 pipeline
				 Done_rd_8 			<= '0';
				 rd_addr			<= (others => '0'); 
				 COUNTER_RD_NEXT 	<= (others => '0'); 
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0';
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0');
				 MUX_MUL1_IN1_SEL 	<= '0'; -- B_regs
				 MUX_MUL1_IN2_SEL 	<= '1'; --HIGH, always, fixed in this case MUL1 is always processing the H
				 BRR_ADDR           <=  COUNTER_3(3 downto 0);
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '1'; --B_regs
				 --B_EN 				<= '0'; --no, wait right result from memory
				 --B_RST 				<= '0';
				 MAIN_ROM_ADDR 		<=  std_logic_vector(unsigned(N_qj_list_OFFSET) + unsigned(COUNTER_1plusSECOND_PART_FLAG_vw)); --offset of main rom
				 AUX2_ROM_ADDR 		<= 	std_logic_vector(unsigned(N_qj_list_OFFSET) + unsigned(COUNTER_1plusSECOND_PART_FLAG_vw)); --offset of aux_rom e aux2_rom 
				 AUX_ROM_ADDR 		<=  std_logic_vector(unsigned(N_qj_list_OFFSET) + unsigned(COUNTER_1plusSECOND_PART_FLAG_vw)); --offset of aux_rom e aux2_rom 
				 ONLY_MUL_CU 		<= '1'; --FIX: can be that it nees to be switched before, in that case put it in the if in the previuos state...
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0';
				 S2_RS_RST 			<= '0';
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '0';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '0';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '0';
				 MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;
				 --wait in this state untile MULs out are valid => 1 to make address valid
																 -- next clock the response il valid => +3 mul pipe lenght-1 => mul pipe lenght in total
																 -- counter is now moving by 2 so, double it =>8
				 COUNTER_1_NEXT <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(2,6)); -- +2 need to skip the higher part og N_qj_list 
				 COUNTER_2_NEXT <= COUNTER_2; -- unsused
				 COUNTER_3_NEXT <= std_logic_vector(unsigned(COUNTER_3) + to_unsigned(1,6)); -- go on on BRR_ADDR

				 if (COUNTER_1 = std_logic_vector(to_unsigned(8,6))) then --perche i red_add_devono essere preparati a samplare
					NEXT_STATE <= BIG_2_continue;
				 else
					NEXT_STATE <= BIG_2_start;
				 end if;

				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0';
				 COMB_EN 		  <= '0'; 
				 COMB_RST 		  <= '0';
				 B2_SOP_TRANSFORM <= '0';
				 B2_PHASE 		  <= '0';
				 switch_windows_2 	<= '0';
    			 WB_RESULT_ADDR_2 <= (others => '0');
				 WB_WE_2 		  <= '0';
				 

			when BIG_2_continue => -- [a]qj * N_qj_inv are saved in the B_regs
						  			-- start computing B_regs[fixed]*Nqj_list[12:0][5:0]
						  			-- MUL1 to MUL6 pipeline are filled, first result is at the output of MULs
									-- ENABLE REG_ADD_H and REG_ADD_L and continue computing
				 Done_rd_8 			<= '0';
				 rd_addr			<= (others => '0'); 
				 COUNTER_RD_NEXT 	<= (others => '0'); 
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0';
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0');
				 MUX_MUL1_IN1_SEL 	<= '0'; -- B_regs
				 MUX_MUL1_IN2_SEL 	<= '1'; --HIGH, always, fixed in this case MUL1 is always processing the H
				 BRR_ADDR           <=  COUNTER_3(3 downto 0);
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '1'; --B_regs
				 --B_EN 				<= '0'; --DISABLED: B_regs[fixed]
				 --B_RST 				<= '0';
				 MAIN_ROM_ADDR 		<=  std_logic_vector(unsigned(N_qj_list_OFFSET) + unsigned(COUNTER_1plusSECOND_PART_FLAG_vw));
				 AUX2_ROM_ADDR 		<= 	std_logic_vector(unsigned(N_qj_list_OFFSET) + unsigned(COUNTER_1plusSECOND_PART_FLAG_vw)); --offset of aux_rom e aux2_rom 
				 AUX_ROM_ADDR 		<=  std_logic_vector(unsigned(N_qj_list_OFFSET) + unsigned(COUNTER_1plusSECOND_PART_FLAG_vw)); --offset of aux_rom e aux2_rom 
				 ONLY_MUL_CU 		<= '1'; 
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0';
				 S2_RS_RST 			<= '0';
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '1';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '1';
				 REG_ADD_H_RST 		<= '0';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '0';
				 MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;


				if (COUNTER_1 = std_logic_vector(to_unsigned(40,6))) then --we are computing the penultimo value to finish process B_regs result, 34+3 ma deve essere pari, quindi 38
					
					COUNTER_1_NEXT <= (others => '0'); --restart count1
				 	COUNTER_2_NEXT <= (others => '0'); --restart count2
					COUNTER_3_NEXT <= (others => '0'); --restart count3
					
					if (SECOND_PART_FLAG = '1') then -- we need to perform the final WB and conclude SOP
						NEXT_STATE <= BIG_2_FINAL_WB_continue1; 
						SECOND_PART_FLAG_NEXT <= '0'; 	   --RESET SECOND_PART_FLAG

					else -- we need to perform the PARTIAl WB and CONTINUE SOP
						NEXT_STATE <= BIG_2_partial_WB_continue1; 
						SECOND_PART_FLAG_NEXT <= '1';
					end if;

				else -- we need to continue calculation to finish process one B_regs result
					NEXT_STATE <= BIG_2_continue;
					COUNTER_1_NEXT <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(2,6)); -- +2 need to skip the higher part og N_qj_list 
				 	COUNTER_2_NEXT <= COUNTER_2; --keep previuos value
					COUNTER_3_NEXT <= std_logic_vector(unsigned(COUNTER_3) + to_unsigned(1,6)); -- go on on BRR_ADDR
					SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG; --keep previuos value
				end if; 

				 SEL_60_63 		  <= '0';
				 COMB_EN 		  <= '0'; 
				 COMB_RST 		  <= '0';
				 B2_SOP_TRANSFORM <= '0';
				 B2_PHASE 		  <= '0';
				 switch_windows_2 	<= '0';
    			 WB_RESULT_ADDR_2 <= (others => '0');
				 WB_WE_2 		  <= '0';
				 

			when BIG_2_partial_WB_continue1 => 
								   -- sum registers have the right values and need to be disabled, until the pipeline wont be correct ag
									-- prepare mux
									-- prepare WB addr
									-- prepare WE
									-- prepare carry accumulation
									-- prepare REG_62_CB sampling 
										--all happening in the next clock cycle

				 Done_rd_8 			<= '0';
				 rd_addr			<= (others => '0'); 
				 COUNTER_RD_NEXT 	<= (others => '0'); 
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0';
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0');
				 MUX_MUL1_IN1_SEL 	<= '0'; -- B_regs
				 MUX_MUL1_IN2_SEL 	<= '1'; --HIGH, always, fixed in this case MUL1 is always processing the H
				 BRR_ADDR           <= (others => '0');
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '1'; --B_regs
				 --B_EN 				<= '0'; 
				 --B_RST 				<= '0';
				 MAIN_ROM_ADDR 		<=  std_logic_vector(unsigned(N_qj_list_OFFSET) + unsigned(COUNTER_1));
				 AUX2_ROM_ADDR 		<= 	std_logic_vector(unsigned(N_qj_list_OFFSET) + unsigned(COUNTER_1));
				 AUX_ROM_ADDR 		<=  std_logic_vector(unsigned(N_qj_list_OFFSET) + unsigned(COUNTER_1));
				 ONLY_MUL_CU 		<= '1'; 
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0';
				 S2_RS_RST 			<= '0';
				 MUX_SOP_SEL 		<= '1';
				 REG_ADD_L_EN 		<= '1';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '0'; 
				 REG_62_CB_EN 		<= '1';
				 REG_62_CB_RST 		<= '0';
				 MUX_WB_SEL 		<= "010";
				 
				 WB_RESULT_ADDR 	<= COUNTER_1(1 downto 0);
				 WB_WE  			<= '1';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;
				 
				 NEXT_STATE <= BIG_2_partial_WB_end;
				 COUNTER_1_NEXT <= COUNTER_1; -- keep 0 of previous state
				 COUNTER_2_NEXT <= COUNTER_2; --keep previuos value
				 COUNTER_3_NEXT <= COUNTER_3; --keep previuos value
				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG; --keep previuos value

				 SEL_60_63 		  <= '0';
				 COMB_EN 		  <= '0'; 
				 COMB_RST 		  <= '0';
				 B2_SOP_TRANSFORM <= '0';
				 B2_PHASE 		  <= '0';
				 switch_windows_2 	<= '0';
    			 WB_RESULT_ADDR_2 <= (others => '0');
				 WB_WE_2 		  <= '0';
				 
			
			when BIG_2_partial_WB_end => -- partial WB concluded, need to produce the next part of the BIG SOP with care		

				 Done_rd_8 			<= '0';
				 rd_addr			<= (others => '0'); 
				 COUNTER_RD_NEXT 	<= (others => '0'); 
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0';
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0');
				 MUX_MUL1_IN1_SEL 	<= '0'; -- B_regs
				 MUX_MUL1_IN2_SEL 	<= '1'; --HIGH, always, fixed in this case MUL1 is always processing the H
				 BRR_ADDR           <= (others => '0');
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '1'; --B_regs
				 --B_EN 				<= '0'; 
				 --B_RST 				<= '0';
				 MAIN_ROM_ADDR 		<=  std_logic_vector(unsigned(N_qj_list_OFFSET) + unsigned(COUNTER_1));
				 AUX2_ROM_ADDR 		<= 	std_logic_vector(unsigned(N_qj_list_OFFSET) + unsigned(COUNTER_1));
				 AUX_ROM_ADDR 		<=  std_logic_vector(unsigned(N_qj_list_OFFSET) + unsigned(COUNTER_1));
				 ONLY_MUL_CU 		<= '1'; 
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0';
				 S2_RS_RST 			<= '0';
				 MUX_SOP_SEL 		<= '1';
				 REG_ADD_L_EN 		<= '0';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '1'; 
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '0';
				 MUX_WB_SEL 	    <= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;
				 
				 NEXT_STATE <= BIG_2_start;
				 COUNTER_1_NEXT <= COUNTER_1; -- 0 in previous state
				 COUNTER_2_NEXT <= COUNTER_2; --keep previuos value
				 COUNTER_3_NEXT <= COUNTER_3; --keep previuos value
				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG; --keep previuos value

				 SEL_60_63 		  <= '0';
				 COMB_EN 		  <= '0'; 
				 COMB_RST 		  <= '0';
				 B2_SOP_TRANSFORM <= '0';
				 B2_PHASE 		  <= '0';
				 switch_windows_2 	<= '0';
    			 WB_RESULT_ADDR_2 <= (others => '0');
				 WB_WE_2 		  <= '0';
				 
						
			
			when BIG_2_FINAL_WB_continue1 => 
								   -- sum registers have the right values and need to be disabled
									-- prepare mux
									-- prepare WB addr
									-- prepare WE
									-- prepare carry accumulation
									-- REG_62_CB has values from before 
										--all happening in the next clock cycle, ripetere ciclo WB_BIG_CYCLES

				 Done_rd_8 			<= '0';
				 rd_addr			<= (others => '0'); 
				 COUNTER_RD_NEXT 	<= (others => '0'); 
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0';
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0');
				 MUX_MUL1_IN1_SEL 	<= '0'; -- B_regs
				 MUX_MUL1_IN2_SEL 	<= '1'; --HIGH, always, fixed in this case MUL1 is always processing the H
				 BRR_ADDR           <= (others => '0');
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '1'; --B_regs
				 --B_EN 				<= '0'; 
				 --B_RST 				<= '0';
				 MAIN_ROM_ADDR 		<=  std_logic_vector(unsigned(N_qj_list_OFFSET) + unsigned(COUNTER_1));
				 AUX2_ROM_ADDR 		<= 	std_logic_vector(unsigned(N_qj_list_OFFSET) + unsigned(COUNTER_1));
				 AUX_ROM_ADDR 		<=  std_logic_vector(unsigned(N_qj_list_OFFSET) + unsigned(COUNTER_1));
				 ONLY_MUL_CU 		<= '1'; 
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0';
				 S2_RS_RST 			<= '0';
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '0';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '0'; 
				 REG_62_CB_EN 		<= '1';
				 REG_62_CB_RST 		<= '0';
				 MUX_WB_SEL 		<= std_logic_vector(unsigned(MUX_WB_SEL_BIG_OFFSET) + unsigned(COUNTER_1(2 downto 0))); 
				 
				 WB_RESULT_ADDR 	<= std_logic_vector(unsigned(COUNTER_1(1 downto 0)) + to_unsigned(1,2)); -- offset finalWB std_logic_vector(to_unsigned(1,2)); 
				 WB_WE  			<= '1';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;
				 
				 COUNTER_3_NEXT <= COUNTER_3; --keep previuos value

				 if (COUNTER_1 = std_logic_vector(unsigned(WB_BIG_CYCLES)-to_unsigned(1,6))) then -- WB is finished
				 	NEXT_STATE <= BIG_2_FINAL_WB_end;
					COUNTER_1_NEXT <= (others => '0'); -- RESET
				 	COUNTER_2_NEXT <= (others => '0'); -- RESET
				 	SECOND_PART_FLAG_NEXT <=  '0'; -- RESET (not really necessary)

				 else 
					 NEXT_STATE <= BIG_2_FINAL_WB_continue1;
				 	 COUNTER_1_NEXT <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,6)); -- increment 
					 COUNTER_2_NEXT <= COUNTER_2; --keep previuos value
				 	 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG; --keep previuos value
				 end if;

				 SEL_60_63 		  <= '0';
				 COMB_EN 		  <= '0'; 
				 COMB_RST 		  <= '0';
				 B2_SOP_TRANSFORM <= '0';
				 B2_PHASE 		  <= '0';
				 switch_windows_2 	<= '0';
    			 WB_RESULT_ADDR_2 <= (others => '0');
				 WB_WE_2 		  <= '0';
				 
		
			when BIG_2_FINAL_WB_end =>

				 Done_rd_8 			<= '0';
				 rd_addr			<= (others => '0'); 
				 COUNTER_RD_NEXT 	<= (others => '0'); 
				 SOP_done 			<= '1';
				 SOP_done2 			<= '0';
				 switch_windows 	<= '1';

				 BCONST_QI_ADDR 	<= (others => '0');
				 MUX_MUL1_IN1_SEL 	<= '0';
				 MUX_MUL1_IN2_SEL 	<= '0';
				 BRR_ADDR           <= (others => '0');
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '0';
				 --B_EN 				<= '0';
				 --B_RST 				<= '1';
				 MAIN_ROM_ADDR 		<= (others => '0');
				 AUX2_ROM_ADDR 		<= (others => '0');
				 AUX_ROM_ADDR 		<= (others => '0');
				 ONLY_MUL_CU 		<= '0';
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0';
				 S2_RS_RST 			<= '1';
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '0';
 				 REG_ADD_L_RST 		<= '1';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '1';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '1';
				 MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');

				 COUNTER_1_NEXT <= (others => '0');
				 COUNTER_2_NEXT <= (others => '0');
				 COUNTER_3_NEXT <= (others => '0');

				 if (COUNTER_8COEFF = "111") then
				 	COUNTER_8COEFF_NEXT <= (others => '0');
					NEXT_STATE 	<= WAIT_FOR_data_valid;
				 else 
					COUNTER_8COEFF_NEXT <= std_logic_vector(unsigned(COUNTER_8COEFF)+to_unsigned(1,3));
					NEXT_STATE 	<= WAIT_FOR_go_BIG;
				 end if;

				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0';
				 COMB_EN 		  <= '0'; 
				 COMB_RST 		  <= '0';
				 B2_SOP_TRANSFORM <= '0';
				 B2_PHASE 		  <= '0';
				 switch_windows_2 	<= '0';
    			 WB_RESULT_ADDR_2 <= (others => '0');
				 WB_WE_2 		  <= '0';
				 
			
			when WAIT_FOR_go_BIG =>

				 Done_rd_8 			<= '0';
				 rd_addr			<= (others => '0');
				 COUNTER_RD_NEXT 	<= (others => '0');
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0';
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0');
				 MUX_MUL1_IN1_SEL 	<= '0';
				 MUX_MUL1_IN2_SEL 	<= '0';
				 BRR_ADDR           <= (others => '0');
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '0';
				 MAIN_ROM_ADDR 		<= (others => '0');
				 AUX2_ROM_ADDR 		<= (others => '0');
				 AUX_ROM_ADDR 		<= (others => '0');
				 ONLY_MUL_CU 		<= '0';
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0';
				 S2_RS_RST 			<= '0';
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '0';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '0';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '0';
				 MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;
				 COUNTER_1_NEXT <= (others => '0');
				 COUNTER_2_NEXT <= (others => '0');
				 COUNTER_3_NEXT <= (others => '0');
				
				 if (go_signal = '0') then
					NEXT_STATE <= WAIT_FOR_go_BIG;
				 else
					NEXT_STATE <= BIG_start_L_setup;
				 end if;

				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0';
				 COMB_EN 		  <= '0'; 
				 COMB_RST 		  <= '0';
				 B2_SOP_TRANSFORM <= '0';
				 B2_PHASE 		  <= '0';
				 switch_windows_2 	<= '0';
    			 WB_RESULT_ADDR_2 <= (others => '0');
				 WB_WE_2 		  <= '0';
				 
				
--SMALL SOP HERE:
		when SMALL_start_setup => --
								-- 
								-- 

				 Done_rd_8 			<= '0';
				 rd_addr			<= COUNTER_RD;  -- READ ADDRESS BECOMES VALID IN THIS CLOCK CYCLE, DATA IS VALID NEXT CLOCK CYCLE
				 COUNTER_RD_NEXT 	<= std_logic_vector(unsigned(COUNTER_RD) + to_unsigned(1,5));
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0'; --new
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0'); 
				 MUX_MUL1_IN1_SEL 	<= '1'; 
				 MUX_MUL1_IN2_SEL 	<= '1'; -- always 30H
				 BRR_ADDR           <= (others => '0');
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '0';
				 MAIN_ROM_ADDR 		<=  std_logic_vector(unsigned(COUNTER_1));
				 AUX2_ROM_ADDR 		<=  std_logic_vector(unsigned(COUNTER_1));
				 AUX_ROM_ADDR 		<=  std_logic_vector(unsigned(COUNTER_1));
				 ONLY_MUL_CU 		<= '1';
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0'; --new
				 S2_RS_RST 			<= '0'; --new
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '0';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '0';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '0';
				 MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;
				 COUNTER_1_NEXT <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,6)); -- +1
				 COUNTER_2_NEXT <= (others => '0'); 
				 COUNTER_3_NEXT <= (others => '0'); 
				
				 if (COUNTER_1 = std_logic_vector(unsigned(MUL30_PIPE_DEPTH))) then -- 1+ address is valid for 1clk , +1 to make data valid, MUL30_PIPE_DEPTH-1 to have result valid, -1 to...
					NEXT_STATE <= SMALL_start_continue_comb;
				 else
					NEXT_STATE <= SMALL_start_setup;
				 end if;
				
				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0';-- irrelevant 
				 COMB_EN 		  <= '1'; --new
				 COMB_RST 		  <= '0';--new
				 B2_SOP_TRANSFORM <= '0'; --new
				 B2_PHASE 		  <= '0';--new
				 switch_windows_2 	<= '0';--new
    			 WB_RESULT_ADDR_2 <= (others => '0');--new
				 WB_WE_2 		  <= '0';--new
				 


		when SMALL_start_continue_comb => --mul pipes are filled, need to start accumulate and keep comb active
								-- 
								-- 

				 Done_rd_8 			<= '0';
				 rd_addr			<= COUNTER_RD;  -- READ ADDRESS BECOMES VALID IN THIS CLOCK CYCLE, DATA IS VALID NEXT CLOCK CYCLE
				 COUNTER_RD_NEXT 	<= std_logic_vector(unsigned(COUNTER_RD) + to_unsigned(1,5));
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0'; --new
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0'); 
				 MUX_MUL1_IN1_SEL 	<= '1';
				 MUX_MUL1_IN2_SEL 	<= '1'; -- always 30H
				 BRR_ADDR           <= (others => '0');
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '0';
				 MAIN_ROM_ADDR 		<=  std_logic_vector(unsigned(COUNTER_1));
				 AUX2_ROM_ADDR 		<=  std_logic_vector(unsigned(COUNTER_1));
				 AUX_ROM_ADDR 		<=  std_logic_vector(unsigned(COUNTER_1));
				 ONLY_MUL_CU 		<= '1';
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0'; --new
				 S2_RS_RST 			<= '0'; --new
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '1';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '1';
				 REG_ADD_H_RST 		<= '0';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '0';
				 MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;
				 COUNTER_1_NEXT <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,6)); -- +1
				 COUNTER_2_NEXT <= (others => '0'); 
				 COUNTER_3_NEXT <= (others => '0'); 
				
				 if (COUNTER_1 = std_logic_vector(unsigned(MUL30_PIPE_DEPTH) + to_unsigned(2,6))) then
					NEXT_STATE <= SMALL_start_continue_2;
				 else
					NEXT_STATE <= SMALL_start_continue_comb;
				 end if;
				
				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0';-- irrelevant 
				 COMB_EN 		  <= '1'; --new
				 COMB_RST 		  <= '0';--new
				 B2_SOP_TRANSFORM <= '0'; --new
				 B2_PHASE 		  <= '0';--new
				 switch_windows_2 	<= '0';--new
    			 WB_RESULT_ADDR_2 <= (others => '0');--new
				 WB_WE_2 		  <= '0';--new
				 

		when SMALL_start_continue_2 => --mul pipes are filled, need to finish accumulate and DEACTIVATE COMB
								-- 
								-- 

				 Done_rd_8 			<= '0';
				 rd_addr			<= COUNTER_RD;  -- READ ADDRESS BECOMES VALID IN THIS CLOCK CYCLE, DATA IS VALID NEXT CLOCK CYCLE
				 COUNTER_RD_NEXT 	<= std_logic_vector(unsigned(COUNTER_RD) + to_unsigned(1,5));
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0'; --new
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0'); 
				 MUX_MUL1_IN1_SEL 	<= '1'; 
				 MUX_MUL1_IN2_SEL 	<= '1'; -- always 30H
				 BRR_ADDR           <= (others => '0');
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '0';
				 MAIN_ROM_ADDR 		<=  std_logic_vector(unsigned(COUNTER_1));
				 AUX2_ROM_ADDR 		<=  std_logic_vector(unsigned(COUNTER_1));
				 AUX_ROM_ADDR 		<=  std_logic_vector(unsigned(COUNTER_1));
				 ONLY_MUL_CU 		<= '1';
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0'; --new
				 S2_RS_RST 			<= '0'; --new
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '1';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '1';
				 REG_ADD_H_RST 		<= '0';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '0';
				 MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;
				 
				 COUNTER_2_NEXT <= (others => '0'); 
				 COUNTER_3_NEXT <= (others => '0'); 
				
				 if (COUNTER_1 = std_logic_vector(unsigned(MUL30_PIPE_DEPTH) + to_unsigned(2,6) + to_unsigned(6,6))) then
					NEXT_STATE <= SMALL_start_WB;
					COUNTER_1_NEXT <= (others => '0'); 
				 else
					NEXT_STATE <= SMALL_start_continue_2;
					COUNTER_1_NEXT <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,6)); -- +1
				 end if;
				
				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0';-- irrelevant 
				 COMB_EN 		  <= '0'; --new
				 COMB_RST 		  <= '0';--new
				 B2_SOP_TRANSFORM <= '0'; --new
				 B2_PHASE 		  <= '0';--new
				 switch_windows_2 	<= '0';--new
    			 WB_RESULT_ADDR_2 <= (others => '0');--new
				 WB_WE_2 		  <= '0';--new
				 


		when SMALL_start_WB => -- accumulation is done! need to WB, 2 times, 0 and 1 from mux WB
								-- sum registers have the right values and need to be disabled
									-- prepare mux
									-- prepare WB addr
									-- prepare WE
										--all happening in the next clock cycle, ripetere ciclo WB_CYCLES=2

				 Done_rd_8 			<= '0';
				 rd_addr			<= (others => '0'); 
				 COUNTER_RD_NEXT 	<= (others => '0'); 
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0'; --new
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0'); 
				 MUX_MUL1_IN1_SEL 	<= '1'; 
				 MUX_MUL1_IN2_SEL 	<= '1'; -- always 30H
				 BRR_ADDR           <= (others => '0');
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '0';
				 MAIN_ROM_ADDR 		<=  std_logic_vector(unsigned(COUNTER_1));
				 AUX2_ROM_ADDR 		<=  std_logic_vector(unsigned(COUNTER_1));
				 AUX_ROM_ADDR 		<=  std_logic_vector(unsigned(COUNTER_1));
				 ONLY_MUL_CU 		<= '1';
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0'; --new
				 S2_RS_RST 			<= '0'; --new
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '0';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '0';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '0';
				 
				 MUX_WB_SEL 		<= std_logic_vector(unsigned(COUNTER_1(2 downto 0))); 
				 WB_RESULT_ADDR 	<= std_logic_vector(unsigned(COUNTER_1(1 downto 0))); 
				 WB_WE  			<= '1';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;
				 
				 COUNTER_2_NEXT <= (others => '0'); 
				 COUNTER_3_NEXT <= (others => '0'); 
				
				 if (COUNTER_1 = std_logic_vector(to_unsigned(1,6))) then
					NEXT_STATE <= SMALL_start_WB_END;
					COUNTER_1_NEXT <= (others => '0'); 
				 else
					NEXT_STATE <= SMALL_start_WB;
					COUNTER_1_NEXT <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,6)); -- +1
				 end if;
				
				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0';-- irrelevant 
				 COMB_EN 		  <= '0'; --new
				 COMB_RST 		  <= '0';--new
				 B2_SOP_TRANSFORM <= '0'; --new
				 B2_PHASE 		  <= '0';--new
				 switch_windows_2 	<= '0';--new
    			 WB_RESULT_ADDR_2 <= (others => '0');--new
				 WB_WE_2 		  <= '0';--new
				 


		when SMALL_start_WB_END => -- accumulation is done! need to WB, 2 times, 0 and 1 from mux WB
									-- use to prepare B2_phase0

				 Done_rd_8 			<= '0';
				 rd_addr			<= (others => '0'); 
				 COUNTER_RD_NEXT 	<= (others => '0'); 
				 SOP_done 			<= '1';
				 SOP_done2 			<= '0'; --new
				 switch_windows 	<= '1';

				 BCONST_QI_ADDR 	<= (others => '0'); 
				 MUX_MUL1_IN1_SEL 	<= '0'; 
				 MUX_MUL1_IN2_SEL 	<= '1'; -- always 30H
				 BRR_ADDR           <= (others => '0');
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '0';
				 MAIN_ROM_ADDR 		<=  (others => '0');
				 AUX2_ROM_ADDR 		<=  (others => '0');
				 AUX_ROM_ADDR 		<=  (others => '0');
				 ONLY_MUL_CU 		<= '1';
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0'; --new
				 S2_RS_RST 			<= '1'; --new
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '0';
 				 REG_ADD_L_RST 		<= '0';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '0';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '0';
				 MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF; 
				 COUNTER_1_NEXT <= (others => '0'); 
				 COUNTER_2_NEXT <= (others => '0'); 
				 COUNTER_3_NEXT <= (others => '0'); 
				
				 NEXT_STATE <= SMALL_B2_P0_start;
	
				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0';-- irrelevant 
				 COMB_EN 		  <= '0'; --new
				 COMB_RST 		  <= '0';--new
				 B2_SOP_TRANSFORM <= '0'; --new
				 B2_PHASE 		  <= '0';--new
				 switch_windows_2 	<= '0';--new
    			 WB_RESULT_ADDR_2 <= (others => '0');--new
				 WB_WE_2 		  <= '0';--new
				 


		
		when SMALL_B2_P0_start => -- start computing B2
									-- take mul in 1 from the comb and in 2 from the memories as always


				 Done_rd_8 			<= '0';
				 rd_addr			<= COUNTER_RD;  -- READ ADDRESS BECOMES VALID IN THIS CLOCK CYCLE, DATA IS VALID NEXT CLOCK CYCLE
				 COUNTER_RD_NEXT 	<= std_logic_vector(unsigned(COUNTER_RD) + to_unsigned(1,5));
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0'; --new
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0'); 
				 MUX_MUL1_IN1_SEL 	<= '0'; --irrelevant
				 MUX_MUL1_IN2_SEL 	<= '1'; -- always 30H
				 BRR_ADDR           <= (others => '0'); --irrelevant
				 BRR_WE				<= '0'; --irrelevant
				 MUX_MANY_MUL_SEL 	<= '0'; --irrelevant
				 MAIN_ROM_ADDR 		<=  std_logic_vector(unsigned(MAIN_ROM_Biqj_OFFSET) + unsigned(COUNTER_1));
				 AUX2_ROM_ADDR 		<=  std_logic_vector(unsigned(AUX_ROM_Biqj_OFFSET) + unsigned(COUNTER_1));
				 AUX_ROM_ADDR 		<=  std_logic_vector(unsigned(AUX_ROM_Biqj_OFFSET) + unsigned(COUNTER_1));
				 ONLY_MUL_CU 		<= '1';
				 MUX_SB_TOP_SEL 	<= '0'; --forgotten forever
				 S2_RS_EN 			<= '1'; --new
				 S2_RS_RST 			<= '0'; --new
				 MUX_SOP_SEL 		<= '0'; -- 0 always
				 REG_ADD_L_EN 		<= '0'; -- 0 always
 				 REG_ADD_L_RST 		<= '1'; -- 0 always
 				 REG_ADD_H_EN 		<= '0'; -- 0 always
				 REG_ADD_H_RST 		<= '1'; -- 0 always
				 REG_62_CB_EN 		<= '0'; -- 0 always
				 REG_62_CB_RST 		<= '0'; -- 0 always
				 
				MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0'); -- 0 always
				 WB_WE  			<= '0'; -- 0 always

				 COUNT_MAX		<= (others => '0'); -- 0 always
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;
	
				 COUNTER_2_NEXT <= (others => '0');
				 COUNTER_3_NEXT <= (others => '0'); 


				 --Addresses: 0,1,2,3,4,5,6
				 COUNTER_1_NEXT <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,6)); -- +1
				
				 --Pipeline control: when full activate new phase 0:  WB every cycle and continue
				 if (COUNTER_1 = std_logic_vector(unsigned(MUL_PLUS_S2_DEPTH))) then -- address is vali, +1 to make data valid, depth-1 to have result valid, -1 because you need to chage the next state one clock earlier (current state will be sampled at the end of the clock cycle and then the new state will already come.
--cioe' 6
					NEXT_STATE <= SMALL_B2_P0_continue_and_wb;
				 else
					NEXT_STATE <= SMALL_B2_P0_start;

				 end if;
				
				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0';-- irrelevant 
				 COMB_EN 		  <= '0'; --new
				 COMB_RST 		  <= '0';--new
				 B2_SOP_TRANSFORM <= '1'; --new
				 B2_PHASE 		  <= '0';--new
				 switch_windows_2 	<= '0';--new
    			 WB_RESULT_ADDR_2 <= (others => '0');--new
				 WB_WE_2 		  <= '0';--new
				 


		when SMALL_B2_P0_continue_and_wb => -- start computing B2
									-- take mul in 1 from the comb and in 2 from the memories as always

				 Done_rd_8 			<= '0';
				 rd_addr			<= COUNTER_RD;  -- READ ADDRESS BECOMES VALID IN THIS CLOCK CYCLE, DATA IS VALID NEXT CLOCK CYCLE
				 COUNTER_RD_NEXT 	<= std_logic_vector(unsigned(COUNTER_RD) + to_unsigned(1,5));
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0'; --new
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0'); 
				 MUX_MUL1_IN1_SEL 	<= '0'; --irrelevant
				 MUX_MUL1_IN2_SEL 	<= '1'; -- always 30H
				 BRR_ADDR           <= (others => '0'); --irrelevant
				 BRR_WE				<= '0'; --irrelevant
				 MUX_MANY_MUL_SEL 	<= '0'; --irrelevant
				 MAIN_ROM_ADDR 		<=  (others => '0'); 
				 AUX2_ROM_ADDR 		<=  (others => '0'); 
				 AUX_ROM_ADDR 		<=  (others => '0'); 
				 ONLY_MUL_CU 		<= '1';
				 MUX_SB_TOP_SEL 	<= '0'; --forgotten forever
				 S2_RS_EN 			<= '1'; --new
				 S2_RS_RST 			<= '0'; --new
				 MUX_SOP_SEL 		<= '0'; -- 0 always
				 REG_ADD_L_EN 		<= '0'; -- 0 always
 				 REG_ADD_L_RST 		<= '0'; -- 0 always
 				 REG_ADD_H_EN 		<= '0'; -- 0 always
				 REG_ADD_H_RST 		<= '0'; -- 0 always
				 REG_62_CB_EN 		<= '0'; -- 0 always
				 REG_62_CB_RST 		<= '0'; -- 0 always
				 
				 MUX_WB_SEL 		<= (others => '0');
				 WB_RESULT_ADDR 	<= (others => '0'); -- 0 always
				 WB_WE  			<= '0'; -- 0 always

				 COUNT_MAX		<= (others => '0'); -- 0 always
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;

				 COUNTER_1_NEXT <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,6)); -- +1
				 COUNTER_2_NEXT <=  (others => '0'); 
				 COUNTER_3_NEXT <= std_logic_vector(unsigned(COUNTER_3) + to_unsigned(1,6)); -- +1
				 
				 
				 --Pipeline control: when full activate new phase 0:  WB every cycle and continue
				 if (COUNTER_1 = std_logic_vector(unsigned(MUL_PLUS_S2_DEPTH) + to_unsigned(7,6))) then 

					NEXT_STATE <= SMALL_B2_P0_continue_and_wb_END;
				 else
					NEXT_STATE <= SMALL_B2_P0_continue_and_wb;

				 end if;
				
				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0';-- irrelevant 
				 COMB_EN 		  <= '0'; --new
				 COMB_RST 		  <= '0';--new
				 B2_SOP_TRANSFORM <= '1'; --new
				 B2_PHASE 		  <= '0';--new
				 switch_windows_2 	<= '0';--new
    			 WB_RESULT_ADDR_2 <= COUNTER_3(2 downto 0);--new
				 WB_WE_2 		  <= '1';--new
				 


			when SMALL_B2_P0_continue_and_wb_END => -- start computing B2
									-- take mul in 1 from the comb and in 2 from the memories as always

				 Done_rd_8 			<= '0';
				 rd_addr			<= (others => '0'); 
				 COUNTER_RD_NEXT 	<= (others => '0'); 
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0'; --new
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0'); 
				 MUX_MUL1_IN1_SEL 	<= '0'; --irrelevant
				 MUX_MUL1_IN2_SEL 	<= '0'; --irrelevant
				 BRR_ADDR           <= (others => '0'); 
				 BRR_WE				<= '0'; 
				 MUX_MANY_MUL_SEL 	<= '0'; --irrelevant
				 MAIN_ROM_ADDR 		<=  (others => '0');  --irrelevant
				 AUX2_ROM_ADDR 		<=  (others => '0');  --irrelevant
				 AUX_ROM_ADDR 		<=  (others => '0');  --irrelevant
				 ONLY_MUL_CU 		<= '0'; -- 0, we need to use barret reduction
				 MUX_SB_TOP_SEL 	<= '0'; --forgotten forever
				 S2_RS_EN 			<= '0'; --new
				 S2_RS_RST 			<= '0'; --new
				 MUX_SOP_SEL 		<= '0'; -- 0 always
				 REG_ADD_L_EN 		<= '0'; -- 0 always
 				 REG_ADD_L_RST 		<= '0'; -- 0 always
 				 REG_ADD_H_EN 		<= '0'; -- 0 always
				 REG_ADD_H_RST 		<= '0'; -- 0 always
				 REG_62_CB_EN 		<= '0'; -- 0 always
				 REG_62_CB_RST 		<= '0'; -- 0 always
				 
				 MUX_WB_SEL 		<= (others => '0');
				 WB_RESULT_ADDR 	<= (others => '0'); -- 0 always
				 WB_WE  			<= '0'; -- 0 always

				 COUNT_MAX		<= (others => '0'); -- 0 always
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;

				 COUNTER_1_NEXT <= (others => '0'); 
				 COUNTER_2_NEXT <= (others => '0'); 
				 COUNTER_3_NEXT <= (others => '0');  
	
				 NEXT_STATE <= SMALL_B2_P1_start;
				
				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0'; --new
				 COMB_EN 		  <= '0'; --new
				 COMB_RST 		  <= '0';--new
				 B2_SOP_TRANSFORM <= '0'; ---- irrelevant 
				 B2_PHASE 		  <= '0';--new
				 switch_windows_2 	<= '0';--new
    			 WB_RESULT_ADDR_2 <= COUNTER_3(2 downto 0);--new
				 WB_WE_2 		  <= '0';--new
				 

		when SMALL_B2_P1_start => -- start computing B2 _ P1
									--need to read memory using WB_RESULT_ADDR_2 and feed to BARRET RED circuit

				 Done_rd_8 			<= '0';
				 rd_addr			<= (others => '0'); 
				 COUNTER_RD_NEXT 	<= (others => '0'); 
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0'; --new
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= conv_temp(4 downto 0); 
				 MUX_MUL1_IN1_SEL 	<= '0'; --irrelevant
				 MUX_MUL1_IN2_SEL 	<= '0'; --irrelevant

				 BRR_ADDR           <= (others => '0');  --irrelevant
				 BRR_WE				<= '0'; 
				 MUX_MANY_MUL_SEL 	<= '0'; --irrelevant
				 MAIN_ROM_ADDR 		<=  (others => '0');  --irrelevant
				 AUX2_ROM_ADDR 		<=  (others => '0');  --irrelevant
				 AUX_ROM_ADDR 		<=  (others => '0');  --irrelevant
				 ONLY_MUL_CU 		<= '0'; -- 0, we need to use barret reduction
				 MUX_SB_TOP_SEL 	<= '0'; --forgotten forever
				 S2_RS_EN 			<= '0'; --new
				 S2_RS_RST 			<= '0'; --new
				 MUX_SOP_SEL 		<= '0'; -- 0 always
				 REG_ADD_L_EN 		<= '0'; -- 0 always
 				 REG_ADD_L_RST 		<= '0'; -- 0 always
 				 REG_ADD_H_EN 		<= '0'; -- 0 always
				 REG_ADD_H_RST 		<= '0'; -- 0 always
				 REG_62_CB_EN 		<= '0'; -- 0 always
				 REG_62_CB_RST 		<= '0'; -- 0 always
				 
				 MUX_WB_SEL 		<= (others => '0');
				 WB_RESULT_ADDR 	<= (others => '0'); -- 0 always
				 WB_WE  			<= '0'; -- 0 always

				 COUNT_MAX		<= (others => '0'); -- 0 always
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;

				 COUNTER_1_NEXT <= (others => '0'); 
				 COUNTER_2_NEXT <= std_logic_vector(unsigned(COUNTER_2) + to_unsigned(1,6)); -- +1 

				 if (COUNTER_3 = std_logic_vector(to_unsigned(9,6)))  then  -- 7 + 2delay
					COUNTER_3_NEXT <= (others => '0');
					NEXT_STATE <= SMALL_B2_P1_WB_final;
				 else
				 	COUNTER_3_NEXT <= std_logic_vector(unsigned(COUNTER_3) + to_unsigned(1,6)); -- +1
					NEXT_STATE <= SMALL_B2_P1_start;
				 end if;
				
				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '1'; --new
				 COMB_EN 		  <= '0'; --new
				 COMB_RST 		  <= '0';--new
				 B2_SOP_TRANSFORM <= '0'; ---- irrelevant 
				 B2_PHASE 		  <= '1';--new important for wb only actuallyu
				 switch_windows_2 	<= '0';--new
    			 WB_RESULT_ADDR_2 <= COUNTER_3(2 downto 0);--new
				 WB_WE_2 		  <= '0';--new
				 

			when SMALL_B2_P1_WB_final => -- start computing B2 _ P1
									--need to read memory using WB_RESULT_ADDR_2 and feed to BARRET RED circuit

				 Done_rd_8 			<= '0';
				 rd_addr			<= (others => '0'); 
				 COUNTER_RD_NEXT 	<= (others => '0'); 
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0'; --new
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= conv_temp(4 downto 0);
				 MUX_MUL1_IN1_SEL 	<= '0'; --irrelevant
				 MUX_MUL1_IN2_SEL 	<= '0'; --irrelevant

				 BRR_ADDR           <= (others => '0'); 
				 BRR_WE				<= '0'; 
				 MUX_MANY_MUL_SEL 	<= '0'; --irrelevant
				 MAIN_ROM_ADDR 		<=  (others => '0');  --irrelevant
				 AUX2_ROM_ADDR 		<=  (others => '0');  --irrelevant
				 AUX_ROM_ADDR 		<=  (others => '0');  --irrelevant
				 ONLY_MUL_CU 		<= '0'; -- 0, we need to use barret reduction
				 MUX_SB_TOP_SEL 	<= '0'; --forgotten forever
				 S2_RS_EN 			<= '0'; --new
				 S2_RS_RST 			<= '0'; --new
				 MUX_SOP_SEL 		<= '0'; -- 0 always
				 REG_ADD_L_EN 		<= '0'; -- 0 always
 				 REG_ADD_L_RST 		<= '0'; -- 0 always
 				 REG_ADD_H_EN 		<= '0'; -- 0 always
				 REG_ADD_H_RST 		<= '0'; -- 0 always
				 REG_62_CB_EN 		<= '0'; -- 0 always
				 REG_62_CB_RST 		<= '0'; -- 0 always
				 
				 MUX_WB_SEL 		<= (others => '0');
				 WB_RESULT_ADDR 	<= (others => '0'); -- 0 always
				 WB_WE  			<= '0'; -- 0 always

				 COUNT_MAX		<= (others => '0'); -- 0 always
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;

				 COUNTER_1_NEXT <= (others => '0'); 
				 COUNTER_2_NEXT <= std_logic_vector(unsigned(COUNTER_2) + to_unsigned(1,6)); -- +1 

				 if (COUNTER_3 = std_logic_vector(to_unsigned(6,6)))  then  -- 6
					COUNTER_3_NEXT <= (others => '0');
					NEXT_STATE <= SMALL_B2_P1_WB_final_END;
				 else
				 	COUNTER_3_NEXT <= std_logic_vector(unsigned(COUNTER_3) + to_unsigned(1,6)); -- +1
					NEXT_STATE <= SMALL_B2_P1_WB_final;
				 end if;
				
				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '1'; --new
				 COMB_EN 		  <= '0'; --new
				 COMB_RST 		  <= '0';--new
				 B2_SOP_TRANSFORM <= '0'; ---- irrelevant 
				 B2_PHASE 		  <= '1';--new important for wb only actuallyu
				 switch_windows_2 	<= '0';--new
    			 WB_RESULT_ADDR_2 <= COUNTER_3(2 downto 0);--new
				 WB_WE_2 		  <= '1';--new
				 

		when SMALL_B2_P1_WB_final_END => 
									
				 Done_rd_8 			<= '0';
				 rd_addr			<= (others => '0'); 
				 COUNTER_RD_NEXT 	<= (others => '0'); 
				 SOP_done 			<= '0';
				 SOP_done2 			<= '1'; --new
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0'); 
				 MUX_MUL1_IN1_SEL 	<= '0'; --irrelevant
				 MUX_MUL1_IN2_SEL 	<= '0'; --irrelevant
				 BRR_ADDR           <= (others => '0'); 
				 BRR_WE				<= '0'; 
				 MUX_MANY_MUL_SEL 	<= '0'; --irrelevant
				 MAIN_ROM_ADDR 		<=  (others => '0');  --irrelevant
				 AUX2_ROM_ADDR 		<=  (others => '0');  --irrelevant
				 AUX_ROM_ADDR 		<=  (others => '0');  --irrelevant
				 ONLY_MUL_CU 		<= '0'; -- 0, we need to use barret reduction
				 MUX_SB_TOP_SEL 	<= '0'; --forgotten forever
				 S2_RS_EN 			<= '0'; --new
				 S2_RS_RST 			<= '0'; --new
				 MUX_SOP_SEL 		<= '0'; -- 0 always
				 REG_ADD_L_EN 		<= '0'; -- 0 always
 				 REG_ADD_L_RST 		<= '0'; -- 0 always
 				 REG_ADD_H_EN 		<= '0'; -- 0 always
				 REG_ADD_H_RST 		<= '0'; -- 0 always
				 REG_62_CB_EN 		<= '0'; -- 0 always
				 REG_62_CB_RST 		<= '0'; -- 0 always
				 
				 MUX_WB_SEL 		<= (others => '0');
				 WB_RESULT_ADDR 	<= (others => '0'); -- 0 always
				 WB_WE  			<= '0'; -- 0 always

				 COUNT_MAX		<= (others => '0'); -- 0 always
				 
				 if (COUNTER_8COEFF = "111") then
				 	COUNTER_8COEFF_NEXT <= (others => '0');
					NEXT_STATE 	<= WAIT_FOR_data_valid;
				 else 
					COUNTER_8COEFF_NEXT <= std_logic_vector(unsigned(COUNTER_8COEFF)+to_unsigned(1,3));
					NEXT_STATE 	<= WAIT_FOR_go_SMALL;
				 end if;

				 COUNTER_1_NEXT <= (others => '0'); 
				 COUNTER_2_NEXT <= (others => '0');
				 COUNTER_3_NEXT <= (others => '0');
				
				
				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0'; --new
				 COMB_EN 		  <= '0'; --new
				 COMB_RST 		  <= '0';--new
				 B2_SOP_TRANSFORM <= '0'; ---- irrelevant 
				 B2_PHASE 		  <= '0';--new important for wb only actuallyu
				 switch_windows_2 <= '1';--new
    			 WB_RESULT_ADDR_2 <= (others => '0');--new
				 WB_WE_2 		  <= '0';--new
				 


		when WAIT_FOR_go_SMALL => 
									
				 Done_rd_8 			<= '0';
				 rd_addr			<= (others => '0'); 
				 COUNTER_RD_NEXT 	<= (others => '0'); 
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0'; --new
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0'); 
				 MUX_MUL1_IN1_SEL 	<= '0'; --irrelevant
				 MUX_MUL1_IN2_SEL 	<= '0'; --irrelevant
				 BRR_ADDR           <= (others => '0'); 
				 BRR_WE				<= '0'; 
				 MUX_MANY_MUL_SEL 	<= '0'; --irrelevant
				 MAIN_ROM_ADDR 		<=  (others => '0');  --irrelevant
				 AUX2_ROM_ADDR 		<=  (others => '0');  --irrelevant
				 AUX_ROM_ADDR 		<=  (others => '0');  --irrelevant
				 ONLY_MUL_CU 		<= '0'; -- 0, we need to use barret reduction
				 MUX_SB_TOP_SEL 	<= '0'; --forgotten forever
				 S2_RS_EN 			<= '0'; --new
				 S2_RS_RST 			<= '0'; --new
				 MUX_SOP_SEL 		<= '0'; -- 0 always
				 REG_ADD_L_EN 		<= '0'; -- 0 always
 				 REG_ADD_L_RST 		<= '0'; -- 0 always
 				 REG_ADD_H_EN 		<= '0'; -- 0 always
				 REG_ADD_H_RST 		<= '0'; -- 0 always
				 REG_62_CB_EN 		<= '0'; -- 0 always
				 REG_62_CB_RST 		<= '0'; -- 0 always
				 
				 MUX_WB_SEL 		<= (others => '0');
				 WB_RESULT_ADDR 	<= (others => '0'); -- 0 always
				 WB_WE  			<= '0'; -- 0 always

				 COUNT_MAX		<= (others => '0'); -- 0 always
				 COUNTER_8COEFF_NEXT <= COUNTER_8COEFF;

				 COUNTER_1_NEXT <= (others => '0'); 
				 COUNTER_2_NEXT <= (others => '0');
				 COUNTER_3_NEXT <= (others => '0');
				
				 if (go_signal = '0') then
					NEXT_STATE <= WAIT_FOR_go_SMALL;
				 else
					NEXT_STATE <= SMALL_start_setup;
				 end if;
				
				 SECOND_PART_FLAG_NEXT <= SECOND_PART_FLAG;

				 SEL_60_63 		  <= '0'; --new
				 COMB_EN 		  <= '0'; --new
				 COMB_RST 		  <= '0';--new
				 B2_SOP_TRANSFORM <= '0'; ---- irrelevant 
				 B2_PHASE 		  <= '0';--new important for wb only actuallyu
				 switch_windows_2 	<= '0';--new
    			 WB_RESULT_ADDR_2 <= (others => '0');--new
				 WB_WE_2 		  <= '1';--new
				 

		when others =>

				 Done_rd_8 			<= '0';
				 rd_addr			<= (others => '0');
				 COUNTER_RD_NEXT 	<= (others => '0');
				 SOP_done 			<= '0';
				 SOP_done2 			<= '0'; --new
				 switch_windows 	<= '0';

				 BCONST_QI_ADDR 	<= (others => '0');
				 MUX_MUL1_IN1_SEL 	<= '0';
				 MUX_MUL1_IN2_SEL 	<= '0';
				 BRR_ADDR           <= (others => '0');
				 BRR_WE				<= '0';
				 MUX_MANY_MUL_SEL 	<= '0';
				 MAIN_ROM_ADDR 		<= (others => '0');
				 AUX2_ROM_ADDR 		<= (others => '0');
				 AUX_ROM_ADDR 		<= (others => '0');
				 ONLY_MUL_CU 		<= '0';
				 MUX_SB_TOP_SEL 	<= '0';
				 S2_RS_EN 			<= '0';--new
				 S2_RS_RST 			<= '1';--new
				 MUX_SOP_SEL 		<= '0';
				 REG_ADD_L_EN 		<= '0';
 				 REG_ADD_L_RST 		<= '1';
 				 REG_ADD_H_EN 		<= '0';
				 REG_ADD_H_RST 		<= '1';
				 REG_62_CB_EN 		<= '0';
				 REG_62_CB_RST 		<= '1';
				 MUX_WB_SEL 		<= (others => '0');
				 
				 WB_RESULT_ADDR 	<= (others => '0');
				 WB_WE  			<= '0';

				 COUNT_MAX		<= (others => '0');
				 COUNTER_8COEFF_NEXT <= (others => '0');
				 COUNTER_1_NEXT <= (others => '0');
				 COUNTER_2_NEXT <= (others => '0');
				 COUNTER_3_NEXT <= (others => '0');
				 NEXT_STATE 	<= WAIT_FOR_data_valid;

				 SECOND_PART_FLAG_NEXT <= '0';

				 SEL_60_63 		  <= '0'; --new
				 COMB_EN 		  <= '0'; --new
				 COMB_RST 		  <= '1'; --new
				 B2_SOP_TRANSFORM <= '0'; --new
				 B2_PHASE 		  <= '0'; --new
				 switch_windows_2 	<= '0'; --new
    			 WB_RESULT_ADDR_2 <= (others => '0');--new
				 WB_WE_2 		  <= '0';--new
				 


		end case;

	end process P_NEXT_STATE;

END behavior_FSM;

--future: write a parser to transform FSM to FSM with CW ROM



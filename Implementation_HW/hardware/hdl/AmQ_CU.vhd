
-- Create Date:   16:44:05 10/02/2017
-- Design Name:   
-- Module Name:   /users/cosic/gcaliann/Desktop/Phase2/phase2/AmQ_CU.vhd
-- Project Name:  phase2

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY AmQ_CU IS
	PORT(
         clk : IN  std_logic;
			RST : IN  std_logic;
         DATA_VALID : IN  std_logic;
			RD_INPUT_ADDR : OUT  std_logic_vector(1 downto 0);
			DONE_mQ : OUT  std_logic;

         CARRY_SEL : OUT  std_logic;
         S_REG_RST : OUT  std_logic;
         S_REG_EN : OUT  std_logic;
         WB_PHASE : OUT  std_logic;
         WE_RAM : OUT  std_logic;
         WB_ADDR : OUT  std_logic_vector(1 downto 0);
			WR_VAR_OFFSET_out: OUT std_logic_vector (2 downto 0);
         MEM_CONFIG_out : OUT  std_logic;
         RAM_ADDR : OUT  std_logic_vector(1 downto 0);
         RD_VAR_OFFSET_out : OUT  std_logic_vector(2 downto 0);
         Qns_ADDR_FINAL : OUT  std_logic_vector(4 downto 0);
         FIN_RES_OFF_out : OUT  std_logic_vector(2 downto 0);
			C_OUT_DPq : IN std_logic;
			CENTRAL_LIFT_HAPPENED : OUT  std_logic; --to be sampled when done is risen.
			ADD_sub : OUT std_logic --ADD:1 sub:0
        );

END AmQ_CU;
 
ARCHITECTURE behavior OF AmQ_CU IS 

type TYPE_STATE is (RST_STATE, WAIT_FOR_data_valid, START_mQ_A, START_mQ_B, MOD_L_PR0, MOD_L_PR1, MOD_L_WB0, MOD_L_WB1, MOD_L_WB2, MOD_L_WB3, MOD_L_END_FAST); --fill with state names
	signal CURRENT_STATE : TYPE_STATE := RST_STATE;
	signal NEXT_STATE : TYPE_STATE;
	
signal COUNTER_1: std_logic_vector (1 downto 0) := (others => '0');
signal COUNTER_1_NEXT: std_logic_vector (1 downto 0) := (others => '0');

signal COUNTER_WB: std_logic_vector (1 downto 0) := (others => '0');
signal COUNTER_WB_NEXT: std_logic_vector (1 downto 0) := (others => '0');

signal COUNTER_2: std_logic_vector (4 downto 0) := (others => '0');
signal COUNTER_2_NEXT: std_logic_vector (4 downto 0) := (others => '0');

signal MEM_CONFIG_SWITCH :  std_logic := '0';
signal MEM_CONFIG : std_logic := '0';

signal WR_VAR_OFFSET: std_logic_vector (2 downto 0) := (others => '0');
signal RD_VAR_OFFSET: std_logic_vector (2 downto 0) := (others => '0');

signal SET_RD_WR_WINDOWS : std_logic_vector (1 downto 0) := (others => '0');
signal SW_RD_WR_WINDOWS : std_logic := '0';

signal SW_RD_WR_WINDOWS_sampled : std_logic := '0';

signal FIN_RES_OFF: std_logic_vector (2 downto 0) := (others => '0');
signal FIN_RES_OFF_NEXT: std_logic_vector (2 downto 0) := (others => '0');

signal ADDsub_reg : std_logic := '1';
signal ADD_sub_NEXT : std_logic := '1';

constant OFFSET_jcst: std_logic_vector (2 downto 0) := "100";

 
BEGIN
	WR_VAR_OFFSET_out <= WR_VAR_OFFSET;
	RD_VAR_OFFSET_out <= RD_VAR_OFFSET;
	FIN_RES_OFF_out <= FIN_RES_OFF;
	MEM_CONFIG_out <= MEM_CONFIG;
	CENTRAL_LIFT_HAPPENED <= SW_RD_WR_WINDOWS_sampled;
	ADD_sub <= ADDsub_reg;

	rd_wr_windowing_proc: process (CLK, RST)
	begin
		if RST = '1' then
			RD_VAR_OFFSET 	<= (others => '0');
			WR_VAR_OFFSET 	<= OFFSET_jcst;
		elsif (CLK = '1' and CLK'EVENT) then
			if SET_RD_WR_WINDOWS = "11" then
				RD_VAR_OFFSET 	<= (others => '0');
				WR_VAR_OFFSET 	<= (others => '0');
			elsif SET_RD_WR_WINDOWS = "01" then
				RD_VAR_OFFSET 	<= (others => '0');
				WR_VAR_OFFSET 	<= OFFSET_jcst;
			elsif SW_RD_WR_WINDOWS = '1' then
				RD_VAR_OFFSET 	<= WR_VAR_OFFSET;
				WR_VAR_OFFSET 	<= RD_VAR_OFFSET;
			else
				RD_VAR_OFFSET 	<= RD_VAR_OFFSET;
				WR_VAR_OFFSET 	<= WR_VAR_OFFSET;
			end if;
		end if;
	end process rd_wr_windowing_proc;
	
	--warning of the type:
	--F/Latch <RD_VAR_OFFSET_0> has a constant value of 0 in block <AmQ_CU>. This FF/Latch will be trimmed during the optimization process.
	--F/Latch <RD_VAR_OFFSET_1> has a constant value of 0 in block <AmQ_CU>. This FF/Latch will be trimmed during the optimization process.
	--NO PROBLEM!!! ACTUALLY IT IS RIGHT, ONLY RD_VAR_OFFSET_2 IS NOT ZERO!!!
	--NO PROBLEM!!! ACTUALLY IT IS RIGHT, ONLY RD_VAR_OFFSET_2 IS NOT ZERO!!!
	--NO PROBLEM!!! ACTUALLY IT IS RIGHT, ONLY RD_VAR_OFFSET_2 IS NOT ZERO!!!
	ftt_proc: process (CLK, RST)
	begin
		if RST = '1' then
			MEM_CONFIG <= '0';
		elsif (CLK = '1' and CLK'EVENT) then
 			if (MEM_CONFIG_SWITCH = '0') then
				MEM_CONFIG <= MEM_CONFIG;
			elsif (MEM_CONFIG_SWITCH = '1') then
				MEM_CONFIG <= not(MEM_CONFIG);
			end if;
		end if;
	end process ftt_proc;

	P_StateUpdate: process (CLK, RST) --CLOCKED PROCESS
	begin
		if RST = '1' then
			CURRENT_STATE <= RST_STATE;
		elsif (CLK = '1' and CLK'EVENT) then
			CURRENT_STATE <= NEXT_STATE;
		end if;
	end process P_StateUpdate;
	
	P_counters: process(CLK, RST)
	begin
		if RST = '1' then
			COUNTER_1  <= (others => '0');
			COUNTER_WB <= (others => '0');
			COUNTER_2  <= (others => '0');
		elsif (CLK = '1' and CLK'EVENT) then
			COUNTER_1  <= COUNTER_1_NEXT;
			COUNTER_WB <= COUNTER_WB_NEXT;
			COUNTER_2  <= COUNTER_2_NEXT;
		end if;
	end process P_counters;
	
	P_regs: process (CLK, RST) --CLOCKED PROCESS
	begin
		if RST = '1' then
			FIN_RES_OFF 	<= (others => '0');
			SW_RD_WR_WINDOWS_sampled <= '0';
			ADDsub_reg <= '1';
		elsif (CLK = '1' and CLK'EVENT) then
			FIN_RES_OFF 	<= FIN_RES_OFF_NEXT;
			SW_RD_WR_WINDOWS_sampled <= SW_RD_WR_WINDOWS;
			ADDsub_reg <= ADD_sub_NEXT;
		end if;
	end process P_regs;

 
 	P_NEXT_STATE : process(CURRENT_STATE, DATA_VALID, C_OUT_DPq,  COUNTER_1, COUNTER_WB, COUNTER_2, FIN_RES_OFF, RD_VAR_OFFSET, ADDsub_reg) --COMBINATIONAL PROCESS
	begin
		case CURRENT_STATE is 
			
			when RST_STATE =>
					 CARRY_SEL 	<= '0';
					 S_REG_RST 	<= '1';
					 S_REG_EN 	<= '0';
					 WB_PHASE 	<= '0';
					 WE_RAM 		<= '0';
					 WB_ADDR 	<= (others => '0');
					 MEM_CONFIG_SWITCH 	<= '0';
					 RAM_ADDR 	<= (others => '0');
					 SET_RD_WR_WINDOWS <= "11";
					 SW_RD_WR_WINDOWS <= '0';
					 Qns_ADDR_FINAL 	<= (others => '0');
					 FIN_RES_OFF_NEXT <= (others => '0');
					 
					 NEXT_STATE <= WAIT_FOR_data_valid;
					 
					 COUNTER_1_NEXT <= (others => '0');
					 COUNTER_WB_NEXT <= (others => '0');
					 COUNTER_2_NEXT <= (others => '0');
					 RD_INPUT_ADDR  <= (others => '0');
					 DONE_mQ <= '0';
					 ADD_sub_NEXT <= ADDsub_reg;
					 
					 
			when WAIT_FOR_data_valid =>
					CARRY_SEL 	<= '0';
					 S_REG_RST 	<= '1';
					 S_REG_EN 	<= '0';
					 WB_PHASE 	<= '0';
					 WE_RAM 		<= '0';
					 WB_ADDR 	<= (others => '0');
					 MEM_CONFIG_SWITCH <= '0';
					 RAM_ADDR 	<= (others => '0');
					 SET_RD_WR_WINDOWS <= "11";
					 SW_RD_WR_WINDOWS <= '0';
					 Qns_ADDR_FINAL <= (others => '0');
					 FIN_RES_OFF_NEXT <= FIN_RES_OFF;
					 
					 if (DATA_VALID = '0') then
						NEXT_STATE <= WAIT_FOR_data_valid;
					 else
						NEXT_STATE <= START_mQ_A;
					 end if;
					 
					 COUNTER_1_NEXT <= (others => '0');
					 COUNTER_WB_NEXT <= (others => '0');
					 COUNTER_2_NEXT <= (others => '0');
					 RD_INPUT_ADDR  <= (others => '0');
					 DONE_mQ <= '0';
					 ADD_sub_NEXT <= ADDsub_reg;
					 
					 
			when START_mQ_A =>
			--prepare read address
					 CARRY_SEL 	<= '0';
					 S_REG_RST 	<= '1';
					 S_REG_EN 	<= '0';
					 WB_PHASE 	<= '0';
					 WE_RAM 		<= '0';
					 WB_ADDR 	<= (others => '0');
					 MEM_CONFIG_SWITCH <= '0';
					 RAM_ADDR 	<= (others => '0');
					 SET_RD_WR_WINDOWS <= "00";
					 SW_RD_WR_WINDOWS <= '0';
					 Qns_ADDR_FINAL <= (others => '0');
					 FIN_RES_OFF_NEXT <= FIN_RES_OFF;
					 
					 NEXT_STATE <= START_mQ_B;
					 
					 COUNTER_1_NEXT <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,2));
					 COUNTER_WB_NEXT <= (others => '0');
					 COUNTER_2_NEXT <= (others => '0');
					 RD_INPUT_ADDR  <= COUNTER_1;
					 DONE_mQ <= '0';
					 ADD_sub_NEXT <= ADDsub_reg;
					 
					 
			when START_mQ_B =>
					 CARRY_SEL 	<= '0';
					 S_REG_RST 	<= '1';
					 S_REG_EN 	<= '0';
					 WB_PHASE 	<= '0';
					 WE_RAM 		<= '1';
					 WB_ADDR 	<= COUNTER_WB;
					 
					 SW_RD_WR_WINDOWS <= '0';
					 MEM_CONFIG_SWITCH <= '0';
					 RAM_ADDR 	<= (others => '0');
					 Qns_ADDR_FINAL 	<= (others => '0');
					 FIN_RES_OFF_NEXT <= FIN_RES_OFF;
					 
					 if (COUNTER_WB = std_logic_vector(to_unsigned(3,2))) then
						NEXT_STATE <= MOD_L_PR0;
						COUNTER_1_NEXT <= (others => '0');
						SET_RD_WR_WINDOWS <= "01";
					 else
						NEXT_STATE <= START_mQ_B;
						COUNTER_1_NEXT <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,2)); -- used for RD_INPUT_ADDR
						SET_RD_WR_WINDOWS <= "00";
					 end if;		
					 
					 COUNTER_WB_NEXT <= std_logic_vector(unsigned(COUNTER_WB) + to_unsigned(1,2));
					 COUNTER_2_NEXT <= (others => '0');
					 RD_INPUT_ADDR  <= COUNTER_1;
					 DONE_mQ <= '0';
					 ADD_sub_NEXT <= ADDsub_reg;
					 
			when MOD_L_PR0 =>
					 CARRY_SEL 	<= '0';
					 S_REG_RST 	<= '0';
					 S_REG_EN 	<= '0';
					 WB_PHASE 	<= '1';
					 WE_RAM 		<= '0';
					 WB_ADDR 	<= (others => '0');
					 SET_RD_WR_WINDOWS <= "00";
					 SW_RD_WR_WINDOWS <= '0';
					 MEM_CONFIG_SWITCH <= '0';
					 RAM_ADDR 	<= COUNTER_1;
					 Qns_ADDR_FINAL 	<= COUNTER_2;
					 FIN_RES_OFF_NEXT <= FIN_RES_OFF;
					 
					 NEXT_STATE <= MOD_L_PR1;
					 
					 COUNTER_1_NEXT  <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,2));
					 COUNTER_WB_NEXT <= (others => '0');
					 COUNTER_2_NEXT  <= std_logic_vector(unsigned(COUNTER_2) + to_unsigned(1,5));
					 RD_INPUT_ADDR   <= (others => '0'); -- not used anymore from here.
					 DONE_mQ <= '0';
					 ADD_sub_NEXT <= ADDsub_reg;
					 
			
			when MOD_L_PR1 =>
					 CARRY_SEL 	<= '0';
					 S_REG_RST 	<= '0';
					 S_REG_EN 	<= '1';
					 WB_PHASE 	<= '1';
					 WE_RAM 		<= '0';
					 WB_ADDR 	<= (others => '0');
					 SET_RD_WR_WINDOWS <= "00";
					 SW_RD_WR_WINDOWS <= '0';
					 MEM_CONFIG_SWITCH <= '0';
					 RAM_ADDR 	<= COUNTER_1;
					 Qns_ADDR_FINAL 	<= COUNTER_2;
					 FIN_RES_OFF_NEXT <= FIN_RES_OFF;
					 
					 NEXT_STATE <= MOD_L_WB0;
					 
					 COUNTER_1_NEXT  <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,2));
					 COUNTER_WB_NEXT <= (others => '0');
					 COUNTER_2_NEXT  <= std_logic_vector(unsigned(COUNTER_2) + to_unsigned(1,5));
					 RD_INPUT_ADDR   <= (others => '0'); -- not used anymore from here.
					 DONE_mQ <= '0';
					 ADD_sub_NEXT <= ADDsub_reg;
					
			
			when MOD_L_WB0 =>
					 CARRY_SEL 	<= '1';
					 S_REG_RST 	<= '0';
					 S_REG_EN 	<= '1';
					 WB_PHASE 	<= '1';
					 WE_RAM 		<= '1';
					 WB_ADDR 	<= COUNTER_WB;
					 SET_RD_WR_WINDOWS <= "00";
					 SW_RD_WR_WINDOWS <= '0';
					 MEM_CONFIG_SWITCH <= '0';
					 RAM_ADDR 	<= COUNTER_1;
					 Qns_ADDR_FINAL 	<= COUNTER_2;
					 FIN_RES_OFF_NEXT <= FIN_RES_OFF;
					 
					 NEXT_STATE <= MOD_L_WB1;
					 
					 COUNTER_1_NEXT  <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,2));
					 COUNTER_WB_NEXT <= std_logic_vector(unsigned(COUNTER_WB) + to_unsigned(1,2));
					 COUNTER_2_NEXT  <= std_logic_vector(unsigned(COUNTER_2) + to_unsigned(1,5));
					 RD_INPUT_ADDR   <= (others => '0'); -- not used anymore from here.
					 DONE_mQ <= '0';
					 ADD_sub_NEXT <= ADDsub_reg;
					 
			when MOD_L_WB1 =>
					 CARRY_SEL 	<= '1';
					 S_REG_RST 	<= '0';
					 S_REG_EN 	<= '1';
					 WB_PHASE 	<= '1';
					 WE_RAM 		<= '1';
					 WB_ADDR 	<= COUNTER_WB;
					 MEM_CONFIG_SWITCH <= '0';
					 SET_RD_WR_WINDOWS <= "00";
					 SW_RD_WR_WINDOWS <= '0';
					 RAM_ADDR 	<= COUNTER_1;
					 Qns_ADDR_FINAL 	<= COUNTER_2;
					 FIN_RES_OFF_NEXT <= FIN_RES_OFF;
					 
					 NEXT_STATE <= MOD_L_WB2;
					 
					 COUNTER_1_NEXT  <= (others => '0');
					 COUNTER_WB_NEXT <= std_logic_vector(unsigned(COUNTER_WB) + to_unsigned(1,2));
					 COUNTER_2_NEXT  <= COUNTER_2;
					 RD_INPUT_ADDR   <= (others => '0'); -- not used anymore from here.
					 DONE_mQ <= '0';
					 ADD_sub_NEXT <= ADDsub_reg;
					 
			when MOD_L_WB2 =>
					 CARRY_SEL 	<= '1';
					 S_REG_RST 	<= '0';
					 S_REG_EN 	<= '1';
					 WB_PHASE 	<= '1';
					 WE_RAM 		<= '1';
					 WB_ADDR 	<= COUNTER_WB;
					 MEM_CONFIG_SWITCH <= '0';
					 SET_RD_WR_WINDOWS <= "00";
					 SW_RD_WR_WINDOWS <= '0';
					 RAM_ADDR 	<= COUNTER_1;
					 Qns_ADDR_FINAL 	<= COUNTER_2;
					 FIN_RES_OFF_NEXT <= FIN_RES_OFF;
					 
					 NEXT_STATE <= MOD_L_WB3;
					 
					 COUNTER_1_NEXT  <= (others => '0');
					 COUNTER_WB_NEXT <= std_logic_vector(unsigned(COUNTER_WB) + to_unsigned(1,2));
					 COUNTER_2_NEXT  <= COUNTER_2;
					 RD_INPUT_ADDR   <= (others => '0'); -- not used anymore from here.
					 DONE_mQ <= '0';
					 ADD_sub_NEXT <= ADDsub_reg;
					 
			when MOD_L_WB3 =>
					 CARRY_SEL 	<= '0';
					 S_REG_RST 	<= '0';
					 S_REG_EN 	<= '1';
					 WB_PHASE 	<= '1';
					 WE_RAM 		<= '1';
					 WB_ADDR 	<= COUNTER_WB;
					 MEM_CONFIG_SWITCH <= '0';
					 
					 RAM_ADDR 	<= COUNTER_1;
					 Qns_ADDR_FINAL 	<= COUNTER_2;
					 FIN_RES_OFF_NEXT <= FIN_RES_OFF;
					 
					 SET_RD_WR_WINDOWS <= "00";

					 if (COUNTER_2 = std_logic_vector(to_unsigned(23,5))) then
						
						SW_RD_WR_WINDOWS <= '0';
						
						if (C_OUT_DPq = '1') then -- C_OUT = 1 => positive result, need to subtract Q
							NEXT_STATE <= MOD_L_PR0;
							ADD_sub_NEXT <= '0';
						else -- C_OUT = 0 => NEG result, use OLD value and do not subtract anything
							NEXT_STATE <= MOD_L_END_FAST;
							ADD_sub_NEXT <= '1';
						end if;
						
					 elsif (COUNTER_2 = std_logic_vector(to_unsigned(27,5))) then
							SW_RD_WR_WINDOWS <= '1';
							NEXT_STATE <= MOD_L_END_FAST;
							ADD_sub_NEXT <= '1';
		
					 else
					 
						 if (C_OUT_DPq = '1') then -- C_OUT = 1 => positive result, use new value
							SW_RD_WR_WINDOWS <= '1';
						 else -- C_OUT = 0 => NEG result, use OLD value
							SW_RD_WR_WINDOWS <= '0';
						 end if;
						 
						 NEXT_STATE <= MOD_L_PR0;
						 ADD_sub_NEXT <= ADDsub_reg;
						 
					 end if;

					 COUNTER_1_NEXT  <= (others => '0');
					 COUNTER_WB_NEXT <= (others => '0');
					 COUNTER_2_NEXT  <= std_logic_vector(unsigned(COUNTER_2) + to_unsigned(1,5));
					 RD_INPUT_ADDR   <= (others => '0'); -- not used anymore from here.
					 DONE_mQ <= '0';


			when MOD_L_END_FAST =>
					 CARRY_SEL 	<= '0';
					 S_REG_RST 	<= '0';
					 S_REG_EN 	<= '0';
					 WB_PHASE 	<= '0';
					 WE_RAM 		<= '0';
					 WB_ADDR 	<= (others => '0');
					 MEM_CONFIG_SWITCH 	<= '1';
					 RAM_ADDR 	<= (others => '0');
					 SET_RD_WR_WINDOWS <= "11";
					 SW_RD_WR_WINDOWS <= '0';
					 Qns_ADDR_FINAL 	<= (others => '0');
					 
					 --FIN_RES_OFF_NEXT <= FIN_RES_OFF;
					 FIN_RES_OFF_NEXT <= RD_VAR_OFFSET; --last RD window
					 
					 NEXT_STATE <= WAIT_FOR_data_valid;
					 
					 COUNTER_1_NEXT <= (others => '0');
					 COUNTER_WB_NEXT <= (others => '0');
					 COUNTER_2_NEXT <= (others => '0');
					 RD_INPUT_ADDR  <= (others => '0');
					 DONE_mQ <= '1';
					 ADD_sub_NEXT <= ADDsub_reg;
					 
			end case;
	end process P_NEXT_STATE;

END;

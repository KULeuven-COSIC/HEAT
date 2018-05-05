library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- .
entity feeder is
    Port ( CLK : in  STD_LOGIC;
			  RST : in  STD_LOGIC;
			  DONE_SOP_2 : in  STD_LOGIC;
           RD_RESULT_ADDR_2_TO_STG_1 : out  STD_LOGIC_VECTOR (2 downto 0);
           A1QJ_READY_TO_STG_3 : out  STD_LOGIC);
end feeder;

architecture Behavioral of feeder is
	type TYPE_STATE is (RST_STATE, WAIT_DONE_SOP_2, DO1, DO2);
	
	signal CURRENT_STATE : TYPE_STATE := RST_STATE;
	signal NEXT_STATE : TYPE_STATE;
	
	signal COUNTER_1: std_logic_vector(2 downto 0):= "000";
	signal COUNTER_1_NEXT: std_logic_vector(2 downto 0):= "000";
begin
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
		end if;
	end process P_counters;
	
	P_NEXT_STATE : process(CURRENT_STATE, COUNTER_1, DONE_SOP_2) --COMBINATIONAL PROCESS
	begin
		case CURRENT_STATE is 
			when RST_STATE =>
				RD_RESULT_ADDR_2_TO_STG_1 <= (others => '0');
				A1QJ_READY_TO_STG_3 <= '0';
				
				COUNTER_1_NEXT  <= (others => '0');
				NEXT_STATE <= WAIT_DONE_SOP_2;


			when WAIT_DONE_SOP_2 =>
				RD_RESULT_ADDR_2_TO_STG_1 <= (others => '0');
				A1QJ_READY_TO_STG_3 <= '0';
				
				COUNTER_1_NEXT  <= (others => '0');
				if(DONE_SOP_2 = '1') then
					NEXT_STATE <= DO1;
				else 
					NEXT_STATE <= WAIT_DONE_SOP_2;
				end if;
			
			when DO1 =>
				RD_RESULT_ADDR_2_TO_STG_1 <= COUNTER_1;
				A1QJ_READY_TO_STG_3 <= '0';
				
				COUNTER_1_NEXT  <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,3));
				NEXT_STATE <= DO2;
				
				
			when DO2 =>
				RD_RESULT_ADDR_2_TO_STG_1 <= COUNTER_1;
				A1QJ_READY_TO_STG_3 <= '1';
				
				COUNTER_1_NEXT  <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,3));
				if(COUNTER_1 = std_logic_vector(to_unsigned(7,3))) then
					NEXT_STATE <= WAIT_DONE_SOP_2;
				else 
					NEXT_STATE <= DO2;
				end if;
			
			when others => 
				RD_RESULT_ADDR_2_TO_STG_1 <= COUNTER_1;
				A1QJ_READY_TO_STG_3 <= '1';
				NEXT_STATE <= WAIT_DONE_SOP_2;
		end case;
	end process P_NEXT_STATE;
end Behavioral;


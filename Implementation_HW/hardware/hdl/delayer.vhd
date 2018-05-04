library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 
entity delayer is
	generic (numb_bits_nCLK_delay : integer:=3;
			 nCLK_delay: integer:=4);
    Port ( CLK : in  STD_LOGIC;
			  RST : in  STD_LOGIC;
			  DONE : in  STD_LOGIC;
           	  GO : out  STD_LOGIC);
end delayer;

architecture Behavioral of delayer is
	
	type TYPE_STATE is (RST_STATE, WAIT_DONE, WAIT_DELAY, SAY_GO);
	
	signal CURRENT_STATE : TYPE_STATE := RST_STATE;
	signal NEXT_STATE : TYPE_STATE;
	
	signal COUNTER_1: std_logic_vector(numb_bits_nCLK_delay-1 downto 0):= (others => '0');
	signal COUNTER_1_NEXT: std_logic_vector(numb_bits_nCLK_delay-1 downto 0):= (others => '0');


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
	
	P_NEXT_STATE : process(CURRENT_STATE, COUNTER_1, DONE) --COMBINATIONAL PROCESS
	begin
		case CURRENT_STATE is 
		
			when RST_STATE =>
				GO <= '0';
				COUNTER_1_NEXT  <= (others => '0');
				NEXT_STATE <= WAIT_DONE;


			when WAIT_DONE =>
				GO <= '0';
				COUNTER_1_NEXT  <= (others => '0');
				if(DONE = '1') then
					NEXT_STATE <= WAIT_DELAY;
				else 
					NEXT_STATE <= WAIT_DONE;
				end if;
			
			when WAIT_DELAY =>
				GO <= '0';
				COUNTER_1_NEXT  <= std_logic_vector(unsigned(COUNTER_1) + to_unsigned(1,numb_bits_nCLK_delay));
				if(COUNTER_1 = std_logic_vector(to_unsigned(nCLK_delay-1,numb_bits_nCLK_delay))) then
					NEXT_STATE <= SAY_GO;
				else 
					NEXT_STATE <= WAIT_DELAY;
				end if;
				
			when SAY_GO =>
				GO <= '1';
				COUNTER_1_NEXT  <= (others => '0');
				NEXT_STATE <= WAIT_DONE;
			
			-- when others => --omitted because all possibilities in type_state are assigned.
		end case;
	end process P_NEXT_STATE;

end Behavioral;


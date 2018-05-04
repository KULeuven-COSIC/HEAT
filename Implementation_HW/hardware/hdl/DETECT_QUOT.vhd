-- Create Date:    13:16:17 09/20/2017 
-- Design Name: a
-- Module Name:    DETECT_72 - Behavioral 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity DETECT_QUOT is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
				QUOT_READY  : in  STD_LOGIC;
				QUOT_to_sense : in  STD_LOGIC_VECTOR (35 downto 0);
				SIGN_DONE: in STD_LOGIC;
				SIGN_RST: out std_logic;
				QUOT_SENSED : out  STD_LOGIC_VECTOR (35 downto 0));
end DETECT_QUOT;

architecture Behavioral of DETECT_QUOT is

	type TYPE_STATE is (RST_STATE, SENSING_STATE,SENSING_STATE2, WAIT_FOR_GO);
	
	signal CURRENT_STATE : TYPE_STATE := RST_STATE;
	signal NEXT_STATE : TYPE_STATE;
	
	signal QUOT_to_sense_REG			: std_logic_vector(35 downto 0):= (others => '0');
	signal QUOT_to_sense_REG_NEXT	: std_logic_vector(35 downto 0):= (others => '0');
	
begin
	
	QUOT_SENSED <= QUOT_to_sense_REG;

	P_StateUpdate: process (CLK, RST) --CLOCKED PROCESS
	begin
		if RST = '1' then
			CURRENT_STATE <= RST_STATE;
		elsif (CLK = '1' and CLK'EVENT) then
			CURRENT_STATE <= NEXT_STATE;
		end if;
	end process P_StateUpdate;
	
	P_QUOT_to_sense_REG: process (CLK, RST) --CLOCKED PROCESS
	begin
		if RST = '1' then
			QUOT_to_sense_REG <= (others => '0');
		elsif (CLK = '1' and CLK'EVENT) then
			QUOT_to_sense_REG <= QUOT_to_sense_REG_NEXT;
		end if;
	end process P_QUOT_to_sense_REG;
	
	P_NEXT_STATE : process(CURRENT_STATE, QUOT_to_sense, QUOT_to_sense_REG, QUOT_READY, SIGN_DONE) --COMBINATIONAL PROCESS
	begin
		case CURRENT_STATE is 
		
			when RST_STATE =>
				SIGN_RST <= '1';
				NEXT_STATE <= SENSING_STATE;
				QUOT_to_sense_REG_NEXT <= (others => '0');

			when SENSING_STATE =>
				SIGN_RST <= '1';
				QUOT_to_sense_REG_NEXT <= QUOT_to_sense_REG;
				if (QUOT_READY = '1') then
					NEXT_STATE <= SENSING_STATE2;
				else 
					NEXT_STATE <= SENSING_STATE;
				end if;
			
			when SENSING_STATE2 =>
				SIGN_RST <= '1';
				NEXT_STATE <= WAIT_FOR_GO;
				QUOT_to_sense_REG_NEXT <= QUOT_to_sense;
			
			when WAIT_FOR_GO =>
				SIGN_RST <= '0';
				QUOT_to_sense_REG_NEXT <= QUOT_to_sense_REG;
				if (SIGN_DONE = '1') then
					NEXT_STATE <= SENSING_STATE;
				else
					NEXT_STATE <= WAIT_FOR_GO;
				end if;

			when others => 
				QUOT_to_sense_REG_NEXT <= (others => '0');
				NEXT_STATE <= RST_STATE;
				
		end case;
	end process P_NEXT_STATE;


end Behavioral;



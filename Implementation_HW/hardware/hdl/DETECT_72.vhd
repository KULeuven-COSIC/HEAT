-- Create Date:    13:16:17 09/20/2017 
-- Design Name: a
-- Module Name:    DETECT_72 - Behavioral 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity DETECT_72 is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
		   GO  : in  STD_LOGIC;
           RD_RESULT_ADDR_SENSING : in  STD_LOGIC_VECTOR (1 downto 0);
           D_OUT_SOP_RANGE_SELECTED : in  STD_LOGIC_VECTOR (71 downto 0);
           SENSED_DATA : out  STD_LOGIC_VECTOR (71 downto 0));
end DETECT_72;

architecture Behavioral of DETECT_72 is

	type TYPE_STATE is (RST_STATE, SENSING_STATE, WAIT_FOR_GO, SENSING_STATE2);
	
	signal CURRENT_STATE : TYPE_STATE := RST_STATE;
	signal NEXT_STATE : TYPE_STATE;
	
	signal sens_data_reg			: std_logic_vector(71 downto 0):= (others => '0');
	signal sens_data_reg_NEXT	: std_logic_vector(71 downto 0):= (others => '0');
	
begin
	
	SENSED_DATA <= sens_data_reg;

	P_StateUpdate: process (CLK, RST) --CLOCKED PROCESS
	begin
		if RST = '1' then
			CURRENT_STATE <= RST_STATE;
		elsif (CLK = '1' and CLK'EVENT) then
			CURRENT_STATE <= NEXT_STATE;
		end if;
	end process P_StateUpdate;
	
	P_sens_data_reg: process (CLK, RST) --CLOCKED PROCESS
	begin
		if RST = '1' then
			sens_data_reg <= (others => '0');
		elsif (CLK = '1' and CLK'EVENT) then
			sens_data_reg <= sens_data_reg_NEXT;
		end if;
	end process P_sens_data_reg;
	
	P_NEXT_STATE : process(CURRENT_STATE, sens_data_reg, GO, RD_RESULT_ADDR_SENSING, D_OUT_SOP_RANGE_SELECTED) --COMBINATIONAL PROCESS
	begin
		case CURRENT_STATE is 
		
			when RST_STATE =>
				sens_data_reg_NEXT <= (others => '0');
				NEXT_STATE <= SENSING_STATE;
				
			when SENSING_STATE =>
				sens_data_reg_NEXT <= sens_data_reg;
				if (RD_RESULT_ADDR_SENSING = "01") then
					NEXT_STATE <= SENSING_STATE2;
				else 
					NEXT_STATE <= SENSING_STATE;
					sens_data_reg_NEXT <= sens_data_reg;
				end if;

			when SENSING_STATE2 =>
				NEXT_STATE <= WAIT_FOR_GO;
				sens_data_reg_NEXT <= D_OUT_SOP_RANGE_SELECTED;
			
			
			when WAIT_FOR_GO =>
				sens_data_reg_NEXT <= sens_data_reg;
				if (GO = '1') then
					NEXT_STATE <= SENSING_STATE;
				else
					NEXT_STATE <= WAIT_FOR_GO;
				end if;

			when others => 
				sens_data_reg_NEXT <= (others => '0');
				NEXT_STATE <= RST_STATE;
				
		end case;
	end process P_NEXT_STATE;


end Behavioral;


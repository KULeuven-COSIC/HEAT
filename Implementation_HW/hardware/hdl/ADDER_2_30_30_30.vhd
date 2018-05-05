----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:16:37 09/12/2017 
-- Design Name: 
-- Module Name:    ADDER_2_30_30_30 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies:  
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ADDER_2_30_30_30 is
    Port ( in_2 	 : in  STD_LOGIC_VECTOR (1 downto 0);
           in_30_1 : in  STD_LOGIC_VECTOR (29 downto 0);
           in_30_2 : in  STD_LOGIC_VECTOR (29 downto 0);
           in_30_3 : in  STD_LOGIC_VECTOR (29 downto 0);
           out_32  : out  STD_LOGIC_VECTOR (31 downto 0));
end ADDER_2_30_30_30;

architecture Behavioral of ADDER_2_30_30_30 is

signal in_30_1_ext :  STD_LOGIC_VECTOR (30 downto 0);
signal in_30_2_ext :  STD_LOGIC_VECTOR (30 downto 0);

signal sum_temp1 : std_logic_vector(30 downto 0);
signal sum_temp2 : std_logic_vector(30 downto 0);
signal sum_temp1_ext : std_logic_vector(31 downto 0);

begin




adder2303030_proc: process (in_2, in_30_1, in_30_1_ext, in_30_2, in_30_2_ext, in_30_3, sum_temp1, sum_temp1_ext, sum_temp2)
	begin
		in_30_1_ext <= '0' & in_30_1;
		in_30_2_ext <= '0' & in_30_2;
		sum_temp1 <= std_logic_vector(unsigned(in_2)+unsigned(in_30_1_ext));
		sum_temp2 <= std_logic_vector(unsigned(in_30_2_ext)+unsigned(in_30_3));
		sum_temp1_ext <= '0' & sum_temp1;
		out_32  <= std_logic_vector(unsigned(sum_temp1_ext)+unsigned(sum_temp2));
	end process adder2303030_proc;
		
end Behavioral;


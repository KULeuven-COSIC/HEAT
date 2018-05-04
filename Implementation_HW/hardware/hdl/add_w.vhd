----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:07:45 02/11/2015 
-- Design Name: 
-- Module Name:    add_48 - rtl 
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
--use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM; 
--use UNISIM.VComponents.all;

entity add_w is
	generic (
		W		: integer := 32);
	port (
		clk	: in  std_logic;
		a		: in  std_logic_vector(W-1 downto 0);
		b		: in  std_logic_vector(W-1 downto 0);
		c_in	: in	std_logic;
		s		: out std_logic_vector(W-1 downto 0);
		c_out	: out std_logic);
end add_w;

architecture rtl of add_w is

	signal sum : std_logic_vector(W downto 0);

	signal c_long : std_logic_vector(W downto 0);

begin

	c_long(W downto 1) <= (others => '0');
	c_long(0) <= c_in;
	sum <= std_logic_vector(unsigned('0' & a) + unsigned('0' & b) + unsigned(c_long));

	process (clk)		
	begin
		if rising_edge(clk) then			
			s <= sum(W-1 downto 0);
			c_out <= sum(W);
		end if;
	end process;

end rtl;


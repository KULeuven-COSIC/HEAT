library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM; 
--use UNISIM.VComponents.all;

entity adder_2_4 is
    Port ( in_2 : in  STD_LOGIC_VECTOR (1 downto 0);
           in_4 : in  STD_LOGIC_VECTOR (3 downto 0);
           out_4 : out  STD_LOGIC_VECTOR (3 downto 0));
end adder_2_4;

architecture Behavioral of adder_2_4 is

signal in_2_ext : std_logic_vector (3 downto 0);

begin

adder24proc: process(in_2,in_2_ext, in_4)
begin
	in_2_ext <= "00" & in_2;
	out_4 <= std_logic_vector(unsigned(in_2_ext)+unsigned(in_4));

end process adder24proc;

end Behavioral;


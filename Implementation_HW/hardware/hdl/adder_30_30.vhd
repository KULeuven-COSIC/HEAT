library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM; 
--use UNISIM.VComponents.all;

entity adder_30_30 is
    Port ( in1_30 : in  STD_LOGIC_VECTOR (29 downto 0);
           in2_30 : in  STD_LOGIC_VECTOR (29 downto 0);
           out_32 : out  STD_LOGIC_VECTOR (31 downto 0));
end adder_30_30;

architecture Behavioral of adder_30_30 is

signal in1_30_ext : STD_LOGIC_VECTOR (31 downto 0);
begin

adder3030_proc: process (in1_30, in2_30, in1_30_ext)
begin
	in1_30_ext <= "00" & in1_30;
	out_32  <= std_logic_vector(unsigned(in1_30_ext)+unsigned(in2_30));
end process adder3030_proc;

end Behavioral;



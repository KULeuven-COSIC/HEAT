library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- .
entity r_rom_118 is
	port (
		clk		: in  std_logic;
		addr	: in  std_logic_vector(2 downto 0);
		r_out 	: out std_logic_vector(117 downto 0));
end r_rom_118;

architecture rtl of r_rom_118 is

	signal r_out_t : std_logic_vector(119 downto 0);

begin

process (clk)

begin

	if rising_edge(clk) then
		case addr is
			-- The hardwired reciprocal 33/1509155612652322963894981558308021422531187968728956929
			when "000" => r_out_t <= x"1c3f13b0f2ec4cb0ad0661f0aea836";
			when "001" => r_out_t <= x"0aa6ef89abdf99d94737cad9790ef5";
			when "010" => r_out_t <= x"25725e19a329553315141bb92ba9ff";
			when "011" => r_out_t <= x"000000000000002182a72b3cd69780";
			-- The hardwired reciprocal 1/1509155612652322963894981558308021422531187968728956929
			when "100" => r_out_t <= x"1d69e83a79926982b49515a97fca26";
			when "101" => r_out_t <= x"0ad4eb942bbb6f3017e9562c662bf0";
			when "110" => r_out_t <= x"000000000000000103f58cf254141b";
			when others   => r_out_t <= x"000000000000000000000000000000";
			end case;
		end if;
	end process;

	r_out <= r_out_t(117 downto 0);

end rtl;


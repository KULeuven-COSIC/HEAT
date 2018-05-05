library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--.
entity div_ctrl_118 is
	generic (
		PIPELINE 	: integer := 23;
		C_ADDR_W 	: integer := 5;
		R_ADDR_W 	: integer := 3);
	port (
		clk		: in  std_logic;
		rst		: in  std_logic;
		sel 	: in  std_logic; -- 0 : round(2c/q), 1 : floor(c/q) 
		c_ready	: in  std_logic;
		c_addr	: out std_logic_vector(C_ADDR_W-1 downto 0);
		r_addr	: out std_logic_vector(R_ADDR_W-1 downto 0);
		en			: out std_logic;
		sft		: out std_logic;
		en_round	: out std_logic;
		d_ready	: out std_logic;
		busy		: out std_logic);
end div_ctrl_118;

architecture rtl of div_ctrl_118 is

	signal state : integer range 0 to 122;

	signal en_round_t, d_ready_t : std_logic;

begin

	i_fsm_comb_addr : process (clk)
	begin
	if rising_edge(clk) then
		case state is
			-- round(33 * c / 1509155612652322963894981558308021422531187968728956929)
			when 0 => c_addr <= "00000"; r_addr <= "000";
			when 5 => c_addr <= "00000"; r_addr <= "001";
			when 6 => c_addr <= "00001"; r_addr <= "000";
			when 11 => c_addr <= "00000"; r_addr <= "010";
			when 12 => c_addr <= "00001"; r_addr <= "001";
			when 13 => c_addr <= "00010"; r_addr <= "000";
			when 18 => c_addr <= "00000"; r_addr <= "011";
			when 19 => c_addr <= "00001"; r_addr <= "010";
			when 20 => c_addr <= "00010"; r_addr <= "001";
			when 21 => c_addr <= "00011"; r_addr <= "000";
			when 26 => c_addr <= "00001"; r_addr <= "011";
			when 27 => c_addr <= "00010"; r_addr <= "010";
			when 28 => c_addr <= "00011"; r_addr <= "001";
			when 37 => c_addr <= "00010"; r_addr <= "011";
			when 38 => c_addr <= "00011"; r_addr <= "010";
			when 43 => c_addr <= "00011"; r_addr <= "011";
			-- floor(1 * c / 1509155612652322963894981558308021422531187968728956929)
			when 72 => c_addr <= "00000"; r_addr <= "100";
			when 77 => c_addr <= "00000"; r_addr <= "101";
			when 78 => c_addr <= "00001"; r_addr <= "100";
			when 83 => c_addr <= "00000"; r_addr <= "110";
			when 84 => c_addr <= "00001"; r_addr <= "101";
			when 89 => c_addr <= "00001"; r_addr <= "110";
			when others => c_addr <= "00000"; r_addr <= "111";
		end case;

		case state is when 24 | 29 | 30 | 35 | 36 | 37 | 42 | 43 | 44 | 45 | 50 | 51 | 52 | 57 | 58 | 59 | 60 | 61 | 62 | 67 | 96 | 101 | 102 | 107 | 108 | 113 => en <= '1'; when others => en <= '0'; end case;

		case state is when 28 | 34 | 41 | 49 | 56 | 66 | 71 | 100 | 106 | 112 | 117 | 121 => sft <= '1'; when others => sft <= '0'; end case;

		case state is when 57 => en_round <= '1'; when others => en_round <= '0'; end case;

		case state is when 66 | 71 | 121 => d_ready_t <= '1'; when others => d_ready_t <= '0'; end case;

	end if;

	end process i_fsm_comb_addr;

	i_fsm_ncomb : process (clk,rst)
	begin
		if rst = '1' then
			state <= 0;
			d_ready <= '0';
		elsif rising_edge(clk) then
			case state is
				when 0 =>
					if c_ready = '1' and sel = '0' then
						state <= state + 1;
					elsif c_ready = '1' and sel = '1' then
						state <= 72;
					end if;
				when 71 => state <= 0;
				when 122 => state <= 0;
				when others => state <= state + 1;
			end case;
			d_ready <= d_ready_t;
		end if;
	end process;

	busy <= '0' when state = 0 else '1';

end rtl;


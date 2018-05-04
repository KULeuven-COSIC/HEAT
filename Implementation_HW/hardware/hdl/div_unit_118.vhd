----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:30:25 02/12/2015 
-- Design Name: 
-- Module Name:    div_unit_118 - struct 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
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

--LIBRARY XilinxCoreLib;
-- .
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM; 
--use UNISIM.VComponents.all;

entity div_unit_118 is
	port (
		clk		: in  std_logic;
		rst		: in  std_logic;
      	sel      : in  std_logic; -- 0: round(2c/q), 1: floor(c/q)
		c_ready	: in  std_logic;
		c_in		: in  std_logic_vector(117 downto 0);
		c_addr	: out std_logic_vector(4 downto 0);
		d_out		: out std_logic_vector(117 downto 0);
		d_ready	: out std_logic;
		busy		: out std_logic);
end div_unit_118;

architecture hierarchical of div_unit_118 is

	constant	W1			: integer := 118;	-- Word size of the multiplier
	constant PIPELINE	: integer := 23;	-- Length of the multiplier pipeline
	constant C_ADDR_W	: integer := 5;	-- Address width of the C RAM
	constant R_ADDR_W	: integer := 3;	-- Address width of the R ROM

	component div_ctrl_118 is
		generic (
			PIPELINE	: integer := 18;	-- Length of the multiplier pipeline
			C_ADDR_W	: integer := 5;	-- Address width of the C RAM
			R_ADDR_W	: integer := 3);	-- Address width of the R ROM	
		port (
			clk		: in  std_logic;
			rst		: in  std_logic;
         sel      : in  std_logic;
			c_ready	: in  std_logic;
			c_addr	: out std_logic_vector(C_ADDR_W-1 downto 0);
			r_addr	: out std_logic_vector(R_ADDR_W-1 downto 0);
			en			: out std_logic;
			sft		: out std_logic;
			en_round	: out std_logic;
			d_ready	: out std_logic;
			busy		: out std_logic);
	end component div_ctrl_118;

	component r_rom_118 is
		port (
			clk	: in  std_logic;
			addr	: in  std_logic_vector(R_ADDR_W-1 downto 0);
			r_out	: out std_logic_vector(W1-1 downto 0));
	end component r_rom_118;

	component multiplier_118 is
		port (
			clk		: in  std_logic;
			a			: in  std_logic_vector(W1-1 downto 0);
			b			: in  std_logic_vector(W1-1 downto 0);
			c			: out std_logic_vector(2*W1-1 downto 0));
	end component;
	
	component add_comb_w is
		generic (
			W		: integer := 32);
		port (
			a		: in  std_logic_vector(W-1 downto 0);
			b		: in  std_logic_vector(W-1 downto 0);
			c_in	: in	std_logic;
			s		: out std_logic_vector(W-1 downto 0);
			c_out	: out std_logic);		
	end component;

	signal r_addr 	: std_logic_vector(R_ADDR_W-1 downto 0);
	signal r			: std_logic_vector(W1-1 downto 0);

	signal product : std_logic_vector(2*W1-1 downto 0);

	signal en, sft, en_round, en_1, en_2, en_3 : std_logic;

	signal product_1 : std_logic_vector(235 downto 59);
	signal product_2 : std_logic_vector(235 downto 118);
	signal product_3 : std_logic_vector(235 downto 177);
	
	signal reg_0, reg_1, reg_2, reg_3 : std_logic_vector(58 downto 0);
	signal reg_4 : std_logic_vector(4 downto 0);
	
	signal add_0, add_1, add_2, add_3 : std_logic_vector(58 downto 0);
	signal add_4 : std_logic_vector(3 downto 0);
	signal round_bit, cadd_0, cadd_1, cadd_2, cadd_3, cadd_4 : std_logic;
	signal cadd_0_r, cadd_1_r, cadd_2_r : std_logic;
	
	signal d : std_logic_vector(117 downto 0);

	signal busy_t : std_logic;

begin

	i_div_ctrl : div_ctrl_118
		port map (clk, rst, sel, c_ready, c_addr, r_addr, en, sft, en_round, d_ready, busy_t);	

	i_r_rom : r_rom_118
		port map (clk,r_addr,r);
		
	i_multiplier_118 : multiplier_118
		port map (clk,c_in, r, product);		

	-- Rounding bit
	round_bit <= d(117) when en_round = '1' else '0';

	-- Adders
	i_add_0 : add_comb_w
		generic map (59)
		port map (product(58 downto 0), reg_0, round_bit, add_0, cadd_0);
	
	i_add_1 : add_comb_w
		generic map (59)
		port map (product_1(117 downto 59), reg_1, cadd_0_r, add_1, cadd_1);
	
	i_add_2 : add_comb_w
		generic map (59)
		port map (product_2(176 downto 118), reg_2, cadd_1_r, add_2, cadd_2);

	i_add_3 : add_comb_w
		generic map (59)
		port map (product_3(235 downto 177), reg_3, cadd_2_r, add_3, cadd_3);
		
	i_add_4 : add_comb_w
		generic map (4)
		port map ((others => '0'), reg_4(3 downto 0), cadd_3, add_4, cadd_4);

	process (clk,rst)
	begin
		if rst = '1' then
			d <= (others => '0');
			reg_0 <= (others => '0');
			reg_1 <= (others => '0');
			reg_2 <= (others => '0');
			reg_3 <= (others => '0');
			reg_4 <= (others => '0');
			product_1 <= (others => '0');
			product_2 <= (others => '0');
			product_3 <= (others => '0');
			en_1 <= '0';
			en_2 <= '0';
			en_3 <= '0';
			cadd_0_r <= '0';
			cadd_1_r <= '0';
			cadd_2_r <= '0';
		elsif rising_edge(clk) then
		
			if en = '1' then
				reg_0 <= add_0;
			end if;
			if en_1 = '1' then
				reg_1 <= add_1;
			end if;
			if en_2 = '1' then
				reg_2 <= add_2;
			end if;
			if en_3 = '1' then
				reg_3 <= add_3;
				reg_4 <= cadd_4 & add_4;
			end if;
			if sft = '1' then
				d <= reg_1 & reg_0;
				reg_0 <= reg_2;
				reg_1 <= reg_3;
				reg_2(4 downto 0) <= reg_4;
				reg_2(58 downto 5) <= (others => '0');
				reg_3 <= (others => '0');
				reg_4 <= (others => '0');
			end if;
		
			product_1(235 downto 59) <= product(235 downto 59);
			product_2(235 downto 118) <= product_1(235 downto 118);
			product_3(235 downto 177) <= product_2(235 downto 177);

			cadd_0_r <= cadd_0;
			cadd_1_r <= cadd_1;
			cadd_2_r <= cadd_2;			
		
			en_1 <= en;
			en_2 <= en_1;
			en_3 <= en_2;
		
		end if;	
	end process;

	d_out <= d;

	busy <= busy_t;

end hierarchical;


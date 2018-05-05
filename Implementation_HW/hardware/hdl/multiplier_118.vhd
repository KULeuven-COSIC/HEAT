----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:05:34 02/10/2015 
-- Design Name: 
-- Module Name:    multiplier_118 - struct 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM; 
--use UNISIM.VComponents.all;

entity multiplier_118 is
	port (
		clk	: in  std_logic;
		a		: in  std_logic_vector(117 downto 0);
		b		: in  std_logic_vector(117 downto 0);
		c		: out	std_logic_vector(235 downto 0));
end multiplier_118;

architecture struct of multiplier_118 is

	constant MULTIPLIER_TYPE : integer := 0;

	component multiplier_59_cg
		port (
			clk	: in  std_logic;
			a 		: in  std_logic_vector(58 downto 0);
			b 		: in  std_logic_vector(58 downto 0);
			p 		: out std_logic_vector(117 downto 0)
		);
	end component;
	
	component multiplier_59_basic
		port (
			clk	: in  std_logic;
			a 		: in  std_logic_vector(58 downto 0);
			b 		: in  std_logic_vector(58 downto 0);
			p 		: out std_logic_vector(117 downto 0)
		);
	end component;
	
	component multiplier_60_cg
		port (
			clk	: in  std_logic;
			a 		: in  std_logic_vector(59 downto 0);
			b 		: in  std_logic_vector(59 downto 0);
			p 		: out std_logic_vector(119 downto 0)
		);
	end component;
	
	component multiplier_60_basic
		port (
			clk	: in  std_logic;
			a 		: in  std_logic_vector(59 downto 0);
			b 		: in  std_logic_vector(59 downto 0);
			p 		: out std_logic_vector(119 downto 0)
		);
	end component;
	
	component add_w
		generic (
			W		: integer := 32);
		port (
			clk	: in  std_logic;
			a		: in  std_logic_vector(W-1 downto 0);
			b		: in  std_logic_vector(W-1 downto 0);
			c_in	: in  std_logic;
			s		: out std_logic_vector(W-1 downto 0);
			c_out : out std_logic
		);
	end component;		

	signal a0,a1,b0,b1 : std_logic_vector(58 downto 0);
	signal a0a1, b0b1 : std_logic_vector(59 downto 0);

	signal c0, c2 : std_logic_vector(117 downto 0);
	signal c1_mult : std_logic_vector(119 downto 0);
	signal c1_mult_1 : std_logic_vector(119 downto 59);
	
	signal c0c2a, not_c0c2a, c0c2b : std_logic_vector(58 downto 0);
	signal not_c0c2b : std_logic_vector(60 downto 0);
	signal c_c0c2a, c_c0c2b : std_logic;
	
	signal c1a : std_logic_vector(58 downto 0);
	signal c1b : std_logic_vector(60 downto 0);
	signal c1b_1 : std_logic_vector(59 downto 59); 
	signal c_c1a : std_logic;
	
	signal c0_1, c0_2 : std_logic_vector(117 downto 0);
	signal c0_3, c0_4, c0_5 : std_logic_vector(58 downto 0);
	
	signal c2_1, c2_2, c2_3 : std_logic_vector(117 downto 0);
	signal c2_4 : std_logic_vector(117 downto 59);
	
	signal y1, y2, y3 : std_logic_vector(58 downto 0);
	signal c_y1, c_y2, c_y3 : std_logic;
	
	signal c1b_1_long : std_logic_vector(58 downto 0);
	
	signal y1_1, y1_2, y2_1 : std_logic_vector(58 downto 0);

begin

	a0 <= a(58 downto 0);
	a1 <= a(117 downto 59);
	b0 <= b(58 downto 0);
	b1 <= b(117 downto 59);

	-- First additions
	i_add_a0a1 : add_w
		generic map (59)
		port map (clk,a0,a1,'0',a0a1(58 downto 0),a0a1(59));	
		
	i_add_b0b1 : add_w
		generic map (59)
		port map (clk,b0,b1,'0',b0b1(58 downto 0),b0b1(59));

	-- Multiplications
	g_mult_cg : if MULTIPLIER_TYPE = 0 generate
		i_mult_c0 : multiplier_59_cg
			port map (clk, a0, b0, c0);

		i_mult_c1 : multiplier_60_cg
			port map (clk, a0a1, b0b1, c1_mult);			

		i_mult_c2 : multiplier_59_cg
			port map (clk, a1, b1, c2);
	end generate g_mult_cg;
	
	g_mult_basic : if MULTIPLIER_TYPE = 1 generate
		i_mult_c0 : multiplier_59_basic
			port map (clk, a0, b0, c0);

		i_mult_c1 : multiplier_60_basic
			port map (clk, a0a1, b0b1, c1_mult);			

		i_mult_c2 : multiplier_59_basic
			port map (clk, a1, b1, c2);
	end generate g_mult_basic;

	-- Second additions
	
	-- c0 + c2
	i_add_c0c2a : add_w
		generic map (59)
		port map (clk,c0(58 downto 0),c2(58 downto 0),'0',c0c2a,c_c0c2a);	
	i_add_c0c2b : add_w
		generic map (59)
		port map (clk,c0_1(117 downto 59),c2_1(117 downto 59),c_c0c2a,c0c2b,c_c0c2b);
	
	-- (a0+a1)*(b0+b1) - (c0+c2)
	not_c0c2a <= not c0c2a;
	i_add_c1a : add_w
		generic map (59)
		port map (clk,c1_mult(58 downto 0),not_c0c2a,'1',c1a,c_c1a);
	not_c0c2b <= '1' & (not c_c0c2b) & (not c0c2b);
	i_add_c1b : add_w
		generic map (61)
		port map (clk,c1_mult_1(119 downto 59),not_c0c2b,c_c1a,c1b);

	-- Registers
	i_regs : process (clk)
	begin
		if rising_edge(clk) then
			
			-- Inputs
			-- Delay by one
			c0_1(117 downto 0)	<= c0(117 downto 0);
			c2_1(117 downto 0)	<= c2(117 downto 0);
			c1_mult_1(119 downto 59) <= c1_mult(119 downto 59);
			c1b_1(59) <= c1b(59);
			-- Delay by two
			c0_2(117 downto 0)	<= c0_1(117 downto 0);
			c2_2(117 downto 0)	<= c2_1(117 downto 0);
			-- Delay by three
			c0_3(58 downto 0)		<= c0_2(58 downto 0);
			c2_3(117 downto 0)	<= c2_2(117 downto 0);
			-- Delay by four
			c0_4(58 downto 0)		<= c0_3(58 downto 0);
			c2_4(117 downto 59)	<= c2_3(117 downto 59);
			-- Delay by five
			c0_5(58 downto 0)		<= c0_4(58 downto 0);
			
			-- Outputs
			-- Delay by one
			y1_1 <= y1;
			y2_1 <= y2;
			-- Delay by two
			y1_2 <= y1_1;
		end if;
	end process;
		
	-- Adders
	i_add_y1 : add_w
		generic map (59)
		port map (clk,c0_2(117 downto 59),c1a,'0',y1,c_y1);
		
	i_add_y2 : add_w
		generic map (59)
		port map (clk,c2_3(58 downto 0),c1b(58 downto 0),c_y1,y2,c_y2);
		
	c1b_1_long(0) <= c1b_1(59);
	c1b_1_long(58 downto 1) <= (others => '0');
	i_add_y3 : add_w
		generic map (59)
		port map (clk,c1b_1_long,c2_4(117 downto 59),c_y2,y3);

	c <= y3 & y2_1 & y1_2 & c0_5;

end struct;


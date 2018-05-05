----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:13:13 09/02/2017 
-- Design Name: 
-- Module Name:    top_Neural_Net - Behavioral 
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
use ieee.std_logic_unsigned.all;

use work.PKG_memiface.ALL;
use work.PKG_demo.ALL;


entity dummy_NN_top is
    Port ( 
			  reset_outside 			: in  STD_LOGIC;
           clock_200				 	: in  STD_LOGIC;
           
			  interrupt_eth         : in  STD_LOGIC;
			  address_eth				: in STD_LOGIC_VECTOR(10 downto 0);
			  web_eth					: in STD_LOGIC;
			  wep_eth					: in STD_LOGIC;			  
			  dinb_eth					: in STD_LOGIC_VECTOR(59 downto 0);
			  doutb_eth					: out STD_LOGIC_VECTOR(59 downto 0);
			  instruction_eth			: in STD_LOGIC_VECTOR(7 downto 0);
			  operand_eth				: in STD_LOGIC_VECTOR(7 downto 0);
			  
			  done_ddr        		: out std_logic;
			  done_comp			     	: out std_logic
    );
end dummy_NN_top;



architecture Behavioral of dummy_NN_top is
	signal clock_100 : std_logic;


	-------------- INSTRUCTION Decoding signala 
	signal rst_ddr_pol, read_write : std_logic;
	
	--------------- INSTRUCTION GENERATOR MSP ----------------------------------------
	signal start_eth, instruction_executed_MSP : std_logic;
	signal instruction_MSP, operand_MSP, operand1_MSP, operand2_MSP, operand_new : std_logic_vector(7 downto 0);
	signal processor_sel_MSP : std_logic_vector(2 downto 0);
	signal memory_sel_MSP : std_logic_vector(3 downto 0);
	signal modulus_sel_MSP : std_logic;

	
	------------- MIG interface signals ----------------------------------------------
	signal phy_init_done_i : STD_LOGIC;
	signal app_rd_d, app_wr_d : STD_LOGIC_VECTOR(C_MIG_APP_DATA_WIDTH-1 downto 0);
	signal app_wr_dm : STD_LOGIC_VECTOR(C_MIG_APP_MASK_WIDTH-1 downto 0);
	signal app_addr : STD_LOGIC_VECTOR(C_MIG_ADDR_WIDTH-1 downto 0);
	signal app_cmd : STD_LOGIC_VECTOR(2 downto 0);
	signal app_en, app_rdy, app_rd_dv, app_rd_dl, app_wr_rdy, app_wr_dv, app_wr_dl : STD_LOGIC;
	signal iodelay_ctrl_rdy_i, rst_infra_i : STD_LOGIC;
	-------------------------------------------------------------------------


	------------- Computation ALU signals ----------------------------------------------
	signal addrb_top : STD_LOGIC_VECTOR(10 downto 0);
	signal dinb_top, doutb_top : STD_LOGIC_VECTOR(255 downto 0);	
	signal dinb_top_additional : STD_LOGIC_VECTOR(59 downto 0);	
	signal web_top, crt_special_load, done_computation : STD_LOGIC;
	signal core_index : STD_LOGIC_VECTOR(2 downto 0);		
	signal processor_sel : STD_LOGIC_VECTOR(2 downto 0); 
	signal top_mem_sel, rdM0, rdM1, wtM0, wtM1 : STD_LOGIC_VECTOR(3 downto 0);
	signal temp_wire : std_logic_vector(3 downto 0);
	-------------------------------------------------------------------------


	------------- Lift signals ----------------------------------------------
	signal rst_lift : STD_LOGIC;
	signal lift_address : STD_LOGIC_VECTOR(5 downto 0);
	signal lift_we, lift_data_type, lift_dv : STD_LOGIC;
	signal lift_data_to_ddr : STD_LOGIC_VECTOR(239 downto 0);	
	signal lift_active, lift_done : STD_LOGIC;
	signal end_reduction_type : STD_LOGIC; -- If 0 then reduces 180 bit data by qi; else reduces 91 bit two words in two iterations.
	-------------------------------------------------------------------------


	------------- DDR-ALU FIFO signals --------------------------------------
	signal fifo1_in, fifo1_out : std_logic_vector(281 downto 0);
	signal fifo1_read_en, fifo1_empty, fifo1_almost_empty, fifo1_write_en, fifo1_full, fifo1_almost_full : std_logic;

	signal fifo2_in, fifo2_out : std_logic_vector(255 downto 0);
	signal fifo2_read_en, fifo2_empty, fifo2_almost_empty, fifo2_write_en, fifo2_full, fifo2_almost_full : std_logic;
	signal ddr_interrupt : std_logic;
	signal bram_data_from_ddr, bram_data_to_ddr : std_logic_vector(239 downto 0);
   signal data_to_ddr : std_logic_vector(239 downto 0);
	
	-- DDR Master signals
	signal bram_address_ddr_i_100 : std_logic_vector(8 downto 0);
	signal bram_wen_ddr_i_100, ddr_wen_ddr_i_100 : std_logic;
	signal ddr_address_ddr_i_100 : std_logic_vector(24 downto 0);
	signal done_ddr_i_100 : std_logic;
	signal ddr_base_address_out : std_logic_vector(7 downto 0);

	-- DDR Slave signals
	signal ddr_wen_200 : std_logic;
	signal address_tag_out, address_tag_in : std_logic_vector(7 downto 0);

	-- Ethernet signals
	signal instruction_new : STD_LOGIC_VECTOR(7 downto 0);
	signal test_wire : STD_LOGIC_VECTOR(5 downto 0);
	
begin
	done_ddr <= done_ddr_i_100;
	done_comp <= done_computation;
	
  	-- 100 MHz clock generation
	CLD_DIV2: process(clock_200)
	begin
		if rising_edge(clock_200) then
			if reset_outside = '1' then 
					clock_100 <= '0';
			else
					clock_100 <= not(clock_100);
			end if;
		end if;
	end process;




-------------------------------------------------------------------------------
-- 										Instruction Decoder
-------------------------------------------------------------------------------


--instruction_new <= instruction_eth when interrupt_eth = '0' else x"00";
   instruction_new <= instruction_MSP when start_eth = '1' else instruction_eth when interrupt_eth = '0' else x"00";
	operand_new <= operand1_MSP when start_eth = '1' else operand_eth;
	rst_ddr_pol <= '0' when instruction_new = x"03" or instruction_new = x"04" or instruction_new = x"05" or instruction_new = x"06" or instruction_new = x"07"  or instruction_new = x"08" or instruction_new = x"09" or instruction_new = x"0a" or instruction_new = x"0b" or instruction_new = x"0f" else '1';
	lift_active <= '1' when instruction_new = x"05" or instruction_new = x"06" or instruction_new = x"07" else '0';
	read_write <=  '1' when instruction_new = x"03" else '0';
	ddr_interrupt <= '1' when rst_ddr_pol = '0' else '0';
	start_eth <=  '1' when instruction_eth = x"41" and interrupt_eth = '0' else '0';

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--                          Instruction Generator                              --  
---------------------------------------------------------------------------------

MSP_inst00: component instruction_gen port map(
                       clk => clock_100, 
							  start_eth => start_eth,
							  program_data_eth => dinb_eth, 
							  program_address_eth => address_eth, 
							  program_data_load_eth => wep_eth,
							  
                       instruction => instruction_MSP, 
							  operand1 => operand1_MSP, 
							  operand2 => operand2_MSP,
							  processor_sel => processor_sel_MSP,
							  memory_sel => memory_sel_MSP,
							  modulus_sel => modulus_sel_MSP,

							  instruction_computation_executed => done_computation,
							  instruction_ddr_executed => done_ddr_i_100
							);



-------------------------------------------------------------------------------
-- 										Computation ALU 
-------------------------------------------------------------------------------

--processor_sel <= operand_eth(7 downto 5);
--top_mem_sel	<= operand_eth(0);

--processor_sel <= operand_MSP(7 downto 5) when start_eth = '1' else operand_eth(7 downto 5);
--top_mem_sel	<= operand_MSP(0) when start_eth = '1' else operand_eth(0);

processor_sel <= processor_sel_MSP when start_eth = '1' else operand_eth(7 downto 5);
--top_mem_sel	<= memory_sel_MSP when start_eth = '1' else operand_eth(0);

top_mem_sel	<= memory_sel_MSP when start_eth = '1' else operand_eth(3 downto 0); -- original
rdM0 <= operand1_MSP(3 downto 0);
rdM1 <= operand1_MSP(7 downto 4);
wtM0 <= operand2_MSP(3 downto 0);
wtM1 <= operand2_MSP(7 downto 4);

--rdM0 <= "0000";
--rdM1 <= "0001";
--wtM0 <= "0110";
--wtM1 <= "0000";

computation_inst00: component PROCESSOR_POLY port map(
							clk => clock_100,
							modulus_sel => modulus_sel_MSP,							
							instruction => instruction_new, 

							interrupt_eth => interrupt_eth,
							processor_sel => processor_sel,
							address_eth => address_eth,
							dinb_eth => dinb_eth,
							web_eth => web_eth,
							doutb_eth => doutb_eth,							

							top_mem_sel => top_mem_sel,
							rdM0 => rdM0,
							rdM1 => rdM1,
							wtM0 => wtM0,
							wtM1 => wtM1,
							
							ddr_interrupt => ddr_interrupt,
							ddr_address => bram_address_ddr_i_100, 
							ddr_we => bram_wen_ddr_i_100,
							ddr_din => bram_data_from_ddr,
							ddr_dout => bram_data_to_ddr,
							
							done => done_computation
							);		
							
crt_special_load <= '0';
core_index <= "000";



-------------------------------------------------------------------------------
-- 										LIFT CORE 
-------------------------------------------------------------------------------


--lift_inst00: component lift_wrapper port map(
--                              clk => clock_100, 
--										rst => rst_lift, 
--										reduction_type => end_reduction_type,
--										top_address => lift_address, 
--										we => lift_we, 
--										din => bram_data_from_ddr, 
--										data_type => lift_data_type, 
--										data_valid => lift_dv,
--										read_out => lift_data_to_ddr, 
--										done => lift_done
--										);

end_reduction_type <= '1' when instruction_new = x"07" else '0';
lift_data_type <= '1' when instruction_new = x"05" else '0';					  
							
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- 									DDR Interfacing using FIFOs 
-------------------------------------------------------------------------------

bram_data_from_ddr <= fifo2_out(251 downto 192) & fifo2_out(187 downto 128) & fifo2_out(123 downto 64) & fifo2_out(59 downto 0);

fifo1: component fifo_100_to_200_module port map(
										 rst => reset_outside, 
										 wr_clk => clock_100, 
										 rd_clk => clock_200,
										 din => fifo1_in,
										 wr_en => fifo1_write_en,
										 rd_en => fifo1_read_en, 
										 dout => fifo1_out,
										 full => fifo1_full, 
										 almost_full => fifo1_almost_full,
										 empty => fifo1_empty,
										 almost_empty => fifo1_almost_empty
										);


-- DDR Master interface, runs at 100 MHz.
ddr_i_100: component ddr_iface_100MHz port map(
                      clk_100 => clock_100, 
							 rst => rst_ddr_pol, 
							 instruction => instruction_new, 
							 ddr_base_address_in => operand_new, --operand_eth, 
							 ddr_base_address_out => ddr_base_address_out,
							 
							 -- signals for ALU-Memory
                      bram_address => bram_address_ddr_i_100, 
							 bram_wen => bram_wen_ddr_i_100,
							 lift_address => lift_address,
							 lift_we => lift_we,
							 ddr_address => ddr_address_ddr_i_100, 
							 ddr_wen => ddr_wen_ddr_i_100,
			
							 -- Signals for FIFOs
							 fifo_read_en => fifo2_read_en, 
							 fifo_read_empty => fifo2_empty, 
							 fifo_write_en => fifo1_write_en, 
							 fifo_write_almost_full => fifo1_almost_full, 
							 fifo_write_full => fifo1_full,
							 
							 -- data validity check
							 address_tag_in => address_tag_in,
							 
							 rst_lift => rst_lift,
							 lift_dv => lift_dv,
							 lift_done =>lift_done,
							 
							 done => done_ddr_i_100				 
							 );

ddr_base_address_out <= operand2_MSP when start_eth = '1' else "00010000";

fifo2: component fifo_200_to_100 port map(	
										 rst => reset_outside, 
										 wr_clk => clock_200, 
										 rd_clk => clock_100,
										 din => fifo2_in,
										 wr_en => fifo2_write_en,
										 rd_en => fifo2_read_en, 
										 dout => fifo2_out,
										 full => fifo2_full, 
										 almost_full => fifo2_almost_full,
										 empty => fifo2_empty,
										 almost_empty => fifo2_almost_empty
										);

ddr_wen_200 <= fifo1_out(0);

-- DDR Slave interface, runs at 200 MHz.
ddr_i_200: component ddr_iface_200Mhz	port map(
									clk_200 => clock_200, 
									rst => reset_outside, 
									fifo_read_en => fifo1_read_en, 
									fifo_read_empty => fifo1_empty,
									fifo_write_en => fifo2_write_en, 
									fifo_write_almost_full => fifo2_almost_full, 
									ddr_wen => ddr_wen_200,
									
									app_rdy => app_rdy, app_rd_dl => app_rd_dl, app_wdf_rdy => app_wr_rdy,
									app_en => app_en, app_wr_dv => app_wr_dv, app_wr_dl => app_wr_dl, app_cmd => app_cmd
									);

app_wr_d <= fifo1_out(281 downto 26);
app_addr <= fifo1_out(25 downto 1) & "000";
app_wr_dm <= (others => '0');


data_to_ddr <= lift_data_to_ddr when lift_active = '1' else bram_data_to_ddr;
address_tag_out <= ddr_address_ddr_i_100(12 downto 9) & ddr_address_ddr_i_100(3 downto 0);
fifo1_in <= address_tag_out(7 downto 4) &  data_to_ddr(239 downto 180) & address_tag_out(3 downto 0) & data_to_ddr(179 downto 120) & "1111" & data_to_ddr(119 downto 60) & "1111" & data_to_ddr(59 downto 0) & ddr_address_ddr_i_100 & ddr_wen_ddr_i_100;
fifo2_in <= app_rd_d;
address_tag_in <= fifo2_out(255 downto 252) & fifo2_out(191 downto 188);

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- DDR3 MIG & CLOCKING
-------------------------------------------------------------------------------
    
DDR_MEM: component ddr_dummy	port map(
						clk => clock_200, 
						rst => reset_outside, 
						app_rdy => app_rdy, 
						app_rd_dv => app_rd_dv, 
						app_rd_dl => app_rd_dl, 
						app_wdf_rdy => app_wr_rdy, 
						app_en => app_en, 
						app_cmd => app_cmd, 
						app_wr_dl => app_wr_dl, 
						app_wr_dv => app_wr_dv, 
						address_ddr => app_addr,
						ddr_din => app_wr_d, 
						ddr_dout =>app_rd_d
						);	 

 
	 
	 
	 
----------------------------------------------------------------------------
-- Ethernet Core
----------------------------------------------------------------------------	 

--eth_interface: component ETH_toplevel_direct port map(
--								reset => reset, 
--								clk_ref_p => clk_ref_p, 
--								clk_ref_n => clk_ref_n, 
--								clk_from_ddr => clk_from_ddr,
--								
--								GPIO_DIPS => GPIO_DIPS, 
--								GPIO_BUTTONS => GPIO_BUTTONS, 
--								GPIO_LEDS => GPIO_LEDS_eth,
--								
--								PHY_MDC => PHY_MDC, 
--								PHY_MDIO => PHY_MDIO, 
--								PHY_COL => PHY_COL,
--								PHY_CRS => PHY_CRS, 
--								PHY_DV => PHY_DV, 
--								PHY_RESET_n => PHY_RESET_n, 
--								PHY_RXCLK => PHY_RXCLK, 
--								PHY_RXD => PHY_RXD, 
--								PHY_RXER => PHY_RXER,
--								PHY_TXC_GTXCLK => PHY_TXC_GTXCLK, 
--								PHY_TXCLK => PHY_TXCLK, 
--								PHY_TXD => PHY_TXD, 
--								PHY_TXEN => PHY_TXEN, 
--								PHY_TXER => PHY_TXER, 
--								serial_response_pr => serial_response_pr,
--								clk_200MHz => clk_200MHz,
--								
--								clock_100 => clock_100,
--								interrupt_eth => interrupt_eth, 
--								address_eth => address_eth, 
--								web_eth => web_eth, 
--								dinb_eth => dinb_eth, 
--								doutb_eth => doutb_eth,
--								instruction_eth => instruction_eth,
--								operand_eth => operand_eth,
--								test_wire => test_wire
--							);



	 

	 

end Behavioral;	 
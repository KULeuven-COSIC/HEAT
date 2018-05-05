library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

use work.PKG_memiface.ALL;
use work.PKG_demo.ALL;


------






------ 

entity ddr_eth_fifo is
    Port ( 
			  reset 	  : in  STD_LOGIC;
           clk_ref_p : in  STD_LOGIC;
           clk_ref_n : in  STD_LOGIC;
           
           -- GPIO
           GPIO_LEDS : out  STD_LOGIC_VECTOR (7 downto 0);
           GPIO_DIPS : in  STD_LOGIC_VECTOR (7 downto 0);
           
           -- UART
           --UART_RX : in STD_LOGIC;
           --UART_TX : out STD_LOGIC;
           
           -- DDR3 memory
           ddr3_dq       : inout std_logic_vector(C_MIG_DQ_WIDTH-1 downto 0);
           ddr3_dm       : out   std_logic_vector(C_MIG_DM_WIDTH-1 downto 0);
           ddr3_addr     : out   std_logic_vector(C_MIG_ROW_WIDTH-1 downto 0);
           ddr3_ba       : out   std_logic_vector(C_MIG_BANK_WIDTH-1 downto 0);
           ddr3_ras_n    : out   std_logic;
           ddr3_cas_n    : out   std_logic;
           ddr3_we_n     : out   std_logic;
           ddr3_reset_n  : out   std_logic;
           ddr3_cs_n     : out   std_logic_vector((C_MIG_CS_WIDTH*C_MIG_nCS_PER_RANK)-1 downto 0);
           ddr3_odt      : out   std_logic_vector((C_MIG_CS_WIDTH*C_MIG_nCS_PER_RANK)-1 downto 0);
           ddr3_cke      : out   std_logic_vector(C_MIG_CKE_WIDTH-1 downto 0);
           ddr3_dqs_p    : inout std_logic_vector(C_MIG_DQS_WIDTH-1 downto 0);
           ddr3_dqs_n    : inout std_logic_vector(C_MIG_DQS_WIDTH-1 downto 0);
           ddr3_ck_p     : out   std_logic_vector(C_MIG_CK_WIDTH-1 downto 0);
           ddr3_ck_n     : out   std_logic_vector(C_MIG_CK_WIDTH-1 downto 0);
			  
			  -- Eth interface
			  --sysclk_p		 	: in  STD_LOGIC;	-- mapped to clk_ref_p
			  --sysclk_n		 	: in  STD_LOGIC;	-- mapped to clk_ref_n
			  GPIO_BUTTONS  	: in std_logic_vector(4 downto 0);
			  PHY_MDC 		 	: out  STD_LOGIC;	
			  PHY_MDIO      	: inout STD_LOGIC;
			  PHY_COL 		 	: in  STD_LOGIC;	
			  PHY_CRS 		 	: in  STD_LOGIC;	
			  PHY_DV 		 	: in  STD_LOGIC;
			  PHY_RESET_n   	: out  STD_LOGIC;
			  PHY_RXCLK 	 	: in  STD_LOGIC;	
			  PHY_RXER 		 	: in  STD_LOGIC;
			  PHY_RXD		 	: in std_logic_vector(7 downto 0);
			  PHY_TXC_GTXCLK	: out  STD_LOGIC;
			  PHY_TXCLK			: in  STD_LOGIC;
			  PHY_TXD			: out std_logic_vector(7 downto 0);
			  PHY_TXEN			: out  STD_LOGIC;
			  PHY_TXER			: out  STD_LOGIC;
			  serial_response_pr	: out  STD_LOGIC
    );
end ddr_eth_fifo;



architecture Behavioral of ddr_eth_fifo is
	signal reset_outside, reset_i, reset_ni, clock_200, clock_100, clock_intermediate, clk_ddr_100, clk_80mhz : STD_LOGIC;

	------------- UART signals ----------------------------------------------
	signal rx_e: STD_LOGIC;
	signal UART_RX_re, UART_TX_we, write_buffer, tx_we: STD_LOGIC;
	signal UART_RX_data, UART_TX_data: STD_LOGIC_VECTOR(7 downto 0);

	signal ld_instruction, ld_operand, ld_data : STD_LOGIC;		-- signals to store instruction, operand and data from UART
	signal instruction, operand: STD_LOGIC_VECTOR(7 downto 0);	-- instruction and operand registers 
	signal data_received_uart, data_transmitted_uart : STD_LOGIC_VECTOR(C_MIG_APP_DATA_WIDTH-1 downto 0);  	-- 256 bit data for UART

	signal web_bram_uart, web_rom_uart : STD_LOGIC;
	signal addrb_bram_uart : STD_LOGIC_VECTOR(10 downto 0); 
	signal addrb_rom_uart : STD_LOGIC_VECTOR(8 downto 0); 
	signal sel_core_group_uart : STD_LOGIC_VECTOR(1 downto 0);
	signal FSM_feedback_uart : STD_LOGIC_VECTOR(7 downto 0); 
	-------------------------------------------------------------------------


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
	signal end_reduction_type : STD_LOGIC;
-- used only: lift_address, lift_we, rst_lift, lift_dv, lift_done

	-------------------------------------------------------------------------


	------------- DDR-ALU FIFO signals --------------------------------------
	signal fifo1_in, fifo1_out : std_logic_vector(281 downto 0);
	signal fifo1_read_en, fifo1_empty, fifo1_almost_empty, fifo1_write_en, fifo1_full, fifo1_almost_full : std_logic;

	signal fifo2_in, fifo2_out : std_logic_vector(255 downto 0);
	signal fifo2_read_en, fifo2_empty, fifo2_almost_empty, fifo2_write_en, fifo2_full, fifo2_almost_full : std_logic;
   signal reset_fifo_eth : std_logic;
	signal ddr_interrupt : std_logic;
	signal bram_data_from_ddr, bram_data_to_ddr : std_logic_vector(239 downto 0);
   signal data_to_ddr : std_logic_vector(239 downto 0);
	
	-- DDR Master signals
	signal bram_address_ddr_i_100 : std_logic_vector(8 downto 0);
	signal bram_wen_ddr_i_100, ddr_wen_ddr_i_100 : std_logic;
	signal ddr_address_ddr_i_100 : std_logic_vector(24 downto 0);
	signal done_ddr_i_100 : std_logic;
	signal done_ddr : std_logic;
	signal ddr_base_address_out : std_logic_vector(7 downto 0);
	
	-- DDR Slave signals
	signal ddr_wen_200 : std_logic;
	signal address_tag_out, address_tag_in : std_logic_vector(7 downto 0);
	
	-- Ethernet signals
	signal GPIO_LEDS_eth : std_logic_vector (7 downto 0);
	signal clk_200MHz, clk_from_ddr, clk_90MHz : std_logic;
	signal interrupt_eth, web_eth, wep_eth : std_logic; 
	signal address_eth : std_logic_vector (10 downto 0);  
	signal dinb_eth, doutb_eth : STD_LOGIC_VECTOR(59 downto 0);
	signal debug_in : std_logic_vector(3 downto 0);

	signal instruction_eth, instruction_new : STD_LOGIC_VECTOR(7 downto 0);
	signal operand_eth : STD_LOGIC_VECTOR(7 downto 0);
	signal test_wire : STD_LOGIC_VECTOR(5 downto 0);
	
	-- Debug signals
	signal counter : std_logic_vector(27 downto 0);
begin

	reset_outside <= GPIO_DIPS(0);
	--GPIO_LEDS <= phy_init_done_i & counter(27 downto 21);
	--GPIO_LEDS <= interrupt_eth & operand_eth(6 downto 0);
	--GPIO_LEDS <= "00" & test_wire;
	GPIO_LEDS <= "11111111";
	
  	-- 100 MHz clock generation
	CLD_DIV2: process(clock_200)
	begin
		if rising_edge(clock_200) then
			if reset_outside = '1' then 
					clock_intermediate <= '0';
			else
					clock_intermediate <= not(clock_intermediate);
			end if;
		end if;
	end process;
	
	tt_sujoy1: component BUFG_sujoy port map(
		I => clock_intermediate,
      O => clock_100     
     );
	 
	 
	--clock_100 <= clk_90MHz;
   --clock_100 <= clk_80mhz;
  	-- store done_ddr
	dn_ddr: process(clock_100)
	begin
		if rising_edge(clock_100) then
			if reset_outside = '1' then 
					done_ddr <= '0';
			--elsif instruction_new = x"00" then 
			--		done_ddr <= '0';
			elsif done_ddr_i_100 = '1' then 
					done_ddr <= '1';
			else
					done_ddr <= done_ddr;
			end if;
		end if;
	end process;	
	debug_in <= done_ddr & "000";

  	-- 100 MHz counter
	--COUNT_TEST: process(clock_100)
	--begin
	--	if rising_edge(clock_100) then
	--		if reset_outside = '1' then 
	--				counter <= x"0000000";
	--		else
	--				counter <= counter  + '1';
	--		end if;
	--	end if;
	--end process;
	

-------------------------------------------------------------------------------
-- 										UART 
-------------------------------------------------------------------------------
--  UART_TX_data <= data_transmitted_uart(7 downto 0);
--  UART_TX_we <= tx_we;
--  
--  completeUART_inst00: component completeUART 
--    generic map ( CLK_FREQ => C_UART_CLK_FREQ, BAUD_RATE => C_UART_BAUD_RATE, DATA_BITS => C_UART_DATA_BITS)
--    port map( reset => reset_outside, clock => clock_100, 
--          rx_req => UART_RX_re, rx_data => UART_RX_data, rx_pin => UART_RX, rx_e => rx_e, 
--          tx_req => UART_TX_we, tx_data => UART_TX_data, tx_pin => UART_TX);
--
--  UART_FSM: component demo_toplevel_FSM port map(
--			 clock => clock_100,
--			 reset => reset_outside,
--			 rx_e => rx_e,
--			 instruction => instruction,
--
--			 -- UART Rx: instruction, operand and data load
--			 rx_re => UART_RX_re,
--			 ld_instruction => ld_instruction,
--			 ld_operand => ld_operand,
--			 ld_data => ld_data,
--
--			 -- UART Tx
--			 write_buffer => write_buffer,
--			 tx_we => tx_we,
--			 
--			 -- Control CORE-Memory
--			 web_bram => web_bram_uart,
--			 web_rom => web_rom_uart,
--			 addrb_bram => addrb_bram_uart,
--			 addrb_rom => addrb_rom_uart,
--			 sel_core_group => sel_core_group_uart,
--
--			 -- debug signals
--			 feedback => FSM_feedback_uart
--		);
--
--  PREG1: process(clock_100)
--  begin
--    if rising_edge(clock_100) then
--        if write_buffer = '1' then 
--				data_transmitted_uart <= doutb_top;
--        elsif tx_we = '1' then 
--				data_transmitted_uart <= x"EB" & data_transmitted_uart(C_MIG_APP_DATA_WIDTH-1 downto 8);
--        end if;
--    end if;
--  end process;
--
--  PREG2: process(clock_100)
--  begin
--    if rising_edge(clock_100) then
--      if reset_outside = '1' then 
--        instruction <= (others => '0');
--        operand <= (others => '0');
--      else
--		  if ld_instruction = '1' then instruction <= UART_RX_data; end if;
--		  if ld_operand = '1' then operand <= UART_RX_data; end if;
--		  if ld_data = '1' then data_received_uart <= UART_RX_data & data_received_uart(C_MIG_APP_DATA_WIDTH-1 downto 8); end if;
--      end if;
--    end if;
--  end process;  
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- 										Instruction Decoder
-------------------------------------------------------------------------------

--	instruction_new <= instruction_eth when interrupt_eth = '0' else x"00";
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

processor_sel <= processor_sel_MSP when start_eth = '1' else operand_eth(7 downto 5);
--top_mem_sel	<= memory_sel_MSP when start_eth = '1' else operand_eth(0); -- original

top_mem_sel	<= memory_sel_MSP when start_eth = '1' else operand_eth(3 downto 0); -- original
rdM0 <= operand1_MSP(3 downto 0);
rdM1 <= operand1_MSP(7 downto 4);
wtM0 <= operand2_MSP(3 downto 0);
wtM1 <= operand2_MSP(7 downto 4);


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
							
							

--addrb_bram_eth <= "00" & address_eth; 
--sel_core_group_eth <= "00";		
--dinb_top_eth <= "0000" & dinb_eth & "0000" & dinb_eth & "0000" & dinb_eth & "0000" & dinb_eth;
--doutb_eth <= doutb_top(59 downto 0);
--
--addrb_top <= bram_address_ddr_i_100 when rst_ddr_pol = '0' else addrb_bram_eth when interrupt_eth = '1' else addrb_bram_uart;
--dinb_top <= fifo2_out when rst_ddr_pol = '0' else dinb_top_eth when interrupt_eth = '1' else data_received_uart;
--dinb_top_additional <= fifo2_out(59 downto 0);
--sel_core_group_top <= core_group_ddr_i_100 when rst_ddr_pol = '0' else sel_core_group_eth when interrupt_eth = '1' else sel_core_group_uart;
--web_top <= bram_wen_ddr_i_100 when rst_ddr_pol = '0' else web_eth when interrupt_eth = '1' else web_bram_uart;

--addrb_bram_eth <= "00" & address_eth; 
--sel_core_group_eth <= "00";		
--dinb_top_eth <= "0000" & dinb_eth & "0000" & dinb_eth & "0000" & dinb_eth & "0000" & dinb_eth;
--doutb_eth <= doutb_top(59 downto 0);

dinb_top <= fifo2_out when rst_ddr_pol = '0' else data_received_uart;
dinb_top_additional <= fifo2_out(59 downto 0);
web_top <= bram_wen_ddr_i_100 when rst_ddr_pol = '0' else web_bram_uart;

crt_special_load <= '0';
core_index <= "000";

							
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- 										LIFT CORE 
-------------------------------------------------------------------------------


--lift_inst00: component lift_wrapper port map(
--                            clk => clock_100, 
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

-------------------------------------------------------------------------------
-- 									DDR Interfacing using FIFOs 
-------------------------------------------------------------------------------
reset_fifo_eth <= '1' when instruction = x"03" else '0';

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

--ddr_i_100: component ddr_iface_100MHz port map(
--                      clk_100 => clock_100, 
--							 rst => rst_ddr_pol, 
--							 instruction => instruction_new,
--							 ddr_base_address_in => operand_eth, --operand, 
--							 
--							 -- signals for ALU-Memory
--                      bram_address => bram_address_ddr_i_100, 
--							 bram_wen => bram_wen_ddr_i_100,
--							 ddr_address => ddr_address_ddr_i_100, 
--							 ddr_wen => ddr_wen_ddr_i_100,
--			
--							 -- Signals for FIFOs
--							 fifo_read_en => fifo2_read_en, 
--							 fifo_read_empty => fifo2_empty, 
--							 fifo_write_en => fifo1_write_en, 
--							 fifo_write_almost_full => fifo1_almost_full, 
--							 fifo_write_full => fifo1_full,
--							 
--							 -- data validity check
--							 address_tag_in => address_tag_in,
--							 
--							 done => done_ddr_i_100				 
--							 );

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
--fifo1_in <= doutb_top & ddr_address_ddr_i_100 & ddr_wen_ddr_i_100;
--address_tag_out <= ddr_address_ddr_i_100(3 downto 0);
address_tag_out <= ddr_address_ddr_i_100(12 downto 9) & ddr_address_ddr_i_100(3 downto 0);
--fifo1_in <= address_tag_out & doutb_top(251 downto 0) & ddr_address_ddr_i_100 & ddr_wen_ddr_i_100;
fifo1_in <= address_tag_out(7 downto 4) &  data_to_ddr(239 downto 180) & address_tag_out(3 downto 0) & data_to_ddr(179 downto 120) & "1111" & data_to_ddr(119 downto 60) & "1111" & data_to_ddr(59 downto 0) & ddr_address_ddr_i_100 & ddr_wen_ddr_i_100;
fifo2_in <= app_rd_d;
--address_tag_in <= fifo2_out(255 downto 252);
address_tag_in <= fifo2_out(255 downto 252) & fifo2_out(191 downto 188);
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------













-------------------------------------------------------------------------------
-- DDR3 MIG & CLOCKING
-------------------------------------------------------------------------------
  reset_i <= not(phy_init_done_i);
  reset_ni <= not(reset);

  ddr3ctrl : entity work.mig_37
    generic map (SIM_BYPASS_INIT_CAL => "OFF", CLKOUT_DIVIDE4 => 15)
    port map(
    clk_ref_p         =>   clk_ref_p, -- I
    clk_ref_n         =>   clk_ref_n, -- I
	 
    ddr3_dq           =>   ddr3_dq,
    ddr3_addr         =>   ddr3_addr,
    ddr3_ba           =>   ddr3_ba,
    ddr3_ras_n        =>   ddr3_ras_n,
    ddr3_cas_n        =>   ddr3_cas_n,
    ddr3_we_n         =>   ddr3_we_n,
    ddr3_reset_n      =>   ddr3_reset_n,
    ddr3_cs_n         =>   ddr3_cs_n,
    ddr3_odt          =>   ddr3_odt,
    ddr3_cke          =>   ddr3_cke,
    ddr3_dm           =>   ddr3_dm,
    ddr3_dqs_p        =>   ddr3_dqs_p,
    ddr3_dqs_n        =>   ddr3_dqs_n,
    ddr3_ck_p         =>   ddr3_ck_p,
    ddr3_ck_n         =>   ddr3_ck_n,

    app_cmd => app_cmd, 
    app_addr => app_addr,
    app_en => app_en,    
    app_rdy => app_rdy,
    app_rd_data => app_rd_d,
    app_rd_data_valid => app_rd_dv,
    app_rd_data_end => app_rd_dl,      
    app_wdf_mask => app_wr_dm,      
    app_wdf_rdy => app_wr_rdy,      
    app_wdf_data => app_wr_d,
    app_wdf_wren => app_wr_dv,
    app_wdf_end => app_wr_dl,
    
    tb_rst            =>   open,
    tb_clk            =>   open,
    clk_ahb           =>   open,
    clk100            =>   clk_ddr_100,
	 clk_80mhz         =>   clk_80mhz,   
    clk            	 =>   clock_200,
	 clk_from_ddr      =>   clk_from_ddr,
    phy_init_done     =>   phy_init_done_i,
    iodelay_ctrl_rdy  =>   iodelay_ctrl_rdy_i,
    rst_infra     	 =>   rst_infra_i,
    sys_rst_14        =>   reset_ni -- I
  );    
  
    
	 
	 
	 
	 
	 
	 
	 
	 
----------------------------------------------------------------------------
-- Ethernet Core
----------------------------------------------------------------------------	 


eth_interface: component ETH_toplevel_direct port map(
								reset => reset, 
								clk_ref_p => clk_ref_p, 
								clk_ref_n => clk_ref_n, 
								clk_from_ddr => clk_from_ddr,
								
								GPIO_DIPS => GPIO_DIPS, 
								GPIO_BUTTONS => GPIO_BUTTONS, 
								GPIO_LEDS => GPIO_LEDS_eth,
								
								PHY_MDC => PHY_MDC, 
								PHY_MDIO => PHY_MDIO, 
								PHY_COL => PHY_COL,
								PHY_CRS => PHY_CRS, 
								PHY_DV => PHY_DV, 
								PHY_RESET_n => PHY_RESET_n, 
								PHY_RXCLK => PHY_RXCLK, 
								PHY_RXD => PHY_RXD, 
								PHY_RXER => PHY_RXER,
								PHY_TXC_GTXCLK => PHY_TXC_GTXCLK, 
								PHY_TXCLK => PHY_TXCLK, 
								PHY_TXD => PHY_TXD, 
								PHY_TXEN => PHY_TXEN, 
								PHY_TXER => PHY_TXER, 
								serial_response_pr => serial_response_pr,
								clk_200MHz => clk_200MHz,
								
								clock_100 => clock_100,
								clk_90MHz => clk_90MHz,
								interrupt_eth => interrupt_eth, 
								address_eth => address_eth, 
								web_eth => web_eth, 
								wep_eth => wep_eth,
								dinb_eth => dinb_eth, 
								doutb_eth => doutb_eth,
								instruction_eth => instruction_eth,
								operand_eth => operand_eth,
								test_wire => test_wire,
								debug_in => debug_in
							);




	 

	 

end Behavioral;	 
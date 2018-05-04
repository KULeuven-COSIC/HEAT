library IEEE;
use IEEE.STD_LOGIC_1164.all;

package PKG_demo is

-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;

--
-- Declare constants
--
--  constant SYSCLK_PERIOD : integer := tCK * nCK_PER_CLK;
--  constant DATA_WIDTH    : integer := 64;

--  constant BURST_LENGTH  : integer := STR_TO_INT(BURST_MODE);

  constant C_UART_CLK_FREQ : natural := 100;
  constant C_UART_BAUD_RATE : natural := 115200;
  constant C_UART_DATA_BITS : natural := 8;

--  constant C_MIG_DATA_WIDTH : integer := 64;
--  constant C_MIG_STARVE_LIMIT : integer := 2;

--
-- Declare functions and procedure
--
--  function STR_TO_INT(BM : string) return integer is
--  begin
--   if(BM = "8") then
--     return 8;
--   elsif(BM = "4") then
--     return 4;
--   else
--     return 0;
--   end if;
--  end function;

--
-- Components
--
--  component clk_ibuf
--    generic (
--      INPUT_CLK_TYPE : string
--      );
--    port (
--      sys_clk_p : in  std_logic;
--      sys_clk_n : in  std_logic;
--      sys_clk   : in  std_logic;
--      mmcm_clk  : out std_logic
--      );
--  end component;
--  
--	component iodelay_ctrl
--    generic (
--      TCQ            : integer;
--      IODELAY_GRP    : string;
--      INPUT_CLK_TYPE : string;
--      RST_ACT_LOW    : integer
--      );
--    port (
--      clk_ref_p        : in  std_logic;
--      clk_ref_n        : in  std_logic;
--      clk_ref          : in  std_logic;
--      sys_rst          : in  std_logic;
--      iodelay_ctrl_rdy : out std_logic
--      );
--  end component iodelay_ctrl;
  
  component demo_new is
      Port( clock : in  STD_LOGIC;
            reset : in  STD_LOGIC;
            rx_e : in STD_LOGIC;
            instruction : in STD_LOGIC_VECTOR(7 downto 0);

            ld_instruction : OUT STD_LOGIC;
            ld_operand : OUT STD_LOGIC;
            ld_data : OUT STD_LOGIC;
	    web_bram : OUT STD_LOGIC;
	    web_rom : OUT STD_LOGIC;
	    write_buffer : OUT STD_LOGIC; 
	    addrb_bram : OUT STD_LOGIC_VECTOR(10 downto 0);
	    addrb_rom : OUT STD_LOGIC_VECTOR(8 downto 0);
	    sel_core_group : OUT STD_LOGIC_VECTOR(1 downto 0);			
            rx_re : OUT STD_LOGIC;
            tx_we : OUT STD_LOGIC;
            feedback : OUT STD_LOGIC_VECTOR(7 downto 0));
  end component;
  


--  component operation is
--      Port ( clock: in STD_LOGIC;
--             reset : in  STD_LOGIC;
--             enable : in  STD_LOGIC;
--             data_i : in  STD_LOGIC_VECTOR (7 downto 0);
--             data_o : out  STD_LOGIC_VECTOR (7 downto 0);
--             done : out STD_LOGIC);
--  end component;
  
  component completeUART is
    generic ( CLK_FREQ  : natural := 100;     -- system clock frequency in MHz
              BAUD_RATE : natural := 115200; -- desired baud rate
              DATA_BITS : natural := 8);     -- # data bits)
    port( reset   : in  std_logic;
          clock   : in  std_logic;
          rx_req  : in  std_logic;
          rx_data : out std_logic_vector(7 downto 0);
          rx_pin  : in  std_logic;
          rx_e  : out  std_logic;
          tx_req  : in  std_logic;
          tx_data : in  std_logic_vector(7 downto 0);
          tx_pin  : out  std_logic
    );
  end component;
 component BUFG_sujoy
  port (
  	I   : in std_logic;
        O   : out std_logic
	); 
end component;
  component fifo_transfer is port(
				 rst : in  std_logic;
				 wr_clk : in  std_logic;
				 rd_clk : in  std_logic;
				 din : in std_logic_vector(255 downto 0);
				 wr_en : in  std_logic;
				 rd_en : in  std_logic;
				 dout : out std_logic_vector(255 downto 0);
				 full : out  std_logic;
				 empty : out std_logic
				);
	end component;

  component ETH_toplevel_direct is port(
            reset : in std_logic;
 	         clk_ref_p : in std_logic; 
            clk_ref_n : in std_logic; 
	    clk_from_ddr : in std_logic;
 								
				GPIO_DIPS : in std_logic_vector(7 downto 0);  
            GPIO_BUTTONS : in std_logic_vector(4 downto 0); 
            GPIO_LEDS : out std_logic_vector(7 downto 0);
								
            PHY_MDC : out std_logic; 
            PHY_MDIO : inout std_logic; 
            PHY_COL : in std_logic; 
            PHY_CRS : in std_logic; 
            PHY_DV : in std_logic; 

            PHY_RESET_n : out std_logic; 
				PHY_RXCLK : in std_logic;
				PHY_RXER : in std_logic; 
            PHY_RXD : in std_logic_vector(7 downto 0);   
       	  	PHY_TXC_GTXCLK : out std_logic; 
            PHY_TXCLK : in std_logic; 
				PHY_TXD : out std_logic_vector(7 downto 0); 
				PHY_TXEN : out std_logic; 
            PHY_TXER : out std_logic; 
	    serial_response_pr : out std_logic;
	    clk_200MHz : out std_logic;
	    clock_100 : in std_logic;	
	    clk_90MHz : out std_logic;
	    interrupt_eth : out std_logic; 
	    address_eth : out std_logic_vector(10 downto 0); 
	    web_eth : out std_logic; 
            wep_eth : out std_logic;
	    dinb_eth : out std_logic_vector(59 downto 0); 
	    doutb_eth : in std_logic_vector(59 downto 0);
            instruction_eth : out std_logic_vector(7 downto 0);
	    operand_eth : out std_logic_vector(7 downto 0);
	    test_wire : out std_logic_vector(5 downto 0);
	    debug_in : in std_logic_vector(3 downto 0)	
	   );
  end component;



component instruction_gen is 
		port(
                      clk : in std_logic; 
		      start_eth : in std_logic;
		      program_data_eth : in std_logic_vector(59 downto 0);
		      program_address_eth : in std_logic_vector(10 downto 0); 
		      program_data_load_eth : in std_logic;
							  
                      instruction : out std_logic_vector(7 downto 0); 
		      operand1 : out std_logic_vector(7 downto 0);
		      operand2 : out std_logic_vector(7 downto 0);
		      processor_sel : out std_logic_vector(2 downto 0);  
                      memory_sel : out std_logic_vector(3 downto 0);
                      modulus_sel : out std_logic;	
		      instruction_computation_executed : in std_logic;
		      instruction_ddr_executed : in std_logic
		);
  end component;

-- component BRAM_wrapper is 
--	port(
--		clka : in std_logic;
--		wea : in std_logic;
--		addra : in std_logic_vector(10 downto 0);
--		dina : in std_logic_vector(59 downto 0);
--		douta : out std_logic_vector(59 downto 0);
--							
--		clkb : in std_logic;
--		web : in std_logic;
--		addrb : in std_logic_vector(7 downto 0);
--		dinb : in std_logic_vector(255 downto 0);
--		doutb : out std_logic_vector(255 downto 0)
--	 );
-- end component;

component fifo_100_to_200_module is 
	port(
		 rst : in  std_logic; 
		 wr_clk : in  std_logic; 
		 rd_clk : in  std_logic;
		 din : in std_logic_vector (281 downto 0);	
		 wr_en  : in  std_logic;
		 rd_en  : in  std_logic;
		 dout : out std_logic_vector (281 downto 0);
		 full : out  std_logic;
		 almost_full : out  std_logic;
		 empty : out  std_logic;
		 almost_empty : out  std_logic
	);
  end component;

component fifo_200_to_100 is 
	port(
		 rst : in  std_logic; 
		 wr_clk : in  std_logic; 
		 rd_clk : in  std_logic;
		 din : in std_logic_vector (255 downto 0);	
		 wr_en  : in  std_logic;
		 rd_en  : in  std_logic;
		 dout : out std_logic_vector (255 downto 0);
		 full : out  std_logic;
		 almost_full : out  std_logic;
		 empty : out  std_logic;
		 almost_empty : out  std_logic
	);
  end component;
	
  component computation is 
	port(
	      clk  : in std_logic; 
	      rst  : in std_logic; 
              addrb_top  : in std_logic_vector(10 downto 0); 
  	      dinb_top  : in std_logic_vector (255 downto 0); 
	      dinb_top_additional : in std_logic_vector (59 downto 0);	
	      sel_core_group : in std_logic_vector (1 downto 0);	
	      web_top  : in std_logic;
	      
		
	      crt_special_load : in std_logic;
	      sel_core_index : in std_logic_vector (2 downto 0);	
						
 	      doutb_top  : out std_logic_vector(255 downto 0);
	      interrupt_eth : in std_logic;		
 	      address_eth : in std_logic_vector(14 downto 0);
 	      dinb_eth : in std_logic_vector(59 downto 0); 
	      web_eth : in std_logic; 
	      doutb_eth : out std_logic_vector(59 downto 0);

 	      done  : out std_logic
	);
   end component;	

  component computation_new is 
	port(
	      	clk  : in std_logic; 
	      	rst  : in std_logic; 

		interrupt_eth : in std_logic;
		processor_sel : in std_logic_vector(2 downto 0);
		address_eth : in std_logic_vector(10 downto 0);
		dinb_eth : in std_logic_vector(59 downto 0);
		web_eth : in std_logic;
		doutb_eth : out std_logic_vector(59 downto 0);
		top_mem_sel: in std_logic;
		done : out std_logic
	);
   end component;


  component PROCESSOR_POLY is 
	port(
	      	clk  : in std_logic;
		modulus_sel : in std_logic; 
	      	instruction  : in std_logic_vector(7 downto 0);

		interrupt_eth : in std_logic;
		processor_sel : in std_logic_vector(2 downto 0);
		address_eth : in std_logic_vector(10 downto 0);
		dinb_eth : in std_logic_vector(59 downto 0);
		web_eth : in std_logic;
		doutb_eth : out std_logic_vector(59 downto 0);

		top_mem_sel: in std_logic_vector(3 downto 0);
		rdM0: in std_logic_vector(3 downto 0);
		rdM1: in std_logic_vector(3 downto 0);
		wtM0: in std_logic_vector(3 downto 0);
		wtM1: in std_logic_vector(3 downto 0);

                ddr_interrupt : in std_logic;
	        ddr_address : in std_logic_vector(8 downto 0); 
                ddr_we : in std_logic;
                ddr_din : in std_logic_vector(239 downto 0); 
                ddr_dout : out std_logic_vector(239 downto 0);

		done : out std_logic
	);
   end component;


   component lift_wrapper is 
          port(
                clk : in std_logic; 
		rst : in std_logic;
                reduction_type : in std_logic;
		top_address : in std_logic_vector(5 downto 0); 
		we : in std_logic; 
		din : in std_logic_vector(239 downto 0); 
		data_type : in std_logic; 
		data_valid : in std_logic;
		read_out : out std_logic_vector(239 downto 0); 
		done : out std_logic
	);
   end component;
		
component ddr_iface_100MHz is 
	port(
             	clk_100 : in std_logic;  
	     	rst : in std_logic;  
	     	instruction : in std_logic_vector(7 downto 0);  
	     	ddr_base_address_in : in std_logic_vector(7 downto 0);
		ddr_base_address_out : in std_logic_vector(7 downto 0);
             	bram_address : out std_logic_vector(8 downto 0);
	     	bram_wen : out std_logic;  
                lift_address : out std_logic_vector(5 downto 0); 
                lift_we : out std_logic;
	     	ddr_address : out std_logic_vector(24 downto 0);
		ddr_wen : out std_logic;  

		fifo_read_en : out std_logic;
		fifo_read_empty : in std_logic;  
		fifo_write_en : out std_logic;  
		fifo_write_almost_full : in std_logic;  
		fifo_write_full : in std_logic;  
		address_tag_in : in std_logic_vector(7 downto 0);
		rst_lift : out std_logic;
                lift_dv : out std_logic; 
                lift_done : in std_logic;

		done : out std_logic		 
	);
   end component;	

component ddr_iface_200Mhz is	
	port(
		clk_200 : in std_logic;  
		rst : in std_logic; 
		fifo_read_en : out std_logic; 
		fifo_read_empty : in std_logic; 
		--fifo_read_almost_empty : in std_logic;
		fifo_write_en : out std_logic; 
		fifo_write_almost_full: in std_logic; 
		ddr_wen : in std_logic; 
				
		app_rdy : in std_logic; 
		app_rd_dl : in std_logic;  
		app_wdf_rdy: in std_logic; 

		app_en : out std_logic; 
		app_wr_dv : out std_logic; 
		app_wr_dl : out std_logic; 
		app_cmd : out std_logic_vector(2 downto 0)
	);
  end component;

  component computation_old is 
	port(
	      clk  : in std_logic; 
	      rst  : in std_logic; 
	      addrb_top  : in std_logic_vector(10 downto 0); 
  	      dinb_top  : in std_logic_vector (255 downto 0); 
	      dinb_top_additional : in std_logic_vector (59 downto 0);	
	      sel_core_group : in std_logic_vector (1 downto 0);	
	      web_top  : in std_logic;
	      fifo_en_top : in std_logic;
		
	      crt_special_load : in std_logic;
	      sel_core_index : in std_logic_vector (2 downto 0);	
						
 	      doutb_top  : out std_logic_vector(255 downto 0);
 	      done  : out std_logic
	);
   end component;

component BUFGMUX 
  port (
  	I0   : in std_logic;
        I1   : in std_logic;
        S    : in std_logic;
        O    : out std_logic
	); 
end component;

component BUFGCTRL 
    	generic (
		 INIT_OUT : natural;  
		 PRESELECT_I0 : boolean; 
		 PRESELECT_I1 : boolean
		);    
	port (  
		O : out std_logic;  
		CE0 : in std_logic;  
		CE1 : in std_logic;  
		I0 : in std_logic;  
		I1 : in std_logic;
		IGNORE0 : in std_logic;  
		IGNORE1 : in std_logic;  
		S0 : in std_logic;  
		S1 : in std_logic  
	);
	end component;



   component top_core_new_wrapper is
	port(
	      	clka : in std_logic;  
	      	clkb : in std_logic;  
              	dinb_top : in std_logic_vector(255 downto 0);
	        fifo_dout : in std_logic_vector(255 downto 0);
		sel_core_group : in std_logic_vector(1 downto 0); 
                sel_core_index : in std_logic_vector(2 downto 0); 
                crt_special_load : in std_logic;
		primesel_top :  in std_logic_vector(6 downto 0);
		addrb_ram : in std_logic_vector(10 downto 0); 
		addrb_rom : in std_logic_vector(8 downto 0); 
		web_ram : in std_logic; 
		web_rom : in std_logic;
		reset_outside : in std_logic;
		rst_cw : in std_logic; 
		rst_ntt : in std_logic; 
		rst_crt : in std_logic;
		ntt_type : in std_logic; 
		crt_type : in std_logic; 
                crt_red_qi : in std_logic;
		inst_cw : in std_logic_vector(1 downto 0);
		crt_input_data_ready : in std_logic;	
	  	dram_read : in std_logic;
		dram_read_additional : in std_logic;	
                index_reverse : in std_logic_vector(14 downto 0); 
                ddr_write_ntt_result : in std_logic;
                ddr_write_crt_result : in std_logic;

                crt_input_data_ready_ack : out std_logic;
	  	data_output : out std_logic_vector(255 downto 0);
                data_output_ntt_result : out std_logic_vector(127 downto 0);
		done_computation : out std_logic;
		mproc_responds : out std_logic;
                test_data : out std_logic_vector(5 downto 0)
	);
  end component; 		

component demo_toplevel_FSM is 
	port(
		clock : in std_logic;
		reset : in std_logic;
		-- decision making input
		rx_e  : in std_logic;
		instruction  : in std_logic_vector(7 downto 0);

		ld_instruction : out std_logic;
		ld_operand  : out std_logic; 
		ld_data  : out std_logic;
		web_bram  : out std_logic; 
		web_rom  : out std_logic; 
		write_buffer  : out std_logic; 
		addrb_bram : out std_logic_vector(10 downto 0); 
		addrb_rom  : out std_logic_vector(8 downto 0);  
		sel_core_group  : out std_logic_vector(1 downto 0); 
		
		rx_re : out std_logic; 
		tx_we : out std_logic;
		feedback : out std_logic_vector(7 downto 0)
	);
  end component;	

component ddr_dummy is 
	port(
		clk : in std_logic;
		rst : in std_logic;

		app_rdy, app_rd_dv, app_rd_dl, app_wdf_rdy : out std_logic;
		address_ddr : in std_logic_vector(27 downto 0);
		app_en, app_wr_dl, app_wr_dv : in std_logic;
		app_cmd : in std_logic_vector(2 downto 0);
		ddr_din : in std_logic_vector(255 downto 0);
		ddr_dout : out std_logic_vector(255 downto 0)
	);
  end component; 


  component BRAM_DDR_combined is
	port(	
		clk : in std_logic;
		reset_outside : in std_logic;
		rst_in : in std_logic;
		ins : in std_logic_vector(7 downto 0);
		address_base : in std_logic_vector(7 downto 0);	
						
		app_rdy : in std_logic;
		app_rd_dl : in std_logic; 
		app_wdf_rdy : in std_logic;
		ddr_read_data_nonzero : in std_logic;
		
		-- UI Inputs
		app_en : out std_logic;
		output_selector : out std_logic;
		app_wr_dv : out std_logic;
		app_wr_dl : out std_logic; 
		app_cmd : out std_logic_vector(2 downto 0);
		address_ddr : out std_logic_vector(24 downto 0); 
		address_bram : out std_logic_vector(12 downto 0);
		web : out std_logic;
		ld_ddr_i : out std_logic;
		ld_ddr_o : out std_logic;
		done_ddr : out std_logic;
		feedback : out std_logic_vector(7 downto 0)
	);
  end component; 

  component BRAM_DDR_interface_pol_crt is
	port(	
		clk_comp : in std_logic;
		clk_ddr : in std_logic;
		reset_outside : in std_logic;
		rst_pol : in std_logic;
		rst_ddr_crt : in std_logic;
		ins : in std_logic_vector(7 downto 0);
		address_base_in : in std_logic_vector(7 downto 0);	
		done_computation : in std_logic;
		rst_crt : out std_logic;
				
		app_rdy : in std_logic;
		app_rd_dl : in std_logic; 
		app_wdf_rdy : in std_logic;
		ddr_read_data_nonzero : in std_logic;
		
		-- UI Inputs
		app_en : out std_logic;
		output_selector : out std_logic;
		app_wr_dv : out std_logic;
		app_wr_dl : out std_logic; 
		app_cmd : out std_logic_vector(2 downto 0);

		address_ddr : out std_logic_vector(24 downto 0); 
		address_bram : out std_logic_vector(12 downto 0);
		web : out std_logic;
		ld_ddr_i : out std_logic_vector(1 downto 0);
		ld_ddr_o : out std_logic;
                index_reverse : out std_logic_vector(14 downto 0); 
                ddr_write_ntt_result : out std_logic;
		done_ddr : out std_logic;
		feedback : out std_logic_vector(7 downto 0);
		
		bram_address_from_ddr_crt : out std_logic_vector(10 downto 0);
		core_index_crt : out std_logic_vector(2 downto 0);
		address_base_offset_odd_crt : out std_logic;
		sel_core_group_from_ddr_crt : out std_logic_vector(1 downto 0);
		shift_ddr_o_crt : out std_logic;
		crt_input_data_ready_crt : out std_logic;
		crt_input_data_ready_ack_crt : in std_logic;
		fifo_empty : in std_logic; 
		fifo_rd_en : out std_logic	
	);
  end component; 
	
  component BRAM_DDR_interface is
	port(	
		clk : in std_logic;
		reset_outside : in std_logic;
		rst : in std_logic;
		instruction : in std_logic_vector(7 downto 0);
		address_base : in std_logic_vector(7 downto 0);	
						
		app_rdy : in std_logic;
		app_rd_dl : in std_logic; 
		app_wdf_rdy : in std_logic;
		ddr_read_data_nonzero : in std_logic;
		
		-- UI Inputs
		app_en : out std_logic;
		output_selector : out std_logic;
		app_wr_dv : out std_logic;
		app_wr_dl : out std_logic; 
		app_cmd : out std_logic_vector(2 downto 0);
		address_ddr : out std_logic_vector(24 downto 0); 
		address_ddr_offset : out std_logic_vector(12 downto 0);
		web : out std_logic;
		ld_ddr_i : out std_logic;
		ld_ddr_o : out std_logic;
		done_ddr : out std_logic;
		feedback : out std_logic_vector(7 downto 0)
	);
  end component; 

  component CRT_interface is
	port(	
		clk : in std_logic;
		reset_outside : in std_logic;
		rst : in std_logic;
		instruction : in std_logic_vector(7 downto 0);
		address_base_input : in std_logic_vector(7 downto 0);	
						
		app_rdy : in std_logic;
		app_rd_dl : in std_logic; 
		app_wdf_rdy : in std_logic;
		ddr_read_data_nonzero : in std_logic;

		-- UI Inputs
		app_en : out std_logic;
		output_selector : out std_logic;
		app_wr_dv : out std_logic;
		app_wr_dl : out std_logic; 
		app_cmd : out std_logic_vector(2 downto 0);
		address_ddr_new : out std_logic_vector(24 downto 0); 
		address_ddr_offset : out std_logic_vector(12 downto 0);
		web : out std_logic;
		ld_ddr_i : out std_logic;
		ld_ddr_o : out std_logic;
		done_ddr : out std_logic;
		feedback : out std_logic_vector(7 downto 0);

		bram_address_from_ddr : out std_logic_vector(10 downto 0);
		core_index : out std_logic_vector(2 downto 0);
		address_base_offset_odd : out std_logic;
		sel_core_group_from_ddr : out std_logic_vector(1 downto 0);
 		shift_ddr_o : out std_logic;
                crt_input_data_ready : out std_logic; 
                crt_input_data_ready_ack : in std_logic
	);
  end component;

  component clocking is
      Port ( reset_i : in  STD_LOGIC;
             clock_p : in  STD_LOGIC;
             clock_n : in  STD_LOGIC;
             clock_100MHz : out  STD_LOGIC;
             clock_200MHz_nobuf : out  STD_LOGIC;
             reset_o : out  STD_LOGIC);
  end component;
  
  component MMCM
  port
   (-- Clock in ports
    CLOCK_P         : in     std_logic;
    CLOCK_N         : in     std_logic;
    -- Clock out ports
    CLK_100MHz          : out    std_logic;
    CLK_200MHz_nobuf    : out    std_logic;
    -- Status and control signals
    reset             : in     std_logic;
    locked            : out    std_logic
   );
  end component;

end PKG_demo;

package body PKG_demo is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end PKG_demo;

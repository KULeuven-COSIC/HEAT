library IEEE;
use IEEE.STD_LOGIC_1164.all;

package PKG_memiface is

-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;

-- Declare constants
  constant C_MIG_INPUT_CLK_TYPE : string := "SINGLE_ENDED";
  constant C_MIG_TCQ : integer := 100;
  constant C_MIG_IODELAY_GRP : string := "IODELAY_MIG";
  constant C_MIG_RST_ACT_LOW : integer := 1;
  
  constant C_MIG_nCK_PER_CLK : integer := 2;
  constant C_MIG_tCK : integer := 2500;
  constant C_MIG_SYSCLK_PERIOD : integer := C_MIG_tCK * C_MIG_nCK_PER_CLK;
  constant C_MIG_MMCM_ADV_BANDWIDTH : string  := "OPTIMIZED";  
  constant C_MIG_CLKFBOUT_MULT_F : integer := 6;  
  constant C_MIG_DIVCLK_DIVIDE : integer := 2;
  constant C_MIG_CLKOUT_DIVIDE : integer := 3;
  
  constant C_MIG_ADDR_CMD_MODE : string := "1T" ;
  constant C_MIG_BANK_WIDTH : integer := 3;
  constant C_MIG_CK_WIDTH : integer := 1;
  constant C_MIG_CKE_WIDTH : integer := 1;
  constant C_MIG_COL_WIDTH : integer := 10;
  constant C_MIG_CS_WIDTH : integer := 1;
  constant C_MIG_DM_WIDTH : integer := 8;
  constant C_MIG_nCS_PER_RANK : integer := 1;
  constant C_MIG_DEBUG_PORT : string := "OFF";
  constant C_MIG_DQ_WIDTH : integer := 64;
  constant C_MIG_DQS_WIDTH : integer := 8;
  constant C_MIG_DQS_CNT_WIDTH : integer := 3;
  constant C_MIG_ORDERING : string := "STRICT";
  constant C_MIG_OUTPUT_DRV : string := "HIGH";
  constant C_MIG_PHASE_DETECT : string := "ON";
  constant C_MIG_RANK_WIDTH : integer := 1;
  constant C_MIG_REFCLK_FREQ : real := 200.0;
  constant C_MIG_REG_CTRL : string := "OFF";
  constant C_MIG_ROW_WIDTH : integer := 14;
  constant C_MIG_RTT_NOM : string := "60";
  constant C_MIG_RTT_WR : string := "OFF";
  constant C_MIG_SIM_BYPASS_INIT_CAL : string := "OFF";
  constant C_MIG_WRLVL : string := "ON";
  constant C_MIG_nDQS_COL0 : integer := 6;
  constant C_MIG_nDQS_COL1 : integer := 2;
  constant C_MIG_nDQS_COL2 : integer := 0;
  constant C_MIG_nDQS_COL3 : integer := 0;
  constant C_MIG_DQS_LOC_COL0 : std_logic_vector(47 downto 0) := X"050403020100";
  constant C_MIG_DQS_LOC_COL1 : std_logic_vector(15 downto 0) := X"0706";
  constant C_MIG_DQS_LOC_COL2 : std_logic_vector(0 downto 0) := "0";
  constant C_MIG_DQS_LOC_COL3 : std_logic_vector(0 downto 0) := "0";
  constant C_MIG_BURST_MODE : string := "8";
  constant C_MIG_BM_CNT_WIDTH : integer := 2;
  constant C_MIG_tPRDI : integer := 1000000;
  constant C_MIG_tREFI : integer := 7800000;
  constant C_MIG_tZQI : integer := 128000000;
  constant C_MIG_ADDR_WIDTH : integer := 28;
  constant C_MIG_ECC : string := "OFF";
  constant C_MIG_ECC_TEST : string := "OFF";
  constant C_MIG_PAYLOAD_WIDTH : integer := 64;
  constant C_MIG_APP_DATA_WIDTH : integer := C_MIG_PAYLOAD_WIDTH * 4;
  constant C_MIG_APP_MASK_WIDTH : integer := C_MIG_APP_DATA_WIDTH / 8;
     
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
--

  component clk_ibuf is
    generic(
      INPUT_CLK_TYPE : string := "DIFFERENTIAL"
      );
    port(
      -- Clock inputs
      sys_clk_p : in  std_logic; -- System clock diff input
      sys_clk_n : in  std_logic;
      sys_clk   : in  std_logic;
      mmcm_clk  : out std_logic
      );
  end component;

  component iodelay_ctrl is
    generic (
      TCQ            : integer := 100;         -- clk->out delay (sim only)
      IODELAY_GRP    : string  := "IODELAY_MIG";  -- May be assigned unique name when
                                                  -- multiple IP cores used in design
      INPUT_CLK_TYPE : string  := "DIFFERENTIAL"; -- input clock type
                                                  -- "DIFFERENTIAL","SINGLE_ENDED"
      RST_ACT_LOW    : integer := 1               -- Reset input polarity
                                                  -- (0 = active high, 1 = active low)
      );
    port (
      clk_ref_p        : in  std_logic;
      clk_ref_n        : in  std_logic;
      clk_ref          : in  std_logic;
      sys_rst          : in  std_logic;
      iodelay_ctrl_rdy : out std_logic
      );
  end component;
  
  component infrastructure
    generic (
     TCQ                : integer;
     CLK_PERIOD         : integer;
     nCK_PER_CLK        : integer;
     MMCM_ADV_BANDWIDTH : string;
     CLKFBOUT_MULT_F    : integer;
     DIVCLK_DIVIDE      : integer;
     CLKOUT_DIVIDE      : integer;
     RST_ACT_LOW        : integer
     );
    port (
     clk_mem          : out std_logic;
     clk              : out std_logic;
     clk_rd_base      : out std_logic;
     rstdiv0          : out std_logic;
     mmcm_clk         : in  std_logic;
     sys_rst          : in  std_logic;
     iodelay_ctrl_rdy : in  std_logic;
     PSDONE           : out std_logic;
     PSEN             : in  std_logic;
     PSINCDEC         : in  std_logic
     );
  end component infrastructure;
  
  component memc_ui_top
    generic(
      REFCLK_FREQ           : real;
      SIM_BYPASS_INIT_CAL   : string;
      IODELAY_GRP           : string;
      nCK_PER_CLK           : integer;
      nCS_PER_RANK          : integer;
      DQS_CNT_WIDTH         : integer;
      RANK_WIDTH            : integer;
      BANK_WIDTH            : integer;
      CK_WIDTH              : integer;
      CKE_WIDTH             : integer;
      COL_WIDTH             : integer;
      CS_WIDTH              : integer;
      DQ_WIDTH              : integer;
      DM_WIDTH              : integer;
      DQS_WIDTH             : integer;
      ROW_WIDTH             : integer;
      BURST_MODE            : string;
      BM_CNT_WIDTH          : integer;
      ADDR_CMD_MODE         : string;
      ORDERING              : string;
      WRLVL                 : string;
      PHASE_DETECT          : string;
      RTT_NOM               : string;
      RTT_WR                : string;
      OUTPUT_DRV            : string;
      REG_CTRL              : string;
      nDQS_COL0             : integer;
      nDQS_COL1             : integer;
      nDQS_COL2             : integer;
      nDQS_COL3             : integer;
      DQS_LOC_COL0          : std_logic_vector(47 downto 0);
      DQS_LOC_COL1          : std_logic_vector(15 downto 0);
      DQS_LOC_COL2          : std_logic_vector(0 downto 0);
      DQS_LOC_COL3          : std_logic_vector(0 downto 0);
      tCK                   : integer;
      DEBUG_PORT            : string;
      tPRDI                 : integer;
      tREFI                 : integer;
      tZQI                  : integer;
      ADDR_WIDTH            : integer;
      TCQ                   : integer;
      ECC                   : string;
      ECC_TEST              : string;
      PAYLOAD_WIDTH         : integer;
      APP_DATA_WIDTH        : integer;
      APP_MASK_WIDTH        : integer
      );
    port(
      clk                       : in    std_logic;
      clk_mem                   : in    std_logic;
      clk_rd_base               : in    std_logic;
      rst                       : in    std_logic;
      ddr_addr                  : out   std_logic_vector(ROW_WIDTH-1 downto 0);
      ddr_ba                    : out   std_logic_vector(BANK_WIDTH-1 downto 0);
      ddr_cas_n                 : out   std_logic;
      ddr_ck_n                  : out   std_logic_vector(CK_WIDTH-1 downto 0);
      ddr_ck                    : out   std_logic_vector(CK_WIDTH-1 downto 0);
      ddr_cke                   : out   std_logic_vector(CKE_WIDTH-1 downto 0);
      ddr_cs_n                  : out   std_logic_vector(CS_WIDTH*nCS_PER_RANK-1 downto 0);
      ddr_dm                    : out   std_logic_vector(DM_WIDTH-1 downto 0);
      ddr_odt                   : out   std_logic_vector(CS_WIDTH*nCS_PER_RANK-1 downto 0);
      ddr_ras_n                 : out   std_logic;
      ddr_reset_n               : out   std_logic;
      ddr_parity                : out   std_logic;
      ddr_we_n                  : out   std_logic;
      ddr_dq                    : inout std_logic_vector(DQ_WIDTH-1 downto 0);
      ddr_dqs_n                 : inout std_logic_vector(DQS_WIDTH-1 downto 0);
      ddr_dqs                   : inout std_logic_vector(DQS_WIDTH-1 downto 0);
      pd_PSEN                   : out   std_logic;
      pd_PSINCDEC               : out   std_logic;
      pd_PSDONE                 : in    std_logic;
      phy_init_done             : out   std_logic;
      bank_mach_next            : out   std_logic_vector(BM_CNT_WIDTH-1 downto 0);
      app_ecc_multiple_err      : out   std_logic_vector(3 downto 0);
      app_rd_data               : out   std_logic_vector((PAYLOAD_WIDTH*4)-1 downto 0);
      app_rd_data_end           : out   std_logic;
      app_rd_data_valid         : out   std_logic;
      app_rdy                   : out   std_logic;
      app_wdf_rdy               : out   std_logic;
      app_addr                  : in    std_logic_vector(ADDR_WIDTH-1 downto 0);
      app_cmd                   : in    std_logic_vector(2 downto 0);
      app_en                    : in    std_logic;
      app_hi_pri                : in    std_logic;
      app_sz                    : in    std_logic;
      app_wdf_data              : in    std_logic_vector((PAYLOAD_WIDTH*4)-1 downto 0);
      app_wdf_end               : in    std_logic;
      app_wdf_mask              : in    std_logic_vector((PAYLOAD_WIDTH/2)-1 downto 0);
      app_wdf_wren              : in    std_logic;
      app_correct_en            : in    std_logic;
      dbg_wr_dq_tap_set         : in    std_logic_vector(5*DQS_WIDTH-1 downto 0);
      dbg_wr_dqs_tap_set        : in    std_logic_vector(5*DQS_WIDTH-1 downto 0);
      dbg_wr_tap_set_en         : in    std_logic;
      dbg_wrlvl_start           : out   std_logic;
      dbg_wrlvl_done            : out   std_logic;
      dbg_wrlvl_err             : out   std_logic;
      dbg_wl_dqs_inverted       : out   std_logic_vector(DQS_WIDTH-1 downto 0);
      dbg_wr_calib_clk_delay    : out   std_logic_vector(2*DQS_WIDTH-1 downto 0);
      dbg_wl_odelay_dqs_tap_cnt : out   std_logic_vector(5*DQS_WIDTH-1 downto 0);
      dbg_wl_odelay_dq_tap_cnt  : out   std_logic_vector(5*DQS_WIDTH-1 downto 0);
      dbg_rdlvl_start           : out   std_logic_vector(1 downto 0);
      dbg_rdlvl_done            : out   std_logic_vector(1 downto 0);
      dbg_rdlvl_err             : out   std_logic_vector(1 downto 0);
      dbg_cpt_tap_cnt           : out   std_logic_vector(5*DQS_WIDTH-1 downto 0);
      dbg_cpt_first_edge_cnt    : out   std_logic_vector(5*DQS_WIDTH-1 downto 0);
      dbg_cpt_second_edge_cnt   : out   std_logic_vector(5*DQS_WIDTH-1 downto 0);
      dbg_rd_bitslip_cnt        : out   std_logic_vector(3*DQS_WIDTH-1 downto 0);
      dbg_rd_clkdly_cnt         : out   std_logic_vector(2*DQS_WIDTH-1 downto 0);
      dbg_rd_active_dly         : out   std_logic_vector(4 downto 0);
      dbg_pd_off                : in    std_logic;
      dbg_pd_maintain_off       : in    std_logic;
      dbg_pd_maintain_0_only    : in    std_logic;
      dbg_inc_cpt               : in    std_logic;
      dbg_dec_cpt               : in    std_logic;
      dbg_inc_rd_dqs            : in    std_logic;
      dbg_dec_rd_dqs            : in    std_logic;
      dbg_inc_dec_sel           : in    std_logic_vector(DQS_CNT_WIDTH-1 downto 0);
      dbg_inc_rd_fps            : in    std_logic;
      dbg_dec_rd_fps            : in    std_logic;
      dbg_dqs_tap_cnt           : out   std_logic_vector(5*DQS_WIDTH-1 downto 0);
      dbg_dq_tap_cnt            : out   std_logic_vector(5*DQS_WIDTH-1 downto 0);
      dbg_rddata                : out   std_logic_vector(4*DQ_WIDTH-1 downto 0)
     );
  end component memc_ui_top;
  
  component memiface is
    Port ( -- reset and clock
           reset_n : in  STD_LOGIC;
           clock : in  STD_LOGIC;
           
           -- DDR3 IO
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
           
           -- UI
           app_cmd                   : in    std_logic_vector(2 downto 0);
           app_addr                  : in    std_logic_vector(C_MIG_ADDR_WIDTH-1 downto 0);
           app_en                    : in    std_logic;
           app_rdy                   : out   std_logic;
           app_rd_data               : out   std_logic_vector(C_MIG_APP_DATA_WIDTH-1 downto 0);
           app_rd_data_valid         : out   std_logic;
           app_rd_data_end           : out   std_logic;
           app_wdf_mask              : in    std_logic_vector(C_MIG_APP_MASK_WIDTH-1 downto 0);
           app_wdf_rdy               : out   std_logic;
           app_wdf_data              : in    std_logic_vector(C_MIG_APP_DATA_WIDTH-1 downto 0);
           app_wdf_wren              : in    std_logic;
           app_wdf_end               : in    std_logic;

           sda           : inout std_logic;
           scl           : out   std_logic;

           phy_init_done : out STD_LOGIC;
           app_ecc_multiple_err : out STD_LOGIC);
  end component;
  
end PKG_memiface;

package body PKG_memiface is

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
 
end PKG_memiface;

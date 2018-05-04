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

  constant C_UART_CLK_FREQ : natural := 200;
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
  
  component demo_toplevel_FSM is
      Port ( clock : in  STD_LOGIC;
             reset : in  STD_LOGIC;
            rx_e : in STD_LOGIC;
            command : in STD_LOGIC;
            app_rdy : in STD_LOGIC;
            app_rd_dl : in STD_LOGIC;
            app_wdf_rdy : in STD_LOGIC;
            app_cmd : out STD_LOGIC_VECTOR(2 downto 0);
            app_en : out STD_LOGIC;
            output_selector : out STD_LOGIC;
            app_wr_dv : out STD_LOGIC;
            app_wr_dl : out STD_LOGIC;
            ldA : OUT STD_LOGIC;
            ldB : OUT STD_LOGIC;
            ldD : OUT STD_LOGIC;
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

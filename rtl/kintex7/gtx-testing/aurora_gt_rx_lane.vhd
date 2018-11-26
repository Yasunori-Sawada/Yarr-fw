----------------------------------------------------------------------------------
-- Company: Osaka University
-- Engineer: Kazuki Yajima(kyajima@cern.ch)
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: aurora_gt_rx_lane - Behavioral
-- Project Name: YARR
-- Target Devices: Xilinx Kintex7
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
-- # RX STATUS:
-- # [0] -> Sync


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_MISC.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

-- uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;


entity aurora_gt_rx_lane is
  generic
    (
      NO_DEBUGCORES : boolean := true
      );
  port
    (
      --------------------
      -- System
      --------------------
      rst_n_i  : in std_logic;
      rx_clk_i : in std_logic;

      enable_i : in std_logic;

      --------------------
      -- Data Input
      --------------------
      gt_rx_data_i       : in std_logic_vector(15 downto 0);
      gt_rx_data_valid_i : in std_logic;

      --------------------
      -- Data Output
      --------------------
      rx_data_o   : out std_logic_vector(63 downto 0);
      rx_header_o : out std_logic_vector(1 downto 0);
      rx_valid_o  : out std_logic;
      rx_stat_o   : out std_logic_vector(7 downto 0)
      );
end aurora_gt_rx_lane;



architecture behavioral of aurora_gt_rx_lane is


--^^^^^^^^^^^^^^^^^^^^^^^^^ Component Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  component gt_rx_64b66b_alignment
    generic
      (
        DATA_IN_WIDTH  : integer range 1 to 20 := 16;
        VALID_INTERVAL : integer               := 2
        );
    port
      (
        --------------------
        -- System
        --------------------
        CLK_IN : in std_logic;
        RESET  : in std_logic;

        --------------------
        -- Interface
        --------------------
        DATA_IN       : in std_logic_vector(15 downto 0);  --(DATA_IN_WIDTH-1 downto 0);
        DATA_IN_VALID : in std_logic;

        DATA_OUT       : out std_logic_vector(65 downto 0);
        DATA_OUT_VALID : out std_logic;
        DATA_OUT_SYNC  : out std_logic;

        --------------------
        -- DEBUG
        --------------------
        ABNORMAL_INTERVAL : out std_logic
        );
  end component gt_rx_64b66b_alignment;


  component gt_rx_64b66b_descrambler
    port
      (
        --------------------
        -- System
        --------------------
        CLK_IN : in std_logic;
        RESET  : in std_logic;

        --------------------
        -- Interface
        --------------------
        DATA_IN       : in std_logic_vector(65 downto 0);  --((WDT_OUT -1) downto 0);
        DATA_IN_VALID : in std_logic;   -- High width must be 1

        DATA_OUT       : out std_logic_vector(63 downto 0);
        DATA_OUT_VALID : out std_logic;
        SYNCHEADER_OUT : out std_logic_vector(1 downto 0)
        );
  end component gt_rx_64b66b_descrambler;

--vvvvvvvvvvvvvvvvvvvvvvv END Component Declarations vvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^ Parameter Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

--vvvvvvvvvvvvvvvvvvvvvv END Parameter Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wire Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  signal rst_s : std_logic := '0';

  signal data_in_valid_s : std_logic := '0';

  signal aligned_66bits_s       : std_logic_vector(65 downto 0);
  signal aligned_66bits_valid_s : std_logic;
  signal alignment_sync_s       : std_logic;

  signal descrambled_64bits_s       : std_logic_vector(63 downto 0);
  signal descrambled_64bits_valid_s : std_logic;
  signal descrambled_syncbits_s     : std_logic_vector(1 downto 0);

--vvvvvvvvvvvvvvvvvvvvvvvvvv END Wire Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvvv


begin

  rst_s <= not rst_n_i;
  data_in_valid_s <= gt_rx_data_valid_i and enable_i;


  gt_rx_64b66b_alignment_inst : gt_rx_64b66b_alignment
    --generic map (
    --  DATA_IN_WIDTH  => 16,
    --  VALID_INTERVAL => 2
    --  )
    port map
    (
      --------------------
      -- System
      --------------------
      CLK_IN => rx_clk_i,
      RESET  => rst_s,

      --------------------
      -- Interface
      --------------------
      DATA_IN        => gt_rx_data_i,
      DATA_IN_VALID  => data_in_valid_s,
      DATA_OUT       => aligned_66bits_s,
      DATA_OUT_VALID => aligned_66bits_valid_s,
      DATA_OUT_SYNC  => alignment_sync_s,

      --------------------
      -- Debug
      --------------------
      ABNORMAL_INTERVAL => open         --abnormal_interval_s
      );


  gt_rx_64b66b_descrambler_inst : gt_rx_64b66b_descrambler
    port map
    (
      --------------------
      -- System
      --------------------
      CLK_IN => rx_clk_i,
      RESET  => rst_s,

      --------------------
      -- Interface
      --------------------
      DATA_IN        => aligned_66bits_s,
      DATA_IN_VALID  => aligned_66bits_valid_s,
      DATA_OUT       => descrambled_64bits_s,
      DATA_OUT_VALID => descrambled_64bits_valid_s,
      SYNCHEADER_OUT => descrambled_syncbits_s
      );


  --WITH_DEBUGCORES : if NO_DEBUGCORES = false generate

  --  ila_gtx_channel_i : ila_gtx_channel
  --    port map
  --    (
  --      clk    => rx_clk_i,
  --      probe0 => rst_s_ila,
  --      probe1 => enable_i_ila,
  --      probe2 => gt_rx_data_i_ila,
  --      probe3 => gt_rx_data_valid_i_ila,
  --      probe4 => rx_data_s,
  --      probe5 => rx_valid_s_ila,
  --      probe6 => rx_stat_s,
  --      probe7 => rx_data_raw_s,
  --      probe8 => abnormal_interval_s_ila
  --      --probe9 => bitslip_datalost_s_ila
  --      );

  --  rst_s_ila(0)               <= rst_s;
  --  enable_i_ila(0)            <= enable_i;
  --  gt_rx_data_i_ila           <= gt_rx_data_i;
  --  gt_rx_data_valid_i_ila(0)  <= gt_rx_data_valid_i;
  --  rx_valid_s_ila(0)          <= rx_valid_s;
  --  abnormal_interval_s_ila(0) <= abnormal_interval_s;
  --  bitslip_datalost_s_ila(0)  <= bitslip_datalost_s;

  --end generate WITH_DEBUGCORES;

  --WITHOUT_DEBUGCORES : if NO_DEBUGCORES = true generate

  --  rst_s_ila(0)               <= '0';
  --  enable_i_ila(0)            <= '0';
  --  gt_rx_data_i_ila           <= (others => '0');
  --  gt_rx_data_valid_i_ila(0)  <= '0';
  --  rx_valid_s_ila(0)          <= '0';
  --  abnormal_interval_s_ila(0) <= '0';
  --  bitslip_datalost_s_ila(0)  <= '0';

  --end generate WITHOUT_DEBUGCORES;


  rx_data_o   <= descrambled_64bits_s;
  rx_header_o <= descrambled_syncbits_s;
  rx_valid_o  <= descrambled_64bits_valid_s;
  rx_stat_o   <= (others => '0');

end behavioral;

----------------------------------------------------------------------------------
-- Company: Osaka University
-- Engineer: Kazuki Yajima(kyajima@cern.ch)
-- 
-- Create Date: 08/10/2018 10:34:14 AM
-- Design Name: 
-- Module Name: sma_gtx_with_nidru - Behavioral
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


entity sma_gtx_with_nidru is
  port
    (
      --------------------
      -- System
      --------------------
      SYS_CLK_p       : in  std_logic;  --200MHz
      SYS_CLK_n       : in  std_logic;
      USER_SMA_GPIO_P : out std_logic;  --156.25MHz
      USER_SMA_GPIO_N : out std_logic;
      RESET           : in  std_logic;

      --------------------
      -- GTX Ports
      --------------------
      GTX_RXN_IN        : in std_logic;
      GTX_RXP_IN        : in std_logic;
      GTREFCLK_PAD_N_IN : in std_logic;
      GTREFCLK_PAD_P_IN : in std_logic;

      -------------------------
      -- Probes for debugging
      -------------------------
      TEST_P_OUT : out std_logic;       --FMC LPC : LN26_P
      TEST_N_OUT : out std_logic;       --FMC LPC : LN26_N
      LED_CHKOUT : out std_logic_vector(7 downto 0)
      );
end sma_gtx_with_nidru;



architecture Behavioral of sma_gtx_with_nidru is


--^^^^^^^^^^^^^^^^^^^^^^^^^ Component Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  component clk_gen_gtx
    port
      (
        SYS_CLK_IN_p : in  std_logic;
        SYS_CLK_IN_n : in  std_logic;
        -- Clock out ports
        CLK_100M_OUT : out std_logic;
        CLK_160M_OUT : out std_logic;
        -- Status and control signals
        reset        : in  std_logic;
        locked       : out std_logic
        );
  end component;


  component gtwizard_rxonly_support is
    generic
      (
        EXAMPLE_SIM_GTRESET_SPEEDUP : string  := "TRUE";  -- simulation setting for GT SecureIP model
        STABLE_CLOCK_PERIOD         : integer := 10
        );
    port
      (
        SOFT_RESET_RX_IN            : in std_logic;
        DONT_RESET_ON_DATA_ERROR_IN : in std_logic;
        Q2_CLK1_GTREFCLK_PAD_N_IN   : in std_logic;
        Q2_CLK1_GTREFCLK_PAD_P_IN   : in std_logic;

        GT0_TX_FSM_RESET_DONE_OUT : out std_logic;
        GT0_RX_FSM_RESET_DONE_OUT : out std_logic;
        GT0_DATA_VALID_IN         : in  std_logic;

        GT0_RXUSRCLK_OUT  : out std_logic;
        GT0_RXUSRCLK2_OUT : out std_logic;

        --_________________________________________________________________________
        --GT0  (X1Y8)
        --____________________________CHANNEL PORTS________________________________
        --------------------------------- CPLL Ports -------------------------------
        gt0_cpllfbclklost_out    : out std_logic;
        gt0_cplllock_out         : out std_logic;
        gt0_cpllpd_in            : in  std_logic;
        gt0_cpllreset_in         : in  std_logic;
        ---------------------------- Channel - DRP Ports  --------------------------
        gt0_drpaddr_in           : in  std_logic_vector(8 downto 0);
        gt0_drpdi_in             : in  std_logic_vector(15 downto 0);
        gt0_drpdo_out            : out std_logic_vector(15 downto 0);
        gt0_drpen_in             : in  std_logic;
        gt0_drprdy_out           : out std_logic;
        gt0_drpwe_in             : in  std_logic;
        --------------------------- Digital Monitor Ports --------------------------
        gt0_dmonitorout_out      : out std_logic_vector(7 downto 0);
        --------------------- RX Initialization and Reset Ports --------------------
        gt0_eyescanreset_in      : in  std_logic;
        gt0_rxuserrdy_in         : in  std_logic;
        -------------------------- RX Margin Analysis Ports ------------------------
        gt0_eyescandataerror_out : out std_logic;
        gt0_eyescantrigger_in    : in  std_logic;
        ------------------------- Receive Ports - CDR Ports ------------------------
        gt0_rxcdrhold_in         : in  std_logic;
        ------------------ Receive Ports - FPGA RX interface Ports -----------------
        gt0_rxdata_out           : out std_logic_vector(31 downto 0);
        --------------------------- Receive Ports - RX AFE -------------------------
        gt0_gtxrxp_in            : in  std_logic;
        ------------------------ Receive Ports - RX AFE Ports ----------------------
        gt0_gtxrxn_in            : in  std_logic;
        ------------------- Receive Ports - RX Buffer Bypass Ports -----------------
        gt0_rxbufreset_in        : in  std_logic;
        gt0_rxbufstatus_out      : out std_logic_vector(2 downto 0);
        -------------------- Receive Ports - RX Equailizer Ports -------------------
        gt0_rxlpmhfovrden_in     : in  std_logic;
        --------------------- Receive Ports - RX Equalizer Ports -------------------
        gt0_rxdfelpmreset_in     : in  std_logic;
        gt0_rxlpmlfklovrden_in   : in  std_logic;
        gt0_rxmonitorout_out     : out std_logic_vector(6 downto 0);
        gt0_rxmonitorsel_in      : in  std_logic_vector(1 downto 0);
        --------------- Receive Ports - RX Fabric Output Control Ports -------------
        gt0_rxoutclkfabric_out   : out std_logic;
        ------------- Receive Ports - RX Initialization and Reset Ports ------------
        gt0_gtrxreset_in         : in  std_logic;
        gt0_rxpcsreset_in        : in  std_logic;
        gt0_rxpmareset_in        : in  std_logic;
        ----------------- Receive Ports - RX Polarity Control Ports ----------------
        gt0_rxpolarity_in        : in  std_logic;
        -------------- Receive Ports -RX Initialization and Reset Ports ------------
        gt0_rxresetdone_out      : out std_logic;
        --------------------- TX Initialization and Reset Ports --------------------
        gt0_gttxreset_in         : in  std_logic;

        GT0_QPLLPD_IN         : in  std_logic;
        --____________________________COMMON PORTS________________________________
        GT0_QPLLOUTCLK_OUT    : out std_logic;
        GT0_QPLLOUTREFCLK_OUT : out std_logic;
        sysclk_in             : in  std_logic
        );
  end component;


  component nidru_mywrapper is
    generic (
      --***** Configuration *****
      WDT_OUT     : in integer range 1 to 40 := 2;  -- output width
      DT_IN_WIDTH : in integer range 4 to 32 := 4;  -- input data width, 4, 20 or 32 bits available

      --***** Eyescan *****
      PH_NUM : in integer range 0 to 2 := 0;  -- max number of extra phases. 0 is no eyescan

      --***** Logic optimization *****
      S_MAX : in integer range 1 to 16 := 2;  -- max number of extracted bits, decimal

      --***** Debug cores *****
      NO_DEBUGCORES : in boolean := true
      );
    port (
      --***** DATA PORTS *****
      DT_IN      : in  std_logic_vector ((DT_IN_WIDTH -1) downto 0);
      CENTER_F   : in  std_logic_vector (36 downto 0);
      ENABLE     : in  std_logic;
      CLK        : in  std_logic;
      RST        : in  std_logic;       -- active high
      RST_FREQ   : in  std_logic;       -- active high
      RECCLK_OUT : out std_logic_vector((DT_IN_WIDTH -1) downto 0);
      DOUT_VALID : out std_logic;
      DOUT       : out std_logic_vector((WDT_OUT -1) downto 0);

      --***** CONFIG PORTS *****
      G1   : in std_logic_vector(4 downto 0);
      G1_P : in std_logic_vector(4 downto 0);
      G2   : in std_logic_vector(4 downto 0);

      --***** DEBUG PORTS *****
      ERR_DETECTED_IN : in std_logic
      );
  end component;


  component vio_gtx
    port (
      clk        : in  std_logic;
      probe_in0  : in  std_logic_vector(7 downto 0);
      probe_out0 : out std_logic_vector(15 downto 0)
      );
  end component;


--vvvvvvvvvvvvvvvvvvvvvvv END Component Declarations vvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^ Parameter Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  attribute keep : string;

  constant EXAMPLE_SIM_GTRESET_SPEEDUP : string  := "TRUE";  -- simulation setting for GT SecureIP model
  constant STABLE_CLOCK_PERIOD         : integer := 10;

  constant WDT_OUT     : integer := 20;
  constant DT_IN_WIDTH : integer := 32;

--vvvvvvvvvvvvvvvvvvvvvv END Parameter Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wire Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  signal SYS_CLK_tmp : std_logic;
  signal SYS_CLK     : std_logic;
  signal CLK_160M    : std_logic;

  ------------------------------- Global Signals -----------------------------
  signal tied_to_ground_i : std_logic;
  --signal tied_to_ground_vec_i  : std_logic_vector(63 downto 0);
  signal tied_to_vcc_i    : std_logic;

  ----------------------------------- GTX ------------------------------------
  --***** CLOCK *****
  signal gt0_tx_mmcm_lock_i            : std_logic;
  signal gt0_txusrclk_i                : std_logic;
  signal gt0_txusrclk2_i               : std_logic;
  signal gt0_rxusrclk_i                : std_logic;
  signal gt0_rxusrclk2_i               : std_logic;
  attribute keep of gt0_tx_mmcm_lock_i : signal is "true";
  attribute keep of gt0_txusrclk_i     : signal is "true";
  attribute keep of gt0_txusrclk2_i    : signal is "true";
  attribute keep of gt0_rxusrclk_i     : signal is "true";
  attribute keep of gt0_rxusrclk2_i    : signal is "true";

  --***** FABRIC CLOCK *****
  signal gt0_rxoutclkfabric_i : std_logic;
  signal gt0_txoutclkfabric_i : std_logic;
  signal gt0_txoutclkpcs_i    : std_logic;

  --***** RESET *****
  signal soft_reset_i                       : std_logic;
  signal gt0_tx_fsm_reset_done_i            : std_logic;
  signal gt0_rx_fsm_reset_done_i            : std_logic;
  signal gt0_txresetdone_i                  : std_logic;
  signal gt0_rxresetdone_i                  : std_logic;
  signal gt0_gtrxreset_i                    : std_logic;
  signal gt0_gttxreset_i                    : std_logic;
  --signal gt0_rxuserrdy_i                  : std_logic;
  --signal gt0_txuserrdy_i                  : std_logic;
  signal gt0_rxpcsreset_i                   : std_logic;
  signal gt0_rxpmareset_i                   : std_logic;
  signal gt0_txpcsreset_i                   : std_logic;
  attribute keep of soft_reset_i            : signal is "true";
  attribute keep of gt0_rx_fsm_reset_done_i : signal is "true";
  attribute keep of gt0_tx_fsm_reset_done_i : signal is "true";
  attribute keep of gt0_rxresetdone_i       : signal is "true";
  attribute keep of gt0_txresetdone_i       : signal is "true";
  attribute keep of gt0_gtrxreset_i         : signal is "true";
  attribute keep of gt0_gttxreset_i         : signal is "true";
  attribute keep of gt0_rxpcsreset_i        : signal is "true";
  attribute keep of gt0_rxpmareset_i        : signal is "true";
  attribute keep of gt0_txpcsreset_i        : signal is "true";

  --***** DATA/Buffer *****
  signal gt0_rxdata_i                 : std_logic_vector(31 downto 0);
  signal gt0_rxbufreset_i             : std_logic;
  signal gt0_rxbufstatus_i            : std_logic_vector(2 downto 0);
  attribute keep of gt0_rxbufreset_i  : signal is "true";
  attribute keep of gt0_rxbufstatus_i : signal is "true";

  --***** DRP PORTS *****
  --signal gt0_drpaddr_i : std_logic_vector(8 downto 0);
  --signal gt0_drpdi_i   : std_logic_vector(15 downto 0);
  --signal gt0_drpdo_i   : std_logic_vector(15 downto 0);
  --signal gt0_drpen_i   : std_logic;
  --signal gt0_drprdy_i  : std_logic;
  --signal gt0_drpwe_i   : std_logic;

  --***** RX EQUALIZER *****
  signal gt0_rxlpmhfovrden_i              : std_logic;
  --signal gt0_rxdfelpmreset_i   : std_logic;
  signal gt0_rxlpmlfklovrden_i            : std_logic;
  --signal gt0_rxmonitorout_i    : std_logic_vector(6 downto 0);
  --signal gt0_rxmonitorsel_i    : std_logic_vector(1 downto 0);
  attribute keep of gt0_rxlpmhfovrden_i   : signal is "true";
  attribute keep of gt0_rxlpmlfklovrden_i : signal is "true";

  --***** RX MARGIN ANALYSIS *****
  --signal gt0_eyescanreset_i     : std_logic;
  --signal gt0_eyescandataerror_i : std_logic;
  --signal gt0_eyescantrigger_i   : std_logic;

  --***** MISC *****
  signal gt0_cpllpd_i                : std_logic;
  signal gt0_cpllreset_i             : std_logic;
  signal gt0_qpllpd_i                : std_logic;
  signal gt0_rxcdrhold_i             : std_logic;
  signal gt0_rxpolarity_i            : std_logic;
  --signal gt0_dmonitorout_i : std_logic_vector(7 downto 0);
  attribute keep of gt0_cpllpd_i     : signal is "true";
  attribute keep of gt0_rxcdrhold_i  : signal is "true";
  attribute keep of gt0_rxpolarity_i : signal is "true";

  ---------------------------- GTX/FPGA Interface ----------------------------
  signal gtx_usrclk_i   : std_logic;
  signal rxdata_valid_i : std_logic;
  signal rxdata_out_i   : std_logic_vector((WDT_OUT -1) downto 0);
  signal txdata_in_i    : std_logic_vector(31 downto 0);

  ---------------------------------- DEBUG -----------------------------------
  --***** Virtual I/O *****
  signal probe_in0  : std_logic_vector(63 downto 0);  --(31 downto 0);
  signal probe_out0 : std_logic_vector(31 downto 0);  --(7 downto 0);
  --signal gtx_probe_in0   : std_logic_vector(7 downto 0);
  --signal gtx_probe_out0  : std_logic_vector(15 downto 0);

  ----***** Clock probes *****
  --signal counter_SYS_CLK   : std_logic_vector(15 downto 0) := (others => '0');
  --signal counter_CLK_160M  : std_logic_vector(15 downto 0) := (others => '0');
  --signal counter_txusrclk  : std_logic_vector(15 downto 0) := (others => '0');
  --signal counter_txusrclk2 : std_logic_vector(15 downto 0) := (others => '0');
  --signal counter_rxusrclk  : std_logic_vector(15 downto 0) := (others => '0');
  --signal counter_rxusrclk2 : std_logic_vector(15 downto 0) := (others => '0');


--vvvvvvvvvvvvvvvvvvvvvvvvvv END Wire Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvvv


begin


  tied_to_ground_i <= '0';
  tied_to_vcc_i    <= '1';


----------------------------------------------
------------------ Clock ---------------------
----------------------------------------------

  sys_clk_gen : clk_gen_gtx
    port map (
      -- Clock in ports
      SYS_CLK_IN_p => SYS_CLK_p,
      SYS_CLK_IN_n => SYS_CLK_n,
      -- Clock out ports
      CLK_100M_OUT => SYS_CLK,
      CLK_160M_OUT => CLK_160M,
      -- Status and control signals
      reset        => RESET,
      locked       => open              --locked
      );

  OBUFDS_USER_SMA_CLK : OBUFDS
    port map
    (
      I  => CLK_160M,
      O  => USER_SMA_GPIO_P,
      OB => USER_SMA_GPIO_N
      );


----------------------------------------------
-------------- GTX Support -------------------
----------------------------------------------

  gtwizard_rxonly_support_i : gtwizard_rxonly_support
    generic map
    (
      EXAMPLE_SIM_GTRESET_SPEEDUP => EXAMPLE_SIM_GTRESET_SPEEDUP,
      STABLE_CLOCK_PERIOD         => STABLE_CLOCK_PERIOD
      )
    port map
    (
      SOFT_RESET_RX_IN            => soft_reset_i,
      DONT_RESET_ON_DATA_ERROR_IN => tied_to_ground_i,
      Q2_CLK1_GTREFCLK_PAD_N_IN   => GTREFCLK_PAD_N_IN,
      Q2_CLK1_GTREFCLK_PAD_P_IN   => GTREFCLK_PAD_P_IN,

      GT0_TX_FSM_RESET_DONE_OUT => gt0_tx_fsm_reset_done_i,
      GT0_RX_FSM_RESET_DONE_OUT => gt0_rx_fsm_reset_done_i,
      GT0_DATA_VALID_IN         => '1',

      GT0_RXUSRCLK_OUT  => gt0_rxusrclk_i,
      GT0_RXUSRCLK2_OUT => gt0_rxusrclk2_i,

      --_________________________________________________________________________
      --GT0  (X1Y8)
      --____________________________CHANNEL PORTS________________________________
      --------------------------------- CPLL Ports -------------------------------
      gt0_cpllfbclklost_out    => open,
      gt0_cplllock_out         => open,
      gt0_cpllpd_in            => gt0_cpllpd_i,
      gt0_cpllreset_in         => gt0_cpllreset_i,
      ---------------------------- Channel - DRP Ports  --------------------------
      gt0_drpaddr_in           => (others => '0'),   --gt0_drpaddr_i,
      gt0_drpdi_in             => (others => '0'),   --gt0_drpdi_i,
      gt0_drpdo_out            => open,              --gt0_drpdo_i,
      gt0_drpen_in             => tied_to_ground_i,  --gt0_drpen_i,
      gt0_drprdy_out           => open,              --gt0_drprdy_i,
      gt0_drpwe_in             => tied_to_ground_i,  --gt0_drpwe_i,
      --------------------------- Digital Monitor Ports --------------------------
      gt0_dmonitorout_out      => open,              --gt0_dmonitorout_i,
      --------------------- RX Initialization and Reset Ports --------------------
      gt0_eyescanreset_in      => tied_to_ground_i,  --gt0_eyescanreset_i,
      gt0_rxuserrdy_in         => tied_to_ground_i,  --gt0_rxuserrdy_i,
      -------------------------- RX Margin Analysis Ports ------------------------
      gt0_eyescandataerror_out => open,              --gt0_eyescandataerror_i,
      gt0_eyescantrigger_in    => tied_to_ground_i,  --gt0_eyescantrigger_i,
      ------------------------- Receive Ports - CDR Ports ------------------------
      gt0_rxcdrhold_in         => gt0_rxcdrhold_i,
      ------------------ Receive Ports - FPGA RX interface Ports -----------------
      gt0_rxdata_out           => gt0_rxdata_i,
      --------------------------- Receive Ports - RX AFE -------------------------
      gt0_gtxrxp_in            => GTX_RXP_IN,
      ------------------------ Receive Ports - RX AFE Ports ----------------------
      gt0_gtxrxn_in            => GTX_RXN_IN,
      ------------------- Receive Ports - RX Buffer Bypass Ports -----------------
      gt0_rxbufreset_in        => gt0_rxbufreset_i,
      gt0_rxbufstatus_out      => gt0_rxbufstatus_i,
      -------------------- Receive Ports - RX Equailizer Ports -------------------
      gt0_rxlpmhfovrden_in     => gt0_rxlpmhfovrden_i,
      --------------------- Receive Ports - RX Equalizer Ports -------------------
      gt0_rxdfelpmreset_in     => tied_to_ground_i,  --gt0_rxdfelpmreset_i,
      gt0_rxlpmlfklovrden_in   => gt0_rxlpmlfklovrden_i,
      gt0_rxmonitorout_out     => open,              --gt0_rxmonitorout_i,
      gt0_rxmonitorsel_in      => "00",              --gt0_rxmonitorsel_i,
      --------------- Receive Ports - RX Fabric Output Control Ports -------------
      gt0_rxoutclkfabric_out   => gt0_rxoutclkfabric_i,
      ------------- Receive Ports - RX Initialization and Reset Ports ------------
      gt0_gtrxreset_in         => gt0_gtrxreset_i,
      gt0_rxpcsreset_in        => gt0_rxpcsreset_i,
      gt0_rxpmareset_in        => gt0_rxpmareset_i,
      ----------------- Receive Ports - RX Polarity Control Ports ----------------
      gt0_rxpolarity_in        => gt0_rxpolarity_i,
      -------------- Receive Ports -RX Initialization and Reset Ports ------------
      gt0_rxresetdone_out      => gt0_rxresetdone_i,
      --------------------- TX Initialization and Reset Ports --------------------
      gt0_gttxreset_in         => gt0_gttxreset_i,

      GT0_QPLLPD_IN          => gt0_qpllpd_i,
      --____________________________COMMON PORTS________________________________
      GT0_QPLLOUTCLK_OUT     => open,
      GT0_QPLLOUTREFCLK_OUT  => open,
      sysclk_in              => SYS_CLK
      );


----------------------------------------------
------------------ NIDRU ---------------------
----------------------------------------------

  nidru_mywrapper_inst : nidru_mywrapper
    generic map
    (
      --***** Configuration *****
      WDT_OUT     => WDT_OUT,
      DT_IN_WIDTH => DT_IN_WIDTH,

      --***** Eyescan *****
      PH_NUM => 1,

      --***** Logic optimization *****
      S_MAX => 10,

      --***** Debug cores *****
      NO_DEBUGCORES => false
      )
    port map
    (
      --***** DATA PORTS *****
      DT_IN      => gt0_rxdata_i,
      CENTER_F   => (others => '0'),  --Controlled by VIO if NO_DEBUGCORES = false
      ENABLE     => '1',
      CLK        => gt0_rxusrclk_i,
      RST        => '0',   --Controlled by VIO if NO_DEBUGCORES = false
      RST_FREQ   => '0',   --Controlled by VIO if NO_DEBUGCORES = false
      RECCLK_OUT => open,  --Monitored by VIO if NO_DEBUGCORES = false
      DOUT_VALID => rxdata_valid_i,
      DOUT       => rxdata_out_i,

      --***** CONFIG PORTS *****
      G1   => (others => '0'),  --Controlled by VIO if NO_DEBUGCORES = false
      G1_P => (others => '0'),  --Controlled by VIO if NO_DEBUGCORES = false
      G2   => (others => '0'),  --Controlled by VIO if NO_DEBUGCORES = false

      --***** DEBUG PORTS *****
      ERR_DETECTED_IN => '0'            --detect_err_prbs_i
      );


----------------------------------------------
----------------- DEBUG ----------------------
----------------------------------------------

  gtx_usrclk_i <= gt0_rxusrclk_i;

  vio_gtx_inst : vio_gtx
    port map (
      clk        => gtx_usrclk_i,
      probe_in0  => probe_in0(39 downto 32),
      probe_out0 => probe_out0(31 downto 16)
      );

  --***** Virtual I/O *****
  --GTX Control
  soft_reset_i          <= probe_out0(16);
  gt0_gtrxreset_i       <= probe_out0(17);
  gt0_gttxreset_i       <= probe_out0(18);
  gt0_rxpcsreset_i      <= probe_out0(19);
  gt0_rxpmareset_i      <= probe_out0(20);
  gt0_txpcsreset_i      <= probe_out0(21);
  gt0_qpllpd_i          <= probe_out0(22);
  gt0_rxcdrhold_i       <= probe_out0(23);
  gt0_rxlpmhfovrden_i   <= probe_out0(24);
  gt0_rxlpmlfklovrden_i <= probe_out0(25);
  gt0_rxpolarity_i      <= probe_out0(26);
  gt0_rxbufreset_i      <= probe_out0(27);

  --GTX Monitoring
  probe_in0(32)           <= gt0_rxresetdone_i;
  probe_in0(33)           <= gt0_txresetdone_i;
  probe_in0(34)           <= gt0_rx_fsm_reset_done_i;
  probe_in0(35)           <= gt0_tx_fsm_reset_done_i;
  probe_in0(36)           <= gt0_tx_mmcm_lock_i;
  probe_in0(39 downto 37) <= gt0_rxbufstatus_i;
  probe_in0(63 downto 40) <= (others => '0');

  ----***** Clock probes *****
  --process (SYS_CLK) begin if rising_edge(SYS_CLK) then counter_SYS_CLK                   <= counter_SYS_CLK + 1; end if; end process;
  --process (CLK_160M) begin if rising_edge(CLK_160M) then counter_CLK_160M                <= counter_CLK_160M + 1; end if; end process;
  --process (gt0_txusrclk_i) begin if rising_edge(gt0_txusrclk_i) then counter_txusrclk    <= counter_txusrclk + 1; end if; end process;
  --process (gt0_txusrclk2_i) begin if rising_edge(gt0_txusrclk2_i) then counter_txusrclk2 <= counter_txusrclk2 + 1; end if; end process;
  --process (gt0_rxusrclk_i) begin if rising_edge(gt0_rxusrclk_i) then counter_rxusrclk    <= counter_rxusrclk + 1; end if; end process;
  --process (gt0_rxusrclk2_i) begin if rising_edge(gt0_rxusrclk2_i) then counter_rxusrclk2 <= counter_rxusrclk2 + 1; end if; end process;

  --LED_CHKOUT(0) <= counter_SYS_CLK  (15);
  --LED_CHKOUT(1) <= counter_CLK_160M (15);
  --LED_CHKOUT(2) <= counter_txusrclk (15);
  --LED_CHKOUT(3) <= counter_txusrclk2(15);
  --LED_CHKOUT(4) <= counter_rxusrclk (15);
  --LED_CHKOUT(5) <= counter_rxusrclk2(15);
  --LED_CHKOUT(6) <= '0';
  --LED_CHKOUT(7) <= '0';
  LED_CHKOUT <= (others => '0');


end Behavioral;

----------------------------------------------------------------------------------
-- Company: Osaka University
-- Engineer: Kazuki Yajima(kyajima@cern.ch)
-- 
-- Create Date: 08/17/2018 04:26:01 PM
-- Design Name: 
-- Module Name: nidru_mywrapper - Behavioral
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
--library UNISIM;
--use UNISIM.VComponents.all;


entity nidru_mywrapper is
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
    RST        : in  std_logic;         -- active high
    RST_FREQ   : in  std_logic;         -- active high
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
end nidru_mywrapper;



architecture Behavioral of nidru_mywrapper is


  function bool_to_stdlogic (bool : in boolean) return std_logic is
  begin
    if bool = true then return '1';
    else return '0'; end if;
  end bool_to_stdlogic;

  function bool_to_string (bool : in boolean) return string is
  begin
    if bool = true then return "true";
    else return "false"; end if;
  end bool_to_string;


--^^^^^^^^^^^^^^^^^^^^^^^^^ Component Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  component nidru_wrapper_v_2_1
    generic (
      --***** Configuration *****
      WDT_OUT     : in integer range 1 to 40 := 2;  -- output width
      DT_IN_WIDTH : in integer range 4 to 32 := 4;  -- input data width, 4, 20 or 32 bits available

      --***** Switchable attributes *****
      --CENTER_F
      EN_CENTER_F_ATTR   : in std_logic                      := '1';  -- when = 1, center_f=center_f_attr
      CENTER_F_ATTR      : in std_logic_vector (36 downto 0) := "0000100111110100000010100010100001110";  -- internal center_f
      --G1
      EN_G1_ATTR         : in std_logic                      := '1';
      G1_ATTR            : in std_logic_vector (4 downto 0)  := "01000";
      --G2
      EN_G2_ATTR         : in std_logic                      := '1';
      G2_ATTR            : in std_logic_vector (4 downto 0)  := "01000";
      --G1_P
      EN_G1_P_ATTR       : in std_logic                      := '1';
      G1_P_ATTR          : in std_logic_vector (4 downto 0)  := "01111";
      --SHIFT_S_PH (For Eyescan)
      EN_SHIFT_S_PH_ATTR : in std_logic                      := '1';
      SHIFT_S_PH_ATTR    : in std_logic_vector (7 downto 0)  := "00000000";
      --EN_INTEG
      EN_EN_INTEG_ATTR   : in std_logic                      := '1';
      EN_INTEG_ATTR      : in std_logic                      := '1';
      --EN(Enable) : EN when EN_EN = '1' else '1';
      EN_EN              : in std_logic                      := '0';

      --***** Eyescan *****
      PH_NUM : in integer range 0 to 2 := 0;  -- max number of extra phases. 0 is no eyescan

      --***** Logic optimization *****
      S_MAX    : in integer range 1 to 16          := 2;  -- max number of extracted bits, decimal
      MASK_CG  : in std_logic_vector (15 downto 0) := "1111111100000000";  -- place same number of LSb zeros
      MASK_PD  : in std_logic_vector (15 downto 0) := "1111111100000000";  -- place same number of LSb zeros
      MASK_VCO : in std_logic_vector (36 downto 0) := "1111111111111111111111111100000000000"  -- place same number of LSb zeros
      );
    port (
      --***** DATA PORTS *****
      DT_IN    : in  std_logic_vector ((DT_IN_WIDTH -1) downto 0);
      CENTER_F : in  std_logic_vector (36 downto 0);
      EN       : in  std_logic;
      CLK      : in  std_logic;
      RST_FREQ : in  std_logic;         -- active high
      RECCLK   : out std_logic_vector((DT_IN_WIDTH -1) downto 0);
      EN_OUT   : out std_logic;
      DOUT     : out std_logic_vector((WDT_OUT -1) downto 0);

      --***** CONFIG PORTS *****
      G1   : in std_logic_vector(4 downto 0);
      G1_P : in std_logic_vector(4 downto 0);
      G2   : in std_logic_vector(4 downto 0);

      --***** DEBUG *****
      PH_OUT     : out std_logic_vector(20 downto 0);
      INTEG      : out std_logic_vector(31 downto 0);
      DIRECT     : out std_logic_vector(31 downto 0);
      CTRL       : out std_logic_vector (31 downto 0);
      AL_PPM     : out std_logic;
      RST        : in  std_logic;                     -- active high
      EN_INTEG   : in  std_logic;                     -- by default 1
      PH_EST_DIS : in  std_logic;                     -- by defauls 0
      VER        : out std_logic_vector(7 downto 0);
      SAMV       : out std_logic_vector(6 downto 0);  -- coded
      SAM        : out std_logic_vector((DT_IN_WIDTH/2 -1) downto 0);

      --***** EYESCAN *****
      SHIFT_S_PH    : in  std_logic_vector(7 downto 0) := (others => '0');
      AUTOM         : in  std_logic                    := '1';
      START_EYESCAN : in  std_logic                    := '0';
      EYESCAN_BUSY  : out std_logic                    := '0';
      RST_PH_0      : in  std_logic                    := '0';
      RST_PH_1      : in  std_logic                    := '0';
      RST_PH_SAMP   : in  std_logic                    := '0';
      ERR_PH_0      : out std_logic_vector (6 downto 0);
      ERR_PH_1      : out std_logic_vector (6 downto 0);

      PH_0_SCAN : out std_logic_vector (7 downto 0);
      PH_1_SCAN : out std_logic_vector (7 downto 0);

      PH_0 : in std_logic_vector(7 downto 0) := (others => '0');  -- Not used
      PH_1 : in std_logic_vector(7 downto 0) := (others => '0');  -- Not used

      WAITING_TIME : in std_logic_vector(47 downto 0) := (others => '0');

      ERR_COUNT_PH_0    : out std_logic_vector (51 downto 0) := (others => '0');
      EN_ERR_COUNT_PH_0 : out std_logic                      := '0';
      ERR_COUNT_PH_1    : out std_logic_vector (51 downto 0) := (others => '0');
      EN_ERR_COUNT_PH_1 : out std_logic                      := '0'
      );
  end component;


  component ila_nidru
    port (
      clk     : in std_logic;
      probe0  : in std_logic_vector((DT_IN_WIDTH -1) downto 0);
      probe1  : in std_logic_vector(0 downto 0);
      probe2  : in std_logic_vector(19 downto 0);
      probe3  : in std_logic_vector((DT_IN_WIDTH -1) downto 0);
      probe4  : in std_logic_vector(20 downto 0);
      probe5  : in std_logic_vector(31 downto 0);
      probe6  : in std_logic_vector(31 downto 0);
      probe7  : in std_logic_vector(31 downto 0);
      probe8  : in std_logic_vector(0 downto 0);
      probe9  : in std_logic_vector(6 downto 0);
      probe10 : in std_logic_vector(15 downto 0);
      probe11 : in std_logic_vector(0 downto 0);
      probe12 : in std_logic_vector(51 downto 0);
      probe13 : in std_logic_vector(0 downto 0);
      probe14 : in std_logic_vector(51 downto 0);
      probe15 : in std_logic_vector(0 downto 0);
      probe16 : in std_logic_vector(0 downto 0);
      probe17 : in std_logic_vector(0 downto 0);
      probe18 : in std_logic_vector(0 downto 0)
      );
  end component;


  component vio_nidru
    port (
      clk        : in  std_logic;
      probe_in0  : in  std_logic_vector(15 downto 0);
      probe_out0 : out std_logic_vector(127 downto 0)
      );
  end component;

--vvvvvvvvvvvvvvvvvvvvvvv END Component Declarations vvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^ Parameter Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  attribute keep  : string;
  constant keep_c : string := bool_to_string(not NO_DEBUGCORES);

--vvvvvvvvvvvvvvvvvvvvvv END Parameter Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wire Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  ------------------------------- Global Signals -----------------------------
  signal tied_to_ground_i : std_logic;
  --signal tied_to_ground_vec_i  : std_logic_vector(63 downto 0);
  signal tied_to_vcc_i    : std_logic;

  ----------------------------- NIDRU Wrapper --------------------------------
  --***** DATA PORTS *****
  signal dt_in_dru_i                   : std_logic_vector((DT_IN_WIDTH -1) downto 0);
  signal center_f_dru_i                : std_logic_vector(36 downto 0);
  signal en_dru_i                      : std_logic;
  signal rst_freq_dru_i                : std_logic;
  signal rst_freq_dru_i_ila            : std_logic_vector(0 downto 0);
  signal recclk_dru_i                  : std_logic_vector((DT_IN_WIDTH -1) downto 0);
  signal en_out_dru_i                  : std_logic;
  signal en_out_dru_i_ila              : std_logic_vector(0 downto 0);
  signal dout_dru_i                    : std_logic_vector((WDT_OUT -1) downto 0);
  attribute keep of dt_in_dru_i        : signal is keep_c;
  attribute keep of center_f_dru_i     : signal is keep_c;
  attribute keep of en_dru_i           : signal is keep_c;
  attribute keep of rst_freq_dru_i     : signal is keep_c;
  attribute keep of rst_freq_dru_i_ila : signal is keep_c;
  attribute keep of recclk_dru_i       : signal is keep_c;
  attribute keep of en_out_dru_i_ila   : signal is keep_c;
  attribute keep of dout_dru_i         : signal is keep_c;

  --***** CONFIG PORTS *****
  signal g1_dru_i              : std_logic_vector(4 downto 0);
  signal g1_p_dru_i            : std_logic_vector(4 downto 0);
  signal g2_dru_i              : std_logic_vector(4 downto 0);
  attribute keep of g1_dru_i   : signal is keep_c;
  attribute keep of g1_p_dru_i : signal is keep_c;
  attribute keep of g2_dru_i   : signal is keep_c;

  --***** DEBUG *****
  signal ph_out_dru_i                : std_logic_vector(20 downto 0);
  signal integ_dru_i                 : std_logic_vector(31 downto 0);
  signal direct_dru_i                : std_logic_vector(31 downto 0);
  signal ctrl_dru_i                  : std_logic_vector(31 downto 0);
  signal al_ppm_dru_i                : std_logic;
  signal al_ppm_dru_i_ila            : std_logic_vector(0 downto 0);
  signal rst_dru_i                   : std_logic;
  signal rst_dru_i_ila               : std_logic_vector(0 downto 0);
  signal ver_dru_i                   : std_logic_vector(7 downto 0);
  signal samv_dru_i                  : std_logic_vector(6 downto 0);
  signal sam_dru_i                   : std_logic_vector((DT_IN_WIDTH/2 -1) downto 0);
  attribute keep of ph_out_dru_i     : signal is keep_c;
  attribute keep of integ_dru_i      : signal is keep_c;
  attribute keep of direct_dru_i     : signal is keep_c;
  attribute keep of ctrl_dru_i       : signal is keep_c;
  attribute keep of al_ppm_dru_i_ila : signal is keep_c;
  attribute keep of rst_dru_i        : signal is keep_c;
  attribute keep of rst_dru_i_ila    : signal is keep_c;
  attribute keep of ver_dru_i        : signal is keep_c;
  attribute keep of samv_dru_i       : signal is keep_c;
  attribute keep of sam_dru_i        : signal is keep_c;

  --***** EYESCAN *****
  signal start_eyescan_dru_i                    : std_logic;
  signal eyescan_busy_dru_i                     : std_logic;
  signal eyescan_busy_dru_i_ila                 : std_logic_vector(0 downto 0);
  signal waiting_time_dru_i                     : std_logic_vector(47 downto 0);
  signal err_count_ph_0_dru_i                   : std_logic_vector(51 downto 0);
  signal en_err_count_ph_0_dru_i                : std_logic;
  signal en_err_count_ph_0_dru_i_ila            : std_logic_vector(0 downto 0);
  signal err_count_ph_1_dru_i                   : std_logic_vector(51 downto 0);
  signal en_err_count_ph_1_dru_i                : std_logic;
  signal en_err_count_ph_1_dru_i_ila            : std_logic_vector(0 downto 0);
  attribute keep of start_eyescan_dru_i         : signal is keep_c;
  attribute keep of eyescan_busy_dru_i_ila      : signal is keep_c;
  attribute keep of waiting_time_dru_i          : signal is keep_c;
  attribute keep of err_count_ph_0_dru_i        : signal is keep_c;
  attribute keep of en_err_count_ph_0_dru_i_ila : signal is keep_c;
  attribute keep of err_count_ph_1_dru_i        : signal is keep_c;
  attribute keep of en_err_count_ph_1_dru_i_ila : signal is keep_c;

  ---------------------------------- DEBUG -----------------------------------
  --***** Virtual I/O *****
  signal probe_in0  : std_logic_vector(15 downto 0);
  signal probe_out0 : std_logic_vector(127 downto 0);

  --***** ILA *****
  signal ERR_DETECTED_IN_ila            : std_logic_vector(0 downto 0);
  attribute keep of ERR_DETECTED_IN_ila : signal is keep_c;


--vvvvvvvvvvvvvvvvvvvvvvvvvv END Wire Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvvv


begin


  tied_to_ground_i <= '0';
  tied_to_vcc_i    <= '1';


----------------------------------------------
------------------ DRU -----------------------
----------------------------------------------

  nidru_inst : nidru_wrapper_v_2_1
    generic map (
      --***** Configuration *****
      WDT_OUT     => WDT_OUT,
      DT_IN_WIDTH => DT_IN_WIDTH,

      --***** Switchable attributes *****
      --CENTER_F
      EN_CENTER_F_ATTR   => '0',
      CENTER_F_ATTR      => "0000100111110100000010100010100001110",
      --G1
      EN_G1_ATTR         => '0',
      G1_ATTR            => "01000",
      --G2
      EN_G2_ATTR         => '0',
      G2_ATTR            => "01000",
      --G1_P
      EN_G1_P_ATTR       => '0',
      G1_P_ATTR          => "01111",
      --SHIFT_S_PH (For Eyescan)
      EN_SHIFT_S_PH_ATTR => '0',
      SHIFT_S_PH_ATTR    => "00000000",
      --EN_INTEG
      EN_EN_INTEG_ATTR   => '0',
      EN_INTEG_ATTR      => '1',
      --EN(Enable) : EN when EN_EN = '1' else '1';
      EN_EN              => '0',

      --***** Eyescan *****
      PH_NUM => PH_NUM,

      --***** Logic optimization *****
      S_MAX    => S_MAX,
      MASK_CG  => X"FFFF",
      MASK_PD  => X"FFFF",
      MASK_VCO => B"1111111111111111111111111111111111111"
      )
    port map (
      --***** DATA PORTS *****
      DT_IN    => dt_in_dru_i,
      CENTER_F => center_f_dru_i,
      EN       => en_dru_i,
      CLK      => CLK,
      RST_FREQ => rst_freq_dru_i,
      RECCLK   => recclk_dru_i,
      EN_OUT   => en_out_dru_i,
      DOUT     => dout_dru_i,

      --***** CONFIG PORTS *****
      G1   => g1_dru_i,
      G1_P => g1_p_dru_i,
      G2   => g2_dru_i,

      --***** DEBUG *****
      PH_OUT     => ph_out_dru_i,
      INTEG      => integ_dru_i,
      DIRECT     => direct_dru_i,
      CTRL       => ctrl_dru_i,
      AL_PPM     => al_ppm_dru_i,
      RST        => rst_dru_i,
      PH_EST_DIS => '0',                -- by defauls 0
      EN_INTEG   => '1',                -- by default 1
      VER        => ver_dru_i,
      SAMV       => samv_dru_i,
      SAM        => sam_dru_i,

      --***** EYESCAN *****
      SHIFT_S_PH        => "00000000",
      AUTOM             => '1',
      START_EYESCAN     => start_eyescan_dru_i,
      EYESCAN_BUSY      => eyescan_busy_dru_i,
      RST_PH_0          => tied_to_ground_i,
      RST_PH_1          => tied_to_ground_i,
      RST_PH_SAMP       => tied_to_ground_i,
      ERR_PH_0          => open,
      ERR_PH_1          => open,
      --PH_0              => "00000000",
      --PH_1              => "00000000",
      PH_0_SCAN         => open,
      PH_1_SCAN         => open,
      WAITING_TIME      => waiting_time_dru_i,
      ERR_COUNT_PH_0    => err_count_ph_0_dru_i,
      EN_ERR_COUNT_PH_0 => en_err_count_ph_0_dru_i,
      ERR_COUNT_PH_1    => err_count_ph_1_dru_i,
      EN_ERR_COUNT_PH_1 => en_err_count_ph_1_dru_i
      );

  dt_in_dru_i <= DT_IN;
  en_dru_i    <= ENABLE;
  RECCLK_OUT  <= recclk_dru_i;
  DOUT_VALID  <= en_out_dru_i;
  DOUT        <= dout_dru_i;


----------------------------------------------
----------------- DEBUG ----------------------
----------------------------------------------

  WITH_DEBUGCORES : if NO_DEBUGCORES = false generate

    ila_nidru_inst : ila_nidru port map (
      clk     => CLK,                   -- input clk
      --NIDRU Data
      probe0  => dt_in_dru_i,
      probe1  => en_out_dru_i_ila,
      probe2  => dout_dru_i,
      probe3  => recclk_dru_i,
      --NIDRU Debug
      probe4  => ph_out_dru_i,
      probe5  => integ_dru_i,
      probe6  => direct_dru_i,
      probe7  => ctrl_dru_i,
      probe8  => al_ppm_dru_i_ila,
      probe9  => samv_dru_i,
      probe10 => sam_dru_i,
      --NIDRU Eyescan
      probe11 => eyescan_busy_dru_i_ila,
      probe12 => err_count_ph_0_dru_i,
      probe13 => en_err_count_ph_0_dru_i_ila,
      probe14 => err_count_ph_1_dru_i,
      probe15 => en_err_count_ph_1_dru_i_ila,
      --NIDRU Reset
      probe16 => rst_dru_i_ila,
      probe17 => rst_freq_dru_i_ila,
      --PRBS Error detection
      probe18 => ERR_DETECTED_IN_ila
      );

    vio_nidru_inst : vio_nidru port map (
      clk        => CLK,                -- input clk
      probe_in0  => probe_in0,
      probe_out0 => probe_out0
      );

    --***** ILA *****
    en_out_dru_i_ila(0)            <= en_out_dru_i;
    al_ppm_dru_i_ila(0)            <= al_ppm_dru_i;
    eyescan_busy_dru_i_ila(0)      <= eyescan_busy_dru_i;
    en_err_count_ph_0_dru_i_ila(0) <= en_err_count_ph_0_dru_i;
    en_err_count_ph_1_dru_i_ila(0) <= en_err_count_ph_1_dru_i;
    rst_dru_i_ila(0)               <= rst_dru_i;
    rst_freq_dru_i_ila(0)          <= rst_freq_dru_i;
    ERR_DETECTED_IN_ila(0)         <= ERR_DETECTED_IN;

    ----***** Virtual I/O *****
    --NIDRU Control
    center_f_dru_i      <= probe_out0(36 downto 0);    --37Bit
    rst_freq_dru_i      <= probe_out0(37);
    g1_dru_i            <= probe_out0(42 downto 38);   --5Bit
    g1_p_dru_i          <= probe_out0(47 downto 43);   --5Bit
    g2_dru_i            <= probe_out0(52 downto 48);   --5Bit
    rst_dru_i           <= probe_out0(53);
    start_eyescan_dru_i <= probe_out0(54);
    waiting_time_dru_i  <= probe_out0(102 downto 55);  --48Bit

    --NIDRU Monitoring
    probe_in0(0)          <= en_dru_i;
    probe_in0(1)          <= en_out_dru_i;
    probe_in0(9 downto 2) <= ver_dru_i;  --8Bit
    probe_in0(10)         <= eyescan_busy_dru_i;

    probe_in0(15 downto 11) <= (others => '0');

  end generate WITH_DEBUGCORES;


  WITHOUT_DEBUGCORES : if NO_DEBUGCORES = true generate

    --***** ILA *****
    en_out_dru_i_ila(0)            <= '0';
    al_ppm_dru_i_ila(0)            <= '0';
    eyescan_busy_dru_i_ila(0)      <= '0';
    en_err_count_ph_0_dru_i_ila(0) <= '0';
    en_err_count_ph_1_dru_i_ila(0) <= '0';
    rst_dru_i_ila(0)               <= '0';
    rst_freq_dru_i_ila(0)          <= '0';

    ----***** Virtual I/O *****
    --NIDRU Control
    center_f_dru_i      <= CENTER_F;
    rst_freq_dru_i      <= RST_FREQ;
    g1_dru_i            <= G1;
    g1_p_dru_i          <= G1_P;
    g2_dru_i            <= G2;
    rst_dru_i           <= RST;
    start_eyescan_dru_i <= '0';
    waiting_time_dru_i  <= (others => '0');

    --NIDRU Monitoring
    probe_in0 <= (others => '0');

  end generate WITHOUT_DEBUGCORES;

end Behavioral;

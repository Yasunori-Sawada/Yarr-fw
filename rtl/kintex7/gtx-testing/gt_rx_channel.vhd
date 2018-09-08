-- ####################################
-- # Project: Yarr
-- # Original file : fei4_rx_channel.vhd
-- # Original Author: Timon Heim
-- #   E-Mail: timon.heim at cern.ch
-- # Modified by : Kazuki Yajima (Osaka U.)
-- #   E-Mail: kazuki.yajima at cern.ch
-- # Comments: RX channel
-- # FE-I4 Style Rx Channel; Sync, Align & Decode
-- ####################################


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library decode_8b10b;

entity gt_rx_channel is
  generic
    (
      NO_DEBUGCORES : boolean := true
      );
  port
    (
      -- Sys connect
      rst_n_i  : in std_logic;
      rx_clk_i : in std_logic;

      enable_i : in std_logic;

      -- Input
      gt_rx_data_i       : in std_logic_vector(19 downto 0);  --((WDT_OUT -1) downto 0);
      gt_rx_data_valid_i : in std_logic;
      trig_tag_i         : in std_logic_vector(31 downto 0);

      -- Output
      rx_data_o     : out std_logic_vector(25 downto 0);
      rx_valid_o    : out std_logic;
      rx_stat_o     : out std_logic_vector(7 downto 0);
      rx_data_raw_o : out std_logic_vector(7 downto 0)
      );
end gt_rx_channel;



architecture behavioral of gt_rx_channel is


--^^^^^^^^^^^^^^^^^^^^^^^^^ Component Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  component gt_rx_8b10b_alignment
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
        DATA_IN       : in std_logic_vector(19 downto 0);  --((WDT_OUT -1) downto 0);
        DATA_IN_VALID : in std_logic;

        DATA_OUT       : out std_logic_vector(9 downto 0);
        DATA_OUT_VALID : out std_logic;
        DATA_OUT_SYNC  : out std_logic;  --Optional

        --------------------
        -- DEBUG
        --------------------
        SHIFTREGS_BITSLIP : out std_logic
        );
  end component;


  component decode_8b10b_wrapper
    port
      (
        CLK      : in  std_logic;
        DIN      : in  std_logic_vector(9 downto 0);
        CE       : in  std_logic;
        SINIT    : in  std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        KOUT     : out std_logic;
        CODE_ERR : out std_logic;
        DISP_ERR : out std_logic;
        ND       : out std_logic
        );
  end component;


  component ila_gtx_channel
    port
      (
        clk    : in std_logic;
        probe0 : in std_logic_vector(0 downto 0);
        probe1 : in std_logic_vector(0 downto 0);
        probe2 : in std_logic_vector(19 downto 0);
        probe3 : in std_logic_vector(0 downto 0);
        probe4 : in std_logic_vector(25 downto 0);
        probe5 : in std_logic_vector(0 downto 0);
        probe6 : in std_logic_vector(7 downto 0);
        probe7 : in std_logic_vector(7 downto 0);
        probe8 : in std_logic_vector(0 downto 0)
        );
  end component;

--vvvvvvvvvvvvvvvvvvvvvvv END Component Declarations vvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^ Parameter Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  attribute keep : string;

  constant c_SOF  : std_logic_vector(7 downto 0) := x"fc";
  constant c_EOF  : std_logic_vector(7 downto 0) := x"bc";
  constant c_IDLE : std_logic_vector(7 downto 0) := x"3c";

--vvvvvvvvvvvvvvvvvvvvvv END Parameter Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wire Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  signal rst_s : std_logic := '0';

  signal rst_s_ila                         : std_logic_vector(0 downto 0);
  signal enable_i_ila                      : std_logic_vector(0 downto 0);
  signal gt_rx_data_i_ila                  : std_logic_vector(19 downto 0);
  signal gt_rx_data_valid_i_ila            : std_logic_vector(0 downto 0);
  signal rx_data_s                         : std_logic_vector(25 downto 0);
  signal rx_valid_s                        : std_logic;
  signal rx_valid_s_ila                    : std_logic_vector(0 downto 0);
  signal rx_stat_s                         : std_logic_vector(7 downto 0);
  signal rx_data_raw_s                     : std_logic_vector(7 downto 0);
  attribute keep of rst_s_ila              : signal is "true";
  attribute keep of enable_i_ila           : signal is "true";
  attribute keep of gt_rx_data_i_ila       : signal is "true";
  attribute keep of gt_rx_data_valid_i_ila : signal is "true";
  attribute keep of rx_data_s              : signal is "true";
  attribute keep of rx_valid_s_ila         : signal is "true";
  attribute keep of rx_stat_s              : signal is "true";
  attribute keep of rx_data_raw_s          : signal is "true";

  signal data_enc_value   : std_logic_vector(9 downto 0);
  signal data_enc_valid   : std_logic;
  signal data_enc_valid_d : std_logic;
  signal data_enc_sync    : std_logic;

  signal shiftregs_bitslip_s                : std_logic;
  signal shiftregs_bitslip_s_ila            : std_logic_vector(0 downto 0);
  attribute keep of shiftregs_bitslip_s_ila : signal is "true";

  signal data_dec_value   : std_logic_vector(7 downto 0);
  signal data_dec_valid   : std_logic;
  signal data_dec_kchar   : std_logic;
  signal data_dec_decerr  : std_logic;
  signal data_dec_disperr : std_logic;

  signal data_fram_cnt    : unsigned(1 downto 0);
  signal data_frame_flag  : std_logic;
  signal data_frame_value : std_logic_vector(25 downto 0);
  signal data_frame_valid : std_logic;

  signal status : std_logic_vector(7 downto 0);

--vvvvvvvvvvvvvvvvvvvvvvvvvv END Wire Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvvv


begin

  -- Reset
  rst_s <= not rst_n_i;

  -- Status Output
  rx_stat_s          <= status;
  status(0)          <= data_enc_valid;                      --data_raw_lock;
  status(1)          <= data_enc_sync;
  status(2)          <= data_dec_decerr;
  status(3)          <= data_dec_disperr;
  status(5 downto 4) <= data_dec_valid & data_dec_kchar;     --data_raw_value;
  status(7 downto 6) <= data_frame_valid & data_frame_flag;  --data_raw_valid;
  rx_data_raw_s      <= data_dec_value;

  -- Frame collector
  rx_data_s  <= data_frame_value;
  rx_valid_s <= data_frame_valid and data_enc_sync and enable_i;
  framing_proc : process(rx_clk_i, rst_n_i)
  begin
    if (rst_n_i = '0') then
      data_fram_cnt    <= (others => '0');
      data_frame_flag  <= '0';
      data_frame_value <= (others => '0');
      data_frame_valid <= '0';
    elsif rising_edge(rx_clk_i) then
      -- Count bytes
      if (data_frame_flag = '1' and data_dec_valid = '1' and data_fram_cnt = 2) then
        data_fram_cnt    <= (others => '0');
        data_frame_valid <= '1';
      elsif (data_frame_flag = '1' and data_dec_valid = '1' and data_fram_cnt < 2) then
        data_fram_cnt    <= data_fram_cnt + 1;
        data_frame_valid <= '0';
      elsif (data_frame_flag = '0') then
        data_fram_cnt    <= (others => '0');
        data_frame_valid <= '0';
      else
        data_frame_valid <= '0';
      end if;

      -- Mark Start and End of Frame
      if (data_dec_valid = '1' and data_dec_kchar = '1' and data_dec_value = c_SOF and data_enc_sync = '1') then
        data_frame_flag                <= '1';
        data_frame_value(25 downto 24) <= "01";  -- tag code
        data_frame_value(23 downto 0)  <= trig_tag_i(23 downto 0);
        data_frame_valid               <= '1';
      elsif (data_dec_valid = '1' and data_dec_kchar = '1' and (data_dec_value = c_EOF or data_dec_value = c_IDLE)) then
        data_frame_flag <= '0';
      end if;

                                                 -- Build Frame
      if (data_frame_flag = '1' and data_dec_valid = '1' and data_dec_kchar = '0') then
        data_frame_value(25 downto 24) <= "00";  -- no special code
        data_frame_value(23 downto 16) <= data_frame_value(15 downto 8);
        data_frame_value(15 downto 8)  <= data_frame_value(7 downto 0);
        data_frame_value(7 downto 0)   <= data_dec_value;
      end if;
    end if;
  end process framing_proc;


  valid_delay : process (rx_clk_i, rst_n_i)
  begin
    if rst_n_i = '0' then
      data_enc_valid_d <= '0';
    elsif rising_edge(rx_clk_i) then
      data_enc_valid_d <= data_enc_valid;
      data_dec_valid   <= data_enc_valid_d;
    end if;
  end process;


  gt_rx_8b10b_alignment_i : gt_rx_8b10b_alignment
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
      DATA_IN       => gt_rx_data_i,
      DATA_IN_VALID => gt_rx_data_valid_i,

      DATA_OUT       => data_enc_value,
      DATA_OUT_VALID => data_enc_valid,
      DATA_OUT_SYNC  => data_enc_sync,

      --------------------
      -- DEBUG
      --------------------
      SHIFTREGS_BITSLIP => shiftregs_bitslip_s
      );


  cmp_decoder : decode_8b10b_wrapper
    port map
    (
      CLK      => rx_clk_i,
      DIN      => data_enc_value,
      CE       => data_enc_valid,
      SINIT    => '0',
      DOUT     => data_dec_value,
      KOUT     => data_dec_kchar,
      CODE_ERR => data_dec_decErr,
      DISP_ERR => data_dec_dispErr,
      ND       => open
      );


  WITH_DEBUGCORES : if NO_DEBUGCORES = false generate

    ila_gtx_channel_i : ila_gtx_channel
      port map
      (
        clk    => rx_clk_i,
        probe0 => rst_s_ila,
        probe1 => enable_i_ila,
        probe2 => gt_rx_data_i_ila,
        probe3 => gt_rx_data_valid_i_ila,
        probe4 => rx_data_s,
        probe5 => rx_valid_s_ila,
        probe6 => rx_stat_s,
        probe7 => rx_data_raw_s,
        probe8 => shiftregs_bitslip_s_ila
        );

    rst_s_ila(0)               <= rst_s;
    enable_i_ila(0)            <= enable_i;
    gt_rx_data_i_ila           <= gt_rx_data_i;
    gt_rx_data_valid_i_ila(0)  <= gt_rx_data_valid_i;
    rx_valid_s_ila(0)          <= rx_valid_s;
    shiftregs_bitslip_s_ila(0) <= shiftregs_bitslip_s;

  end generate WITH_DEBUGCORES;

  WITHOUT_DEBUGCORES : if NO_DEBUGCORES = true generate

    rst_s_ila(0)               <= '0';
    enable_i_ila(0)            <= '0';
    gt_rx_data_i_ila           <= (others => '0');
    gt_rx_data_valid_i_ila(0)  <= '0';
    rx_valid_s_ila(0)          <= '0';
    shiftregs_bitslip_s_ila(0) <= '0';

  end generate WITHOUT_DEBUGCORES;


  rx_data_o     <= rx_data_s;
  rx_valid_o    <= rx_valid_s;
  rx_stat_o     <= rx_stat_s;
  rx_data_raw_o <= rx_data_raw_s;

end behavioral;

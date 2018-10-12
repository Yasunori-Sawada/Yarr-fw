----------------------------------------------------------------------------------
-- Company: Osaka University
-- Engineer: Kazuki Yajima(kyajima@cern.ch)
-- 
-- Create Date: 08/10/2018 10:34:14 AM
-- Design Name: 
-- Module Name: gt_rx_alignment - Behavioral
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


entity gt_rx_8b10b_alignment is
  generic
    (
      DATA_IN_WIDTH  : integer range 1 to 20 := 20;
      VALID_INTERVAL : integer               := 20
      -- NOTICE : VALID_INTERVAL must be equal or more than DATA_IN_WIDTH/2
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
      DATA_IN       : in std_logic_vector(DATA_IN_WIDTH-1 downto 0);
      DATA_IN_VALID : in std_logic;

      DATA_OUT       : out std_logic_vector(9 downto 0);
      DATA_OUT_VALID : out std_logic;
      DATA_OUT_SYNC  : out std_logic;   --Optional

      --------------------
      -- DEBUG
      --------------------
      ABNORMAL_INTERVAL : out std_logic;
      BITSLIP_DATALOST  : out std_logic
      );
end gt_rx_8b10b_alignment;



architecture Behavioral of gt_rx_8b10b_alignment is


--^^^^^^^^^^^^^^^^^^^^^^^^^ Component Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

--vvvvvvvvvvvvvvvvvvvvvvv END Component Declarations vvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^ Parameter Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  -- FE-I4 Encoded Comma Words used for Alignment of the Decoder
  constant IDLE_WORD : std_logic_vector(9 downto 0) := "1001111100";  --"0011111001";
  constant SOF_WORD  : std_logic_vector(9 downto 0) := "0001111100";  --"0011111000";
  constant EOF_WORD  : std_logic_vector(9 downto 0) := "0101111100";  --"0011111010";

  --constant SYNC_EXPIRE_TIME : integer := 160000000;  -- Same as YARR
  constant SYNC_EXPIRE_TIME : integer := 8388607;  -- 2**23-1

--vvvvvvvvvvvvvvvvvvvvvv END Parameter Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wire Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  signal data_sr_i       : std_logic_vector((DATA_IN_WIDTH-1)+11 downto 0);
  signal datashift_cnt_i : integer range 0 to 31 := 0;

  signal data_aligned_even_i : std_logic;
  signal data_aligned_odd_i  : std_logic;

  signal detect_idle_even_i : std_logic;
  signal detect_sof_even_i  : std_logic;
  signal detect_eof_even_i  : std_logic;
  signal detect_idle_odd_i  : std_logic;
  signal detect_sof_odd_i   : std_logic;
  signal detect_eof_odd_i   : std_logic;

  signal detect_comma_even_i : std_logic;
  signal detect_comma_odd_i  : std_logic;

  signal dout_valid_d1 : std_logic := '0';
  signal dout_valid_d2 : std_logic := '0';

  signal databit_cnt_i  : integer range 0 to 15               := 0;
  signal synctime_cnt_i : integer range 0 to SYNC_EXPIRE_TIME := 0;
  --signal synctime_cnt_i : integer range 0 to 4294967295 := 0;

--vvvvvvvvvvvvvvvvvvvvvvvvvv END Wire Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvvv


begin


  data_shift_register : process (CLK_IN, RESET)
  begin
    if RESET = '1' then
      data_sr_i         <= (others => '0');
      datashift_cnt_i   <= 0;
      ABNORMAL_INTERVAL <= '0';
      BITSLIP_DATALOST  <= '0';

    elsif rising_edge(CLK_IN) then
      if DATA_IN_VALID = '1' then
        data_sr_i((DATA_IN_WIDTH-1)+11 downto 11) <= DATA_IN;
        datashift_cnt_i                           <= 0;
        if datashift_cnt_i = VALID_INTERVAL-1 then
          ABNORMAL_INTERVAL <= '0';
        else
          ABNORMAL_INTERVAL <= '1';
        end if;

        if datashift_cnt_i < DATA_IN_WIDTH/2 then
          BITSLIP_DATALOST <= '1';
        else
          BITSLIP_DATALOST <= '0';
        end if;

      else
        if datashift_cnt_i < DATA_IN_WIDTH/2 then
          data_sr_i((DATA_IN_WIDTH-1)+11 downto 0) <= "00" & data_sr_i((DATA_IN_WIDTH-1)+11 downto 2);
        end if;
        datashift_cnt_i   <= datashift_cnt_i + 1;
        ABNORMAL_INTERVAL <= '0';
        BITSLIP_DATALOST  <= '0';
      end if;

    end if;
  end process;


  detect_idle_even_i <= '1' when (data_sr_i(10 downto 1) = IDLE_WORD or data_sr_i(10 downto 1) = not IDLE_WORD) else '0';
  detect_sof_even_i  <= '1' when (data_sr_i(10 downto 1) = SOF_WORD or data_sr_i(10 downto 1) = not SOF_WORD)   else '0';
  detect_eof_even_i  <= '1' when (data_sr_i(10 downto 1) = EOF_WORD or data_sr_i(10 downto 1) = not EOF_WORD)   else '0';
  detect_idle_odd_i  <= '1' when (data_sr_i(9 downto 0) = IDLE_WORD or data_sr_i(9 downto 0) = not IDLE_WORD)   else '0';
  detect_sof_odd_i   <= '1' when (data_sr_i(9 downto 0) = SOF_WORD or data_sr_i(9 downto 0) = not SOF_WORD)     else '0';
  detect_eof_odd_i   <= '1' when (data_sr_i(9 downto 0) = EOF_WORD or data_sr_i(9 downto 0) = not EOF_WORD)     else '0';

  detect_comma_even_i <= '1' when (detect_idle_even_i = '1' or detect_sof_even_i = '1' or detect_eof_even_i = '1') else '0';
  detect_comma_odd_i  <= '1' when (detect_idle_odd_i = '1' or detect_sof_odd_i = '1' or detect_eof_odd_i = '1')    else '0';

  sampling_data : process(CLK_IN, RESET)
  begin
    if RESET = '1' then
      DATA_OUT            <= (others => '0');
      dout_valid_d1       <= '0';
      data_aligned_even_i <= '0';
      data_aligned_odd_i  <= '0';
      databit_cnt_i       <= 0;
      synctime_cnt_i      <= 0;

    elsif rising_edge(CLK_IN) then
      if (detect_comma_even_i = '1' or detect_comma_odd_i = '1') then
        if detect_comma_even_i = '1' then
          DATA_OUT            <= data_sr_i(10 downto 1);
          data_aligned_even_i <= '1';
          data_aligned_odd_i  <= '0';
        elsif detect_comma_odd_i = '1' then
          DATA_OUT            <= data_sr_i(9 downto 0);
          data_aligned_even_i <= '0';
          data_aligned_odd_i  <= '1';
        end if;

        dout_valid_d1  <= '1';
        databit_cnt_i  <= 0;
        synctime_cnt_i <= 0;

      elsif data_aligned_even_i = '1' or data_aligned_odd_i = '1' then
        if data_aligned_even_i = '1' then
          DATA_OUT <= data_sr_i(10 downto 1);
        elsif data_aligned_odd_i = '1' then
          DATA_OUT <= data_sr_i(9 downto 0);
        end if;

        if synctime_cnt_i = SYNC_EXPIRE_TIME then
          data_aligned_even_i <= '0';
          data_aligned_odd_i  <= '0';
          synctime_cnt_i      <= 0;
        else
          synctime_cnt_i <= synctime_cnt_i + 1;
        end if;

        if databit_cnt_i = 8 then
          dout_valid_d1 <= '1';
          databit_cnt_i <= 0;
        else
          dout_valid_d1 <= '0';
          if datashift_cnt_i < 10 then
            databit_cnt_i <= databit_cnt_i + 2;
          end if;
        end if;

      else
        dout_valid_d1       <= '0';
        data_aligned_even_i <= '0';
        data_aligned_odd_i  <= '0';
        databit_cnt_i       <= 0;
        synctime_cnt_i      <= 0;
      end if;

    end if;
  end process;


  detect_edge : process(CLK_IN, RESET)
  begin
    if RESET = '1' then
      dout_valid_d2 <= '0';
    elsif rising_edge(CLK_IN) then
      dout_valid_d2 <= dout_valid_d1;
    end if;
  end process;

  DATA_OUT_VALID <= '1' when (dout_valid_d1 = '1' and dout_valid_d2 = '0') else '0';
  DATA_OUT_SYNC  <= data_aligned_even_i or data_aligned_odd_i;

end Behavioral;

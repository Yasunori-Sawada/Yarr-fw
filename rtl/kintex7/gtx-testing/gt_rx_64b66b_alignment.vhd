----------------------------------------------------------------------------------
-- Company: Osaka University
-- Engineer: Kazuki Yajima(kyajima@cern.ch)
-- 
-- Create Date: 08/10/2018 10:34:14 AM
-- Design Name: 
-- Module Name: gt_rx_64b66b_alignment - Behavioral
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


entity gt_rx_64b66b_alignment is
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
end gt_rx_64b66b_alignment;



architecture Behavioral of gt_rx_64b66b_alignment is


--^^^^^^^^^^^^^^^^^^^^^^^^ Parameter Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  -- Valid sync headers for 64b66b
  constant c_DATA_HEADER : std_logic_vector(1 downto 0) := "10";
  constant c_CMND_HEADER : std_logic_vector(1 downto 0) := "01";

  constant c_WAITING_SYNC     : integer := 32;
  constant c_ERROR_THRESHOLD  : integer := 5;
  constant c_ERROR_EXPIRATION : integer := 10;

--vvvvvvvvvvvvvvvvvvvvvv END Parameter Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wire Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  signal data_sr_s       : std_logic_vector(16*6-1 downto 0);  --((DATA_IN_WIDTH-1)+10+1 downto 0);
  signal datashift_cnt_s : integer range 0 to 15 := 1;

  signal data_out_s    : std_logic_vector(65 downto 0) := (others => '0');
  signal dout_valid_s  : std_logic                     := '0';
  signal start_point_s : integer range 0 to 127        := 66;

  signal slide_outdata_s      : std_logic := '0';
  signal slide_outdata_flag_s : std_logic := '0';

  signal databit_cnt_s   : integer range 0 to 15                 := 0;
  signal synctime_cnt_s  : integer range 0 to c_WAITING_SYNC     := 0;
  signal error_cnt_s     : integer range 0 to c_ERROR_THRESHOLD  := 0;
  signal error_exp_cnt_s : integer range 0 to c_ERROR_EXPIRATION := 0;

--vvvvvvvvvvvvvvvvvvvvvvvvvv END Wire Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvvv


begin


  data_shift_registers : process (CLK_IN, RESET)
  begin
    if RESET = '1' then
      data_sr_s         <= (others => '0');
      datashift_cnt_s   <= 1;
      ABNORMAL_INTERVAL <= '0';

    elsif rising_edge(CLK_IN) then
      if DATA_IN_VALID = '1' then
        datashift_cnt_s <= 0;

        if datashift_cnt_s = 1 then
          data_sr_s(16*6-1 downto 16*5) <= DATA_IN;
          ABNORMAL_INTERVAL             <= '0';
        elsif datashift_cnt_s < 1 then
          data_sr_s         <= DATA_IN & data_sr_s(16*6-1 downto 16);
          ABNORMAL_INTERVAL <= '1';
        else
          data_sr_s(16*6-1 downto 16*5) <= DATA_IN;
          ABNORMAL_INTERVAL             <= '1';
        end if;

      else
        if datashift_cnt_s < 1 then
          data_sr_s <= "0000000000000000" & data_sr_s(16*6-1 downto 16);
        end if;
        datashift_cnt_s   <= datashift_cnt_s + 1;
        ABNORMAL_INTERVAL <= '0';
      end if;

    end if;
  end process data_shift_registers;


  gearbox_to_66bit : process(CLK_IN, RESET)
  begin
    if RESET = '1' then
      data_out_s           <= (others => '0');
      dout_valid_s         <= '0';
      start_point_s        <= 66;
      slide_outdata_flag_s <= '0';

    elsif rising_edge(CLK_IN) then

      if slide_outdata_s = '1' then
        slide_outdata_flag_s <= '1';
      elsif start_point_s < 16 and slide_outdata_flag_s = '1' then
        slide_outdata_flag_s <= '0';
      end if;

      if start_point_s < 16 then
        dout_valid_s <= '1';
        if slide_outdata_flag_s = '1' then
          data_out_s    <= data_sr_s(65+start_point_s+1 downto start_point_s+1);
          start_point_s <= start_point_s+1 + 66;
        else
          data_out_s    <= data_sr_s(65+start_point_s downto start_point_s);
          start_point_s <= start_point_s + 66;
        end if;
      else
        dout_valid_s <= '0';
        if datashift_cnt_s < 1 then
          start_point_s <= start_point_s - 16;
        end if;
      end if;

    end if;
  end process gearbox_to_66bit;


  check_syncheader : process(CLK_IN, RESET)
  begin
    if RESET = '1' then
      synctime_cnt_s  <= 0;
      error_cnt_s     <= 0;
      error_exp_cnt_s <= 0;
      slide_outdata_s <= '0';
      DATA_OUT_SYNC   <= '0';

    elsif rising_edge(CLK_IN) then

      if dout_valid_s = '1' then
        if data_out_s(1 downto 0) = c_DATA_HEADER or data_out_s(1 downto 0) = c_CMND_HEADER then

          if synctime_cnt_s = c_WAITING_SYNC then
            DATA_OUT_SYNC <= '1';
          elsif synctime_cnt_s < c_WAITING_SYNC then
            synctime_cnt_s <= synctime_cnt_s + 1;
          end if;

          if error_exp_cnt_s = c_ERROR_EXPIRATION then
            error_cnt_s     <= 0;
            error_exp_cnt_s <= 0;
          elsif error_exp_cnt_s < c_ERROR_EXPIRATION then
            error_exp_cnt_s <= error_exp_cnt_s + 1;
          end if;

        else

          if error_cnt_s = c_ERROR_THRESHOLD then
            synctime_cnt_s  <= 0;
            error_cnt_s     <= 0;
            slide_outdata_s <= '1';
            DATA_OUT_SYNC   <= '0';
          elsif error_cnt_s < c_ERROR_THRESHOLD then
            error_cnt_s     <= error_cnt_s + 1;
            error_exp_cnt_s <= 0;
          end if;

        end if;
      else
        slide_outdata_s <= '0';
      end if;

    end if;
  end process check_syncheader;


  DATA_OUT       <= data_out_s;
  DATA_OUT_VALID <= dout_valid_s;

end Behavioral;

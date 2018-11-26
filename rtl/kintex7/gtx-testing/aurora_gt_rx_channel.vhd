----------------------------------------------------------------------------------
-- Company: Osaka University
-- Engineer: Kazuki Yajima(kyajima@cern.ch)
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: aurora_gt_rx_channel - Behavioral
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


-- Type definition
library IEEE;
use IEEE.STD_LOGIC_1164.all;

package aurora_gt_rx_channel_pkg is
  type rx_lane_array is array (natural range <>) of std_logic_vector(15 downto 0);
end aurora_gt_rx_channel_pkg;
-- END Type definition


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

-- User package
library work;
use work.aurora_gt_rx_channel_pkg.all;


entity aurora_gt_rx_channel is
  generic
    (
      g_NUM_LANES : integer range 1 to 4 := 1
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
      gt_rx_data_i       : in rx_lane_array(g_NUM_LANES-1 downto 0);
      gt_rx_data_valid_i : in std_logic_vector(g_NUM_LANES-1 downto 0);

      --------------------
      -- Data Output
      --------------------
      rx_data_o  : out std_logic_vector(63 downto 0);
      rx_valid_o : out std_logic;
      rx_stat_o  : out std_logic_vector(7 downto 0)
      );
end aurora_gt_rx_channel;



architecture behavioral of aurora_gt_rx_channel is


--^^^^^^^^^^^^^^^^^^^^^^^^^ Component Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  function log2_ceil(val : integer) return natural is
    variable result : natural;
  begin
    for i in 0 to g_NUM_LANES-1 loop
      if (val <= (2 ** i)) then
        result := i;
        exit;
      end if;
    end loop;
    return result;
  end function;


  component aurora_gt_rx_lane
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
  end component aurora_gt_rx_lane;


  component rx_channel_fifo
    port (
      rst    : in  std_logic;
      wr_clk : in  std_logic;
      rd_clk : in  std_logic;
      din    : in  std_logic_vector(63 downto 0);
      wr_en  : in  std_logic;
      rd_en  : in  std_logic;
      dout   : out std_logic_vector(63 downto 0);
      full   : out std_logic;
      empty  : out std_logic
      );
  end component;


  component rr_arbiter
    generic (
      g_CHANNELS : integer := g_NUM_LANES
      );
    port (
      -- sys connect
      clk_i : in  std_logic;
      rst_i : in  std_logic;
      -- requests
      req_i : in  std_logic_vector(g_NUM_LANES-1 downto 0);
      -- grants
      gnt_o : out std_logic_vector(g_NUM_LANES-1 downto 0)
      );
  end component rr_arbiter;

--vvvvvvvvvvvvvvvvvvvvvvv END Component Declarations vvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^ Parameter Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  constant c_DATA_HEADER : std_logic_vector(1 downto 0) := "01";
  constant c_CTRL_HEADER : std_logic_vector(1 downto 0) := "10";

  constant c_EMPTY_TYPE       : std_logic_vector(7 downto 0) := x"1E";
  constant c_CNTRL_TYPE       : std_logic_vector(7 downto 0) := x"78";
  constant c_AUTOR_AUTOR_TYPE : std_logic_vector(7 downto 0) := x"B4";
  constant c_AUTOR_RDREG_TYPE : std_logic_vector(7 downto 0) := x"55";
  constant c_RDREG_AUTOR_TYPE : std_logic_vector(7 downto 0) := x"99";
  constant c_RDREG_RDREG_TYPE : std_logic_vector(7 downto 0) := x"D2";
  constant c_ERROR_TYPE       : std_logic_vector(7 downto 0) := x"CC";

--vvvvvvvvvvvvvvvvvvvvvv END Parameter Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wire Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  signal rst_s : std_logic := '0';

  signal rx_data_s  : std_logic_vector(63 downto 0);
  signal rx_valid_s : std_logic;

  type rx_data_array is array (g_NUM_LANES-1 downto 0) of std_logic_vector(63 downto 0);
  type rx_header_array is array (g_NUM_LANES-1 downto 0) of std_logic_vector(1 downto 0);
  type rx_status_array is array (g_NUM_LANES-1 downto 0) of std_logic_vector(7 downto 0);

  signal rx_descrambled_64bits_s : rx_data_array;
  signal rx_header_2bits_s       : rx_header_array;
  signal rx_status_s             : rx_status_array;

  signal rx_descrambled_valid_s : std_logic_vector(g_NUM_LANES-1 downto 0);

  signal frametype_8bits_s : rx_status_array;

  signal rx_fifo_din_s      : rx_data_array;
  signal rx_fifo_wren_s     : std_logic_vector(g_NUM_LANES-1 downto 0);
  signal rx_fifo_rden_s     : std_logic_vector(g_NUM_LANES-1 downto 0);
  signal rx_fifo_rden_tmp_s : std_logic_vector(g_NUM_LANES-1 downto 0);

  signal rx_fifo_dout_s      : rx_data_array;
  signal rx_fifo_full_s      : std_logic_vector(g_NUM_LANES-1 downto 0);
  signal rx_fifo_empty_s     : std_logic_vector(g_NUM_LANES-1 downto 0);
  signal rx_fifo_not_empty_s : std_logic_vector(g_NUM_LANES-1 downto 0);

  signal channel : integer range 0 to g_NUM_LANES-1;

--vvvvvvvvvvvvvvvvvvvvvvvvvv END Wire Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvvv


begin

  rst_s <= not rst_n_i;

  rx_lane_loop : for I in 0 to g_NUM_LANES-1 generate

    aurora_gt_rx_lane_inst : aurora_gt_rx_lane
      port map
      (
        rst_n_i            => rst_n_i,
        rx_clk_i           => rx_clk_i,
        enable_i           => enable_i,
        gt_rx_data_i       => gt_rx_data_i(I),
        gt_rx_data_valid_i => gt_rx_data_valid_i(I),
        rx_data_o          => rx_descrambled_64bits_s(I),
        rx_header_o        => rx_header_2bits_s(I),
        rx_valid_o         => rx_descrambled_valid_s(I),
        rx_stat_o          => open
        );


    -- TODO need to save register reads!
    -- TODO use

    -- We expect these types of data:
    -- b01 - D[63:0] - 64 bit data
    -- b10 - 0x1E - 0x04 - 0xXXXX - D[31:0] - 32 bit data
    -- b10 - 0x1E - 0x00 - 0x0000 - 0x00000000 - 0 bit data
    -- b10 - 0x78 - Flag[7:0] - 0xXXXX - 0xXXXXXXXX - Idle
    -- b10 - 0xB4 - D[55:0] - Register read (MM)
    frametype_8bits_s(I) <= rx_descrambled_64bits_s(I)(63 downto 56) when rx_header_2bits_s(I) = c_CTRL_HEADER else x"DA";

    -- Swapping [63:32] and [31:0] to reverse swapping by casting 64-bit to uint32_t
    data_filter : process (rx_clk_i, rst_s)
    begin
      if rst_s = '1' then
        rx_fifo_din_s(I)  <= (others => '0');
        rx_fifo_wren_s(I) <= '0';

      elsif rising_edge(rx_clk_i) then

        if rx_header_2bits_s(I) = c_DATA_HEADER then
          -------------------------
          -- DATA FRAME
          rx_fifo_din_s(I)  <= rx_descrambled_64bits_s(I)(31 downto 0) & rx_descrambled_64bits_s(I)(63 downto 32);
          rx_fifo_wren_s(I) <= rx_descrambled_valid_s(I);

        elsif rx_header_2bits_s(I) = c_CTRL_HEADER then
          -------------------------
          -- COMMAND or DATA FRAME
          if (frametype_8bits_s(I) = c_AUTOR_RDREG_TYPE or
              frametype_8bits_s(I) = c_RDREG_AUTOR_TYPE or
              frametype_8bits_s(I) = c_RDREG_RDREG_TYPE) then
            rx_fifo_din_s(I)  <= rx_descrambled_64bits_s(I)(31 downto 0) & rx_descrambled_64bits_s(I)(63 downto 32);
            rx_fifo_wren_s(I) <= rx_descrambled_valid_s(I);
          elsif frametype_8bits_s(I) = c_EMPTY_TYPE then
            rx_fifo_din_s(I) <= rx_descrambled_64bits_s(I)(31 downto 0) & x"FFFFFFFF";
            if rx_descrambled_64bits_s(I)(55 downto 48) = x"04" then
              rx_fifo_wren_s(I) <= rx_descrambled_valid_s(I);
            else
              rx_fifo_wren_s(I) <= '0';
            end if;
          end if;

        else
          -------------------------
          -- OTHERS
          rx_fifo_din_s(I)  <= (others => '0');
          rx_fifo_wren_s(I) <= '0';

        end if;

      end if;
    end process;

    cmp_lane_fifo : rx_channel_fifo
      port map
      (
        rst    => rst_s,
        wr_clk => rx_clk_i,
        rd_clk => rx_clk_i,
        din    => rx_fifo_din_s(I),
        wr_en  => rx_fifo_wren_s(I),
        rd_en  => rx_fifo_rden_s(I),
        dout   => rx_fifo_dout_s(I),
        full   => rx_fifo_full_s(I),
        empty  => rx_fifo_empty_s(I)
        );

  end generate rx_lane_loop;


  -- Arbiter
  rx_fifo_not_empty_s <= not rx_fifo_empty_s;
  cmp_rr_arbiter : rr_arbiter
    port map
    (
      clk_i => rx_clk_i,
      rst_i => rst_s,
      req_i => rx_fifo_not_empty_s,
      gnt_o => rx_fifo_rden_tmp_s
      );


  reg_proc : process (rx_clk_i, rst_n_i)
  begin
    if (rst_n_i = '0') then
      rx_fifo_rden_s <= (others => '0');
      rx_data_s      <= (others => '0');
      rx_valid_s     <= '0';
      channel        <= 0;
    elsif rising_edge(rx_clk_i) then
      rx_fifo_rden_s <= rx_fifo_rden_tmp_s;
      channel        <= log2_ceil(to_integer(unsigned(rx_fifo_rden_tmp_s)));
      if (unsigned(rx_fifo_rden_s) = 0 or ((rx_fifo_rden_s and rx_fifo_empty_s) = rx_fifo_rden_s)) then
        rx_valid_s <= '0';
        rx_data_s  <= x"DEADBEEFDEADBEEF";
      else
        rx_valid_s <= '1';
        rx_data_s  <= rx_fifo_dout_s(channel);
      end if;
    end if;
  end process reg_proc;


  rx_data_o  <= rx_data_s;
  rx_valid_o <= rx_valid_s;

end behavioral;

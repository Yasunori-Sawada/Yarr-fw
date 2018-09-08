library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library decode_8b10b;

entity gt_rx_channel_tb is
end gt_rx_channel_tb;



architecture simulation of gt_rx_channel_tb is


--^^^^^^^^^^^^^^^^^^^^^^^^^ Component Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  component gt_rx_channel
    port
      (
        -- Sys connect
        rst_n_i   : in std_logic;
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
  end component;

--vvvvvvvvvvvvvvvvvvvvvvv END Component Declarations vvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^ Parameter Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  constant clk_period : time := 6.25 ns;
  constant rst_time   : time := 100 ns;

  constant IDLE_WORD : std_logic_vector(9 downto 0) := "1001111100";  --"0011111001";
  constant SOF_WORD  : std_logic_vector(9 downto 0) := "0001111100";  --"0011111000";
  constant EOF_WORD  : std_logic_vector(9 downto 0) := "0101111100";  --"0011111010";

--vvvvvvvvvvvvvvvvvvvvvv END Parameter Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wire Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  -- Sys connect
  signal rst_n_s   : std_logic := '0';
  signal rx_clk_s : std_logic := '0';

  signal enable_s : std_logic := '1';

  -- Input
  signal gt_rx_data_s       : std_logic_vector(19 downto 0) := (others => '0');  --((WDT_OUT -1) downto 0);
  signal gt_rx_data_valid_s : std_logic                     := '0';
  signal trig_tag_s         : std_logic_vector(31 downto 0) := (others => '0');

  -- Output
  signal rx_data_o     : std_logic_vector(25 downto 0);
  signal rx_valid_o    : std_logic;
  signal rx_stat_o     : std_logic_vector(7 downto 0);
  signal rx_data_raw_o : std_logic_vector(7 downto 0);

--vvvvvvvvvvvvvvvvvvvvvvvvvv END Wire Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Procedures ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  procedure tic (count : integer := 1) is
  begin
    for i in 1 to count loop
      wait until rising_edge(rx_clk_s);
    end loop;
  end tic;

  procedure data_send
    (
      data                        : in  std_logic_vector(19 downto 0);
      signal gt_rx_data_tmp       : out std_logic_vector(19 downto 0);
      signal gt_rx_data_valid_tmp : out std_logic
      )
  is
  begin
    gt_rx_data_tmp       <= data;
    gt_rx_data_valid_tmp <= '1';
    tic;
    gt_rx_data_tmp       <= (others => '0');
    gt_rx_data_valid_tmp <= '0';
    tic(19);
  end data_send;

--vvvvvvvvvvvvvvvvvvvvvvvvvv END Procedures vvvvvvvvvvvvvvvvvvvvvvvvvvvv

begin

  gt_rx_channel_i : gt_rx_channel
    port map
    (
      -- Sys connect
      rst_n_i   => rst_n_s,
      rx_clk_i => rx_clk_s,

      enable_i => enable_s,

      -- Input
      gt_rx_data_i       => gt_rx_data_s,
      gt_rx_data_valid_i => gt_rx_data_valid_s,
      trig_tag_i         => trig_tag_s,

      -- Output
      rx_data_o     => rx_data_o,
      rx_valid_o    => rx_valid_o,
      rx_stat_o     => rx_stat_o,
      rx_data_raw_o => rx_data_raw_o
      );

  clk : process
  begin
    rx_clk_s <= '0';
    wait for clk_period/2;
    rx_clk_s <= '1';
    wait for clk_period/2;
  end process;

  stim_proc : process
  begin
    wait for rst_time;
    rst_n_s <= '1';

    tic(10);
    data_send("11111000110000011100", gt_rx_data_s, gt_rx_data_valid_s);
    data_send("11111000110000011100", gt_rx_data_s, gt_rx_data_valid_s);
    data_send("11111000110000011100", gt_rx_data_s, gt_rx_data_valid_s);
    data_send("10001011110000011100", gt_rx_data_s, gt_rx_data_valid_s);
    data_send("01110011010010010011", gt_rx_data_s, gt_rx_data_valid_s);
    data_send("11100111000111010001", gt_rx_data_s, gt_rx_data_valid_s);
    data_send("01110100011100100100", gt_rx_data_s, gt_rx_data_valid_s);
    data_send("01110011001011100100", gt_rx_data_s, gt_rx_data_valid_s);

  end process;

end simulation;


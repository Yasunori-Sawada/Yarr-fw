library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity rx_64b66b_descrambler_tb is
end rx_64b66b_descrambler_tb;



architecture simulation of rx_64b66b_descrambler_tb is


--^^^^^^^^^^^^^^^^^^^^^^^^^ Component Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  component descrambler
    port (
      data_in   : in  std_logic_vector(0 to 65);
      data_out  : out std_logic_vector(63 downto 0);
      enable    : in  std_logic;
      sync_info : out std_logic_vector(1 downto 0);
      clk       : in  std_logic;
      rst       : in  std_logic
      );
  end component descrambler;

  component gt_rx_64b66b_descrambler
    port (
      CLK_IN         : in  std_logic;
      RESET          : in  std_logic;
      DATA_IN        : in  std_logic_vector(65 downto 0);  --((WDT_OUT -1) downto 0);
      DATA_IN_VALID  : in  std_logic;   -- High width must be 1
      DATA_OUT       : out std_logic_vector(63 downto 0);
      DATA_OUT_VALID : out std_logic;
      SYNCHEADER_OUT : out std_logic_vector(1 downto 0)
      );
  end component gt_rx_64b66b_descrambler;


--vvvvvvvvvvvvvvvvvvvvvvv END Component Declarations vvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^ Parameter Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  constant clk_period : time := 6.25 ns;
  constant rst_time   : time := 100 ns;

--vvvvvvvvvvvvvvvvvvvvvv END Parameter Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wire Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  -- Sys connect
  signal rst_s : std_logic := '1';
  signal clk_s : std_logic := '0';

  -- Input
  signal data_in_s : std_logic_vector(0 to 65) := (others => '0');
  signal enable_s  : std_logic                 := '0';

  -- Output
  signal data_out_1 : std_logic_vector(63 downto 0);
  signal data_out_2 : std_logic_vector(63 downto 0);

  signal sync_info_1 : std_logic_vector(1 downto 0);
  signal sync_info_2 : std_logic_vector(1 downto 0);

  signal compare_1_and_2 : std_logic;

--vvvvvvvvvvvvvvvvvvvvvvvvvv END Wire Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Procedures ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  procedure tic (count : integer := 1) is
  begin
    for i in 1 to count loop
      wait until rising_edge(clk_s);
    end loop;
  end tic;

  procedure data_send
    (
      data_in               : in  std_logic_vector(0 to 65);
      signal data_in_tmp    : out std_logic_vector(0 to 65);
      signal data_valid_tmp : out std_logic
      )
  is
  begin
    data_in_tmp    <= data_in;
    data_valid_tmp <= '1';
    tic;
    --data_in_tmp       <= (others => '0');
    data_valid_tmp <= '0';
    tic(100);
  end data_send;


--vvvvvvvvvvvvvvvvvvvvvvvvvv END Procedures vvvvvvvvvvvvvvvvvvvvvvvvvvvv

begin

  gt_rx_64b66b_descrambler_inst : gt_rx_64b66b_descrambler
    port map (
      CLK_IN         => clk_s,
      RESET          => rst_s,
      DATA_IN        => data_in_s,
      DATA_IN_VALID  => enable_s,
      DATA_OUT       => data_out_1,
      DATA_OUT_VALID => open,
      SYNCHEADER_OUT => sync_info_1
      );

  descrambler_cmp : descrambler
    port map
    (
      data_in   => data_in_s,
      data_out  => data_out_2,
      enable    => enable_s,
      sync_info => sync_info_2,
      clk       => clk_s,
      rst       => rst_s
      );

  clk : process
  begin
    clk_s <= '0';
    wait for clk_period/2;
    clk_s <= '1';
    wait for clk_period/2;
  end process;

  stim_proc : process
  begin
    wait for rst_time;
    rst_s <= '0';

    tic(10);
    data_send("010001000000000000000000000000000000000000000000000000000000000000", data_in_s, enable_s);
    data_send("001000000000000000000000000000000000000000000000000000000000000000", data_in_s, enable_s);
    data_send("000100000000000000000000000000000000000000000000000000000000000000", data_in_s, enable_s);
    data_send("000010000000000000000000000000000000000000000000000000000000000000", data_in_s, enable_s);
    data_send("000010000000000000000100000000000000000000000000000000000000000000", data_in_s, enable_s);
    

  end process;

  compare_1_and_2 <= '1' when data_out_1 = data_out_2 and sync_info_1 = sync_info_2 else '0';

end simulation;

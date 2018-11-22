library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity rx_64b66b_alignment_tb is
end rx_64b66b_alignment_tb;



architecture simulation of rx_64b66b_alignment_tb is


--^^^^^^^^^^^^^^^^^^^^^^^^^ Component Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  component gt_rx_64b66b_alignment
    port (
      CLK_IN            : in  std_logic;
      RESET             : in  std_logic;
      DATA_IN           : in  std_logic_vector(15 downto 0);
      DATA_IN_VALID     : in  std_logic;  -- High width must be 1
      DATA_OUT          : out std_logic_vector(65 downto 0);
      DATA_OUT_VALID    : out std_logic;
      DATA_OUT_SYNC     : out std_logic;
      ABNORMAL_INTERVAL : out std_logic
      );
  end component gt_rx_64b66b_alignment;


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
  signal data_in_s       : std_logic_vector(15 downto 0) := (others => '0');
  signal data_in_valid_s : std_logic                     := '0';
  signal slide_outdata_s : std_logic                     := '0';

  -- Output
  signal data_out_s          : std_logic_vector(65 downto 0);
  signal data_out_valid_s    : std_logic;
  signal data_out_sync_s     : std_logic;
  signal abnormal_interval_s : std_logic;

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
      data_in               : in  std_logic_vector(15 downto 0);
      signal data_in_tmp    : out std_logic_vector(15 downto 0);
      signal data_valid_tmp : out std_logic
      )
  is
  begin
    data_in_tmp    <= data_in;
    data_valid_tmp <= '1';
    tic;
    --data_in_tmp       <= (others => '0');
    data_valid_tmp <= '0';
    tic(1);
  end data_send;

  procedure data_send_no
    (
      data_in               : in  std_logic_vector(15 downto 0);
      signal data_in_tmp    : out std_logic_vector(15 downto 0);
      signal data_valid_tmp : out std_logic
      )
  is
  begin
    data_in_tmp    <= data_in;
    data_valid_tmp <= '1';
    tic;
    --data_in_tmp       <= (others => '0');
    data_valid_tmp <= '0';
  end data_send_no;


--vvvvvvvvvvvvvvvvvvvvvvvvvv END Procedures vvvvvvvvvvvvvvvvvvvvvvvvvvvv

begin

  gt_rx_64b66b_alignment_inst : gt_rx_64b66b_alignment
    port map (
      CLK_IN            => clk_s,
      RESET             => rst_s,
      DATA_IN           => data_in_s,
      DATA_IN_VALID     => data_in_valid_s,
      DATA_OUT          => data_out_s,
      DATA_OUT_VALID    => data_out_valid_s,
      DATA_OUT_SYNC     => data_out_sync_s,
      ABNORMAL_INTERVAL => abnormal_interval_s
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
    --data_send("0100000000000000", data_in_s, data_in_valid_s);
    --data_send("0100000000000000", data_in_s, data_in_valid_s);
    --data_send("0100000000000000", data_in_s, data_in_valid_s);
    --data_send("0100000000000000", data_in_s, data_in_valid_s);
    --data_send("0100000000000000", data_in_s, data_in_valid_s);
    --data_send("0100000000000000", data_in_s, data_in_valid_s);
    --data_send("0100000000000000", data_in_s, data_in_valid_s);
    --data_send("0100000000000000", data_in_s, data_in_valid_s);
    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    --data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);
    data_send("0000100000000001", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);

    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send_no("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);
    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);
    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    tic(3);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);
    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);
    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);
    data_send("1000000000010000", data_in_s, data_in_valid_s);
    data_send("0000010000000000", data_in_s, data_in_valid_s);
    data_send("0000000000100000", data_in_s, data_in_valid_s);
    data_send("0000100000000001", data_in_s, data_in_valid_s);
    data_send("0000000001000000", data_in_s, data_in_valid_s);
    data_send("0001000000000010", data_in_s, data_in_valid_s);
    data_send("0000000010000000", data_in_s, data_in_valid_s);
    data_send("0010000000000100", data_in_s, data_in_valid_s);
    data_send("0000000100000000", data_in_s, data_in_valid_s);
    data_send("0100000000001000", data_in_s, data_in_valid_s);
    data_send("0000001000000000", data_in_s, data_in_valid_s);

  end process;

end simulation;

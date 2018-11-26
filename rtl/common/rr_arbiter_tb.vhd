library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity rr_arbiter_tb is
end rr_arbiter_tb;



architecture simulation of rr_arbiter_tb is


--^^^^^^^^^^^^^^^^^^^^^^^^^ Component Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  component rr_arbiter
    generic
      (
        g_CHANNELS : integer := 16
        );
    port
      (
        -- sys connect
        clk_i : in std_logic;
        rst_i : in std_logic;

        -- requests
        req_i : in  std_logic_vector(g_CHANNELS-1 downto 0);
        -- grant
        gnt_o : out std_logic_vector(g_CHANNELS-1 downto 0)
        );
  end component rr_arbiter;


--vvvvvvvvvvvvvvvvvvvvvvv END Component Declarations vvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^ Parameter Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  constant clk_period : time := 6.25 ns;
  constant rst_time   : time := 100 ns;

  constant g_CHANNELS : integer := 4;

--vvvvvvvvvvvvvvvvvvvvvv END Parameter Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wire Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  -- Sys connect
  signal rst_s : std_logic := '1';
  signal clk_s : std_logic := '0';

  -- Input
  signal req_s : std_logic_vector(g_CHANNELS-1 downto 0) := (others => '0');

  -- Output
  signal gnt_s : std_logic_vector(g_CHANNELS-1 downto 0);

--vvvvvvvvvvvvvvvvvvvvvvvvvv END Wire Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvvv



--^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Procedures ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  procedure tic (count : integer := 1) is
  begin
    for i in 1 to count loop
      wait until rising_edge(clk_s);
    end loop;
  end tic;

--vvvvvvvvvvvvvvvvvvvvvvvvvv END Procedures vvvvvvvvvvvvvvvvvvvvvvvvvvvv

begin

  rr_arbiter_inst : rr_arbiter
    generic map
    (
      g_CHANNELS => g_CHANNELS
      )
    port map
    (
      clk_i => clk_s,
      rst_i => rst_s,
      req_i => req_s,
      gnt_o => gnt_s
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

    req_s <= "0001"; tic(10);
    req_s <= "0010"; tic(10);
    req_s <= "0100"; tic(10);
    req_s <= "1000"; tic(10);
    req_s <= "0001"; tic(10);
    req_s <= "0011"; tic(10);
    req_s <= "0111"; tic(10);
    req_s <= "1111"; tic(10);
    req_s <= "0000"; tic(10);

  end process;

end simulation;

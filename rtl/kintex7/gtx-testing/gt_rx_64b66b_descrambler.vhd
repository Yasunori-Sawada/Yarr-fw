----------------------------------------------------------------------------------
-- Company: Osaka University
-- Engineer: Kazuki Yajima(kyajima@cern.ch)
-- 
-- Create Date: 08/10/2018 10:34:14 AM
-- Design Name: 
-- Module Name: gt_rx_64b66b_descrambler - Behavioral
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


entity gt_rx_64b66b_descrambler is
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
      DATA_IN       : in std_logic_vector(65 downto 0);  --((WDT_OUT -1) downto 0);
      DATA_IN_VALID : in std_logic;     -- High width must be 1

      DATA_OUT       : out std_logic_vector(63 downto 0);
      DATA_OUT_VALID : out std_logic;
      DATA_OUT_SYNC  : out std_logic_vector(1 downto 0)
      );
end gt_rx_64b66b_descrambler;



architecture Behavioral of gt_rx_64b66b_descrambler is

--^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Wire Declarations ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  signal scrambled_64bits_i : std_logic_vector(63 downto 0);
  signal temp_DATA_OUT_i    : std_logic_vector(63 downto 0);

  signal scrambled_128bits_buf_i     : std_logic_vector(127 downto 0);

--vvvvvvvvvvvvvvvvvvvvvvvvvv END Wire Declarations vvvvvvvvvvvvvvvvvvvvvvvvvvvv

begin


  scrambled_64bits_i <= DATA_IN(63 downto 0);
  DATA_OUT_SYNC      <= DATA_IN(65 downto 64);


  buffer_128bits : process(CLK_IN, RESET)
  begin

    if RESET = '1' then
      scrambled_128bits_buf_i <= (others => '0');
      DATA_OUT_VALID          <= '0';

    elsif rising_edge(CLK_IN) then
      DATA_OUT_VALID <= DATA_IN_VALID;

      if DATA_IN_VALID = '1' then
        scrambled_128bits_buf_i <= scrambled_128bits_buf_i(63 downto 0) & scrambled_64bits_i;
      end if;
    end if;
  end process;


  descrambling : for I in 0 to 63 generate
    temp_DATA_OUT_i(63-I) <= scrambled_128bits_buf_i(63-I) xor
                             scrambled_128bits_buf_i(63-I+38+1) xor
                             scrambled_128bits_buf_i(63-I+57+1);
  end generate;


  DATA_OUT <= temp_DATA_OUT_i;


end Behavioral;

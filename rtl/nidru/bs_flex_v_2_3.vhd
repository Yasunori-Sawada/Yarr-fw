

-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 1
--  \   \        Filename: bs_flex_v_2_1.vhd
--  /   /        Date Last Modified:  Apr 15 2015
-- /___/   /\    Date Created:  Apr 15 2015
-- \   \  /  \
--  \___\/\___\
-- 
--Device: 7 Series and Ultracsale
--Purpose: This is the code of an ideal deserializer. 
--Reference:
--    
--Revision History:
--    Rev 1.0 - First created, P. Novellini, Apr 15 2015.
--    Rev 2:
--          RST is now active HIGH
--          Fixed bug, preventing BS to work with 40 bits output
--    Rev 2.1 
--          RST is now synchronous
--    Rev 2.2 
--          Fixed bug preventing the BS to operate at low WDT_OUT
--    Rev 2.3 
--          revision in entity name added
--          support for WDT_OUT = 1

---------------------------------------------------------------------------------------------
-- Copyright 2007 - 2015, Xilinx, Inc.
-- This file contains confidential and proprietary information of Xilinx, Inc. and is
-- protected under U.S. and international copyright and other intellectual property laws.
---------------------------------------------------------------------------------------------
--
-- Disclaimer:
--        This disclaimer is not a license and does not grant any rights to the materials
--        distributed herewith. Except as otherwise provided in a valid license issued to
--        you by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE
--        MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY
--        DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY,
--        INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT,
--        OR FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable
--        (whether in contract or tort, including negligence, or under any other theory
--        of liability) for any loss or damage of any kind or nature related to, arising
--        under or in connection with these materials, including for any direct, or any
--        indirect, special, incidental, or consequential loss or damage (including loss
--        of data, profits, goodwill, or any type of loss or damage suffered as a result
--        of any action brought by a third party) even if such damage or loss was
--        reasonably foreseeable or Xilinx had been advised of the possibility of the same.
-- CRITICAL APPLICATIONS
--        Xilinx products are not designed or intended to be fail-safe, or for use in any
--        application requiring fail-safe performance, such as life-support or safety
--        devices or systems, Class III medical devices, nuclear facilities, applications
--        related to the deployment of airbags, or any other applications that could lead
--        to death, personal injury, or severe property or environmental damage
--        (individually and collectively, "Critical Applications"). Customer assumes the
--        sole risk and liability of any use of Xilinx products in Critical Applications,
--        subject only to applicable laws and regulations governing limitations on product
--        liability.
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity bs_flex_v_2_3 is
  generic (
    WDT_IN  : in integer range 2 to 40 := 16;
    WDT_OUT : in integer range 1 to 40 := 16;

    S_MAX : in integer range 2 to 31 := 20
    );
  port (
    CLK    : in  std_logic;
    RST    : in  std_logic;
    DIN    : in  std_logic_vector((WDT_IN - 1) downto 0);
    EN     : in  std_logic;
    EN_IN  : in  std_logic_vector(4 downto 0);
    EN_OUT : out std_logic                              := '0';
    DOUT   : out std_logic_vector((WDT_OUT-1) downto 0) := (others => '0')
    );
end bs_flex_v_2_3;

architecture behavior of bs_flex_v_2_3 is

  component rotwdt
    generic (
      WDT_IN  : in integer range 2 to 40 := 10;
      WDT_OUT : in integer range 2 to 40 := 10;

      WDT_OUT_1 : in std_logic_vector(7 downto 0);
      S_MAX     : in integer range 2 to 40 := 10
      );
    port (
      CLK  : in  std_logic;
      RST  : in  std_logic;
      EN   : in  std_logic;
      HIN  : in  std_logic_vector((2*WDT_OUT - 1) downto 0);
      HOUT : out std_logic_vector((2*WDT_OUT - 1) downto 0) := (others => '0');
      P    : in  std_logic_vector(7 downto 0)
      );
  end component;


  component control
    generic (
      WDT_IN  : in integer range 2 to 40 := 10;
      WDT_OUT : in integer range 2 to 40 := 10;

      WDT_OUT_1 : in std_logic_vector(7 downto 0);
      S_MAX     : in integer range 2 to 40 := 10
      );
    port (
      CLK    : in  std_logic;
      RST    : in  std_logic;
      EN     : in  std_logic;
      DV     : in  std_logic_vector(6 downto 0);
      SHIFT  : out std_logic_vector(7 downto 0) := (others => '0');
      WRFLAG : out std_logic                    := '0';
      VALID  : out std_logic                    := '0'
      );
  end component;


  signal mask        : std_logic_vector((2*WDT_OUT - 1) downto 0) := (others => '0');
  signal dinext      : std_logic_vector((2*WDT_OUT - 1) downto 0) := (others => '0');
  signal dinext_rot  : std_logic_vector((2*WDT_OUT - 1) downto 0) := (others => '0');
  -- signal dinext_pre  : std_logic_vector((2*WDT_OUT - WDT_IN - 1) downto 0) := (others => '0');
  signal dinext_pre  : std_logic_vector((2*WDT_OUT - 1) downto 0) := (others => '0');
  signal regwdt      : std_logic_vector((2*WDT_OUT - 1) downto 0) := (others => '0');
  signal regout      : std_logic_vector((WDT_OUT-1) downto 0)     := (others => '0');
  signal pointer1    : std_logic_vector(7 downto 0)               := (others => '0');
  signal wrflag      : std_logic                                  := '0';
  signal valid       : std_logic                                  := '0';
  signal EN_IN_int   : std_logic_vector(6 downto 0)               := (others => '0');
  constant dm0       : std_logic_vector((WDT_OUT - 1) downto 0)   := (others => '1');
  constant dm1       : std_logic_vector((WDT_OUT - 1) downto 0)   := (others => '0');
  constant dm        : std_logic_vector((2*WDT_OUT - 1) downto 0) := dm1 & dm0;
  constant WDT_OUT_1 : std_logic_vector(7 downto 0)               := CONV_STD_LOGIC_VECTOR(WDT_OUT, 8);
  -- signal WDT_OUT_1 : std_logic_vector(5 downto 0)                        := (others => '0');
  

begin


  output_1 : if WDT_OUT = 1 generate

    DOUT(0) <= DIN(0);
    EN_OUT  <= EN_IN(0);

  end generate;


  output_else : if WDT_OUT > 1 generate

    
    Inst_mask_bs : rotwdt
      generic map(
        WDT_IN    => WDT_IN,
        WDT_OUT   => WDT_OUT,
        WDT_OUT_1 => WDT_OUT_1,
        S_MAX     => S_MAX
        )
      port map(
        CLK  => CLK,
        RST  => RST,
        HIN  => dm,
        EN   => EN,
        HOUT => mask,
        P    => pointer1
        );

    EN_IN_int <= "00"&EN_IN;

    I_control : control
      generic map(
        WDT_IN    => WDT_IN,
        WDT_OUT   => WDT_OUT,
        WDT_OUT_1 => WDT_OUT_1,
        S_MAX     => S_MAX
        )

      port map(
        CLK    => CLK,
        RST    => RST,
        DV     => EN_IN_int,
        EN     => EN,
        SHIFT  => pointer1,
        WRFLAG => wrflag,
        VALID  => valid
        );

    
    dinext_gen_2 : if WDT_OUT = 2 generate
      dinext <= "00" & DIN (1 downto 0);
    end generate dinext_gen_2;

    dinext_gen_3 : if WDT_OUT = 3 generate
      dinext <= "000" & DIN (2 downto 0);
    end generate dinext_gen_3;

    dinext_gen_4 : if WDT_OUT = 4 generate
      dinext <= "0000" & DIN (3 downto 0);
    end generate dinext_gen_4;

    dinext_gen_5 : if WDT_OUT = 5 generate
      dinext <= "00000" & DIN (4 downto 0);
    end generate dinext_gen_5;

    dinext_gen_6 : if WDT_OUT = 6 generate
      dinext <= "000000" & DIN (5 downto 0);
    end generate dinext_gen_6;

    dinext_gen_7 : if WDT_OUT = 7 generate
      dinext <= "0000000" & DIN (6 downto 0);
    end generate dinext_gen_7;

    dinext_gen_8 : if WDT_OUT = 8 generate
      dinext <= "00000000" & DIN (7 downto 0);
    end generate dinext_gen_8;

    dinext_gen_9 : if WDT_OUT = 9 generate
      dinext <= "000000000" & DIN (8 downto 0);
    end generate dinext_gen_9;

    dinext_gen_10_40 : if (WDT_OUT >= 10 and WDT_OUT <= 40) generate
      dinext <= dinext_pre((2*WDT_OUT - WDT_IN - 1) downto 0) & DIN;
    end generate dinext_gen_10_40;

    -- dinext <= dinext_pre((2*WDT_OUT - WDT_IN - 1) downto 0) & DIN;



    -- dinext <= dinext_pre & DIN;


    -- dinext <= DIN (3 downto 0);

    Inst_data_bs : rotwdt
      generic map(
        WDT_IN    => WDT_IN,
        WDT_OUT   => WDT_OUT,
        WDT_OUT_1 => WDT_OUT_1,
        S_MAX     => S_MAX
        )
      port map(
        CLK  => CLK,
        RST  => RST,
        HIN  => dinext,
        EN   => EN,
        HOUT => dinext_rot,
        P    => pointer1
        );



    process (CLK, RST)
    begin
      
      if rising_edge(CLK) then
        if RST = '1' then
          regwdt <= (others => '0');
          
        elsif EN = '1' then
          for i in 0 to (2*WDT_OUT - 1) loop
            if mask(i) = '1' then
              regwdt(i) <= dinext_rot(i);  -- update
            else
              regwdt(i) <= regwdt(i);      -- keep
            end if;
          end loop;
        end if;
      end if;
    end process;

    regout <= regwdt((WDT_OUT - 1) downto 0) when wrflag = '0' else regwdt((2*WDT_OUT - 1) downto WDT_OUT);

    process (CLK, RST)
    begin
      
      if rising_edge(CLK) then
        if RST = '1' then
          DOUT <= (others => '0');
        elsif EN = '1' then
          DOUT <= regout;
        end if;
      end if;
    end process;

    process (CLK, RST)
    begin
      
      if rising_edge(CLK) then
        if RST = '1' then
          EN_OUT <= '0';
        elsif EN = '1' then
          EN_OUT <= valid;
        end if;
      end if;
    end process;


  end generate;
end;


--------------------------------------------------------------------------------
-- to Elisa
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity control is
  generic (
    WDT_IN    : in integer range 2 to 40 := 10;
    WDT_OUT   : in integer range 2 to 40 := 10;
    WDT_OUT_1 : in std_logic_vector(7 downto 0);
    S_MAX     : in integer range 2 to 40 := 10
    );
  port (
    CLK    : in  std_logic;
    RST    : in  std_logic;
    EN     : in  std_logic;
    DV     : in  std_logic_vector(6 downto 0);
    SHIFT  : out std_logic_vector(7 downto 0) := (others => '0');
    WRFLAG : out std_logic                    := '0';
    VALID  : out std_logic                    := '0'
    );
end control;

architecture behavior of control is


  signal temp    : std_logic_vector(8 downto 0) := (others => '0');
  signal pointer : std_logic_vector(8 downto 0) := (others => '0');
  signal flag    : std_logic                    := '0';
  signal flag_d  : std_logic                    := '0';
  signal rflag   : std_logic                    := '0';
  signal wrflags : std_logic                    := '0';
  signal valids  : std_logic                    := '0';

begin



-- pointer

  temp <= (pointer + ('0' & DV));       -- 0->31

  process (CLK, RST)
  begin
    
    if rising_edge(CLK) then
      if RST = '1' then
        pointer <= (others => '0');
      elsif EN = '1' then
        if temp <= ((WDT_OUT_1(7 downto 0) & '0') - '1') then
          pointer <= temp;
        else
          pointer <= temp - ((WDT_OUT_1(7 downto 0) & '0'));
        end if;
      end if;
    end if;
  end process;

  SHIFT <= pointer(7 downto 0);
  flag  <= '0' when (pointer < WDT_OUT_1) else '1';

  process (CLK, RST)
  begin
    
    if rising_edge(CLK) then
      if RST = '1' then
        flag_d <= '0';
      elsif EN = '1' then
        flag_d <= flag;
      end if;
    end if;
  end process;

  process (CLK, RST)
  begin
    
    if rising_edge(CLK) then
      if RST = '1' then
        wrflags <= '0';
        valids  <= '0';
      elsif EN = '1' then
        wrflags <= flag_d;
        valids  <= flag xor flag_d;
      end if;
    end if;
  end process;

  WRFLAG <= wrflags;
  VALID  <= valids;

end;




--------------------------------------------------------------------------------
-- to Elisa
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity rotwdt is
  generic (
    WDT_IN    : in integer range 2 to 40        := 10;
    WDT_OUT   : in integer range 2 to 40        := 10;
    WDT_OUT_2 : in std_logic_vector(5 downto 0) := "111111";  -- uscita width *2 -1
    WDT_OUT_1 : in std_logic_vector(7 downto 0) := "10000000";  -- uscita width
    S_MAX     : in integer range 2 to 31        := 10
    );
  port (
    CLK  : in  std_logic;
    RST  : in  std_logic;
    HIN  : in  std_logic_vector((2*WDT_OUT - 1) downto 0);
    EN   : in  std_logic;
    HOUT : out std_logic_vector((2*WDT_OUT - 1) downto 0) := (others => '0');
    P    : in  std_logic_vector(7 downto 0)
    );
end rotwdt;

architecture behavior of rotwdt is

  signal a : std_logic_vector((2*WDT_OUT - 1) downto 0) := (others => '0');
  signal b : std_logic_vector((2*WDT_OUT - 1) downto 0) := (others => '0');
  signal c : std_logic_vector((2*WDT_OUT - 1) downto 0) := (others => '0');
  signal d : std_logic_vector((2*WDT_OUT - 1) downto 0) := (others => '0');
  signal e : std_logic_vector((2*WDT_OUT - 1) downto 0) := (others => '0');
  signal f : std_logic_vector((2*WDT_OUT - 1) downto 0) := (others => '0');
  signal g : std_logic_vector((2*WDT_OUT - 1) downto 0) := (others => '0');
  signal h : std_logic_vector((2*WDT_OUT - 1) downto 0) := (others => '0');

begin

  a <= HIN((2*WDT_OUT - 1) downto 0) when P(0) = '0' else HIN((2*WDT_OUT - 2) downto 0) & HIN((2*WDT_OUT - 1));  -- 1


  rot2 : if (2*WDT_OUT >= 2) generate
    b <= a((2*WDT_OUT - 1) downto 0) when P(1) = '0' else a((2*WDT_OUT - 3) downto 0) & a((2*WDT_OUT - 1) downto (2*WDT_OUT - 2));  -- 2
  end generate rot2;

  rot2_n : if (2*WDT_OUT < 2) generate
    b <= a;                             -- 2
  end generate rot2_n;

  rot4 : if (2*WDT_OUT >= 4) generate
    c <= b((2*WDT_OUT - 1) downto 0) when P(2) = '0' else b((2*WDT_OUT - 5) downto 0) & b((2*WDT_OUT - 1) downto (2*WDT_OUT - 4));  -- 4
  end generate rot4;

  rot4_n : if (2*WDT_OUT < 4) generate
    c <= b;                             -- 4
  end generate rot4_n;

  rot8 : if (2*WDT_OUT >= 8) generate
    d <= c((2*WDT_OUT - 1) downto 0) when P(3) = '0' else c((2*WDT_OUT - 9) downto 0) & c((2*WDT_OUT - 1) downto (2*WDT_OUT - 8));  -- 8
  end generate rot8;

  rot8_n : if (2*WDT_OUT < 8) generate
    d <= c;                             -- 8
  end generate rot8_n;

  rot16 : if (2*WDT_OUT >= 16) generate
    e <= d((2*WDT_OUT - 1) downto 0) when P(4) = '0' else d((2*WDT_OUT - 17) downto 0) & d((2*WDT_OUT - 1) downto (2*WDT_OUT - 16));  -- 16
  end generate rot16;

  rot16_n : if (2*WDT_OUT < 16) generate
    e <= d;                             -- 16
  end generate rot16_n;

  rot32 : if (2*WDT_OUT >= 32) generate
    f <= e((2*WDT_OUT - 1) downto 0) when P(5) = '0' else e((2*WDT_OUT - 33) downto 0) & e((2*WDT_OUT - 1) downto (2*WDT_OUT - 32));  -- 32
  end generate rot32;

  rot32_n : if (2*WDT_OUT < 32) generate
    f <= e;
  end generate rot32_n;

  rot64 : if (2*WDT_OUT >= 64) generate
    g <= f((2*WDT_OUT - 1) downto 0) when P(6) = '0' else f((2*WDT_OUT - 65) downto 0) & f((2*WDT_OUT - 1) downto (2*WDT_OUT - 64));  -- 64
  end generate rot64;

  rot64_n : if (2*WDT_OUT < 64) generate
    g <= f;
  end generate rot64_n;

  rot128 : if (2*WDT_OUT >= 128) generate
    h <= g((2*WDT_OUT - 1) downto 0) when P(7) = '0' else g((2*WDT_OUT - 129) downto 0) & g((2*WDT_OUT - 1) downto (2*WDT_OUT - 128));  -- 64
  end generate rot128;

  rot128_n : if (2*WDT_OUT < 128) generate
    h <= g;
  end generate rot128_n;

  process (CLK, RST, EN)
  begin
    
    if rising_edge(CLK) then
      if RST = '1' then
        HOUT <= (others => '0');
      elsif EN = '1' then
        
        HOUT <= h;
      end if;
    end if;
  end process;


end;

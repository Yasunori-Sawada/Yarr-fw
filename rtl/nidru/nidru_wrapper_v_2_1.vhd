-------------------------------------------------------------------------------
-- Copyright (c) 2005 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 2.1
--  \   \        Filename: nidru_wrapper_v_2_1
--  /   /        Date Last Modified:  Thu Jan 17 2008
-- /___/   /\    Date Created: Wed May 2 2007
-- \   \  /  \
--  \___\/\___\
-- 
--Device: 7 series and US
--Purpose: This is the wrapper of the NI DRU  
--         
-- Version 1 - Initial release
-- Version 2 - Added eyescan support
--           - added support for nidru v 8
--
-- Nidru Versions:
-- Version 1 - used in the Video 
-- Version 3 - added controls for :
--                                    - complexity scaling
--                                    - Parallel phase load added
--                                    - second phase error management strategy (PH_EST_DIS)
--                                    - frequency estimation disable (EN_INTEG) 
--                                    - ppm alarm added  
--                                    - S_MAX added, max number of samples to optimize logic usage.
--                                    - inclusion of reduced-nidru
-- Version 4    - Optional efficient data compressor, no fuctional change.
-- Version 5    - Eliminated some unknown signals at the beginning of simulation, no fucntional change
-- Version 6    - S_MAX is now integer
--              - PH_EST_DIS/EN_INTEG are ports
--              - EN_ADV_COMPR is now BOOLean
--              - RST is now active high 
--              - PH_EST_DIS bahavior corrected when set to 1
--              - PH_EST_DIS bahavior corrected when set to 1 also in full filter 
--              - security controls added to NIDRU code.
--              - fixed reset sign in filter
--              - fixed filter in reduced NIDRU
--              - corrected sensitivity list of many processes (minor)
-- Version 7    - Version Alignement
-- Version 8    - lp_filter and lp_filter_r have reduced latency
--              - advanced compressor is active by default
--              - added capability to shift runtime the sampling phase
--              - eyescan logic and ports available
--              - added 32 bit version
-- Version 2.1  - reset of wrapper versioning, aligned with XAPP
--              - wrapper for nidru v 9 
--              - fixed minor non-centered eye diagram
--              - added support for 4 bit
--              - RES_FREQ is now synch
------------------------------------------------------------------------------
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
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity nidru_wrapper_v_2_1 is
  generic (

    -- configuration
    WDT_OUT            : in integer range 1 to 40          := 2;  -- output width
    DT_IN_WIDTH        : in integer range 4 to 32          := 4;  -- input data width, 4, 20 or 32 bits available
    EN_CENTER_F_ATTR   : in std_logic                      := '1';  -- when = 1, center_f=center_f_attr
    CENTER_F_ATTR      : in std_logic_vector (36 downto 0) := "0000100111110100000010100010100001110";  -- internal center_fEN_G1_ATTR           : in std_logic                      := '1';
    EN_G1_ATTR         : in std_logic                      := '1';
    G1_ATTR            : in std_logic_vector (4 downto 0)  := "01000";
    EN_G2_ATTR         : in std_logic                      := '1';
    G2_ATTR            : in std_logic_vector (4 downto 0)  := "01000";
    EN_G1_P_ATTR       : in std_logic                      := '1';
    G1_P_ATTR          : in std_logic_vector (4 downto 0)  := "01111";
    EN_SHIFT_S_PH_ATTR : in std_logic                      := '1';
    SHIFT_S_PH_ATTR    : in std_logic_vector (7 downto 0)  := "00000000";
    EN_EN_INTEG_ATTR   : in std_logic                      := '1';
    EN_INTEG_ATTR      : in std_logic                      := '1';
    EN_EN              : in std_logic                      := '0';

    --eyescan
    PH_NUM : in integer range 0 to 2 := 0;  -- max number of extra phases. 0 is no eyescan


    -- logic optimization
    S_MAX    : in integer range 1 to 16          := 2;  -- max number of extracted bits, decimal
    MASK_CG  : in std_logic_vector (15 downto 0) := "1111111100000000";  -- place same number of LSb zeros
    MASK_PD  : in std_logic_vector (15 downto 0) := "1111111100000000";  -- place same number of LSb zeros
    MASK_VCO : in std_logic_vector (36 downto 0) := "1111111111111111111111111100000000000"  -- plase same number of LSb zeros


    );

  port (
    -- DATA PORTS
    DT_IN    : in  std_logic_vector ((DT_IN_WIDTH -1) downto 0);
    EN       : in  std_logic;
    CLK      : in  std_logic;
    RST_FREQ : in  std_logic;           -- active high
    RECCLK   : out std_logic_vector((DT_IN_WIDTH -1) downto 0);
    EN_OUT   : out std_logic;
    DOUT     : out std_logic_vector((WDT_OUT -1) downto 0);

    -- CONFIG PORTS
    CENTER_F : in std_logic_vector (36 downto 0);
    G1       : in std_logic_vector(4 downto 0);
    G1_P     : in std_logic_vector(4 downto 0);
    G2       : in std_logic_vector(4 downto 0);

    -- DEBUG
    PH_OUT     : out std_logic_vector(20 downto 0);
    INTEG      : out std_logic_vector(31 downto 0);
    DIRECT     : out std_logic_vector(31 downto 0);
    CTRL       : out std_logic_vector (31 downto 0);
    AL_PPM     : out std_logic;
    RST        : in  std_logic;                     -- active high
    EN_INTEG   : in  std_logic;                     -- by default 1
    PH_EST_DIS : in  std_logic;                     -- by defauls 0
    VER        : out std_logic_vector(7 downto 0);
    SAMV       : out std_logic_vector(6 downto 0);  -- coded
    SAM        : out std_logic_vector((DT_IN_WIDTH/2 -1) downto 0);

    -- EYESCAN
    SHIFT_S_PH    : in  std_logic_vector(7 downto 0) := (others => '0');
    AUTOM         : in  std_logic                    := '1';
    START_EYESCAN : in  std_logic                    := '0';
    EYESCAN_BUSY  : out std_logic                    := '0';
    RST_PH_0      : in  std_logic                    := '0';
    RST_PH_1      : in  std_logic                    := '0';
    RST_PH_SAMP   : in  std_logic                    := '0';
    ERR_PH_0      : out std_logic_vector (6 downto 0);
    ERR_PH_1      : out std_logic_vector (6 downto 0);
    PH_0_SCAN     : out std_logic_vector (7 downto 0);
    PH_1_SCAN     : out std_logic_vector (7 downto 0);

    PH_0 : in std_logic_vector(7 downto 0) := (others => '0');
    PH_1 : in std_logic_vector(7 downto 0) := (others => '0');

    WAITING_TIME : in std_logic_vector(47 downto 0) := (others => '0');

    ERR_COUNT_PH_0    : out std_logic_vector (51 downto 0) := (others => '0');
    EN_ERR_COUNT_PH_0 : out std_logic                      := '0';
    ERR_COUNT_PH_1    : out std_logic_vector (51 downto 0) := (others => '0');
    EN_ERR_COUNT_PH_1 : out std_logic                      := '0'



    );

end nidru_wrapper_v_2_1;

architecture Behavioral of nidru_wrapper_v_2_1 is

  component dru_v_9
    generic (
      DT_IN_WIDTH  : in integer range 1 to 64          := 20;  -- input data width
      S_MAX        : in integer range 1 to 16          := 10;  -- max number of extracted bits, decimal
      -- ENABLE_CENTER_F_ATTR : in std_logic                      := '1';  -- when = 1, center_f=center_f_attr
      -- CENTER_F_ATTR        : in std_logic_vector (36 downto 0) := "0100000000000000000000000000000000000";  -- internal center_f
      EN_G1_ATTR   : in std_logic                      := '0';
      G1_ATTR      : in std_logic_vector (4 downto 0)  := "01000";
      EN_G2_ATTR   : in std_logic                      := '0';
      G2_ATTR      : in std_logic_vector (4 downto 0)  := "01000";
      EN_G1_P_ATTR : in std_logic                      := '0';
      G1_P_ATTR    : in std_logic_vector (4 downto 0)  := "01111";
      MASK_CG      : in std_logic_vector (15 downto 0) := "1111111111110000";  -- place same number of LSb zeros
      MASK_PD      : in std_logic_vector (15 downto 0) := "1111111111110000";  -- place same number of LSb zeros
      MASK_VCO     : in std_logic_vector (36 downto 0) := "1111111111111111111111111111111110000";  -- plase same number of LSb zeros
      EN_ADV_COMPR : in boolean                        := false  -- by default 0. when set to 1 activates the advanced compressor


      );
    port(
      DT_IN      : in  std_logic_vector((DT_IN_WIDTH -1) downto 0);
      CENTER_F   : in  std_logic_vector(36 downto 0);
      EN         : in  std_logic;
      G1         : in  std_logic_vector(4 downto 0);
      G1_P       : in  std_logic_vector(4 downto 0);
      G2         : in  std_logic_vector(4 downto 0);
      CLK        : in  std_logic;
      PL         : in  std_logic;
      PHASE_IN   : in  std_logic_vector(31 downto 0);
      RST        : in  std_logic;
      RST_FREQ   : in  std_logic;
      EN_INTEG   : in  std_logic := '1';  -- by default 1
      PH_EST_DIS : in  std_logic := '0';  -- by defauls 0              
      PH_OUT     : out std_logic_vector(20 downto 0);
      INTEG      : out std_logic_vector(31 downto 0);
      DIRECT     : out std_logic_vector(31 downto 0);
      CTRL       : out std_logic_vector(31 downto 0);
      AL_PPM     : out std_logic;

      RECCLK : out std_logic_vector((DT_IN_WIDTH -1) downto 0);
      SAMV   : out std_logic_vector(6 downto 0);
      SAM    : out std_logic_vector((DT_IN_WIDTH/2 -1) downto 0);

      -- eyescan
      RST_PH_0    : in  std_logic                    := '0';
      RST_PH_1    : in  std_logic                    := '0';
      RST_PH_SAMP : in  std_logic                    := '0';
      ERR_PH_0    : out std_logic_vector (6 downto 0);
      ERR_PH_1    : out std_logic_vector (6 downto 0);
      SHIFT_S_PH  : in  std_logic_vector(7 downto 0) := (others => '0');
      PH_0        : in  std_logic_vector(7 downto 0) := (others => '0');
      PH_1        : in  std_logic_vector(7 downto 0) := (others => '0');

      -- version
      VER : out std_logic_vector(7 downto 0)
      );
  end component;

  component bs_flex_v_2_3
    generic (
      WDT_IN  : in integer range 2 to 40 := 10;
      WDT_OUT : in integer range 1 to 40 := 10;

      S_MAX : in integer range 1 to 31 := 10
      );
    port (
      CLK    : in  std_logic;
      RST    : in  std_logic;
      DIN    : in  std_logic_vector((WDT_IN - 1) downto 0);
      EN     : in  std_logic;
      EN_IN  : in  std_logic_vector(4 downto 0);
      EN_OUT : out std_logic;
      DOUT   : out std_logic_vector((WDT_OUT-1) downto 0)
      );
  end component;

  component eyescan_controller_v_1_0
    generic(
      ERR_WIDTH : in integer range 1 to 7 := 7;  -- width of error vector
      PH_NUM    : in integer range 0 to 2 := 2   -- max number of extra phases.
      );

    port (
      WAITING_TIME      : in  std_logic_vector (47 downto 0);  -- wating time in clock cycles/point
      START_EYESCAN     : in  std_logic;
      EYESCAN_BUSY      : out std_logic;
      CLK               : in  std_logic;
      EN                : in  std_logic;
      RST               : in  std_logic;
      ERR_COUNT_PH_0    : out std_logic_vector (51 downto 0);
      EN_ERR_COUNT_PH_0 : out std_logic;
      ERR_COUNT_PH_1    : out std_logic_vector (51 downto 0);
      EN_ERR_COUNT_PH_1 : out std_logic;
      RST_PH_SAMP       : out std_logic;
      RST_PH_0          : out std_logic;
      RST_PH_1          : out std_logic;
      ERR_PH_0          : in  std_logic_vector ((ERR_WIDTH - 1) downto 0);
      ERR_PH_1          : in  std_logic_vector ((ERR_WIDTH - 1) downto 0);
      PH_0              : out std_logic_vector (7 downto 0);
      PH_1              : out std_logic_vector (7 downto 0)

      );

  end component;

  signal samv_int_1                                     : std_logic_vector (6 downto 0)                   := (others => '0');
  signal sam_int                                        : std_logic_vector ((DT_IN_WIDTH/2 - 1) downto 0) := (others => '0');
  signal RST_PH_SAMP_INT                                : std_logic                                       := '0';
  signal RST_PH_0_int, RST_PH_1_int                     : std_logic                                       := '0';
  signal RST_PH_0_auto, RST_PH_1_auto, RST_PH_SAMP_auto : std_logic                                       := '0';
  signal ERR_PH_0_int, ERR_PH_1_int                     : std_logic_vector (6 downto 0)                   := (others => '0');
  signal PH_0_int, PH_1_int                             : std_logic_vector (7 downto 0)                   := (others => '0');
  signal PH_0_auto, PH_1_auto                           : std_logic                                       := '0';
  signal g1_int, g2_int, g1_p_int                       : std_logic_vector (4 downto 0)                   := (others => '0');
  signal SHIFT_S_PH_int                                 : std_logic_vector (7 downto 0)                   := (others => '0');
  signal En_int                                         : std_logic                                       := '0';
  signal CENTER_F_int                                   : std_logic_vector (36 downto 0)                  := (others => '0');
  signal EN_INTEG_int                                   : std_logic                                       := '0';
  
begin
  
  

  
  
  SAM       <= sam_int;
  ERR_PH_0  <= "0000000"  when PH_NUM = 0 else err_ph_0_int;
  ERR_PH_1  <= "0000000"  when PH_NUM = 0 else err_ph_1_int;
  PH_0_SCAN <= "00000000" when PH_NUM = 0 else ph_0_int;
  PH_1_SCAN <= "00000000" when PH_NUM = 0 else ph_1_int;

  g1_int         <= G1         when EN_G1_ATTR = '0'         else G1_ATTR;
  g2_int         <= G2         when EN_G2_ATTR = '0'         else G2_ATTR;
  g1_p_int       <= G1_P       when EN_G1_P_ATTR = '0'       else G1_P_ATTR;
  SHIFT_S_PH_int <= SHIFT_S_PH when EN_SHIFT_S_PH_ATTR = '0' else SHIFT_S_PH_ATTR;
  EN_int         <= EN         when EN_EN = '1'              else '1';
  CENTER_F_INT   <= CENTER_F   when EN_CENTER_F_ATTR = '0'   else CENTER_F_ATTR;
  EN_INTEG_int   <= EN_INTEG   when EN_EN_INTEG_ATTR = '0'   else EN_INTEG_ATTR;

  Inst_dru : dru_v_9
    generic map(
      DT_IN_WIDTH  => DT_IN_WIDTH,
      S_MAX        => S_MAX,
      EN_G1_ATTR   => EN_G1_ATTR,
      G1_ATTR      => G1_ATTR,
      EN_G2_ATTR   => EN_G2_ATTR,
      G2_ATTR      => G2_ATTR,
      EN_G1_P_ATTR => EN_G1_P_ATTR,
      G1_P_ATTR    => G1_P_ATTR,
      MASK_CG      => MASK_CG,
      MASK_PD      => MASK_PD,
      EN_ADV_COMPR => true,
      MASK_VCO     => MASK_VCO
      )
    port map(
      DT_IN      => DT_IN,
      CENTER_F   => CENTER_F_int,
      EN         => EN_int,
      G1         => g1_int,
      G1_P       => g1_p_int,
      G2         => g2_int,
      CLK        => CLK,
      PH_OUT     => PH_OUT,
      INTEG      => INTEG,
      DIRECT     => DIRECT,
      CTRL       => CTRL,
      AL_PPM     => AL_PPM,
      PL         => '0',
      PHASE_IN   => (others => '0'),
      RST        => RST,
      RST_FREQ   => RST_FREQ,
      EN_INTEG   => EN_INTEG_int,
      PH_EST_DIS => PH_EST_DIS,

      RECCLK      => RECCLK,
      SAMV        => samv_int_1,
      SAM         => sam_int,
      --eyescan
      RST_PH_0    => RST_PH_0_int,
      RST_PH_1    => RST_PH_1_int,
      RST_PH_SAMP => RST_PH_SAMP_int,
      ERR_PH_0    => ERR_PH_0_int,
      ERR_PH_1    => ERR_PH_1_int,
      SHIFT_S_PH  => SHIFT_S_PH_int,
      PH_0        => PH_0_int,
      PH_1        => PH_1_int,
      --version
      VER         => VER
      );

  bs_flex_dru : bs_flex_v_2_3
    generic map(
      WDT_IN  => (DT_IN_WIDTH/2),
      WDT_OUT => WDT_OUT,
      S_MAX   => S_MAX
      )
    port map(
      CLK    => CLK,
      RST    => RST,
      DIN    => sam_int,
      EN     => EN_int,
      EN_IN  => samv_int_1(4 downto 0),
      EN_OUT => EN_OUT,
      DOUT   => DOUT
      );

  eyescan_controller_inst : eyescan_controller_v_1_0
    generic map(
      ERR_WIDTH => 7,                   -- width of error vector
      PH_NUM    => PH_NUM
      )

    port map(
      WAITING_TIME      => WAITING_TIME,
      START_EYESCAN     => START_EYESCAN,
      EYESCAN_BUSY      => EYESCAN_BUSY,
      CLK               => CLK,
      EN                => EN_int,
      RST               => RST,
      ERR_COUNT_PH_0    => ERR_COUNT_PH_0,
      EN_ERR_COUNT_PH_0 => EN_ERR_COUNT_PH_0,
      ERR_COUNT_PH_1    => ERR_COUNT_PH_1,
      EN_ERR_COUNT_PH_1 => EN_ERR_COUNT_PH_1,
      RST_PH_SAMP       => RST_PH_SAMP_auto,
      RST_PH_0          => RST_PH_0_auto,
      RST_PH_1          => RST_PH_1_auto,
      ERR_PH_0          => ERR_PH_0_int,
      ERR_PH_1          => ERR_PH_1_int,
      PH_0              => PH_0_int,
      PH_1              => PH_1_int

      );

  process (RST, CLK, EN, AUTOM)
  begin
    if AUTOM = '1' then
      
      RST_PH_0_int    <= RST_PH_0_auto;
      RST_PH_1_int    <= RST_PH_1_auto;
      RST_PH_SAMP_int <= RST_PH_SAMP_auto;
      

    else
      RST_PH_0_int    <= RST_PH_0;
      RST_PH_1_int    <= RST_PH_1;
      RST_PH_SAMP_int <= RST_PH_SAMP;
      

    end if;
  end process;


  SAMV <= samv_int_1;
  


  
end Behavioral;

-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 1
--  \   \        Filename: eyescan_controller_v_1_0.vhd
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
use IEEE.STD_LOGIC_SIGNED.all;

entity eyescan_controller_v_1_0 is
  generic(
    ERR_WIDTH : in integer range 1 to 7 := 4;  -- width of error vector
    PH_NUM    : in integer range 0 to 2 := 1   -- max number of extra phases.
    );

  port (
    WAITING_TIME      : in  std_logic_vector (47 downto 0);  -- wating time in clock cycles/point
    START_EYESCAN     : in  std_logic;
    EYESCAN_BUSY      : out std_logic                      := '0';
    CLK               : in  std_logic;
    EN                : in  std_logic;
    RST               : in  std_logic;
    ERR_COUNT_PH_0    : out std_logic_vector (51 downto 0) := (others => '0');
    EN_ERR_COUNT_PH_0 : out std_logic                      := '0';
    ERR_COUNT_PH_1    : out std_logic_vector (51 downto 0) := (others => '0');
    EN_ERR_COUNT_PH_1 : out std_logic                      := '0';
    RST_PH_SAMP       : out std_logic                      := '0';
    RST_PH_0          : out std_logic                      := '0';
    RST_PH_1          : out std_logic                      := '0';
    ERR_PH_0          : in  std_logic_vector ((ERR_WIDTH - 1) downto 0);
    ERR_PH_1          : in  std_logic_vector ((ERR_WIDTH - 1) downto 0);
    PH_0              : out std_logic_vector (7 downto 0)  := (others => '0');
    PH_1              : out std_logic_vector (7 downto 0)  := (others => '0')

    );


end eyescan_controller_v_1_0;

architecture Behavioral of eyescan_controller_v_1_0 is

  



  signal cnt                                    : std_logic_vector(10 downto 0) := (others => '0');
  signal sub_cnt                                : std_logic_vector(47 downto 0) := (others => '0');
  signal ph_0_int, ph_1_int                     : std_logic_vector(7 downto 0)  := (others => '0');
  signal ERR_COUNT_PH_1_int, ERR_COUNT_PH_0_int : std_logic_vector(52 downto 0) := (others => '0');
  signal ERR_COUNT_PH_0_int_next                : std_logic_vector(52 downto 0) := (others => '0');
  signal ERR_COUNT_PH_1_int_next                : std_logic_vector(52 downto 0) := (others => '0');
  signal start_eyescan_int                      : std_logic                     := '0';


begin



  extra_0_ph : if (PH_NUM = 0) generate

    EYESCAN_BUSY      <= '0';
    ERR_COUNT_PH_0    <= (others => '0');
    ERR_COUNT_PH_1    <= (others => '0');
    PH_0              <= (others => '0');
    PH_1              <= (others => '0');
    EN_ERR_COUNT_PH_0 <= '0';
    EN_ERR_COUNT_PH_1 <= '0';
    
  end generate extra_0_ph;



  extra_1_ph : if (PH_NUM = 1) generate
    
    ERR_COUNT_PH_0_int_next <= ERR_COUNT_PH_0_int + ('0'&ERR_PH_0);

    process (CLK, RST, EN)
    begin
      if RST = '1' then
        start_eyescan_int <= '0';
      elsif CLK = '1' and EN = '1' and CLK'event then
        start_eyescan_int <= START_EYESCAN;
      end if;
    end process;

    process (CLK, RST, EN)
    begin
      if RST = '1' then

      elsif CLK = '1' and EN = '1' and CLK'event then
        if cnt = "00000000000" then
          ph_0_int           <= "00000000";
          ph_1_int           <= "00000000";
          EYESCAN_BUSY       <= '0';
          RST_PH_0           <= '1';
          RST_PH_1           <= '1';
          RST_PH_SAMP        <= '1';
          sub_cnt            <= (others => '0');
          ERR_COUNT_PH_0_int <= (others => '0');
          if START_EYESCAN = '1' and start_eyescan_int = '0' then
            cnt          <= cnt + '1';
            EYESCAN_BUSY <= '1';
          else
            cnt <= "00000000000";
          end if;
          
        elsif cnt = "00000000001" then
          RST_PH_0    <= '0';
          RST_PH_SAMP <= '0';
          cnt         <= cnt + '1';
          
        elsif (cnt >= "00000000010" and cnt <= "00010000001") then
          ph_0_int <= ph_0_int + '1';
          cnt      <= cnt + '1';
          -- end if;
          
        elsif (cnt >= "00010000010" and cnt <= "00110000010" and sub_cnt /= (WAITING_TIME)) then
          -- if sub_cnt /= WAITING_TIME then 
          sub_cnt <= sub_cnt + '1';
          if sub_cnt = "000000000000000000000000000000000000000000000000" then
            
            ERR_COUNT_PH_0_int <= (others => '0');

            cnt <= cnt + '1';

            --if (ph_0_int /= "10000000" AND cnt /= "00010000001") then  -- phase -128
            ph_0_int <= ph_0_int - '1';
          --end if;
          else
            
            if ERR_COUNT_PH_0_int_next(52) = '1' then

              ERR_COUNT_PH_0_int <= ERR_COUNT_PH_0_int;
              
            else
              
              ERR_COUNT_PH_0_int <= ERR_COUNT_PH_0_int_next;
              
            end if;
            
          end if;
          if sub_cnt = (WAITING_TIME - '1') then
            EN_ERR_COUNT_PH_0 <= '1';

            sub_cnt <= (others => '0');
          else
            EN_ERR_COUNT_PH_0 <= '0';
            
          end if;
        elsif (cnt = "00110000011") then
          sub_cnt      <= (others => '0');
          EYESCAN_BUSY <= '1';
          cnt          <= cnt + '1';
        elsif (cnt = "00110000100") then
          EYESCAN_BUSY <= '0';
          cnt          <= (others => '0');
        end if;
      end if;
      

    end process;




    EN_ERR_COUNT_PH_1 <= '0';
    ERR_COUNT_PH_0    <= ERR_COUNT_PH_0_int(51 downto 0);
    ERR_COUNT_PH_1    <= (others => '0');
    PH_0              <= ph_0_int;
    PH_1              <= (others => '0');
    
  end generate extra_1_ph;


  extra_2_ph : if (PH_NUM = 2) generate
    
    ERR_COUNT_PH_0_int_next <= ERR_COUNT_PH_0_int + ('0'&ERR_PH_0);
    ERR_COUNT_PH_1_int_next <= ERR_COUNT_PH_1_int + ('0'&ERR_PH_1);

    process (CLK, RST, EN)
    begin
      if RST = '1' then
        start_eyescan_int <= '0';
      elsif CLK = '1' and EN = '1' and CLK'event then
        start_eyescan_int <= START_EYESCAN;
      end if;
    end process;

    process (CLK, RST, EN)
    begin
      if RST = '1' then

      elsif CLK = '1' and EN = '1' and CLK'event then
        if cnt = "00000000000" then
          ph_0_int           <= "00000000";
          ph_1_int           <= "00000000";
          EYESCAN_BUSY       <= '0';
          RST_PH_0           <= '1';
          RST_PH_1           <= '1';
          RST_PH_SAMP        <= '1';
          sub_cnt            <= (others => '0');
          ERR_COUNT_PH_0_int <= (others => '0');
          ERR_COUNT_PH_1_int <= (others => '0');
          if START_EYESCAN = '1' and start_eyescan_int = '0' then
            cnt          <= cnt + '1';
            EYESCAN_BUSY <= '1';
          else
            cnt <= "00000000000";
          end if;
          
        elsif cnt = "00000000001" then
          RST_PH_0    <= '0';
          RST_PH_1    <= '0';
          RST_PH_SAMP <= '0';
          cnt         <= cnt + '1';
          
        elsif cnt = "00000000010" then
          ph_0_int <= ph_0_int - '1';
          cnt      <= cnt + '1';
          -- end if;
          
        elsif (cnt >= "00000000011" and cnt <= "00010000011" and sub_cnt /= (WAITING_TIME)) then  -- 128 steps per side.
          -- if sub_cnt /= WAITING_TIME then 
          sub_cnt <= sub_cnt + '1';
          if sub_cnt = "000000000000000000000000000000000000000000000000" then
            
            ERR_COUNT_PH_0_int <= (others => '0');
            ERR_COUNT_PH_1_int <= (others => '0');

            cnt      <= cnt + '1';
            ph_0_int <= ph_0_int + '1';  --ph_0 for dx
            ph_1_int <= ph_1_int - '1';  --ph_1 for sx
            
          else
            
            if ERR_COUNT_PH_0_int_next(52) = '1' then
              ERR_COUNT_PH_0_int <= ERR_COUNT_PH_0_int;
            else
              ERR_COUNT_PH_0_int <= ERR_COUNT_PH_0_int_next;
            end if;

            if ERR_COUNT_PH_1_int_next(52) = '1' then
              ERR_COUNT_PH_1_int <= ERR_COUNT_PH_1_int;
            else
              ERR_COUNT_PH_1_int <= ERR_COUNT_PH_1_int_next;
            end if;
            
          end if;
          if sub_cnt = (WAITING_TIME - '1') then
            EN_ERR_COUNT_PH_0 <= '1';
            EN_ERR_COUNT_PH_1 <= '1';

            sub_cnt <= (others => '0');
          else
            EN_ERR_COUNT_PH_0 <= '0';
            EN_ERR_COUNT_PH_1 <= '0';
            
          end if;
        elsif (cnt = "00010000100") then
          sub_cnt      <= (others => '0');
          EYESCAN_BUSY <= '1';
          cnt          <= cnt + '1';
        elsif (cnt = "00010000101") then
          EYESCAN_BUSY <= '0';
          cnt          <= (others => '0');
        end if;
      end if;
      

    end process;





    ERR_COUNT_PH_0 <= ERR_COUNT_PH_0_int(51 downto 0);
    ERR_COUNT_PH_1 <= ERR_COUNT_PH_1_int(51 downto 0);
    PH_0           <= ph_0_int;
    PH_1           <= ph_1_int;
    
  end generate extra_2_ph;
  
  
  
  
end Behavioral;

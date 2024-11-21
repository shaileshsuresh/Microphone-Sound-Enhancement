--Package with constants

library ieee;
use ieee.std_logic_1164.all;

package adc_package is
  -- operations
  constant RD : std_logic := '1';
  constant WR : std_logic := '0';
  -- registers : page 0x00
  constant PAGE_CFG      : std_logic_vector(7 downto 0) := x"00";
  constant SLEEP_CFG     : std_logic_vector(7 downto 0) := x"02";
  constant ASI_CFG0      : std_logic_vector(7 downto 0) := x"07";
  constant IN_CH_EN      : std_logic_vector(7 downto 0) := x"73";
  constant ASI_OUT_CH_EN : std_logic_vector(7 downto 0) := x"74";
  constant PWR_CFG       : std_logic_vector(7 downto 0) := x"75";
  
end package adc_package;

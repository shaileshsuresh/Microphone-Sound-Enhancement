-- 4x1 MUX that selects the required channel

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity simple_selector is
   port (
    switch     : in  std_logic_vector(1 downto 0);
    chan1_data : in  std_logic_vector(15 downto 0);
    chan2_data : in  std_logic_vector(15 downto 0);
    chan3_data : in  std_logic_vector(15 downto 0);
    chan4_data : in  std_logic_vector(15 downto 0);
    out_data   : out std_logic_vector(15 downto 0)
   );
end simple_selector;

architecture arch_simple_selector of simple_selector is

begin
   
  out_data <= chan1_data when switch = "00" else
              chan2_data when switch = "01" else
              chan3_data when switch = "10" else
              chan4_data;
              
end arch_simple_selector;

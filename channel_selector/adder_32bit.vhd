-- Adder 32 bit


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adder_32bit is
    Port ( input1 : in STD_LOGIC_VECTOR (31 downto 0);
           input2 : in STD_LOGIC_VECTOR (31 downto 0);
           execute : in STD_LOGIC;
           sum : out STD_LOGIC_VECTOR (31 downto 0));
end adder_32bit;

architecture Behavioral of adder_32bit is

begin

  
      sum <= input1 + input2;
    
end Behavioral;

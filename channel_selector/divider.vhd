-- Divider. Used to divide vector by right shift. Sub-module of wrapper. Change ACT_DEN to change denominator. 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divider is
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           input_rec : in STD_LOGIC;
           input : in STD_LOGIC_VECTOR (31 downto 0);
           output : out STD_LOGIC_VECTOR (31 downto 0));
end divider;

architecture Behavioral of divider is

-- Constants
    constant DENOMINATOR : INTEGER := 1024;
    constant ACT_DEN : INTEGER := 10;				--THIS IS WHAT SHOULD BE CHANGED

-- Signals
    signal temp_output : STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal temp_input_rec : STD_LOGIC;
begin

temp_input_rec <= input_rec;
output <= temp_output;

    main : process(clk, resetn, input_rec)
    variable holder : STD_LOGIC_VECTOR (31 DOWNTO 0);
    begin
    
    if resetn = '0' then
        temp_input_rec <= '0';
        temp_output <= x"00000000";

    elsif rising_edge(clk) then
        --if temp_input_rec <= '1' then
        
        temp_output <= std_logic_vector(shift_right(unsigned(input), ACT_DEN));
        
        --division_loop: for k in 0 to DENOMINATOR -1 loop
        --    holder := shift_right(unsigned(holder), 1);
        --end loop;
        
        
    end if;
    end process;
    
end Behavioral;

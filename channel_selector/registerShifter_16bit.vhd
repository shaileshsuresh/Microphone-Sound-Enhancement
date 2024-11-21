-- The shift register shifts 16-bit vector into the next register


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity registerShifter_16bit is
    Port (clk : in STD_LOGIC;
          resetn : in STD_LOGIC;
          load_flag : in STD_LOGIC;
          input : in STD_LOGIC_VECTOR(15 DOWNTO 0);
          output : out STD_LOGIC_VECTOR(15 DOWNTO 0)
           );
end registerShifter_16bit;

architecture Behavioral of registerShifter_16bit is

    signal temp_output : std_logic_vector(15 DOWNTO 0);

begin

    main: process(clk, resetn)
    begin
        
        if resetn = '0' then
            output <= x"0000";
        
        elsif rising_edge(clk) then
            if load_flag = '1' then
                output <= input;
            end if;
        --elsif falling_edge(clk) then
        --    if load_flag = '1' then
        --        output <= temp_output;
        --    end if;
        else
        
        end if;
    end process;            

end Behavioral;

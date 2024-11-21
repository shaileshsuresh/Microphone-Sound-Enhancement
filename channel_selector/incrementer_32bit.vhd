-- Incrementer. Used for incrementing a value by an incoming value. Used as a sub-module in main_shift_reg_16bit. 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity incrementer_32bit is
    Port ( clk : in STD_LOGIC;
	resetn : in STD_LOGIC; 
	input1 : in STD_LOGIC_VECTOR (31 downto 0);
           execute : in STD_LOGIC;
           sum : out STD_LOGIC_VECTOR (31 downto 0));
end incrementer_32bit;

architecture Behavioral of incrementer_32bit is

	signal temp_sum : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal holder : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal track : STD_LOGIC_VECTOR(31 DOWNTO 0);
begin
	--holder <= input1;
	
   main_proc : process(clk, resetn)
   begin
	if resetn = '0' then
	temp_sum <= x"00000000";
	holder <= x"00000000";
	elsif rising_edge(clk) then
		holder <= temp_sum;
		if execute = '1' then
		temp_sum <= STD_LOGIC_VECTOR(unsigned(input1)) + STD_LOGIC_VECTOR(unsigned(holder));
		
        	end if;
	sum <= temp_sum;
	end if;
end process;
end Behavioral;

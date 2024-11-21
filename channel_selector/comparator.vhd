-- Comparators used in channel selector module, sub-module of wrapper. Used to compare two vectors and choose the larger vector as output.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;


entity comparator is
    Port (clk : in std_logic;
          resetn : in std_logic;
          input1 : in std_logic_vector(31 DOWNTO 0);
          input2 : in std_logic_vector(31 DOWNTO 0);
          output : out std_logic_vector(31 DOWNTO 0)
           );
end comparator;

architecture Behavioral of comparator is

	SIGNAL channel1 : signed(31 DOWNTO 0);
	SIGNAL channel2 : signed(31 DOWNTO 0);
	

	SIGNAL temp_channel : STD_LOGIC_VECTOR(31 DOWNTO 0);


begin

			channel1 <= signed(input1);

			channel2 <= signed(input2);


	output <= temp_channel;

	main_proc:PROCESS(clk, resetn)
	begin
	
	if resetn = '0' then
		temp_channel <= x"00000000";
	elsif rising_edge(clk) then
	
		if channel1 > channel2 then
			temp_channel <= std_logic_vector(channel1);
		else
			temp_channel <= std_logic_vector(channel2);
		end if;
	
	end if;
	end process;

end Behavioral;


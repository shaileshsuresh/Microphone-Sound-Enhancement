-- Wrapper file for the entire Rolling average module

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

entity wrapper is
    Port (clk : in std_logic;
          resetn : in std_logic;
          rec_flag : in std_logic;
          input1 : in STD_LOGIC_VECTOR(15 DOWNTO 0);
          input2 : in STD_LOGIC_VECTOR(15 DOWNTO 0);
          input3 : in STD_LOGIC_VECTOR(15 DOWNTO 0);
          input4 : in STD_LOGIC_VECTOR(15 DOWNTO 0);
          --input : in std_logic_vector(63 DOWNTO 0);
          output : out std_logic_vector(15 DOWNTO 0);
          sel : out std_logic_vector(1 downto 0)
           );
end wrapper;

architecture Behavioral of wrapper is
	-- ila
	COMPONENT ila_wrapper is
		PORT (
			clk : IN STD_LOGIC;
			probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
			probe1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
			probe2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
			probe3 : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
		);
	END COMPONENT ila_wrapper;
	SIGNAL output_main : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL output128bit : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL output1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL output2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL output3 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL output4 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL divtocomp11 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL divtocomp12 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL divtocomp21 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL divtocomp22 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL divtocomp31 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL divtocomp32 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal temp_sel	: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL temp_output : STD_LOGIC_VECTOR(31 DOWNTO 0);
	

	component mainShiftReg_16bit is
	port (clk : in std_logic;
          resetn : in std_logic;
          rec_flag : in std_logic;
          input : in std_logic_vector(15 DOWNTO 0);
          output : out STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	COMPONENT divider is
	port (clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           input_rec : in STD_LOGIC;
           input : in STD_LOGIC_VECTOR (31 downto 0);
           output : out STD_LOGIC_VECTOR (31 downto 0));
	end component;

	COMPONENT comparator is
	port(clk : in std_logic;
          resetn : in std_logic;
          input1 : in std_logic_vector(31 DOWNTO 0);
          input2 : in std_logic_vector(31 DOWNTO 0);
          output : out std_logic_vector(31 DOWNTO 0));
	END COMPONENT;

begin
	inst_ila_wrapper:
	component ila_wrapper 
	port map (
		clk => clk,
		probe0(0) => rec_flag,
		probe1 => output1,
		probe2 => output2,
		probe3 => temp_sel
	);
	output <= temp_output(15 downto 0);

    
	
	channel_1_inst: mainShiftReg_16bit
	port map(clk => clk,
		resetn => resetn,
		rec_flag => rec_flag,
		input => input1,
		output => output1
		);

	channel_2_inst: mainShiftReg_16bit
	port map(clk => clk,
		resetn => resetn,
		rec_flag => rec_flag,
		input => input2,
		output => output2
		);

	channel_3_inst: mainShiftReg_16bit
	port map(clk => clk,
		resetn => resetn,
		rec_flag => rec_flag,
		input => input3,
		output => output3
		);

	channel_4_inst: mainShiftReg_16bit
	port map(clk => clk,
		resetn => resetn,
		rec_flag => rec_flag,
		input => input4,
		output => output4
		);

	--main_comp_inst: for i in 3 downto 1 generate
	--	inst: mainShiftReg_16bit
	--	port map(clk => clk,
	--	resetn => resetn,
	--	rec_flag => rec_flag,
	--	input => input((16*(i+1)) - 1 downto (16*i)),
	--	output => o
	--	);
	--	end generate;

	channel_1_div: divider
	port map(clk => clk,
		resetn => resetn,
		input_rec => rec_flag,
		input => output1,
		output => divtocomp11
		);
	
	channel_2_div: divider
	port map(clk => clk,
		resetn => resetn,
		input_rec => rec_flag,
		input => output2,
		output => divtocomp12
		);
	
	channel_3_div: divider
	port map(clk => clk,
		resetn => resetn,
		input_rec => rec_flag,
		input => output3,
		output => divtocomp21
		);

	channel_4_div: divider
	port map(clk => clk,
		resetn => resetn,
		input_rec => rec_flag,
		input => output4,
		output => divtocomp22
		);

	--div_inst: for i in 3 downto 1 generate
	--	inst: divider
	--	port map(clk => clk,
	--	resetn => resetn,
	--	input_rec => rec_flag,
	--	input => output128bit((32*(i+1)) - 1 downto (32*i)),
	--	output => output((32*(i+1)) - 1 downto (32*i))
	--	);
	--	end generate;


	comparator1: comparator
	port map(clk => clk,
	resetn => resetn,
	input1 => divtocomp11,
	input2 => divtocomp12,
	output => divtocomp31
	);
	
	comparator2: comparator
	port map(clk => clk,
	resetn => resetn,
	input1 => divtocomp21,
	input2 => divtocomp22,
	output => divtocomp32
	);
	
	comparator3: comparator
	port map(clk => clk,
	resetn => resetn,
	input1 => divtocomp31,
	input2 => divtocomp32,
	output => temp_output
	);
       
       
    sel <=   temp_sel; 

		
		process (clk)
		begin
			if rising_edge(clk) then
				if temp_output = divtocomp11 then
					temp_sel <= "00";
				elsif temp_output = divtocomp12 then
					temp_sel <= "01";
				elsif temp_output = divtocomp21 then
					temp_sel <= "10";
				elsif temp_output = divtocomp22 then
					temp_sel <= "11";
				end if;
			end if;
		end process;
    --temp_sel <= "00" when temp_output = divtocomp11 else
           --			"01" when temp_output = divtocomp12 else
           	--		"10" when temp_output = divtocomp21 else
           	--		"11" when temp_output = divtocomp22 else
						--		"00";      
--	sel_proc: process(clk, resetn)
--	begin
--	if resetn = '0' then
--		sel <= "00";
--	elsif rising_edge(clk) then
--		if temp_output = divtocomp11 then
--			sel <= "00";
--		elsif temp_output = divtocomp12 then
--			sel <= "01";
--		elsif temp_output = divtocomp21 then
--			sel <= "10";
--		elsif temp_output = divtocomp22 then
--			sel <= "11";
--		else
--		end if;

--	end if;
--	end process;

	


------------------------------------------------------------------- 
--Part that works, one instance
	--main_inst : mainShiftReg_16bit
	--port map(clk => clk,
	--resetn => resetn,
	--rec_flag => rec_flag,
	--input => input,
	--output => output_main
	--);
	
	--divider_inst : divider
	--port map(clk => clk,
	--resetn => resetn,
	--input_rec => rec_flag,
	--input => output_main,
	--output => output
	--);

end Behavioral;

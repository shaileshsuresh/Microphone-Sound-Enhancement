-- Wrapper file for the channel selector

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;



entity wrap_simple_sel is
  generic (
        CHAN_WID : integer := 16
    );
  
  port (
    clk   : in  std_logic;
    rstn  : in  std_logic;
    fsync : in std_logic;
    input_i : in std_logic_vector(63 downto 0);
    output_o : out std_logic_vector(15 downto 0)
	);
end entity wrap_simple_sel;

architecture arch_wrap_simple_sel of wrap_simple_sel is
  

	
	component wrapper is
	port (clk : in std_logic;
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
	end component wrapper;

	signal dummy_wrap_out : std_logic_vector(15 downto 0);
	signal sel : std_logic_vector(1 downto 0);


	component simple_selector is
	port(
    switch     : in  std_logic_vector(1 downto 0);
    chan1_data : in  std_logic_vector(15 downto 0);
    chan2_data : in  std_logic_vector(15 downto 0);
    chan3_data : in  std_logic_vector(15 downto 0);
    chan4_data : in  std_logic_vector(15 downto 0);
    out_data   : out std_logic_vector(15 downto 0)
   );
	end component simple_selector;





begin

	wrapper_inst: wrapper
	port map(clk => clk,
	resetn => rstn,
	rec_flag => fsync,
	input1 => input_i(15 downto 0),
	input2 => input_i(31 downto 16),
	input3 => input_i(47 downto 32),
	input4 => input_i(63 downto 48),
	output => dummy_wrap_out,
	sel => sel
	);

	simple_selector_inst: simple_selector
	port map(switch => sel,
	chan1_data => input_i(15 downto 0),
	chan2_data => input_i(31 downto 16),
	chan3_data => input_i(47 downto 32),
	chan4_data => input_i(63 downto 48),
	out_data => output_o
	);

end arch_wrap_simple_sel;


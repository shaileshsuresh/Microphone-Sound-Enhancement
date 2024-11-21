--This module integrates the low pass and high pass filter along with the filter controller via UART receiver module.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_wrapper is



port( clk: in std_logic;
      reset : in std_logic;

      fclk 	     : in std_logic;
      rx         : in std_logic;
      in_sig	 : in std_logic_vector(15 downto 0);
      out_sig    : out std_logic_vector(15 downto 0)

);

end controller_wrapper;

architecture arch_controller_wrapper of controller_wrapper is

--signal clk : std_logic;
--signal reset : std_logic;
--signal sig_data_out : std_logic_vector(7 downto 0);
signal valid: std_logic;
signal uart: std_logic_vector(7 downto 0);
signal rx_sig : std_logic;
--signal N_sig : integer;
--signal FS_sig : std_logic_vector(15 downto 0);
--signal DFC_sig : std_logic_vector(15 downto 0);
--signal fclk_sig : std_logic;
--signal fcon_en_i : std_logic;
--signal fcon_cmd_i : std_logic_vector(15 downto 0);
--signal in_sig : std_logic_vector(15 downto 0);
--signal out_sig : std_logic_vector(15 downto 0);
signal fcon_en_lp : std_logic;
signal fcon_en_hp : std_logic;
signal fcon_cmd_lp : std_logic_vector(15 downto 0);
signal fcon_cmd_hp : std_logic_vector(15 downto 0);
signal out_sig_lp : std_logic_vector(15 downto 0);
signal in_sig_hp : std_logic_vector(15 downto 0);
signal out_sig_hp : std_logic_vector(15 downto 0);

component ila_controller_wrapper 
 
 port( clk    : in std_logic;
       PROBE0 : in std_logic;
       PROBE1 : in std_logic;
       PROBE2 : in std_logic;
       PROBE3 : in std_logic_vector(15 downto 0);
       PROBE4 : in std_logic_vector(15 downto 0)
       
     );
     
 end component ila_controller_wrapper;


component lp_filter

 generic (
    N   : integer   := 6;                           -- filter order
    FS  : std_logic_vector(15 downto 0) := x"BB80"; -- sampling frequency
    DFC : std_logic_vector(15 downto 0) := x"0AF0"  -- default cut-off frequency
  );
  port (
    clk        : in std_logic;
    fclk       : in std_logic;
    rstn       : in std_logic;
    -- from filter controller
    fcon_en_i  : in std_logic;
    fcon_cmd_i : in std_logic_vector(15 downto 0);
    -- data
    in_sig     : in  std_logic_vector(15 downto 0);
    out_sig    : out std_logic_vector(15 downto 0)
  );

end component;



component hp_filter

generic (
    N   : integer   := 4;                           -- filter order
    FS  : std_logic_vector(15 downto 0) := x"BB80"; -- sampling frequency
    DFC : std_logic_vector(15 downto 0) := x"0064"  -- default cut-off frequency
  );
  port (
    clk        : in std_logic;
    fclk       : in std_logic;
    rstn       : in std_logic;
    -- from filter controller
    fcon_en_i  : in std_logic;
    fcon_cmd_i : in std_logic_vector(15 downto 0);
    -- data
    in_sig     : in  std_logic_vector(15 downto 0);
    out_sig    : out std_logic_vector(15 downto 0)
  );

end component;
-- new hpf
component newhp_filter is
  port (
    clk    : in  std_logic;
    rstn   : in  std_logic;
    fclk   : in  std_logic; --  frame clock 48000Hz
    y      : out std_logic_vector(15 downto 0);
    x      : in  std_logic_vector(15 downto 0)
  );
end component newhp_filter;






component uart_rx 

Port(
	clk : in STD_LOGIC;
    reset : in STD_LOGIC;
	data_out : out STD_LOGIC_VECTOR(7 downto 0);
    rx : in STD_LOGIC;
	data_received : out std_logic);
end component;

component filter_controller

Port(
    clk        : in  std_logic;
    rstn       : in  std_logic;
    -- uart
    uart_valid : in std_logic;
    uart_data  : in std_logic_vector(7 downto 0);
    -- filter
    en_lp0     : out std_logic;
    en_hp0     : out std_logic;
    data       : out std_logic_vector(15 downto 0)

);
end component;


begin




inst_lp_filter: 

component lp_filter


	   
port map( clk => clk,
	  fclk => fclk,
	  rstn => reset,
	  fcon_en_i => fcon_en_lp,
	  fcon_cmd_i => fcon_cmd_lp,
	  in_sig => in_sig,--(11 downto 0) & std_logic_vector'("0000"),
	  out_sig => out_sig_lp);


in_sig_hp <= out_sig_lp;

--inst_hp_filter: 
--component hp_filter 
--port map( clk => clk,
--	  fclk => fclk,
--	  rstn => reset,
--	  fcon_en_i => fcon_en_hp,
--	  fcon_cmd_i => fcon_cmd_hp,
--    in_sig => in_sig,-- in_sig_hp,
--	  out_sig => out_sig_hp);
 
inst_newhp_filter:
component newhp_filter
port map (
     clk => clk,
    fclk => fclk,
	  rstn => reset,
	  x => in_sig_hp,
	  y => out_sig_hp
);  

inst_uart: 

component uart_rx

port map( clk => clk,
	  reset => reset,
      data_out => uart,
	  rx => rx,
	  data_received => valid
);


inst_filter_controller:

component filter_controller

port map( clk => clk,
	  rstn => reset,
	  uart_valid => valid,
	  uart_data => uart,
	  en_lp0 => fcon_en_lp,
  	  en_hp0 => fcon_en_hp,
	  data => fcon_cmd_hp

);

out_sig <= out_sig_lp(15 downto 0) ;

--ila
--inst_ila_controller_wrapper : ila_controller_wrapper

--port map(
--clk => clk,
--PROBE0 => reset,
--PROBE1 => fclk,
--PROBE2 => rx,
--PROBE3 => in_sig,
--PROBE4 => out_sig_lp
--);


end architecture arch_controller_wrapper;


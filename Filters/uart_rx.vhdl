--This component implements the UART reception from the keyboard to the FPGA. 
--This module is required for controlling the cut-off frequency of the filter using keyboard commands

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_rx is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
	       data_out : out STD_LOGIC_VECTOR(7 downto 0);
           rx : in STD_LOGIC;
		   data_received : out std_logic);
end uart_rx;

architecture Behavioral of uart_rx is
type state is (ready, start, stop);
signal present_state: state := ready;
signal store : std_logic_vector(7 downto 0);
signal baud_rate : std_logic;
signal baud_count : integer range 0 to 1023;
signal i      : integer range 0 to 10;
signal baud_rate_buf : std_logic;
signal rx_buf : STD_LOGIC;
signal data_out_sig : std_logic_vector(7 downto 0);
signal data_received_sig : std_logic;

component ila_3 is

port( 
    clk : IN STD_LOGIC;
    PROBE0: in std_logic;
    --PROBE1: in std_logic;
    PROBE1 : in STD_LOGIC_VECTOR(7 downto 0);
    PROBE2 : in STD_LOGIC;
    PROBE3 : in std_logic

);

end component ila_3;

begin

process(clk, reset)
begin
  if reset = '0' then
    baud_count <= 0;
    baud_rate <= '0';
  else
  if rising_edge(clk) then
    if baud_count = 868-1 then  -- 100 MHz / 115200
        baud_rate <= '1';
        baud_count <= 0;
    else
        baud_count <= baud_count + 1;
        baud_rate <= '0';
    end if;
 end if;
 end if;
end process;
  
 process(clk, reset)
 begin
 if reset = '0' then
   present_state <= ready;
   i             <= 0;
   store         <= (others=>'0');
   rx_buf        <= '0';
   baud_rate_buf <= '0';
   data_received_sig <= '0';
   data_out_sig      <= (others=>'0');
 else
 if rising_Edge(clk) then
    rx_buf    <= rx;
    baud_rate_buf <= baud_rate;
  --if baud_rate = '1' then 
    if present_state = ready then
        data_out_sig      <= (others=>'0');		--reset all bits of the signal to 0 inorder to be able to receive the bits
		if rx='0' and baud_rate = '1' and baud_rate_buf = '0' then
            present_state <= start;			
            i<=0;
        end if;
    end if;
    
    if present_state = start then
        if baud_rate = '1' and baud_rate_buf = '0' then
          i <= i + 1;
        end if;
        
        
        
        if i = 0 then
            store(0) <= rx;		-- sends each value serially to the buffer
        end if;
        
        if i = 1 then
            store(1) <= rx;
        end if;
        
        if i = 2 then
            store(2) <= rx;
        end if;
        
        if i = 3 then
            store(3) <= rx;
        end if;
        
        if i = 4 then
            store(4) <= rx;
        end if;
        
        if i = 5 then
            store(5) <= rx;
        end if;
        
        if i = 6 then
            store(6) <= rx;
        end if;
        
        if i = 7 then
            store(7) <= rx;
            
        end if;

        if i = 8 then
            present_state <= stop; 		-- data is no longer received after 8 bits
            i <= 0;
        end if;

    end if;
	if present_state = stop then
        if baud_count = 868 -2 then
            data_out_sig <= store;
			data_received_sig<='1';   -- indicates successful reception of data
        elsif baud_count = 868 -1 then
            data_out_sig      <= (others=>'0');
            data_received_sig<='0';
        end if;

		if rx = '1' and baud_rate = '1' and baud_rate_buf = '0' then
            present_state <= ready;
		    store <= (others=>'0');
			
		end if;
		
		
			
	end if;
  --end if;
 end if;
end if;

data_out <= data_out_sig;
data_received <= data_received_sig;
       
end process;

--ILA

inst_ila3 : ila_3

port map(
clk => clk,
PROBE0 => reset,
--PROBE1 => reset,
PROBE1 => data_out_sig,
PROBE2 => rx,
PROBE3 => data_received_sig
);

end Behavioral;

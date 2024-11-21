--This module enables to adjust the cut-off frequency of the filter. First select the filter by entering '1' for low pass filter and '2' for high pass filter.
--Now, enter the hex value of cut-off frequency from the keyboard using some UART interface like 'Coolterm'
--The filter adjusts its frequency response according to the value entered.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity filter_controller is
  port (
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
end entity filter_controller;

architecture arch_filter_controller of filter_controller is
  type vector_8 is array (NATURAL RANGE <>) OF std_logic_vector(7 DOWNTO 0);
  -- ILA component
  --

  -- finite state machine
  TYPE state_type IS (
    idle_state,
    load_state,
    send_state
  );
  signal state_signal      : state_type;
  signal next_state_signal : state_type;
  -- global
  signal counter    : integer range 0 to 3;
  signal buff       : vector_8(0 to 2);
  signal uart_valid_buf : std_logic;
  signal uart_data_buf  : std_logic_vector(7 downto 0);
begin
  ------------------------------------------------------------------------------------------------------------------ FSM: state_transition_proc
  state_transition_proc:
  process (rstn,clk)
  begin
    if (rstn = '0') then
      state_signal <= idle_state;
    elsif rising_edge(clk) then
      state_signal <= next_state_signal;
    end if;
  end process state_transition_proc;
  ------------------------------------------------------------------------------------------------------------------ FSM: state_flow_proc
  state_flow_proc:
  process (state_signal,uart_valid,counter)
  begin
    case state_signal is
      when idle_state =>
        if uart_valid = '1' then
          next_state_signal <= load_state;
        else
          next_state_signal <= idle_state;
        end if;
      when load_state =>
        if counter = 3 then
          next_state_signal <= send_state;
        else
          next_state_signal <= load_state;
        end if;
      when send_state =>
        next_state_signal <= idle_state;
      when others =>
        next_state_signal <= idle_state;

    end case;
  end process state_flow_proc;
  ------------------------------------------------------------------------------------------------------------------ FSM: assignment_proc
  assignment_proc:
  process (state_signal,buff)
  begin
    data   <= x"0000";
    en_lp0 <= '0';
    en_hp0 <= '0';
    case state_signal is
      when idle_state =>

      when load_state =>

      when send_state =>
        data <= buff(1) & buff(2);
        if buff(0) = x"01" then -- lpf
          en_lp0 <= '1';
          en_hp0 <= '0';
        elsif buff(0) = x"02" then -- hpf
          en_lp0 <= '0';
          en_hp0 <= '1';
        end if;
      when others =>

    end case;
  end process assignment_proc;
  ------------------------------------------------------------------------------------------------------------------ others
  data_reg_proc:
  process (clk,rstn)
  begin
    if rstn = '0' then
      counter <= 0;
      uart_data_buf  <= x"00";
      uart_valid_buf <= '0';
      buff(0) <= x"00";
      buff(1) <= x"00";
      buff(2) <= x"00";

    elsif rising_edge(clk) then
      uart_data_buf  <= uart_data;
      uart_valid_buf <= uart_valid;

      case state_signal is
        when idle_state =>
          counter <= 0;
	
        when load_state =>
          if uart_valid_buf = '1' then
            if counter = 0 then
              buff(0) <= uart_data_buf;
              counter <= counter + 1;
	          elsif counter = 1 then
              buff(1) <= uart_data_buf;
              counter <= counter + 1;
            elsif counter = 2 then
              buff(2) <= uart_data_buf;
              counter <= counter + 1;
            end if;
          end if;
        when send_state =>
          counter <= 0;
        when others =>
          counter <= 0;
      end case;
    end if;
  end process data_reg_proc;

end architecture arch_filter_controller;

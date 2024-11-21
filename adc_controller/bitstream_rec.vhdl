--TDM handler which converts the bitstream serial data to parallel data

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity bitstream_rec is
    port (
        resetn     : in std_logic;
        bclk        : in std_logic; -- bclk
        input_bit  : in std_logic;
        fsync      : in std_logic;
        chan1_data : out std_logic_vector(15 downto 0);
        chan2_data : out std_logic_vector(15 downto 0);
        chan3_data : out std_logic_vector(15 downto 0);
        chan4_data : out std_logic_vector(15 downto 0)
    );
end bitstream_rec;

architecture behavioral of bitstream_rec is
  signal fsync_buf  : std_logic;
  signal i          : integer range 0 to 511;
	signal chan1_buff : std_logic_vector(15 downto 0);
  signal chan2_buff : std_logic_vector(15 downto 0);
  signal chan3_buff : std_logic_vector(15 downto 0);
  signal chan4_buff : std_logic_vector(15 downto 0);

  signal input_bit_buf1 : std_logic;
  signal input_bit_buf2 : std_logic;
	-- finite state machine
  TYPE state_type IS (
    idle_state,
    data_state
  );
  signal state_signal      : state_type;
  signal next_state_signal : state_type;

begin
  ------------------------------------------------------------------------------------------------------------------ FSM: state_transition_proc
  state_transition_proc:
  process (resetn,bclk)
  begin
    if (resetn = '0') then
      state_signal <= idle_state;
    elsif rising_edge(bclk) then
      state_signal <= next_state_signal;
    end if;
  end process state_transition_proc;
  ------------------------------------------------------------------------------------------------------------------ FSM: state_flow_proc
  state_flow_proc:
  process (state_signal,fsync,fsync_buf,i)
  begin
    case state_signal is
      when idle_state =>
        if fsync = '1' then
          next_state_signal <= data_state;
        else
          next_state_signal <= idle_state;
        end if;
      when data_state =>
        if i = 64 then
          next_state_signal <= idle_state;
        else
          next_state_signal <= data_state;
        end if;
      when others =>
        next_state_signal <= idle_state;
    end case;
  end process state_flow_proc;
  ------------------------------------------------------------------------------------------------------------------ FSM: assignment_proc
  assignment_proc:
  process (state_signal)
  begin
    case state_signal is
      when idle_state =>
        
      when data_state =>

      when others =>

    end case;
  end process assignment_proc;
  ---------------------------------------
  reg_proc:
  process (bclk,resetn)
  begin
    if resetn = '0' then
      chan1_buff <= x"0000";
      chan2_buff <= x"0000";
      chan3_buff <= x"0000";
      chan4_buff <= x"0000";
      --chan1_data <= x"0000";
      --chan2_data <= x"0000";
      --chan3_data <= x"0000";
      --chan4_data <= x"0000";
      input_bit_buf1 <= '0';
      input_bit_buf2 <= '0';
      fsync_buf  <= '0';
      i <= 0;
    elsif rising_edge(bclk) then
      input_bit_buf1 <= input_bit;
      input_bit_buf2 <= input_bit_buf1;
      fsync_buf     <= fsync; 
      case state_signal is
        when idle_state =>
          i <= 0;
        when data_state =>
          --if i = 0 then
          --  chan1_data <= chan1_buff;
          --  chan2_data <= chan2_buff;
          --  chan3_data <= chan3_buff;
          --  chan4_data <= chan4_buff;
          --end if;
          if i < 64 then
            i <= i + 1;
          end if;
          if i >= 0 and i < 16 then
            chan1_buff(15-i) <= input_bit_buf1;
          elsif i >= 16 and i < 32 then
            chan2_buff(15-(i-16)) <= input_bit_buf1;
          elsif i >= 32 and i < 48 then
            chan3_buff(15-(i-32)) <= input_bit_buf1;
          elsif i >= 48 and i < 64 then
            chan4_buff(15-(i-48)) <= input_bit_buf1;
          end if;

        when others =>
          i <= 0;
      end case;
    end if;
  end process reg_proc;
  process (fsync,resetn)
  begin
    if resetn = '0' then
      chan1_data <= x"0000";
      chan2_data <= x"0000";
      chan3_data <= x"0000";
      chan4_data <= x"0000";
    elsif rising_edge(fsync) then
      chan1_data <= chan1_buff;
      chan2_data <= chan2_buff;
      chan3_data <= chan3_buff;
      chan4_data <= chan4_buff;
    end if;
  end process;
end behavioral;

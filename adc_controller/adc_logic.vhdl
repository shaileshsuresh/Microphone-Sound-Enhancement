--Configures all the registers for the ADC transmission

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
library work;


entity adc_logic is
  port (
    clk      : in  std_logic;
    rstn     : in  std_logic;
    sdn      : out std_logic;
    asi_en   : out std_logic;
    -- spi transceiver
    spi_tx   : out std_logic;
    spi_txd  : out std_logic_vector(7 downto 0);
    spi_done : in  std_logic;
    spi_rxd  : in  std_logic_vector(7 downto 0)
  );
end entity adc_logic;


architecture archi_adc_logic of adc_logic is
  -- operations
  constant RD : std_logic := '1';
  constant WR : std_logic := '0';
  component spi_transceiver is
    port (
      clk    : in  std_logic;
      rstn   : in  std_logic;
      tx     : in  std_logic;
      done  : out std_logic;
      txdata : in  std_logic_vector(7 downto 0);
      rxdata : out std_logic_vector(7 downto 0);
      -- spi
      nsel   : out std_logic; -- spi device select
      sclk   : out std_logic; -- spi clock output
      sdo    : out std_logic;-- spi data out
      sdi    : in  std_logic); -- spi data in
  end component spi_transceiver;
  -- finite state machine
  TYPE state_type IS (
    initial_state,
    idle_state,
    delay_state,
    cmd_load_state,
    cmd_send_state
  );
  signal state_signal      : state_type;
  signal next_state_signal : state_type;
  -- global control signals
  signal initial_proc : std_logic; -- initial process ongoing
  signal count_value  : integer range 0 to 100000000;
  signal adc_reg      : std_logic_vector(7 downto 0);
  -- data to be sent via SPI
  signal txbyte_0     : std_logic_vector(7 downto 0);
  signal txbyte_1     : std_logic_vector(7 downto 0);
  -- output signals
  signal asi_en_out  : std_logic;
  signal sdn_out     : std_logic;
  signal spi_tx_out  : std_logic;
  signal spi_txd_out : std_logic_vector(7 downto 0);
  -- reg
  signal spi_done_reg : std_logic;

begin

  ------------------------------------------------------------------------------------------------------------------ Output
  sdn     <= sdn_out;
  spi_tx  <= spi_tx_out;
  spi_txd <= spi_txd_out;
  asi_en  <= asi_en_out;
  ------------------------------------------------------------------------------------------------------------------ ILA

  ------------------------------------------------------------------------------------------------------------------ FSM: state_transition_proc
  state_transition_proc:
  process (rstn,clk)
  begin
    if (rstn = '0') then
      state_signal <= initial_state;
    elsif rising_edge(clk) then
      state_signal <= next_state_signal;
    end if;
  end process state_transition_proc;
  ------------------------------------------------------------------------------------------------------------------ FSM: state_flow_proc
  state_flow_proc:
  process (state_signal,adc_reg,count_value,initial_proc)
  begin
    case state_signal is
      when initial_state =>
        next_state_signal <= delay_state;
      when idle_state =>
        next_state_signal <= idle_state;
      when delay_state =>
        if adc_reg = x"7F" and count_value = 300000 then
          next_state_signal <= cmd_load_state;
        elsif adc_reg = x"02" and count_value = 240000 then
          next_state_signal <= cmd_load_state;
        elsif adc_reg /= x"7F" and  adc_reg /= x"02" and count_value = 240000 then
          next_state_signal <= cmd_load_state;
        else
          next_state_signal <= delay_state;
        end if;
      when cmd_load_state =>
        next_state_signal <= cmd_send_state;
      when cmd_send_state =>
        if count_value = 2 then
          if adc_reg = x"75" and initial_proc = '1' then
            next_state_signal <= idle_state;
          else
            next_state_signal <= delay_state;
          end if;
        else
          next_state_signal <= cmd_send_state;
        end if;
      when others =>
        next_state_signal <= delay_state;
    end case;
  end process state_flow_proc;
  ------------------------------------------------------------------------------------------------------------------ FSM: assignment_proc
  assignment_proc:
  process (state_signal,count_value,txbyte_0,txbyte_1)
  begin
    spi_tx_out  <= '0';
    spi_txd_out <= x"00";
    case state_signal is
      when initial_state =>
      when idle_state =>
      when delay_state =>
      when cmd_load_state =>
      when cmd_send_state =>
        if count_value = 0 then
          spi_tx_out <= '1';
          spi_txd_out <= txbyte_0;
        elsif count_value = 1 then
          spi_tx_out <= '1';
          spi_txd_out <= txbyte_1;
        else
          spi_tx_out <= '0';
          spi_txd_out <= x"00";
        end if;
      when others =>
    end case;
  end process assignment_proc;
  ------------------------------------------------------------------------------------------------------------------ others
  data_reg_proc:
  process (rstn,clk)
  begin
    if rstn = '0' then
      initial_proc <= '1';
      sdn_out      <= '0';
      adc_reg      <= x"7F";
      txbyte_0     <= x"00";
      txbyte_1     <= x"00";
      spi_done_reg <= '0';
    elsif rising_edge(clk) then
      spi_done_reg <= spi_done;
      case state_signal is
        when initial_state =>
          initial_proc <= '1';
        when idle_state =>
          initial_proc <= '0';
        when delay_state =>
          if adc_reg = x"7F" and count_value = 100000 then
            sdn_out <= '1';
          end if;
          if next_state_signal /= delay_state then
            if adc_reg = x"7F" and initial_proc = '1' then
              adc_reg <= x"02";
            elsif adc_reg = x"02" and initial_proc = '1' then
              adc_reg <= x"07";
            elsif adc_reg = x"07" and initial_proc = '1' then
              adc_reg <= x"08";
            elsif adc_reg = x"08" and initial_proc = '1' then
              adc_reg <= x"3B";
            -- SLOTS
            elsif adc_reg = x"3B" and initial_proc = '1' then
              adc_reg <= x"0B";
            elsif adc_reg = x"0B" and initial_proc = '1' then
              adc_reg <= x"0C";
            elsif adc_reg = x"0C" and initial_proc = '1' then
              adc_reg <= x"0D";
            elsif adc_reg = x"0D" and initial_proc = '1' then
              adc_reg <= x"0E";
            --CHANNEL CONF0
            elsif adc_reg = x"0E" and initial_proc = '1' then
              adc_reg <= x"3C";
            elsif adc_reg = x"3C" and initial_proc = '1' then
              adc_reg <= x"41";
            elsif adc_reg = x"41" and initial_proc = '1' then
              adc_reg <= x"46";
            elsif adc_reg = x"46" and initial_proc = '1' then
              adc_reg <= x"4B";
            --
            elsif adc_reg = x"4B" and initial_proc = '1' then
              adc_reg <= x"13";
            elsif adc_reg = x"13" and initial_proc = '1' then
              adc_reg <= x"14";
            elsif adc_reg = x"14" and initial_proc = '1' then
              adc_reg <= x"16";
            elsif adc_reg = x"16" and initial_proc = '1' then
              adc_reg <= x"21";
            elsif adc_reg = x"21" and initial_proc = '1' then
              adc_reg <= x"73";
            elsif adc_reg = x"73" and initial_proc = '1' then
              adc_reg <= x"74";
            elsif adc_reg = x"74" and initial_proc = '1' then
              adc_reg <= x"75";
            elsif adc_reg = x"75" and initial_proc = '1' then
              adc_reg <= x"7F";
            end if;
            
          end if;
        when cmd_load_state =>
          if adc_reg = x"02" then
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"01";
          elsif adc_reg = x"07" then
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"00";
          elsif adc_reg = x"08" then
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"00";
          -- SLOTS
          elsif adc_reg = x"0B" then
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"00";
          elsif adc_reg = x"0C" then
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"01";
          elsif adc_reg = x"0D" then
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"02";
          elsif adc_reg = x"0E" then
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"03";
          -- CHANNEL CONF0
          elsif adc_reg = x"3C" then -- DC/AC coupling 1
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"10";
          elsif adc_reg = x"41" then -- DC/AC coupling 2
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"10";
          elsif adc_reg = x"46" then -- DC/AC coupling 3
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"10";
          elsif adc_reg = x"4B" then -- DC/AC coupling 4
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"10";
          --
          elsif adc_reg = x"21" then
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"A0"; 
          elsif adc_reg = x"13" then
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"80";
          elsif adc_reg = x"3B" then
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"D0";
          elsif adc_reg = x"14" then -- bclk/fclk
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"45";
          elsif adc_reg = x"16" then
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"10";
          elsif adc_reg = x"73" then
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"F0";
          elsif adc_reg = x"74" then
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"F0";
          elsif adc_reg = x"75" then
            txbyte_0 <= adc_reg(6 downto 0) & WR;
            txbyte_1 <= x"E0";
          end if;
        when cmd_send_state =>
          
        when others =>
      end case;
    end if;
  end process data_reg_proc;

  counter_proc:
  process (clk,rstn)
  begin
    if rstn = '0' then
      count_value <= 0;
    elsif rising_edge(clk) then
      case state_signal is
        when initial_state =>
        when idle_state =>
        when delay_state =>
          count_value <= count_value + 1;
        when cmd_load_state =>
        when cmd_send_state =>
          if spi_done_reg = '0' and spi_done = '1' then
            count_value <= count_value + 1;
          end if;
        when others =>
      end case;
      if state_signal /= next_state_signal then
        count_value <= 0;
      end if;
    end if;
  end process counter_proc;
  asi_en_out <= not(initial_proc);
end architecture archi_adc_logic;

-- Implements SPI protocol for ADC controller

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_transceiver is
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
end entity spi_transceiver;

architecture archi_spi_transceiver of spi_transceiver is
  constant CLOCK_FREQ : integer := 100000000;
  constant CLOCK_DIV  : integer := 1000000; -- 1M
  constant CLOCK_CNT  : integer := (CLOCK_FREQ/CLOCK_DIV); 
  constant CLOCK_HCNT : integer := CLOCK_CNT/2; 
  constant BYTE_LEN   : integer := 8;
  signal   txbuf      : std_logic_vector(BYTE_LEN-1 downto 0);
  signal   rxbuf      : std_logic_vector(BYTE_LEN-1 downto 0);
  


  signal state_signal      : std_logic_vector(8 downto 0);
  signal next_state_signal : std_logic_vector(8 downto 0);
  signal count_value : integer range CLOCK_CNT downto 1;
  signal sdo_buf     : std_logic;
  --signal sclk_gen    : std_logic;



  -- -- ILA
  -- COMPONENT ila_1 IS
  -- PORT (
  --   clk : IN STD_LOGIC;
  --   probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
  --   probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
  --   probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
  --   probe3 : IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
  --   probe4 : IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
  --   probe5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
  --   probe6 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
  --   probe7 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
  --   probe8 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
  --   probe9 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  --   probe10 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  --   probe11 : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
  -- );
  -- END COMPONENT  ila_1;
  -- output signals
  signal done_out   : std_logic;
  signal rxdata_out : std_logic_vector(7 downto 0);
  signal nsel_out   : std_logic; -- spi device select
  signal sclk_out   : std_logic; -- spi clock output
  signal sdo_out    : std_logic;-- spi data out
  signal state_out  : std_logic_vector(3 downto 0);
  signal next_state_out  : std_logic_vector(3 downto 0);
begin
  done   <= done_out;
  rxdata <= rxdata_out;
  nsel   <= nsel_out;
  sclk   <= sclk_out;
  sdo    <= sdo_out;
  process (state_signal,next_state_signal,clk) 
  begin
    case state_signal is
      when "100000000" =>
      state_out <= "1000";
      when "010000000" =>
      state_out <= "0111";
      when "001000000" =>
      state_out <= "0110";
      when "000100000" =>
      state_out <= "0101";
      when "000010000" =>
      state_out <= "0100";
      when "000001000" =>
      state_out <= "0011";
      when "000000100" =>
      state_out <= "0010";
      when "000000010" =>
      state_out <= "0001";
      when "000000001" =>
      state_out <= "0000";
      when others =>
      state_out <= "1111";
    end case;
    case next_state_signal is
      when "100000000" =>
      next_state_out <= "1000";
      when "010000000" =>
      next_state_out <= "0111";
      when "001000000" =>
      next_state_out <= "0110";
      when "000100000" =>
      next_state_out <= "0101";
      when "000010000" =>
      next_state_out <= "0100";
      when "000001000" =>
      next_state_out <= "0011";
      when "000000100" =>
      next_state_out <= "0010";
      when "000000010" =>
      next_state_out <= "0001";
      when "000000001" =>
      next_state_out <= "0000";
      when others =>
      next_state_out <= "1111";
    end case;
  end process;
  -- --ILA
  -- inst_ila1 : ila_1
  -- PORT MAP (
  --   clk => clk,
  --   probe0(0) => rstn, 
  --   probe1(0) => tx, 
  --   probe2(0) => done_out, 
  --   probe3 => txdata, 
  --   probe4 => rxdata_out, 
  --   probe5(0) => nsel_out, 
  --   probe6(0) => sclk_out, 
  --   probe7(0) => sdo_out,
  --   probe8(0) => sdi,
  --   probe9 => std_logic_vector(to_unsigned(count_value, 8)),
  --   probe10 =>state_out,
  --   probe11 =>next_state_out
  -- );

  reg_proc:
  process (rstn,clk)
  begin
    if (rstn = '0') then
      txbuf   <= "00000000";
      rxbuf   <= "00000000";
      --sdo_buf <= '1';
    else
      if rising_edge(clk) then
        if tx = '1' then
          if next_state_signal = "010000000" then
            txbuf <= txdata;
          end if;
        end if;
          case state_signal is
            when "100000000" =>
              --
            when "010000000" =>
              if count_value = CLOCK_HCNT/2 then 
                rxbuf(7) <= sdi;
              elsif count_value = 0 then
                --sdo_buf <= txbuf(7);
              end if;
            when "001000000" =>
              if count_value = CLOCK_HCNT/2 then 
                rxbuf(6) <= sdi;
              elsif count_value = 0 then
                --sdo_buf <= txbuf(6);
              end if;
            when "000100000" =>
              if count_value = CLOCK_HCNT/2 then 
                rxbuf(5) <= sdi;
              elsif count_value = 0 then
                --sdo_buf <= txbuf(5);
              end if;
            when "000010000" =>
              if count_value = CLOCK_HCNT/2 then 
                rxbuf(4) <= sdi;
              elsif count_value = 0 then
                --sdo_buf <= txbuf(4);
              end if;
            when "000001000" =>
              if count_value = CLOCK_HCNT/2 then 
                rxbuf(3) <= sdi;
              elsif count_value = 0 then
                --sdo_buf <= txbuf(3);
              end if;
            when "000000100" =>
              if count_value = CLOCK_HCNT/2 then 
                rxbuf(2) <= sdi;
              elsif count_value = 0 then
                --sdo_buf <= txbuf(2);
              end if;
            when "000000010" =>
              if count_value = CLOCK_HCNT/2 then 
                rxbuf(1) <= sdi;
              elsif count_value = 0 then
                --sdo_buf <= txbuf(1);
              end if;
            when "000000001" =>
              if count_value = CLOCK_HCNT/2 then 
                rxbuf(0) <= sdi;
              elsif count_value = 0 then
                --sdo_buf <= txbuf(0);
              end if;
            when others =>
              --
          end case;
      end if;
      
      
    end if;
  end process reg_proc;




  state_transition_proc:
  process (rstn,clk)
  begin
    if (rstn = '0') then
      state_signal <= "100000000";
    elsif rising_edge(clk) then
      state_signal <= next_state_signal;
    end if;
  end process state_transition_proc;

  state_flow_proc:
  process (state_signal,tx,count_value)
  begin
    next_state_signal <= "100000000";
    case state_signal is
      when "100000000" =>
        if tx = '1' and count_value = CLOCK_HCNT/2 then
          next_state_signal <= "010000000";
        else
          next_state_signal <= "100000000";
        end if;

      when "010000000" =>
        if count_value = CLOCK_CNT then
          next_state_signal <= "001000000";
        else
          next_state_signal <= "010000000";
        end if;
      when "001000000" =>
        if count_value = CLOCK_CNT then
          next_state_signal <= "000100000";
        else
          next_state_signal <= "001000000";
        end if;
      when "000100000" =>
        if count_value = CLOCK_CNT then
          next_state_signal <= "000010000";
        else
          next_state_signal <= "000100000";
        end if;
      when "000010000" =>
        if count_value = CLOCK_CNT then
          next_state_signal <= "000001000";
        else
          next_state_signal <= "000010000";
        end if; 
      when "000001000" =>
        if count_value = CLOCK_CNT then
          next_state_signal <= "000000100";
        else
          next_state_signal <= "000001000";
        end if;
      when "000000100" =>
        if count_value = CLOCK_CNT then
          next_state_signal <= "000000010";
        else
          next_state_signal <= "000000100";
        end if;
      when "000000010" =>
        if count_value = CLOCK_CNT then
          next_state_signal <= "000000001";
        else
          next_state_signal <= "000000010";
        end if;
      when "000000001" =>
        if count_value = CLOCK_CNT then
          if tx = '1' then
            next_state_signal <= "010000000";
          else
            next_state_signal <= "100000000";
          end if;
        else
          next_state_signal <= "000000001";
        end if;
      when others =>
        next_state_signal <= "100000000";
    end case;
  end process state_flow_proc;

  assignment_proc:
  process (state_signal,tx,sdo_buf,rxbuf,count_value,txbuf)
  begin
    sclk_out  <= '0';
    nsel_out  <= '1';
    sdo_out   <= '1';
    done_out  <= '0';
    rxdata_out <= "00000000";
    sdo_buf <= '1';
    case state_signal is
      when "100000000" =>
        if tx = '1' then
          sclk_out  <= '0';
          nsel_out  <= '0';
        else
          nsel_out  <= '1';
        end if;
      when "010000000" =>
        if count_value > CLOCK_HCNT  then 
          sclk_out     <= '0';
        else
          sclk_out     <= '1';
        end if;
        nsel_out  <= '0';
        sdo_out   <= txbuf(7);
      when "001000000" =>
        if count_value > CLOCK_HCNT  then 
          sclk_out     <= '0';
        else
          sclk_out     <= '1';
        end if;
        nsel_out  <= '0';
        sdo_out   <= txbuf(6);
        
      when "000100000" =>
        if count_value > CLOCK_HCNT  then 
          sclk_out     <= '0';
        else
          sclk_out     <= '1';
        end if;
        nsel_out  <= '0';
        sdo_out   <= txbuf(5);
        
      when "000010000" =>
        if count_value > CLOCK_HCNT  then 
          sclk_out     <= '0';
        else
          sclk_out     <= '1';
        end if;
        nsel_out  <= '0';
        sdo_out   <= txbuf(4);
        
      when "000001000" =>
        if count_value > CLOCK_HCNT  then 
          sclk_out     <= '0';
        else
          sclk_out     <= '1';
        end if;
        nsel_out  <= '0';
        sdo_out   <= txbuf(3);
        
      when "000000100" =>
        if count_value > CLOCK_HCNT  then 
          sclk_out     <= '0';
        else
          sclk_out     <= '1';
        end if;
        nsel_out  <= '0';
        sdo_out   <= txbuf(2);
        
      when "000000010" =>
        if count_value > CLOCK_HCNT  then 
          sclk_out     <= '0';
        else
          sclk_out     <= '1';
        end if;
        nsel_out  <= '0';
        sdo_out   <= txbuf(1);
        
      when "000000001" =>

        if count_value > CLOCK_HCNT  then 
          sclk_out     <= '0';
          done_out     <= '1';
          rxdata_out   <= rxbuf;
        else
          sclk_out     <= '1';
        end if;
        
        nsel_out  <= '0';
        sdo_out   <= txbuf(0);
        
        
      when others =>
        --
    end case;
  end process assignment_proc;

  counter_process:
  process (clk,rstn) is

  begin
    if rstn = '0' then
      count_value <= 1;
      --sclk_gen    <= '0';
    elsif rising_edge(clk) then
      if state_signal = "100000000" then
        if tx = '1' then
          count_value <= count_value + 1;
        end if;
        if next_state_signal /= "100000000" then
          count_value <= 1;
        end if;
      elsif state_signal /= "100000000" then
        if count_value = CLOCK_CNT then
          count_value <= 1;
          --sclk_gen    <= '0';
        elsif count_value = CLOCK_HCNT then
          --sclk_gen    <= '1';
          count_value <= count_value + 1;
        else
        count_value <= count_value + 1;
        end if;
      else
        count_value <= 1;
      end if;
    end if;
  end process counter_process;
end architecture archi_spi_transceiver;


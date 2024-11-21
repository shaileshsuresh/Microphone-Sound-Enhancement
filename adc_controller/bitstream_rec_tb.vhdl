--Testbench for bitstream_rec module (TDM handler)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity bitstream_rec_tb is

end bitstream_rec_tb;

architecture arch_bitstream_rec_tb of bitstream_rec_tb is
  component bitstream_rec is
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
  end component bitstream_rec;
  signal resetn_tb    : std_logic;
  signal bclk_tb      : std_logic := '1';
  signal input_bit_tb : std_logic;
  signal fsync_tb     : std_logic;

  signal chan1_data_tb : std_logic_vector(15 downto 0);
  signal chan2_data_tb : std_logic_vector(15 downto 0);
  signal chan3_data_tb : std_logic_vector(15 downto 0);
  signal chan4_data_tb : std_logic_vector(15 downto 0);

begin
  inst_bitstream_rec:
  component bitstream_rec 
  port map (
    resetn     => resetn_tb,
    bclk       => bclk_tb,
    input_bit  => input_bit_tb,
    fsync      => fsync_tb,
    chan1_data => chan1_data_tb,
    chan2_data => chan2_data_tb,
    chan3_data => chan3_data_tb,
    chan4_data => chan4_data_tb
  );

  clk_proc:
  process
  begin
    wait for 5 ns;
    bclk_tb <= not bclk_tb;
  end process clk_proc;

  resetn_tb <= '0', '1' after 100 ns;

  process 
  begin
    fsync_tb     <= '0';
    input_bit_tb <= '1';
    wait for 500 ns;

    for j in 0 to 95 loop
      for i in 0 to 95 loop
        if i = 0 then
          fsync_tb     <= '1';
        else
          fsync_tb     <= '0';
        end if;
        input_bit_tb <= input_bit_tb;
        wait for 10 ns;
      end loop;
      input_bit_tb <= not input_bit_tb;
    end loop;
  end process;

end architecture arch_bitstream_rec_tb;

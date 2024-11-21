--ADC controller which combines the features of SPI, TDM and the configured adc registers and delivers the digital output

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity adc_controller is
  generic (
        CHAN_WID : integer := 16
    );
  
  port (
    clk   : in  std_logic;
    rstn  : in  std_logic;
    sdn   : out std_logic;
    -- spi interface
    nsel  : out std_logic;
    sclk  : out std_logic;
    sdo   : out std_logic;
    sdi   : in  std_logic;
    -- asi interface
    mclk  : out std_logic;
    fsync : in std_logic;
    bclk  : in std_logic;
    sdin  : in  std_logic;
    -- converted data
    dac_clk : out std_logic;
    chan1_data : out std_logic_vector(CHAN_WID-1 downto 0);
    chan2_data : out std_logic_vector(CHAN_WID-1 downto 0);
    chan3_data : out std_logic_vector(CHAN_WID-1 downto 0);
    chan4_data : out std_logic_vector(CHAN_WID-1 downto 0)
    );
end entity adc_controller;

architecture archi_adc_controller of adc_controller is
  

  component clk_adc is
    port (
      clk_in1  : in  std_logic;
      reset    : in  std_logic;
      locked   : out std_logic;
      clk_out1 : out std_logic
    );
  end component clk_adc;
  
  component adc_logic is
    port (
      clk      : in  std_logic;
      rstn     : in  std_logic;
      sdn      : out std_logic;
      asi_en   : out std_logic;
      -- spi transceiver
      spi_tx   : out std_logic;
      spi_txd  : out std_logic_vector(7 downto 0);
      spi_done : in  std_logic;
      spi_rxd  : in  std_logic_vector(7 downto 0));
  end component adc_logic;
  signal asi_en   : std_logic;
  signal spi_tx   : std_logic;
  signal spi_txd  : std_logic_vector(7 downto 0);
  signal spi_done : std_logic;
  signal spi_rxd  : std_logic_vector(7 downto 0);

  component spi_transceiver is
    port (
      clk    : in  std_logic;
      rstn   : in  std_logic;
      tx     : in  std_logic;
      done   : out std_logic;
      txdata : in  std_logic_vector(7 downto 0);
      rxdata : out std_logic_vector(7 downto 0);
      -- spi
      nsel   : out std_logic;
      sclk   : out std_logic;
      sdo    : out std_logic;
      sdi    : in  std_logic);
  end component spi_transceiver;

  component bitstream_rec is
    port (
        resetn : in std_logic;
        bclk : in std_logic;
        input_bit : in std_logic;
        fsync : in std_logic;
        chan1_data : out std_logic_vector(CHAN_WID-1 downto 0);
        chan2_data : out std_logic_vector(CHAN_WID-1 downto 0);
        chan3_data : out std_logic_vector(CHAN_WID-1 downto 0);
        chan4_data : out std_logic_vector(CHAN_WID-1 downto 0)
    );
  end component bitstream_rec;
  --dac
  component DAC16 is  
      Port (
        resetn : in std_logic;
        clk : in std_logic;
        input : in std_logic_vector(15 downto 0);
        clk_output : out std_logic;
        output : out std_logic_vector(15 downto 0));
  end component DAC16;
  signal output_abc  : std_logic_vector(15 downto 0);
  
  
  
  
  -- temp
  signal rst       : std_logic;
  -- output
  signal nsel_out  : std_logic;
  signal sclk_out  : std_logic;
  signal sdo_out   : std_logic;
  signal fsync_out : std_logic;
  signal bclk_out  : std_logic;
  signal sdout_out : std_logic;
  signal sdn_out   : std_logic;
  signal mclk_out  : std_logic;
  signal chan1_data_out : std_logic_vector(CHAN_WID-1 downto 0);
  signal chan2_data_out : std_logic_vector(CHAN_WID-1 downto 0);
  signal chan3_data_out : std_logic_vector(CHAN_WID-1 downto 0);
  signal chan4_data_out : std_logic_vector(CHAN_WID-1 downto 0);
  -- ila
 --COMPONENT ila_adc_controller is
 --  PORT (
 --    clk : IN STD_LOGIC;
  --   probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
  --   probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
  --   probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
  --   probe3 : IN STD_LOGIC_VECTOR(15 DOWNTO 0)
 --  );
 --END COMPONENT ila_adc_controller;
  signal locked : std_logic;
begin
  --dac
  inst_DAC16:
  component DAC16
  port map (
    resetn     => rstn,
    clk        => clk,
    input      => x"0000",
    clk_output => dac_clk,
    output     => output_abc
  );
  -- mclk gen // 12
  inst_clk_adc:
  component clk_adc
  port map (
    clk_in1  => clk,
    reset    => rst,
    locked   => locked,
    clk_out1 => mclk_out);
  -- ila
  --inst_ila_adc_controller:
 --component ila_adc_controller
 -- PORT MAP (
 -- clk => clk,
 -- probe0(0) => fsync, 
--  probe1(0) => bclk, 
--  probe2(0) => sdin,
 -- probe3 => chan1_data_out
 -- );
  -- temp
  rst <= not(rstn);
  -- output
  nsel  <= nsel_out;
  sclk  <= sclk_out;
  sdo   <= sdo_out;
  sdn   <= sdn_out;
  mclk  <= mclk_out;
  chan1_data <= chan1_data_out;
  chan2_data <= chan2_data_out;
  chan3_data <= chan3_data_out;
  chan4_data <= chan4_data_out;


  inst_adc_logic:
  component adc_logic
  port map (
    clk      => clk,
    rstn     => rstn,
    sdn      => sdn_out,
    asi_en   => asi_en,
    spi_tx   => spi_tx,
    spi_txd  => spi_txd,
    spi_done => spi_done,
    spi_rxd  => spi_rxd
  );

  inst_spi_transceiver:
  component spi_transceiver
  port map (
    clk    => clk,
    rstn   => rstn,
    tx     => spi_tx,
    done   => spi_done,
    txdata => spi_txd,
    rxdata => spi_rxd,
    nsel   => nsel_out,
    sclk   => sclk_out,
    sdo    => sdo_out,
    sdi    => sdi
  );

  inst_bitstream_rec:
  component bitstream_rec
  port map (
    bclk        => bclk,
    resetn     => rstn,
    input_bit  => sdin,
    fsync      => fsync,
    chan1_data => chan1_data_out,
    chan2_data => chan2_data_out,
    chan3_data => chan3_data_out,
    chan4_data => chan4_data_out
  );
end architecture archi_adc_controller;

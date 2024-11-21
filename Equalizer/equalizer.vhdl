-- EQUALIZER: wrapper
--Equalizer top module which combines features of Lowpass filter, bandpass filter and highpass filter

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
entity equalizer is
  port (
    clk    : in  std_logic;
    rstn   : in  std_logic;
    --fclk   : in  std_logic; --  frame clock 48000Hz
    -- control port
    ctrl : in std_logic_vector(15 downto 0); -- vol|lp|bp|hp
    -- data port
    y      : out  std_logic_vector(15 downto 0);
    x      : in std_logic_vector(15 downto 0)
  );
end entity equalizer;

architecture arch_equalizer of equalizer is
  type vector_mul is array (NATURAL RANGE <>) OF signed(3 DOWNTO -12);
  constant PARA_VOL : vector_mul := (
    x"0000",x"0111",x"0222",x"0333",x"0444",x"0555",x"0666",x"0777",
    x"0888",x"0999",x"0AAA",x"0BBB",x"0CCC",x"0DDD",x"0EEE",x"1000"
  );
  constant PARA_DF  : vector_mul := (
    x"0000",x"0331",x"0404",x"050F",x"065E",x"0804",x"0A18",x"0CB5",
    x"1000",x"1424",x"195B",x"1FEC",x"2830",x"3298",x"3FB2",x"5030"
  );
  -- components
  -- ila
  COMPONENT ila_equalizer is
   PORT (
     clk : IN STD_LOGIC;
     probe0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
     probe1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
     probe2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
     probe3 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
     probe4 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
     probe5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
   );
  END COMPONENT ila_equalizer;
  component eq_lp is
    port (
      clk    : in  std_logic;
      rstn   : in  std_logic;
      fclk   : in  std_logic; --  frame clock 48000Hz
      y      : out  std_logic_vector(15 downto 0);
      x      : in std_logic_vector(15 downto 0)
    );
  end component eq_lp;
  component eq_hp is
    port (
      -- clk    : in  std_logic;
      rstn   : in  std_logic;
      fclk   : in  std_logic; --  frame clock 48000Hz
      y      : out  std_logic_vector(15 downto 0);
      x      : in std_logic_vector(15 downto 0)
    );
  end component eq_hp;
  component eq_bp is
    port (
  --    clk    : in  std_logic; -- use fclk instead
      rstn   : in  std_logic;
      fclk   : in  std_logic; --  frame clock 48000Hz
      y      : out  std_logic_vector(15 downto 0);
      x      : in std_logic_vector(15 downto 0)
    );
  end component eq_bp;

  signal ctrl_vol : integer range 0 to 15;
  signal ctrl_lp  : integer range 0 to 15;
  signal ctrl_bp  : integer range 0 to 15;
  signal ctrl_hp  : integer range 0 to 15;

  signal vol_mul : signed(19 downto -12);
  signal lpf_mul : signed(23 downto -24);
  signal bpf_mul : signed(23 downto -24);
  signal hpf_mul : signed(23 downto -24);

  signal lpf_in : std_logic_vector(15 downto 0);
  signal bpf_in : std_logic_vector(15 downto 0);
  signal hpf_in : std_logic_vector(15 downto 0);

  signal lpf_out : std_logic_vector(15 downto 0);
  signal bpf_out : std_logic_vector(15 downto 0);
  signal hpf_out : std_logic_vector(15 downto 0);
  signal y_sum   : signed(15 downto 0);
  signal y_temp  : std_logic_vector(15 downto 0);
  signal y_mul   : std_logic_vector(15 downto 0);
  signal y_out   : std_logic_vector(15 downto 0);
  
  
  -- clocking 
  signal fclk : std_logic;
  signal cnt  : integer range 0 to 3000;
  signal locked : std_logic;
  component clk_eq is
    port (
      clk_in1  : in  std_logic;
      resetn   : in  std_logic;
      locked   : out std_logic;
      clk_out1 : out std_logic
    );
  end component clk_eq;
begin
  
  fclk_proc:
  process (rstn,clk)
  begin
    if rstn = '0' then
        fclk <= '0';
        cnt  <= 0;
    elsif rising_edge(clk) then
        if cnt = 2083 then
          cnt <= 1;
        else
          cnt <= cnt + 1;
        end if;
        if cnt = 1 then
          fclk <= '1' ;
        elsif cnt = 1041 then
          fclk <= '0';
        end if;
    end if;
  end process fclk_proc;
  
  
  
  inst_eq_lp:
  component eq_lp
  port map (
  clk => clk,
    rstn => rstn,
    fclk => fclk,
    x    => lpf_in,
    y    => lpf_out
  );
  inst_eq_bp:
  component eq_bp
  port map (
    rstn => rstn,
    fclk => fclk,
    x    => bpf_in,
    y    => bpf_out 
  );
  inst_eq_hp:
  component eq_hp
  port map (
    rstn => rstn,
    fclk => fclk,
    x    => hpf_in,
    y    => hpf_out
  );

  ctrl_vol <= TO_INTEGER(unsigned(ctrl(15 downto 12)));
  ctrl_lp  <= TO_INTEGER(unsigned(ctrl(11 downto 8)));
  ctrl_bp  <= TO_INTEGER(unsigned(ctrl(7 downto 4)));
  ctrl_hp  <= TO_INTEGER(unsigned(ctrl(3 downto 0)));

  vol_mul <= signed(x) * PARA_VOL(ctrl_vol);
  lpf_mul <= vol_mul * PARA_DF(ctrl_lp);
  bpf_mul <= vol_mul * PARA_DF(ctrl_bp);
  hpf_mul <= vol_mul * PARA_DF(ctrl_hp);

  lpf_in <= std_logic_vector(lpf_mul(15 downto 0));
  bpf_in <= std_logic_vector(bpf_mul(15 downto 0));
  hpf_in <= std_logic_vector(hpf_mul(15 downto 0));

  process (rstn, fclk)
  begin
    if rstn = '0' then
      y_out  <= x"0000";
    elsif rising_edge(fclk) then
      y_out  <= not y_mul(15) & y_mul(14 downto 0);
    end if;
  end process;

  y_sum <= signed(lpf_out) + signed(bpf_out) + signed(hpf_out);
  y_temp <= std_logic_vector(y_sum);
  y_mul  <= y_temp;
  
  y <= y_out;
  
  --ila
  inst_ila_equalizer:
  component ila_equalizer
  PORT MAP (
  clk       => clk,
  probe0    => x, 
  probe1    => lpf_in, 
  probe2    => bpf_in,
  probe3    => hpf_in,
  probe4    => y_out,
  probe5(0)  => fclk
 );

end architecture arch_equalizer;

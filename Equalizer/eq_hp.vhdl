-- EQUALIZER: high-pass filter component
-- EQUALIZER: high-pass filter component for frequencies above 4kHz

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity eq_hp is
  port (
    clk    : in  std_logic;
    rstn   : in  std_logic;
    fclk   : in  std_logic; --  frame clock 48000Hz
    y      : out std_logic_vector(15 downto 0);
    x      : in  std_logic_vector(15 downto 0)
  );
end entity eq_hp;

architecture arch_eq_hp of eq_hp is
  type para_array_type is array(0 TO 4) OF std_logic_vector(27 downto 0);
  -- B0-B1-B2-A1-A2
  constant PART1 : para_array_type := ( x"0100000", -- 1
                                        x"0100000", -- -1.000000000000691
                                        x"0000000", -- 0
                                        x"FF55B54", -- -0.665203926752363
                                        x"0000000"  -- 0
                                      );
  constant PART2 : para_array_type := ( x"0100000", -- 1
                                        x"FE08CC8", -- -1.965630387715011
                                        x"00FFFFF", -- 0.999999999998860
                                        x"FE9DC30", -- -1.383744183626513
                                        x"0086D01"  -- 0.526612494585635
                                      );
  constant PART3 : para_array_type := ( x"0100000", -- 1
                                        x"FE16B82", -- -1.911253018415766
                                        x"0100000", -- 1.000000000000448
                                        x"FE6C029", -- -1.578086275082525
                                        x"00CA6B5"  -- 0.790700215956199
                                      );
  constant G : std_logic_vector(27 downto 0) :=x"0100000";-- x"0086BB3"; -- 0.526294691561818
  -- component
  component eq_part is
    generic (
      B0 : std_logic_vector(27 downto 0); -- 7:-20
      B1 : std_logic_vector(27 downto 0);
      B2 : std_logic_vector(27 downto 0);
      A1 : std_logic_vector(27 downto 0);
      A2 : std_logic_vector(27 downto 0)
    );
    port (
      clk    : in  std_logic;
      fclk   : in  std_logic; --  frame clock 48000Hz
      rstn   : in  std_logic;
      y      : out std_logic_vector(35 downto 0);
      x      : in  std_logic_vector(35 downto 0)
    );
  end component eq_part;
  
  signal eq_part1_out  : std_logic_vector(35 downto 0);
  signal eq_part2_out  : std_logic_vector(35 downto 0);
  signal eq_part3_out  : std_logic_vector(35 downto 0);

  signal eq_part1_gain : signed(63 downto 0);
  signal eq_part1_in  : std_logic_vector(35 downto 0);
  signal eq_part2_in   : std_logic_vector(35 downto 0);

begin
  eq_part1_in <= (std_logic_vector'(x"00") & x & std_logic_vector'(x"000")) when x(15) = '0' else (std_logic_vector'(x"FF") & x & std_logic_vector'(x"000"));

  inst_eq_part1:
  component eq_part
    generic map (
      B0 => PART1(0),
      B1 => PART1(1),
      B2 => PART1(2),
      A1 => PART1(3),
      A2 => PART1(4)
    )
    port map (
      clk  => clk,
      fclk => fclk,
      rstn => rstn,
      x    => eq_part1_in,
      y    => eq_part1_out
    );

  eq_part1_gain <= signed(eq_part1_out) * signed(G);
  
  gain_proc:
  process (rstn,fclk)
  begin
    if rstn = '0' then
      eq_part2_in <= x"000000000";
    elsif rising_edge(fclk) then
      eq_part2_in <= std_logic_vector(eq_part1_gain(55 downto 20));
    end if;
  end process gain_proc;



  inst_eq_part2:
  component eq_part
    generic map (
      B0 => PART2(0),
      B1 => PART2(1),
      B2 => PART2(2),
      A1 => PART2(3),
      A2 => PART2(4)
    )
    port map (
      clk  => clk,
      fclk => fclk,
      rstn => rstn,
      x    => eq_part2_in,
      y    => eq_part2_out
    );

  inst_eq_part3:
  component eq_part
    generic map (
      B0 => PART3(0),
      B1 => PART3(1),
      B2 => PART3(2),
      A1 => PART3(3),
      A2 => PART3(4)
    )
    port map (
      clk  => clk,
      fclk => fclk,
      rstn => rstn,
      x    => eq_part2_out,
      y    => eq_part3_out
    );

  y <= eq_part3_out(27 downto 12);
  
end architecture arch_eq_hp;

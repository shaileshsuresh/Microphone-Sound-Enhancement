-- EQUALIZER: high-pass filter component

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity newhp_filter is
  port (
    clk    : in  std_logic;
    rstn   : in  std_logic;
    fclk   : in  std_logic; --  frame clock 48000Hz
    y      : out std_logic_vector(15 downto 0);
    x      : in  std_logic_vector(15 downto 0)
  );
end entity newhp_filter;

architecture arch_newhp_filter of newhp_filter is
  type para_array_type is array(0 TO 4) OF std_logic_vector(27 downto 0);
  -- B0-B1-B2-A1-A2
  constant PART1 : para_array_type := ( x"0100000", -- 1
                                        x"FF00038", -- -0.999946810631343
                                        x"0000000", -- 0
                                        x"FF9145F", -- -0.995027187519884
                                        x"0000000"  -- 0
                                      );
  constant PART2 : para_array_type := ( x"0100000", -- 1
                                        x"FDFFFAC", -- -2.000080735080919
                                        x"010005A", -- 1.000086065884170
                                        x"FE02107", -- -1.991936828367649
                                        x"00FDF18"  -- 0.991966884654222
                                      );
  constant PART3 : para_array_type := ( x"0100000", -- 1
                                        x"FE00032", -- -1.999953177722835
                                        x"00FFFDD", -- 0.999967129142807
                                        x"FE00CC3", -- -1.996885171284679
                                        x"00FF366"  -- 0.996923908852947
                                      );
  constant G : std_logic_vector(27 downto 0) :=x"00FDF18";-- x""; -- 0.991966638925721
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
  
end architecture arch_newhp_filter;

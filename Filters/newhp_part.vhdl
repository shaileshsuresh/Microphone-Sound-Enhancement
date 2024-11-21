-- low-pass filter component
--This module calculates the transfer function and filter coefficients of the high pass filter as per the manual derivation and sends the output for the filter

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity hp_part is
  generic (
    FS : std_logic_vector(15 downto 0):=x"BB80"; -- sampling frequency
    COS: std_logic_vector(23 downto 0):=x"FFFBDC" -- cos(ki) [11:-12]
  );
  port (
    clk    : in  std_logic;
    fclk   : in  std_logic; --  frame clock 48000Hz
    rstn   : in  std_logic;
    cordic : in  std_logic_vector(31 downto 0);
    y      : out  std_logic_vector(15 downto 0);
    x      : in std_logic_vector(15 downto 0)
  );
end entity hp_part;

architecture arch_hp_part of hp_part is
  -- for test
  --constant fc : std_logic_vector(15 downto 0) := x"1770";
  --constant x  :  std_logic_vector(15 downto 0):= x"1770";
  -- ila ip
--  COMPONENT ila_hp_part
--    PORT (
--      clk : IN STD_LOGIC;
--      probe0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
--      probe1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
--    );
--  END COMPONENT ila_hp_part;
  
  -- PI
  constant PI    : signed(2 downto -13) := x"647A";
  constant ZERO  : signed(11 downto -12) := x"000000";
  constant ONE   : signed(11 downto -12) := x"001000";
  constant ONE_N : signed(11 downto -12) := x"FFF000";
  constant TWO   : signed(11 downto -12) := x"002000";
  
  -- cotangent
  signal cotangent    : signed(15 downto -12);
  signal cotangent_sq : signed(31 downto -24);
  signal cotangent_2sq: signed(21 downto -2);
  signal cotangent_c  : signed(27 downto -24);
  signal cotangent_2c  : signed(21 downto -2);
  --parameters
  signal b0   : signed(21 downto -2);
  signal b1   : signed(21 downto -2);
  signal b2   : signed(21 downto -2);
  signal a0   : signed(21 downto -2);
  signal a1   : signed(21 downto -2);
  signal a2   : signed(21 downto -2);
  -- parameters
  signal p0 : signed(23 downto -12);
  signal p1 : signed(23 downto -12);
  signal p2 : signed(23 downto -12);
  signal p3 : signed(23 downto -12); --no negative sign
  signal p4 : signed(23 downto -12); --no negative sign
  -- parameters
  signal t0 : signed(27 downto -12);
  signal t1 : signed(27 downto -12);
  signal t2 : signed(27 downto -12);
  signal t3 : signed(27 downto -12); --no negative sign
  signal t4 : signed(27 downto -12); --no negative sign
  -- x and y
  signal x_n0 : signed(15 downto 0);
  signal x_n1 : signed(15 downto 0);
  signal x_n2 : signed(15 downto 0);
  signal y_n0 : signed(15 downto 0);
  signal y_n1 : signed(15 downto 0);
  signal y_n2 : signed(15 downto 0);

  signal y_n0_temp : signed(27 downto -12);
begin
  -- for test
  
  -- ila ip
--  inst_ila_hp_part:
--  ila_hp_part
--  port map (
--	clk => clk,
--	probe0 => std_logic_vector(cordic_input),
--	probe1 => "00000000"&std_logic_vector(p3(11 downto -12))
--  );
  
  --------- parameter update
  -- calculate cotangent
  cotangent    <= signed(cordic(15 downto 0)&x"000") / signed(x"000"&cordic(31 downto 16));
  cotangent_sq <= cotangent * cotangent;
  cotangent_2sq<= cotangent_sq(20 downto -3);
  cotangent_c  <= cotangent*signed(COS);
  cotangent_2c <= cotangent_c(20 downto -3);
  -- calculate b
  b0 <= cotangent_sq(21 downto -2);
  b1 <= ZERO - cotangent_2sq;
  b2 <= cotangent_sq(21 downto -2);
  -- calculate a
  a0 <= signed'(x"000004") + cotangent_sq(21 downto -2) - cotangent_2c;
  a1 <= signed'(x"000008") - cotangent_2sq;
  a2 <= signed'(x"000004") + cotangent_sq(21 downto -2) + cotangent_2c;
  
  -- calculate p
  p0 <= (b0 & x"000") / ( x"000" & a0);
  p1 <= (b1 & x"000") / (x"000" & a0);
  p2 <= (b2 & x"000") / (x"000" & a0);
  p3 <= (a1 & x"000") / ( x"000" & a0);
  p4 <= (a2 & x"000") / ( x"000" & a0);
  -- calculate terms
  t0 <= p0(11 downto -12) * x_n0;
  t1 <= p1(11 downto -12) * x_n1;
  t2 <= p2(11 downto -12) * x_n2;
  t3 <= p3(11 downto -12) * y_n1;
  t4 <= p4(11 downto -12) * y_n2;
  process (fclk, rstn)
  begin
    if rstn = '0' then
      x_n1 <= x"0000";
      x_n2 <= x"0000";
      y_n1 <= x"0000";
      y_n2 <= x"0000";
    elsif rising_edge(fclk) then
      x_n1 <= x_n0;
      x_n2 <= x_n1;
      y_n1 <= y_n0;
      y_n2 <= y_n1;
    end if;
  end process;
--  x_n0 <= signed(x"0000") when rstn = '0' else signed(x);
  x_n0 <= signed(x);
  y_n0_temp <= t0+t1+t2-t3-t4;
  y_n0 <= y_n0_temp(15 downto 0);
  y    <= std_logic_vector(y_n0);
  
end architecture arch_hp_part;



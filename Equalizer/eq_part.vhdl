--Calculates the filter coefficients for the filter component in equalizer 

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity eq_part is
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
end entity eq_part;

architecture arch_eq_part of eq_part is

  

  -- parameters
  signal t0 : signed(63 downto 0);
  signal t1 : signed(63 downto 0);
  signal t2 : signed(63 downto 0);
  signal t3 : signed(63 downto 0);
  signal t4 : signed(63 downto 0);
  -- x and y
  signal x_n0 : signed(35 downto 0);
  signal x_n1 : signed(35 downto 0);
  signal x_n2 : signed(35 downto 0);
  signal y_n0 : signed(35 downto 0);
  signal y_n1 : signed(35 downto 0);
  signal y_n2 : signed(35 downto 0);
  
  signal y_n0_temp : signed(63 downto 0);
begin
  -- calculate terms
  t0 <= signed(B0) * x_n0;
  t1 <= signed(B1) * x_n1;
  t2 <= signed(B2) * x_n2;
  t3 <= signed(A1) * y_n1;
  t4 <= signed(A2) * y_n2;

  process(fclk,rstn)
  begin
    if rstn = '0' then
      x_n1 <= x"000000000";
      x_n2 <= x"000000000";
      y_n1 <= x"000000000";
      y_n2 <= x"000000000";
    elsif rising_edge(fclk) then
      x_n1 <= x_n0;
      x_n2 <= x_n1;
      y_n1 <= y_n0;
      y_n2 <= y_n1;
    end if;
  end process;

  x_n0 <= signed(x);
  y_n0_temp <= t0+t1+t2-t3-t4;
  y_n0 <= y_n0_temp(55 downto 20);
  y    <= std_logic_vector(y_n0);
  
end architecture arch_eq_part;



--lp_filter2(backup)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity lp_filter is
  generic (
    N   : integer   := 4;                           -- filter order
    FS  : std_logic_vector(15 downto 0) := x"BB80"; -- sampling frequency
    DFC : std_logic_vector(15 downto 0) := x"0FA0"  -- default cut-off frequency
  );
  port (
    clk        : in std_logic;
    fclk       : in std_logic;
    rstn       : in std_logic;
    -- from filter controller
    fcon_en_i  : in std_logic;
    fcon_cmd_i : in std_logic_vector(15 downto 0);
    -- data
    in_sig     : in  std_logic_vector(15 downto 0);
    out_sig    : out std_logic_vector(15 downto 0)
  );
end entity lp_filter;

architecture arch_lp_filter of lp_filter is
  constant PI : signed(2 downto -13) := x"647A";
  -- temp
  signal fc : std_logic_vector(15 downto 0);
  -- component
  component lp_part is
    generic (
      FS : std_logic_vector(15 downto 0):=x"BB80"; -- sampling frequency
      COS: std_logic_vector(23 downto 0):=x"FFFBDC" -- cos(ki) [11:-12]
    );
    port (
      clk    : in  std_logic;
      fclk   : in  std_logic; --  frame clock 48000Hz
      rstn   : in  std_logic;
      cordic : in  std_logic_vector(31 downto 0);
      y      : out std_logic_vector(15 downto 0);
      x      : in  std_logic_vector(15 downto 0)
    );
  end component lp_part;
  -- cordic ip
  COMPONENT cordic_sin
    PORT (
      aclk                : IN STD_LOGIC;
      s_axis_phase_tvalid : IN STD_LOGIC;
      s_axis_phase_tdata  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      m_axis_dout_tvalid  : OUT STD_LOGIC;
      m_axis_dout_tdata   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
    );
  END COMPONENT;
  -- cordic
  signal cordic_cal_1 : signed(15 downto -16);
  signal cordic_cal_2 : signed(5 downto -26);
  signal cordic_input : signed(2 downto -13);--
  signal cordic_output: STD_LOGIC_VECTOR(31 downto 0);

  type cos_array_type is array(1 TO N/2) OF std_logic_vector(23 downto 0);
  type data_array_type is array(1 TO N/2) OF std_logic_vector(15 downto 0);
  constant COS : cos_array_type := (x"FFF9e1",
                                    x"FFF138");
  signal y_signal : data_array_type;
  
begin
  -- temp
  -- calculate pi*fc/fs -> cordic_input
  cordic_cal_1 <= signed(std_logic_vector'(fc & x"0000")) / signed(std_logic_vector'(x"0000" & FS)); 
  cordic_cal_2 <= cordic_cal_1(2 downto -13) * PI;
  cordic_input <= cordic_cal_2(2 downto -13);
  -- main
  out_sig <= y_signal(2);
  
  inst_lp_part_1:
    lp_part 
    generic map (
      FS => FS,
      COS => COS(1)
    )
    port map (
      clk    => clk,
      fclk   => fclk,
      rstn   => rstn,
      cordic => cordic_output,
      y      => y_signal(1),
      x      => in_sig
    );
  --gene_lpf:
  --for i in 2 to N/2 generate
    inst_lp_part_i:
    lp_part 
    generic map (
      FS => FS,
      COS => COS(2)
    )
    port map (
      clk    => clk,
      fclk   => fclk,
      rstn   => rstn,
      cordic => cordic_output,
      y      => y_signal(2),
      x      => y_signal(1)
    );
  --end generate gene_lpf;
  -- cordic ip
  inst_cordic_sin:
  cordic_sin
  port map (
    aclk                => fclk,
    s_axis_phase_tvalid => '0',
    s_axis_phase_tdata  => std_logic_vector(cordic_input),
    m_axis_dout_tdata   => cordic_output
  );
  
  fc_update_proc:
  process (clk,rstn)
  begin
    if rstn = '0' then
      fc <= DFC;
    elsif rising_edge(clk) then
      if fcon_en_i = '1' then
        fc <= fcon_cmd_i;
      else
        fc <= fc;
      end if;
    end if;
  end process fc_update_proc;
  

end arch_lp_filter;

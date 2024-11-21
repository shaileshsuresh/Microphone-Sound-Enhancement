-- Controls the state transition that governs the rolling average module
-- Performs calculation of the total sum in the buffer.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mainShiftReg_16bit is
    Port (clk : in std_logic;
          resetn : in std_logic;
          rec_flag : in std_logic;
          input : in std_logic_vector(15 DOWNTO 0);
          output : out std_logic_vector(31 DOWNTO 0)
           );
end mainShiftReg_16bit;

architecture Behavioral of mainShiftReg_16bit is

    CONSTANT VEC_SIZE : INTEGER := 16;
    CONSTANT REG_SIZE : INTEGER := 1024;		--1024
    
    type reg_arr is array (0 TO REG_SIZE) of std_logic_vector(VEC_SIZE-1 downto 0);
    type state_type is (idle_state,
    setup_state,
    setup_shift_state,
    first_sum_state,
    second_sum_state,
    send_state
	);
    type holder_type is array (0 to 3) of std_logic_vector(31 DOWNTO 0);
    
    signal reg_array : reg_arr;
    signal current_state : state_type;
    signal next_state : state_type;
    signal holder : holder_type;
    signal neg_1024_reg: std_logic_vector(31 DOWNTO 0);
    signal counter : INTEGER := 0;
    signal load_flag : std_logic;
    signal our_flag : std_logic;
    signal setup_addition : std_logic;
    signal first_sum : std_logic;
    signal second_sum : std_logic;
    signal reg_array1024 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal first_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal temp_holder : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal load_setup : STD_LOGIC;
	signal holder0 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal holder1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal temp_sum : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal step_from_setup : std_logic;
    
    signal abs_input :std_logic_vector (15 DOWNTO 0);
    signal abs_input2 :std_logic_vector (15 DOWNTO 0);

    component complement_32bit is
	port(input : in STD_LOGIC_VECTOR(31 DOWNTO 0);
	     output : out STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
    end component;
    
    component registerShifter_16bit is
        port(clk : in STD_LOGIC;
          resetn : in STD_LOGIC;
          load_flag : in STD_LOGIC;
          input : in STD_LOGIC_VECTOR(15 DOWNTO 0);
          output : out STD_LOGIC_VECTOR(15 DOWNTO 0)
           );
    end component;
    
    component adder_32bit is
    port ( input1 : in STD_LOGIC_VECTOR (31 downto 0);
           input2 : in STD_LOGIC_VECTOR (31 downto 0);
           execute : in STD_LOGIC;
           sum : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    component register32bit is
	port(clk : in STD_LOGIC;
		resetn : in STD_LOGIC;
		load : in STD_LOGIC;
		input : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		output : out STD_LOGIC_VECTOR(31 DOWNTO 0));
	end component;

   component incrementer_32bit is
	port(clk : in STD_LOGIC;
	resetn : in STD_LOGIC; 
	input1 : in STD_LOGIC_VECTOR (31 downto 0);
           execute : in STD_LOGIC;
           sum : out STD_LOGIC_VECTOR (31 downto 0));
end component;
	
	

begin
    process (input,abs_input2)
	begin
		if input(15) = '0' then
			abs_input <= input;

		elsif input(15) = '1' then 
           abs_input <= (not abs_input2(15))&(not abs_input2(14))&(not abs_input2(13))&(not abs_input2(12))&(not abs_input2(11))&(not abs_input2(10))&(not abs_input2(9))&(not abs_input2(8))&(not abs_input2(7))&(not abs_input2(6))&(not abs_input2(5))&(not abs_input2(4))&(not abs_input2(3))&(not abs_input2(2))&(not abs_input2(1))&(not abs_input2(0));
		
		end if;
    end process;
    abs_input2 <= std_logic_vector(signed(input) - x"0001");
	--holder(0) <= (31 DOWNTO 16 => '0') & reg_array(REG_SIZE);
    --load_flag <= rec_flag;
    holder0(31 downto 16) <= (others => '0');
    holder0(15 downto 0) <= reg_array(0);

    register0 : registerShifter_16bit 
    port map(clk => clk, 
    resetn => resetn,
    load_flag => rec_flag,              --Switch registers when we receive information
    input => std_logic_vector(abs_input),
    output => reg_array(0));  
    
    
    gen: for i in 1 to REG_SIZE generate  -- Actually 0 - 1024, 1024 used for subtration
        inst: registerShifter_16bit 
        port map(clk => clk,
        resetn => resetn,
        load_flag => rec_flag,
        input => reg_array(i-1),
        output => reg_array(i)
        );
        end generate;
      
  
   -- When init state, do nothing. For 1024 clock pulses.
   -- When loading state, add 32bitvector <= reg_array(1023) + 32bitvector;
   -- When regular state, add 32bitvector <= 32bitvector + reg_array(0) - reg_array(1023); 
   
   incrementer : incrementer_32bit
    port map(clk => clk,
	resetn => resetn,
	input1 => holder0,
	execute => setup_addition,
	sum => holder1 
	);

	
  
   
   complement_inst : complement_32bit
   port map(input => reg_array1024,
   output => neg_1024_reg
   );
   
   adder_first_sum : adder_32bit          -- Add register 0 and 1023
   port map(input1 => first_reg,
   input2 => neg_1024_reg,
   execute => first_sum,
   sum => holder(2)
   );
   
   adder_second_sum : adder_32bit          -- Add rolling average with the sum of adder_complement.
   port map(input1 => holder(1),
   input2 => holder(2),
   execute => second_sum,
   sum => holder(3)
   );


   
   
   state_proc: process(clk, resetn, next_state)
   begin
    if rising_edge(clk) then
        
        if resetn = '0' then
            current_state <= idle_state;
        else
           current_state <= next_state;    
        end if;
   end if;
   end process;
   
   state_flow_proc: process(resetn, rec_flag, current_state, counter)
   begin 
   
    --next_state <= current_state;
        if resetn = '0' then
            next_state <= idle_state;
            
        else 
            case current_state is
                when idle_state =>
                    if rec_flag = '1' then
                        if counter < REG_SIZE then
                        
                            next_state <= setup_state;
				
                        else
                            next_state <= first_sum_state;
                        end if;
                    else  
                        next_state <= idle_state;
                    end if;
                  
                when setup_state =>
                    next_state <= setup_shift_state; 
                when setup_shift_state =>
                    next_state <= idle_state;
                when first_sum_state => 
                    next_state <= second_sum_state;
                when second_sum_state => 
                    next_state <= send_state;
                when send_state => 
                    next_state <= idle_state; 
          end case;
      end if;
   end process;
   
   
   main_proc : process(resetn, current_state, step_from_setup)
   begin
  	if resetn = '0' then
	counter <= 0;
	holder(0) <= x"00000000";
	holder(1) <= x"00000000";
	--holder(2) <= x"00000000";
	--holder(3) <= x"00000000";
	step_from_setup <= '0';
	else
        case current_state is
            when idle_state =>
                setup_addition <= '0';
                first_sum <= '0';
                second_sum <= '0';
               	load_setup <= '0';
		if step_from_setup = '0' then
			temp_sum <= holder1;
		elsif step_from_setup = '1' then
			temp_sum <= holder(3);
		end if;
            when setup_state => 
            
		          counter <= counter + 1;
                    setup_addition <= '1';
		          load_setup <= '1';
            	--temp_sum <= holder1;
            when setup_shift_state =>
                setup_addition <= '1';
		          load_setup <= '0';
                
            when first_sum_state =>        --Make this firstsumstate
		
			step_from_setup <= '1';
		
		reg_array1024(31 DOWNTO 16) <= (OTHERS => '0');
		reg_array1024(15 DOWNTO 0) <= reg_array(REG_SIZE-1);
		first_reg(31 DOWNTO 16) <= (OTHERS => '0');
		first_reg(15 DOWNTO 0) <= reg_array(0);
		holder(1) <= temp_sum;
		--reg_array1024 <= x"0000" & reg_array(REG_SIZE);
		--first_reg <= x"0000" & reg_array(0);
		--neg_1024_reg <= not(reg_array1024) + '1';
                first_sum <= '1';
            when second_sum_state =>
                first_sum <= '1';                
                second_sum <= '1';
  
            when send_state =>
                second_sum <= '1';
		--temp_sum <= holder(3);
                output <= holder(3);
		

         end case;       
	end if;
   
    end process;
end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ALU_components_pack.all;

entity ALU_top is
   port ( clk        : in  std_logic;
          reset_n    : in  std_logic;
          b_Enter    : in  std_logic;
          input      : in  std_logic_vector(7 downto 0);
          output     : out std_logic_vector(9 downto 0)
        );
end ALU_top;

architecture structural of ALU_top is
   -- component definitions
   component ALU_ctrl
      port ( clk     : in  std_logic;
          reset   : in  std_logic;
          enter   : in  std_logic;
          sign    : in  std_logic;
          FN      : out std_logic_vector (3 downto 0);   -- ALU functions
          RegCtrl : out std_logic_vector (1 downto 0)   -- Register update control bits
        );
    end component;
    
    component ALU
       port ( A          : in  std_logic_vector (7 downto 0);   -- Input A
           B          : in  std_logic_vector (7 downto 0);   -- Input B
           FN         : in  std_logic_vector (3 downto 0);   -- ALU functions provided by the ALU_Controller (see the lab manual)
           result      : out std_logic_vector (7 downto 0);   -- ALU output (unsigned binary)
           overflow   : out std_logic;                       -- '1' if overflow ocurres, '0' otherwise 
           sign       : out std_logic                        -- '1' if the result is a negative value, '0' otherwise
         );
    end component;
    
    component regUpdate
       port ( clk        : in  std_logic;
           reset      : in  std_logic;
           RegCtrl    : in  std_logic_vector (1 downto 0);   -- Register update control from ALU controller
           input      : in  std_logic_vector (7 downto 0);   -- Switch inputs
           A          : out std_logic_vector (7 downto 0);   -- Input A
           B          : out std_logic_vector (7 downto 0)   -- Input B
         );
    end component;
    
    component binary2BCD   
      generic ( WIDTH : integer := 8   -- 8 bit binary to BCD
            );
      port ( clk, reset : in std_logic;
           binary_in : in  std_logic_vector(WIDTH-1 downto 0);  -- binary input width
           BCD_out   : out std_logic_vector(9 downto 0)        -- BCD output, 10 bits [2|4|4] to display a 3 digit BCD value when input has length 8
         );
    end component;
    
    component seven_seg_driver 
       port ( clk           : in  std_logic;
              reset         : in  std_logic;
              BCD_digit     : in  std_logic_vector(9 downto 0);          
              sign          : in  std_logic;
              overflow      : in  std_logic;
              DIGIT_ANODE   : out std_logic_vector(3 downto 0);
              SEGMENT       : out std_logic_vector(6 downto 0)
            );
    end component;
    
    -- SIGNAL DEFINITIONS
    signal enter_edge, enter_debounced, enter_sync : std_logic;
    signal sign_edge, sign_debounced, sign_sync : std_logic;
    
    signal FN: std_logic_vector(3 downto 0);
    signal RegCtrl: std_logic_vector(1 downto 0);
    signal regA, regB: std_logic_vector(7 downto 0);
    signal result, result_2scomp : std_logic_vector(7 downto 0);
    signal overflow, sign : std_logic;
    signal bcd_number: std_logic_vector(9 downto 0);
    signal reset: std_logic;
begin

    reset <= not reset_n;

    -- Find the positive edge of the button signals, output a signal for one clock cycle
    edge1: rising_edge_detector
    port map (clk        => clk,
              rst        => reset,
              signal_in  => enter_sync,
              edge_found => enter_edge
             );

    -- BUTTON SIGNAL PROCESSING DONE
    
    alu_fsm: ALU_ctrl
    port map (clk     => clk,
              reset   => reset,
              enter   => enter_edge,
              sign    => sign_edge,
              FN      => FN, -- ALU functions
              RegCtrl => RegCtrl   -- Register update control bits
             );
     
    regAB_control: regUpdate
    port map ( clk     => clk,
               reset   => reset,
               RegCtrl => RegCtrl,   -- Register update control from ALU controller
               input   => input,   -- Switch inputs
               A       => regA,   -- Input A
               B       => regB   -- Input B
             );
             
    ALU_instance: ALU
    port map ( A => regA,   -- Input A
               B => regB,   -- Input B
               FN  => FN,   -- ALU functions provided by the ALU_Controller (see the lab manual)
               result => result, -- ALU output (unsigned binary)
               overflow => overflow,                     -- '1' if overflow ocurres, '0' otherwise 
               sign => sign                       -- '1' if the result is a negative value, '0' otherwise
    );

    result_2scomp <= std_logic_vector(unsigned(not(result)) + 1) when sign = '1' else result;
    
    bcd_converter: binary2BCD   
    port map ( clk => clk, 
               reset => reset,
               binary_in => result_2scomp,  -- binary input width
               BCD_out   => bcd_number       -- BCD output, 10 bits [2|4|4] to display a 3 digit BCD value when input has length 8
    );
    
    seven_seg_driver_inst: seven_seg_driver 
    port map ( clk => clk,
               reset => reset,
               BCD_digit => bcd_number,         
               sign => sign,
               overflow => overflow,
               DIGIT_ANODE => anode,
               SEGMENT => seven_seg
    );

end structural;

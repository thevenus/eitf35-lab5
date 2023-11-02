library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity ALU is
   port ( A          : in  std_logic_vector (7 downto 0);   -- Input A
          B          : in  std_logic_vector (7 downto 0);   -- Input B
          FN         : in  std_logic_vector (3 downto 0);   -- ALU functions provided by the ALU_Controller (see the lab manual)
          result 	 : out std_logic_vector (7 downto 0);   -- ALU output (unsigned binary)
	      overflow   : out std_logic;                       -- '1' if overflow ocurres, '0' otherwise 
	      sign       : out std_logic                        -- '1' if the result is a negative value, '0' otherwise
        );
end ALU;

architecture behavioral of ALU is
    signal result_ext: std_logic_vector(8 downto 0);
    signal mod3_result: std_logic_vector(1 downto 0);
    signal mult_result : std_logic_vector(15 downto 0);
--    signal mult_of_detection : std_logic_vector(7 downto 0) := "11111111";
--    signal mod3_num: std_logic_vector(7 downto 0);
    signal mod3_sign: std_logic;
    
    component mod3
    port(
        num_in : in STD_LOGIC_VECTOR (7 downto 0);
        sign_in : in STD_LOGIC;
        num_mod3_out : out STD_LOGIC_VECTOR (1 downto 0)
    );
    end component;

begin

   mux: process ( FN, A, B, mod3_result, mult_result)
   begin
--        mult_result <= (others => '0');
        
        case FN is
            when "0010" => -- Unsigned addition
                result_ext <= std_logic_vector(unsigned(('0' & A)) + unsigned(('0' & B)));
            when "0011" => -- Unsigned Subtraction
                result_ext <= std_logic_vector(unsigned(('0' & A)) - unsigned(('0' & B)));
            when "0100" => -- Unsigned mod3
                result_ext <= "0000000" & mod3_result;
            when "0101" => -- Unsigned multiply
                if (unsigned(mult_result) > 255) then
                    result_ext <= '1' & mult_result(7 downto 0);
                else 
                    result_ext <= '0' & mult_result(7 downto 0);
                end if;
            when others =>
                result_ext <= (others => '0');
        end case;
   end process;   

    -- MOD3 calculations
    mod3_calculator : mod3
    port map(
       num_in => A,
       sign_in => mod3_sign,
       num_mod3_out => mod3_result 
    );
    mod3_sign <= A(7) when FN = "1100" else '0';
    
    mult_result <= std_logic_vector(unsigned((A)) * unsigned((B)));

    -- Overflow and sign detection
    overflow <= result_ext(8) when (FN = "0010" or FN = "0101") else '0'; -- unsigned addition and multiplication; 
    
    sign <= result_ext(8) when FN = "0011" else '0'; -- unsigned subtraction

    result <= std_logic_vector(unsigned(not(result_ext(7 downto 0))) + 1) when FN="0011" and result_ext(8) = '1' else
              mult_result(7 downto 0) when FN = "0101" else
              result_ext(7 downto 0); 

end behavioral;

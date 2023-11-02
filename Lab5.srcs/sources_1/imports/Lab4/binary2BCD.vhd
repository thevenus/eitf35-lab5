library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ALU_components_pack.all;

entity binary2BCD is
   generic ( WIDTH : integer := 8   -- 8 bit binary to BCD
           );
   port ( clk, reset : in std_logic;
          binary_in : in  std_logic_vector(WIDTH-1 downto 0);  -- binary input width
          BCD_out   : out std_logic_vector(9 downto 0)        -- BCD output, 10 bits [2|4|4] to display a 3 digit BCD value when input has length 8
        );
end binary2BCD;

architecture structural of binary2BCD is 
    signal shift_reg, shift_next, shift_inc : std_logic_vector(10+WIDTH-1 downto 0);
    
    signal cnt_reg : std_logic_vector(3 downto 0);
    signal cnt_next : std_logic_vector(3 downto 0);
    
    signal BCD_out_reg : std_logic_vector(9 downto 0);
    signal BCD_out_next : std_logic_vector(9 downto 0);

begin
    shift_reg_dff : dff
    generic map (W => 10+WIDTH)
    port map(
        clk => clk,
        reset => reset, 
        d => shift_next,
        q => shift_reg   
    );
    
    cnt_reg_dff : dff
    generic map (W => 4)
    port map (
        clk => clk,
        reset => reset,
        d => cnt_next,
        q => cnt_reg
    );
    
    BCD_out_reg_dff : dff
    generic map (W => 10)
    port map (
        clk => clk, 
        reset => reset,
        d => BCD_out_next,
        q => BCD_out_reg
    );
    
    cnt_next <= std_logic_vector(unsigned(cnt_reg) + 1) when unsigned(cnt_reg) < 8 else "0000";
    BCD_out_next <= shift_reg(WIDTH+10-1 downto 8) when cnt_reg = "0000" else BCD_out_reg;
    
    combinational_shifter : process (shift_reg, cnt_reg)
    begin
        if (unsigned(shift_reg(15 downto 12)) >= 5) then
            if (unsigned(shift_reg(11 downto 8)) >= 5) then
                shift_inc <= std_logic_vector(unsigned(shift_reg(17 downto 8)) + 48 + 3) & shift_reg(7 downto 0);
            else
                shift_inc <= std_logic_vector(unsigned(shift_reg(17 downto 8)) + 48) & shift_reg(7 downto 0);
            end if;
        else
            if (unsigned(shift_reg(11 downto 8)) >= 5) then
                shift_inc <= std_logic_vector(unsigned(shift_reg(17 downto 8)) + 3) & shift_reg(7 downto 0);
            else
                shift_inc <= shift_reg;
            end if;
        end if; 
    end process;
    
    shift_next <= shift_inc(16 downto 0) & '0' when cnt_reg /= "0000" else "0000000000" & binary_in;
    
    BCD_out <= BCD_out_reg;
        
end structural;

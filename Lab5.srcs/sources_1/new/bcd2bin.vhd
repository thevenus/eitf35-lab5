library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ALU_components_pack.all;

entity bcd2bin is
   port ( clk, reset : in std_logic;
          BCD_in : in  std_logic_vector(11 downto 0);  
          bin_out   : out std_logic_vector(7 downto 0)
        );
end bcd2bin;

architecture structural of bcd2bin is 
    signal shift_reg, shift_next, shift_inc : std_logic_vector(21 downto 0);
    
    signal cnt_reg : std_logic_vector(3 downto 0);
    signal cnt_next : std_logic_vector(3 downto 0);
    
    signal bin_out_reg, bin_out_next : std_logic_vector (7 downto 0);
    
    signal BCD : std_logic_vector(11 downto 0);

begin
    shift_reg_dff : dff
    generic map (W => 22)
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
    
    bin_out_reg_inst : dff 
    generic map (W => 8)
    port map (
        clk => clk,
        reset => reset,
        d => bin_out_next,
        q => bin_out_reg
    );
    
    cnt_next <= std_logic_vector(unsigned(cnt_reg) + 1) when unsigned(cnt_reg) < 10 else "0000";
    bin_out_next <= shift_reg(7 downto 0) when cnt_reg = "0000" and unsigned(shift_reg(9 downto 0)) <= 255 else 
                    "11111111" when cnt_reg = "0000" and unsigned(shift_reg(9 downto 0)) > 255 else
                    bin_out_reg;
    
    combinational_shifter : process (shift_reg, cnt_reg)
    begin
        if (unsigned(shift_reg(21 downto 18)) >= 8) then
            if (unsigned(shift_reg(17 downto 14)) >= 8) then
                if (unsigned(shift_reg(13 downto 10)) >= 8) then
                    shift_inc <= std_logic_vector(unsigned(shift_reg(21 downto 10)) - 768 - 48 - 3) & shift_reg(9 downto 0);
                else
                    shift_inc <= std_logic_vector(unsigned(shift_reg(21 downto 10)) - 768 - 48) & shift_reg(9 downto 0);
                end if;
            else
                if (unsigned(shift_reg(13 downto 10)) >= 8) then
                    shift_inc <= std_logic_vector(unsigned(shift_reg(21 downto 10)) - 768 - 3) & shift_reg(9 downto 0);
                else
                    shift_inc <= std_logic_vector(unsigned(shift_reg(21 downto 10)) - 768) & shift_reg(9 downto 0);
                end if;
            end if;
        else
            if (unsigned(shift_reg(17 downto 14)) >= 8) then
                if (unsigned(shift_reg(13 downto 10)) >= 8) then
                    shift_inc <= std_logic_vector(unsigned(shift_reg(21 downto 10)) - 48 - 3) & shift_reg(9 downto 0);
                else
                    shift_inc <= std_logic_vector(unsigned(shift_reg(21 downto 10)) - 48) & shift_reg(9 downto 0);
                end if;
            else
                if (unsigned(shift_reg(13 downto 10)) >= 8) then
                    shift_inc <= std_logic_vector(unsigned(shift_reg(21 downto 10)) - 3) & shift_reg(9 downto 0);
                else
                    shift_inc <= shift_reg;
                end if;
            end if;
        end if;
    end process;
    
    -- convert BCD digit if it is operator
    process (BCD_in)
    begin
        case BCD_in(3 downto 0) is 
            when "1010" =>
                BCD <= "000100110000"; -- 130
            when "1011" =>
                BCD <= "000100110001"; -- 131
            when "1100" =>
                BCD <= "000100110010"; -- 132
            when "1101" =>
                BCD <= "000100110011"; -- 133
            when others =>
                BCD <= BCD_in;
        end case;
    end process;
    
    shift_next <= '0' & shift_reg(21 downto 1) when cnt_reg = "0001" else 
                  '0' & shift_inc(21 downto 1) when cnt_reg /= "0000" else 
                  BCD & "0000000000";
    
    bin_out <= bin_out_reg;
    
end structural;

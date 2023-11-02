library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_seg_driver is
   port ( clk           : in  std_logic;
          reset         : in  std_logic;
          BCD_digit     : in  std_logic_vector(11 downto 0);          
          DIGIT_ANODE   : out std_logic_vector(3 downto 0);
          SEGMENT       : out std_logic_vector(6 downto 0)
        );
end seven_seg_driver;

architecture behavioral of seven_seg_driver is

-- SIGNAL DEFINITIONS HERE IF NEEDED
    signal current_digit : std_logic_vector(3 downto 0);
    
    signal cnt_reg, cnt_next : unsigned(15 downto 0);
    
    signal anode_reg, anode_next: std_logic_vector(3 downto 0);
    
begin
    -- 16 bit counter sequential and combinational parts
    counter_register : process (clk, reset)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                cnt_reg <= (others => '0');
                anode_reg <= "1110";
            else
                cnt_reg <= cnt_next;
                anode_reg <= anode_next;
            end if;
        end if;
    end process;
    
    cnt_next <= cnt_reg + 1;
    
    -- ANODE shift
    anode_next <= anode_reg(2 downto 0) & anode_reg(3) when cnt_reg = 0 else anode_reg;
    DIGIT_ANODE <= anode_reg;
    
    -- choose corresponding BCD digit based on current selected ANODE
    current_digit <= BCD_digit(3 downto 0) when anode_reg = "1110" else
                     BCD_digit(7 downto 4) when anode_reg = "1101" else
                     BCD_digit(11 downto 8) when anode_reg = "1011" else
                     "1110";
                     
    -- binary to segment converter - LUT
    process (current_digit)
    begin
        SEGMENT <= (others => '0');
        case current_digit is
            when "0000" =>
                SEGMENT <= "1000000";
            when "0001" =>
                SEGMENT <= "1111001";
            when "0010" =>
                SEGMENT <= "0100100";
            when "0011" =>
                SEGMENT <= "0110000";
            when "0100" =>
                SEGMENT <= "0011001";
            when "0101" =>
                SEGMENT <= "0010010";
            when "0110" =>
                SEGMENT <= "0000010";
            when "0111" =>
                SEGMENT <= "1111000";
            when "1000" =>
                SEGMENT <= "0000000";
            when "1001" =>
                SEGMENT <= "0010000";
            when "1010" => -- plus
                SEGMENT <= "0001100";
            when "1011" => -- minus
                SEGMENT <= "0111111";
            when "1100" => -- mod3
                SEGMENT <= "1001001";
            when "1101" => -- multiply
                SEGMENT <= "0001001";
            when "1110" =>
                SEGMENT <= "1111111";
            when others =>
                SEGMENT <= "0000110";
        end case;                    
    end process;
    
end behavioral;

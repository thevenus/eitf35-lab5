----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.09.2023 08:48:34
-- Design Name: 
-- Module Name: mod3 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mod3 is
    Port ( num_in : in STD_LOGIC_VECTOR (7 downto 0);
           sign_in : in STD_LOGIC;
           num_mod3_out : out STD_LOGIC_VECTOR (1 downto 0));
end mod3;

architecture Behavioral of mod3 is
    signal internal_1: unsigned (7 downto 0);
    signal internal_2: unsigned (7 downto 0);
    signal internal_3: unsigned (7 downto 0);
    signal internal_4: unsigned (7 downto 0);
    signal internal_5: unsigned (7 downto 0);
    signal internal_6: unsigned (7 downto 0);
    signal result    : unsigned (7 downto 0);

begin
    process (num_in, sign_in)
    begin
        if (sign_in = '1') then
            internal_1 <= unsigned(signed (num_in) + 192);
        elsif (unsigned(num_in) >= 192) then
            internal_1 <= unsigned(num_in) - 192;
        else
            internal_1 <= unsigned(num_in);
        end if;
    end process;

    internal_2   <= internal_1 - 96 when internal_1 >= 96 else internal_1;
    internal_3   <= internal_2 - 48 when internal_2 >= 48 else internal_2;
    internal_4   <= internal_3 - 24 when internal_3 >= 24 else internal_3;
    internal_5   <= internal_4 - 12 when internal_4 >= 12 else internal_4;
    internal_6   <= internal_5 - 6  when internal_5 >= 6 else internal_5;
    result <= internal_6 - 3  when internal_6 >= 3 else internal_6;
    
    num_mod3_out <= std_logic_vector(result(1 downto 0));

end Behavioral;

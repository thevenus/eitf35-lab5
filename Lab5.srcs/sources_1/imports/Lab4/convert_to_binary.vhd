-------------------------------------------------------------------------------
-- Title      : convert_to_binary.vhd 
-- Project    : Keyboard VLSI Lab
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Description: 
-- 		        Look-up-Table
-- 		
--
-------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;


entity convert_to_binary is
    port (
	     scan_code_in : in unsigned(7 downto 0);
	     binary_out : out unsigned(3 downto 0)
	 );
end convert_to_binary;

architecture convert_to_binary_arch of convert_to_binary is
begin

-- simple combinational logic using case statements (LUT)
    combinational_binary_converter : process (scan_code_in)
    begin
        binary_out <= "0000";
        case scan_code_in is
            when x"45" =>
                binary_out <= "0000";
            when x"16" =>
                binary_out <= "0001";
            when x"1E" =>
                binary_out <= "0010";
            when x"26" =>
                binary_out <= "0011";
            when x"25" =>
                binary_out <= "0100";
            when x"2E" =>
                binary_out <= "0101";
            when x"36" =>
                binary_out <= "0110";
            when x"3D" =>
                binary_out <= "0111";
            when x"3E" =>
                binary_out <= "1000";
            when x"46" =>
                binary_out <= "1001";
            when "10000010" => -- 130 = addition
                binary_out <= "1010";
            when "10000011" => -- 131 = subtraction
                binary_out <= "1011";
            when "10000100" => -- 132 = mod3
                binary_out <= "1100";
            when "10000101" => -- 133 = multiply
                binary_out <= "1101";
            when x"00" => -- turn segments off
                binary_out <= "1110";
            when others =>
                binary_out <= "1111";
        end case;
    end process;
end convert_to_binary_arch;

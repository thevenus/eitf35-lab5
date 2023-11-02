-------------------------------------------------------------------------------
-- Title      : convert_scancode.vhd 
-- Project    : Keyboard VLSI Lab
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Description: 
-- 		        Implement a shift register to convert serial to parallel
-- 		        A counter to flag when the valid code is shifted in
--
-------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity convert_scancode is
    port (
	     clk : in std_logic;
	     rst : in std_logic;
	     edge_found : in std_logic;
	     serial_data : in std_logic;
	     valid_scan_code : out std_logic;
	     scan_code_out : out unsigned(7 downto 0)
	 );
end convert_scancode;

architecture convert_scancode_arch of convert_scancode is
    signal current_shift_reg : unsigned(9 downto 0);
    signal next_shift_reg : unsigned(9 downto 0);
    signal current_counter : unsigned(3 downto 0);
    signal next_counter : unsigned(3 downto 0);
begin
    sequential : process (clk, rst)
    begin 
        if (rst = '1') then
            current_shift_reg <= (others => '0');
            current_counter <= (others => '0');
        elsif (rising_edge(clk)) then
            current_shift_reg <= next_shift_reg;
            current_counter <= next_counter;
        end if;
    end process;
    
    -- COMBINATIONAL CIRCUIT
    -- if edge_found is high load serial data and shift the register to right
    next_shift_reg <= current_shift_reg when edge_found = '0' else serial_data & current_shift_reg(9 downto 1);
    
    -- if edge_found is low don't change the register value, otherwise increment it if counter has not reached 10, and reset it when it reaches
    next_counter <= current_counter when edge_found = '0' else
                    (others => '0') when current_counter = 10 else
                    current_counter + 1;
                    
    -- when counter reaches 11 set valid_scan_code high
    valid_scan_code <= '1' when current_counter = 0 else '0';
    
    -- the lower 8 bits of the shift register are the scan code 
    scan_code_out <= current_shift_reg(7 downto 0);
    
end convert_scancode_arch;

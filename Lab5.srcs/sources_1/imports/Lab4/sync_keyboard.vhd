-------------------------------------------------------------------------------
-- Title      : sync_keyboard.vhd 
-- Project    : Keyboard VLSI Lab
-------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity sync_keyboard is
    port (
	     clk : in std_logic; 
	     kb_clk : in std_logic;
	     kb_data : in std_logic;
	     kb_clk_sync : out std_logic;
	     kb_data_sync : out std_logic
	 );
end sync_keyboard;

architecture sync_keyboard_arch of sync_keyboard is
    signal kb_data_meta : std_logic;
    signal kb_clk_meta : std_logic;
begin 
    first_flip_flop: process (clk)
    begin
        if (rising_edge(clk)) then
            kb_data_meta <= kb_data;
            kb_clk_meta <= kb_clk;
        end if;
    end process;
    
    second_flip_flop: process (clk)
    begin
        if (rising_edge(clk)) then
            kb_data_sync <= kb_data_meta;
            kb_clk_sync <= kb_clk_meta;
        end if;
    end process;    
end sync_keyboard_arch;


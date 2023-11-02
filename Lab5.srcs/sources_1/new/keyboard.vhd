----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/13/2023 01:27:39 PM
-- Design Name: 
-- Module Name: keyboard - Behavioral
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
use ieee.numeric_std.all;

library work;
use work.ALU_components_pack.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity keyboard is
    port (
        clk : in std_logic;
        reset : in std_logic;
        kb_data	: in std_logic;
        kb_clk  : in std_logic;
        enter_pressed: out std_logic;
        BCD_num : out unsigned(11 downto 0);
        seg_en : out std_logic_vector(3 downto 0);
        SEGMENT : out std_logic_vector(6 downto 0)
    );
end keyboard;

architecture Behavioral of keyboard is
    component falling_edge_detector is
    port (
         clk : in std_logic;
         rst : in std_logic;
         kb_clk_sync : in std_logic;
         edge_found : out std_logic
         );
    end component;
    
    component sync_keyboard is
    port (
         clk : in std_logic; 
         kb_clk : in std_logic;
         kb_data : in std_logic;
         kb_clk_sync : out std_logic;
         kb_data_sync : out std_logic
         );
    end component;
    
    component convert_scancode is
    port (
         clk : in std_logic;
         rst : in std_logic;
         edge_found : in std_logic;
         serial_data : in std_logic;
         valid_scan_code : out std_logic;
         scan_code_out : out unsigned(7 downto 0)
         );
    end component;
    
    component keyboard_ctrl is
    port (
         clk : in std_logic; 
         rst : in std_logic;
         valid_code : in std_logic;
         scan_code_in : in unsigned(7 downto 0);
         enter_pressed : out std_logic;
         last_3keys : out unsigned (23 downto 0)
         );
    end component;
    
    component convert_to_binary is
    port (
         scan_code_in : in unsigned(7 downto 0);
         binary_out : out unsigned(3 downto 0)
         );
    end component;
    
    component seven_seg_driver is
       port ( clk           : in  std_logic;
              reset         : in  std_logic;
              BCD_digit     : in  std_logic_vector(11 downto 0);          
              DIGIT_ANODE   : out std_logic_vector(3 downto 0);
              SEGMENT       : out std_logic_vector(6 downto 0)
            );
    end component;
    
    signal rst : std_logic;
    
    signal kb_clk_sync, kb_data_sync : std_logic;
    signal edge_found : std_logic;
    signal scan_code : unsigned(7 downto 0);
    signal valid_scan_code : std_logic; 
    signal binary_num : unsigned(3 downto 0);
    signal code_to_display : unsigned(7 downto 0);
    
    signal last_3keys : unsigned(23 downto 0);
    signal bcd_3dig : unsigned (11 downto 0);
begin

    rst <= reset;

    -- syncrhonize all the input signal from keyboard
    sync_keyboard_inst : sync_keyboard
    port map (
		 clk => clk,
		 kb_clk => kb_clk,
		 kb_data => kb_data,
		 kb_clk_sync => kb_clk_sync,
		 kb_data_sync => kb_data_sync
	     );

-- detect the falling edge of kb_clk
-- double check if its synthesizable !!
    falling_edge_detector_inst : falling_edge_detector
    port map (
		 clk => clk,
		 rst => rst,
		 kb_clk_sync => kb_clk_sync,
		 edge_found => edge_found
	     );


-- basically convert serial kb_data to parallel scan code 
-- make sure not to use edge_found as clock !!! (i.e dont use edge_found'event)
    convert_scancode_inst : convert_scancode
    port map (
		 clk => clk,
		 rst => rst,
		 edge_found => edge_found,
		 serial_data => kb_data_sync,
		 valid_scan_code => valid_scan_code,
		 scan_code_out => scan_code
	     );
	     
-- control, implement state machine
    keyboard_ctrl_inst : keyboard_ctrl
    port map (
        clk => clk,
        rst => rst,
        valid_code => valid_scan_code,
        scan_code_in => scan_code,
        enter_pressed => enter_pressed,
        last_3keys => last_3keys
    );
    
    convert_to_binary_inst1 : convert_to_binary
    port map (
        scan_code_in => last_3keys(7 downto 0),
        binary_out => bcd_3dig(3 downto 0)
    );
    
    convert_to_binary_inst2 : convert_to_binary
    port map (
        scan_code_in => last_3keys(15 downto 8),
        binary_out => bcd_3dig(7 downto 4)
    );
    
    convert_to_binary_inst3 : convert_to_binary
    port map (
        scan_code_in => last_3keys(23 downto 16),
        binary_out => bcd_3dig(11 downto 8)
    );
    
    seven_seg_inst : seven_seg_driver
    port map (
        clk => clk,
        reset => rst,
        BCD_digit => std_logic_vector(bcd_3dig),        
        DIGIT_ANODE => seg_en,
        SEGMENT => SEGMENT
    );
    
    BCD_num <= bcd_3dig;
end Behavioral;

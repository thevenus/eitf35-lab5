-------------------------------------------------------------------------------
-- Title      : keyboard_top.vhd 
-- Project    : Keyboard VLSI Lab
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Description: 
-- 		Keyboard top level	
-- 		Functionality of all sub-modules are mentioned in manual.
--		All the required interconnects are already done, students have
-- 		to basically fill vhdl code in the sub-modules !!
--		
--
--
--
-------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.ALU_components_pack.all;

entity keyboard_top is
    port (
	     clk          : in std_logic;
	     rst          : in std_logic;
	     kb_data	  : in std_logic;
	     kb_clk	  : in std_logic;
	     sc		  : out unsigned(7 downto 0);
	     num	  : out unsigned(7 downto 0);
	     seg_en	  : out unsigned(3 downto 0)
	 );
end keyboard_top;

architecture keyboard_top_arch of keyboard_top is
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
		 code_to_display : out unsigned(7 downto 0);
		 seg_en : out unsigned(3 downto 0)
	     );
    end component;

    component convert_to_binary is
	port (
		 scan_code_in : in unsigned(7 downto 0);
		 binary_out : out unsigned(3 downto 0)
	     );
    end component;

    component binary_to_sg
	port (
		 binary_in : in unsigned(3 downto 0);
		 sev_seg   : out unsigned(7 downto 0)
	     );
    end component;

    signal kb_clk_sync, kb_data_sync : std_logic;
    signal edge_found : std_logic;
    signal scan_code : unsigned(7 downto 0);
    signal valid_scan_code : std_logic; 
    signal binary_num : unsigned(3 downto 0);
    signal code_to_display : unsigned(7 downto 0);

begin  

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
-- drive led with the shifted output
    sc <= scan_code;


-- control, implement state machine
    keyboard_ctrl_inst : keyboard_ctrl
    port map (
		 clk => clk,
		 rst => rst,
		 valid_code => valid_scan_code,
		 scan_code_in => scan_code,
		 code_to_display => code_to_display,
		 seg_en => seg_en
	     );

    convert_to_binary_inst : convert_to_binary
    port map (
		 scan_code_in => code_to_display,
		 binary_out => binary_num
	     );


    binary_to_sg_inst : binary_to_sg
    port map (
		 binary_in => binary_num,
		 sev_seg => num
	     );

end keyboard_top_arch;

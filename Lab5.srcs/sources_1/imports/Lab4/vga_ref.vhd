library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.vga_ref_pack.all;

entity vga_ref is
	Port ( clk : in  std_logic;
		    rst : in  std_logic;
		    hs  : out std_logic;
		    vs  : out std_logic;
		    rgb_out : out std_logic_vector (11 downto 0)
		  );
end vga_ref;

architecture Behavioral of vga_ref is

    component clk_wiz_0 is
     port (
      clk_in1   : in std_logic;
      clk_out1  : out std_logic;
      reset     : in std_logic;
      locked    : out std_logic
     );
    end component;
    
    component seven_seg_vga is 
    Port ( pixel_clk : in STD_LOGIC;
           reset: in STD_LOGIC;
           A : in STD_LOGIC_VECTOR (9 downto 0);
           B : in STD_LOGIC_VECTOR (9 downto 0);
           op : in STD_LOGIC_VECTOR (7 downto 0);
           ans : in STD_LOGIC_VECTOR (9 downto 0);
           sign : in STD_LOGIC;
           overflow : in STD_LOGIC;
           rgb_out : out STD_LOGIC_VECTOR (2 downto 0);
           hsync : out STD_LOGIC;
           vsync : out STD_LOGIC
     );
    end component;
	
    -- General signals
	signal clk_sys	: std_logic; 
	signal clk_locked, rst_sys : std_logic;
	
	signal r_out    : std_logic_vector(3 downto 0);
	signal g_out    : std_logic_vector(3 downto 0);
	signal b_out    : std_logic_vector(3 downto 0);
	
	signal rgb       : std_logic_vector(2 downto 0);
	
begin

	rst_sys <= rst or (not clk_locked);		-- Release system reset when clock is stable
	
	-- Replicate the r g and b signals for nexys 4 board
	rgb_out(11 downto 8) <= r_out;
	rgb_out(7 downto 4)  <= g_out;
	rgb_out(3 downto 0)  <= b_out;
	
	r_out <= rgb(2) & rgb(2) & rgb (2) & rgb(2);
	g_out <= rgb(1) & rgb(1) & rgb (1) & rgb(1);
	b_out <= rgb(0) & rgb(0) & rgb (0) & rgb(0);
	
	
	Inst_clock_gen:
	clk_wiz_0
	port map (   clk_in1  	=> clk,
				 clk_out1 	=> clk_sys,			-- Don't touch! active high reset
				 reset    	=> rst,		-- Divided 50MHz input clock
				 locked     => clk_locked
				);

    inst_7seg_vga:
    seven_seg_vga
    port map ( pixel_clk => clk_sys,
               reset => rst_sys,
               A =>  "0100100011",
               B =>  "1001100101",
               op => "10000101",
               ans => "1010011001",
               sign => '0',
               overflow => '0',
               rgb_out => rgb,
               hsync => hs,
               vsync => vs
     );
    
end Behavioral;
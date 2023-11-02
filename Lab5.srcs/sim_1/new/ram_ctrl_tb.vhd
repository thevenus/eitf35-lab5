----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/26/2023 12:33:33 PM
-- Design Name: 
-- Module Name: ram_ctrl_tb - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ram_ctrl_tb is
--  Port ( );
end ram_ctrl_tb;

architecture Behavioral of ram_ctrl_tb is

component ram_ctrl is
    port (
		clk : in std_logic;
		reset_p : in std_logic;
		data_in : in std_logic_vector(7 downto 0);
		btnc_edge : in std_logic;
		enter_pressed : in std_logic;
		A_out : out std_logic_vector(7 downto 0);
		B_out : out std_logic_vector(7 downto 0);
		OP_out : out std_logic_vector(7 downto 0)
    );
   end component;
   
   --SIgnal
    signal clk : std_logic := '0';
    signal reset_p : std_logic := '1';
    signal btnc_edge :  std_logic := '1';
    signal enter_pressed :  std_logic := '0';
    signal data_in :  std_logic_vector(7 downto 0);
    signal A_out :  std_logic_vector(7 downto 0);
    signal B_out :  std_logic_vector(7 downto 0);
    signal OP_out :  std_logic_vector(7 downto 0);
    
   -- Clock period definitions
   constant clk_period : time := 10 ns;
   
begin 
    clk <= not clk after clk_period/2;
    reset_p <= '0' after 20 ns;
    
    uut: ram_ctrl port map(
            clk => clk,
            reset_p => reset_p,
            data_in => data_in,
            btnc_edge => btnc_edge,
            enter_pressed => enter_pressed,
            A_out => A_out,
            OP_out => OP_out,
            B_out => B_out

    );
    

        data_in <=  "00000001", -- 001
                    "00000011" after 2*4*clk_period, -- 3
                    "00001000" after 3*4*clk_period; -- 8
--                    "00101000" after 4*3*clk_period; -- 27
--                    "00000000" after 5*3*clk_period, -- 0
--                    "11111111" after 6*3*clk_period, -- 255
--                    "00000110" after 7*3*clk_period, -- 6
--                    "00001110" after 8*3*clk_period; -- 14
         
         btnc_edge <= '0' after 15*clk_period;
            
         enter_pressed <= '1' after 20*clk_period;   
        
end Behavioral;

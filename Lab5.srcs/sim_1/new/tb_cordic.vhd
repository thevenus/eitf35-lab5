----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.11.2023 11:27:15
-- Design Name: 
-- Module Name: tb_cordic - Behavioral
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

entity tb_cordic is
--  Port ( );
end tb_cordic;

architecture Behavioral of tb_cordic is
    component cordic
      Port (
          clk : in std_logic;
          reset_p : in std_logic;
          X : in std_logic_vector(7 downto 0);
          Y : in std_logic_vector(7 downto 0);
          Hypotenuse : out std_logic_vector(23 downto 0);
          Overflow : out std_logic;
          Angle : out std_logic_vector(23 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    signal reset_p : std_logic := '1';
    signal X, Y : std_logic_vector(7 downto 0);
    signal H, A : std_logic_vector(23 downto 0);
    signal Overflow : std_logic;
    
    constant PERIOD : time := 100ns;

begin
    DUT_cordic : cordic
    port map (
        clk => clk,
        reset_p => reset_p,
        X => X,
        Y => Y,
        Hypotenuse => H,
        Overflow => Overflow,
        Angle => A
    );
    
    clk <= not clk after PERIOD/2;
    reset_p <= '0' after 250ns;
    
    X <= "10110110";
    Y <= "10110110";
    
    
    

end Behavioral;

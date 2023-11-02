library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regUpdate is
   port ( clk        : in  std_logic;
          reset      : in  std_logic;
          RegCtrl    : in  std_logic_vector (1 downto 0);   -- Register update control from ALU controller
          input      : in  std_logic_vector (7 downto 0);   -- Switch inputs
          A          : out std_logic_vector (7 downto 0);   -- Input A
          B          : out std_logic_vector (7 downto 0)   -- Input B
        );
end regUpdate;

architecture behavioral of regUpdate is
    component dff
    generic ( W : integer
            );
    port ( clk     : in  std_logic;
           reset   : in  std_logic;
           d       : in  std_logic_vector(W-1 downto 0);
           q       : out std_logic_vector(W-1 downto 0)
         );
    end component;
    
    signal regA, regB, regA_next, regB_next : std_logic_vector(7 downto 0);
begin
    regA_next <= input when RegCtrl = "10" else regA;
    regB_next <= input when RegCtrl = "01" else regB;
    A <= regA;
    B <= regB;
    
    regA_dff : dff
    generic map (W => 8)
    port map (
        clk => clk,
        reset => reset,
        d => regA_next,
        q => regA
    );
    
    regB_dff : dff
    generic map (W => 8)
    port map (
        clk => clk,
        reset => reset, 
        d => regB_next,
        q => regB   
    );
end behavioral;

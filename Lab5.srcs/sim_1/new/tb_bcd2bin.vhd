library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_bcd2bin is
end entity;

architecture structural of tb_bcd2bin is
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal binary_out : std_logic_vector(7 downto 0);
    signal BCD_in : std_logic_vector(11 downto 0);
    
    constant PERIOD : time := 100ns;
    
    component bcd2bin 
    port ( clk, reset : in std_logic;
         BCD_in : in  std_logic_vector(11 downto 0);
         bin_out   : out std_logic_vector(7 downto 0)       
    );
    end component;
begin
    DUT_bcd2bin : bcd2bin
    port map (
        clk => clk,
        reset => reset,
        BCD_in => BCD_in,
        bin_out => binary_out    
    );
    
    clk <= not clk after PERIOD/2;
    reset <= '0' after 100ns;
    
    BCD_in    <= "000000000001", -- 001
                 "000000000001" after 2*10*PERIOD, -- 123
                 "001001001000" after 3*10*PERIOD, -- 248
                 "000000101000" after 4*10*PERIOD, -- 27
                 "000010011000" after 5*10*PERIOD, -- 098
                 "001001100110" after 6*10*PERIOD, -- 999
                 "000000001010" after 7*10*PERIOD, -- 130
                 "000000001011" after 8*10*PERIOD; -- 131

end structural;
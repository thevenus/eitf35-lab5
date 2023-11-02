----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.10.2023 08:38:55
-- Design Name: 
-- Module Name: cordic - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cordic is
  Port (
    clk : in std_logic;
    reset_p : in std_logic;
    X : in std_logic_vector(7 downto 0);
    Y : in std_logic_vector(7 downto 0);
    Hypotenuse : out std_logic_vector(23 downto 0);
    Overflow : out std_logic;
    Angle : out std_logic_vector(23 downto 0)
  );
end cordic;

architecture Behavioral of cordic is
    signal it_cnt, it_next : natural range 0 to 16;
    signal X_reg, X_next : signed(23 downto 0);
    signal Y_reg, Y_next : signed(23 downto 0);
    signal H_reg, H_next : signed(47 downto 0);
    signal A_reg, A_next : signed(23 downto 0);
    signal AngleTable : signed(23 downto 0);
    signal SumAngle_reg, SumAngle_next : signed(23 downto 0);
begin
    sequential : process (clk, reset_p)
    begin
        if (rising_edge(clk)) then
            if (reset_p = '1') then
                it_cnt <= 0;
                X_reg <= (others => '0');
                Y_reg <= (others => '0');
                H_reg <= (others => '0');
                A_reg <= (others => '0');
                SumAngle_reg <= (others => '0');
            else 
                it_cnt <= it_next;
                X_reg <= X_next;
                Y_reg <= Y_next;
                H_reg <= H_next;
                A_reg <= A_next;
                SumAngle_reg <= SumAngle_next;
            end if;
        end if;
    end process;
    
    combinational : process (X_reg, Y_reg, it_cnt, X, Y, SumAngle_reg, A_reg, H_reg, AngleTable)
    begin
        it_next <= it_cnt;
        X_next <= X_reg;
        Y_next <= Y_reg;
        H_next <= H_reg;
        A_next <= A_reg;
        SumAngle_next <= SumAngle_reg;

        if (it_cnt = 0) then
            X_next <= "0000" & signed(X) & "000000000000";
            Y_next <= "0000" & signed(Y) & "000000000000";
            SumAngle_next <= (others => '0');
            it_next <= it_cnt + 1;
        elsif (it_cnt = 11) then
            H_next <= X_reg * "000000000000100110110111";
            A_next <= SumAngle_reg;
            it_next <= 0;
        elsif (Y_reg(23) = '0') then
            X_next <= X_reg + shift_right(Y_reg, it_cnt-1);
            Y_next <= Y_reg - shift_right(X_reg, it_cnt-1);
            SumAngle_next <= SumAngle_reg + AngleTable;
            it_next <= it_cnt + 1;
        elsif (Y_reg(23) = '1') then
            X_next <= X_reg - shift_right(Y_reg, it_cnt-1);
            Y_next <= Y_reg + shift_right(X_reg, it_cnt-1);
            SumAngle_next <= SumAngle_reg - AngleTable;
            it_next <= it_cnt + 1;
        end if;
    end process;
    
    AngleLUT : process (it_cnt)
    begin
        case it_cnt is
            when 1 => 
                AngleTable <= "000000101101000000000000"; -- 45
            when 2 => 
                AngleTable <= "000000011010100100001010"; -- 26.565
            when 3 =>
                AngleTable <= "000000001110000010010011"; -- 14.036
            when 4 =>
                AngleTable <= "000000000111001000000000"; -- 7.125
            when 5 =>
                AngleTable <= "000000000011100100110111"; -- 3.576
            when 6 =>
                AngleTable <= "000000000001110010100011"; -- 1.790
            when 7 =>
                AngleTable <= "000000000000111001010001"; -- 0.895
            when 8 =>
                AngleTable <= "000000000000011100101011"; -- 0.448
            when 9 =>
                AngleTable <= "000000000000001110010101"; -- 0.224
            when 10 =>
                AngleTable <= "000000000000000111001010"; -- 0.112
            when others =>
                AngleTable <= "000000000000000000000000"; -- 0.0
        end case;
    end process;
    
    Hypotenuse <= std_logic_vector(H_reg(35 downto 12));
    Overflow <= '1' when H_reg(47 downto 32) > 0 else '0';
    Angle <= std_logic_vector(A_reg);
    
end Behavioral;

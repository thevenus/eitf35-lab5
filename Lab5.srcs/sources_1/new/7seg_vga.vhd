----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/16/2023 11:58:09 AM
-- Design Name: 
-- Module Name: 7seg_vga - Behavioral
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seven_seg_vga is
    Port ( pixel_clk : in STD_LOGIC;
           reset: in STD_LOGIC;
           A : in STD_LOGIC_VECTOR (9 downto 0);
           B : in STD_LOGIC_VECTOR (9 downto 0);
           op : in STD_LOGIC_VECTOR (7 downto 0);
           ans : in STD_LOGIC_VECTOR (17 downto 0);
           ans_angle : in STD_LOGIC_VECTOR (17 downto 0);
           sign : in STD_LOGIC;
           overflow : in STD_LOGIC;
           rgb_out : out STD_LOGIC_VECTOR (2 downto 0);
           hsync : out STD_LOGIC;
           vsync : out STD_LOGIC
     );
end seven_seg_vga;

architecture Behavioral of seven_seg_vga is
--    signal cnt_reg, cnt_next : unsigned(

    component seven_seg_dig is
    port (
        segment : in STD_LOGIC_VECTOR (7 downto 0);
        hpos : in STD_LOGIC_VECTOR (10 downto 0);
        vpos : in STD_LOGIC_VECTOR (10 downto 0);
        hcount : in STD_LOGIC_VECTOR (10 downto 0);
        vcount : in STD_LOGIC_VECTOR (10 downto 0);
        rgb_out: out STD_LOGIC_VECTOR (2 downto 0)
    );
    end component;
    
    component vga_controller_640_60 is
    port ( 
         rst       : in  std_logic; 
         pixel_clk : in  std_logic; 
         HS        : out std_logic; 
         VS        : out std_logic; 
         blank     : out std_logic; 
         hcount    : out std_logic_vector(10 downto 0); 
         vcount    : out std_logic_vector(10 downto 0)
    );
    end component;
    
    signal rgb1, rgb2, rgb3, rgb4, rgb5, rgb6, rgb7, rgb8, rgb9, rgb10, rgb11, rgb12, rgb13, rgb14, rgb15, rgb16, rgb17, rgb18, rgb19, rgb20, rgb21, rgb22 : std_logic_vector(2 downto 0);
    signal rgb       : std_logic_vector(2 downto 0);
    
    -- VGA module
    signal blank : std_logic;
    signal hcount,vcount : std_logic_vector(10 downto 0);
    signal current_digit : std_logic_vector(3 downto 0);
    signal segment : std_logic_vector(7 downto 0);
    signal sign_of : std_logic_vector(7 downto 0);
    signal operator : std_logic_vector (7 downto 0);
    signal angle_sign : std_logic_vector(7 downto 0);
    signal angle_decimal: std_logic_vector(7 downto 0);

begin
    vgactrl640_60:
    vga_controller_640_60
    port map ( pixel_clk  => pixel_clk,
              rst         => reset,
              blank       => blank,
              hcount      => hcount,
              hs          => hsync,
              vcount      => vcount,
              vs          => vsync
    );
    ----------------------------------------------------------
    ----------POSITIONING THE DIGITS--------------------------
    ----------------------------------------------------------
    process (hcount, vcount, A, B, ans, ans_angle, op)
    begin
        if (hcount <= 20+40-09) then                     
            current_digit <= "00" & A(9 downto 8);
        elsif (hcount <= 20+80-9) then
            current_digit <= A(7 downto 4);
        elsif (hcount <= 20+120-9) then
            current_digit <= A(3 downto 0);
        elsif (hcount <= 20+200-9) then
            current_digit <= "00" & B(9 downto 8);
        elsif (hcount <= 20+240-9) then
            current_digit <= B(7 downto 4);
        elsif (hcount <= 20+280-9) then
            current_digit <= B(3 downto 0);
        elsif (hcount <= 20+400-9 and vcount < 319) then
            current_digit <= "00" & ans(17 downto 16);
        elsif (hcount <= 20+440-9 and vcount < 319) then
            current_digit <= ans(15 downto 12);
        elsif (hcount <= 20+480-9 and vcount < 319) then
            current_digit <= ans(11 downto 8);
        elsif (hcount <= 20+560-9 and vcount < 319 and op = "10000110") then
            current_digit <= ans(7 downto 4);
        elsif (hcount <= 20+600-9 and vcount < 319 and op = "10000110") then
            current_digit <= ans(3 downto 0);
        --Angle-----------------------------
        elsif (hcount <= 20+400-9 and vcount >= 319 and op = "10000110") then    
            current_digit <= "00" & ans_angle(17 downto 16);
        elsif (hcount <= 20+440-9 and vcount >= 319 and op = "10000110") then
            current_digit <= ans_angle(15 downto 12);
        elsif (hcount <= 20+480-9 and vcount >= 319 and op = "10000110") then
            current_digit <= ans_angle(11 downto 8);
        elsif (hcount <= 20+560-9 and vcount >= 319 and op = "10000110") then
            current_digit <= ans_angle(7 downto 4);
        elsif (hcount <= 20+600-9 and vcount >= 319 and op = "10000110") then
            current_digit <= ans_angle(3 downto 0);
        else current_digit <= "1111";            
        end if;
    end process;
    
        -- binary to segment converter - LUT
    process (current_digit)
    begin
        segment <= (others => '0');
        case current_digit is
            when "0001" =>
                segment <= "01111001";
            when "0010" =>
                segment <= "00100100";
            when "0011" =>
                segment <= "00110000";
            when "0100" =>
                segment <= "00011001";
            when "0101" =>
                segment <= "00010010";
            when "0110" =>
                segment <= "00000010";
            when "0111" =>
                segment <= "01111000";
            when "1000" =>
                segment <= "00000000";
            when "1001" =>
                segment <= "00010000";
            when "0000" =>
                segment <= "01000000";
            when "1110" =>
                segment <= "01111111";
            when "1010" =>
                segment <= "00111111";
            when "1011" =>
                segment <= "00001110";
            when others =>
                segment <= "01111111";
        end case;                    
    end process;

    digit_1 :
    seven_seg_dig
    port map (
        segment => segment,
        hpos => "00000010101", --20
        vpos => "00010110011",
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb1
    );
    
    digit_2 :
    seven_seg_dig
    port map (
        segment => segment,
        hpos => "00000111100", --60
        vpos => "00010110011",
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb2
    );
    
    digit_3 :
    seven_seg_dig
    port map (
        segment => segment,
        hpos => "00001100100", --100
        vpos => "00010110011",
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb3
    );
    
    digit_4 :
    seven_seg_dig
    port map (
        segment => operator,
        hpos => "00010001100", --140
        vpos => "00010110011",
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb4
    );
    operator <= op when op = 130 or op = 131 or op = 132 or op = 133 or op = 134 else "10000010";
    
    digit_5 :
    seven_seg_dig
    port map (
        segment => segment,
        hpos => "00010110100", --180
        vpos => "00010110011",
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb5
    );
    
    digit_6 :
    seven_seg_dig
    port map (
        segment => segment,
        hpos => "00011011100", --220
        vpos => "00010110011",
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb6
    );
    
    digit_7 :
    seven_seg_dig
    port map (
        segment => segment,
        hpos => "00100000100", --260
        vpos => "00010110011",
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb7
    );
    
    digit_8 :
    seven_seg_dig
    port map (
        segment =>  "10000111", 
        hpos =>     "00100101100", --300
        vpos => "00010110011",
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb8
    );
    
    digit_9 :
    seven_seg_dig
    port map (
        segment => sign_of,
        hpos => "00101010100", --340
        vpos => "00010110011",
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb9
    );
    sign_of <= "10000011" when sign = '1' else
               "00001110" when overflow = '1' else
               "10000010";
    
    digit_10 :
    seven_seg_dig
    port map (
        segment => segment,
        hpos => "00101111100", --380
        vpos => "00010110011",
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb10
    );
    
    digit_11 :
    seven_seg_dig
    port map (
        segment => segment,
        hpos => "00110100100", --420
        vpos => "00010110011",
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb11
    );
    
    digit_12 :
    seven_seg_dig
    port map (
        segment => segment,
        hpos => "00111001100", --460
        vpos => "00010110011",
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb12
    );
    
    
    digit_13 :
    seven_seg_dig
    port map (
        segment => angle_decimal,
        hpos => "00111110100", --500
        vpos => "00010110011",
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb13
    );
        

    digit_14 :
    seven_seg_dig
    port map (
        segment => segment,
        hpos => "01000011100", --540
        vpos => "00010110011",
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb14
    );
    

    digit_15 :
    seven_seg_dig
    port map (
        segment => segment,
        hpos => "01001000100", --580
        vpos => "00010110011", --179
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb15
    );

    digit_16 :
    seven_seg_dig
    port map (
        segment => angle_sign,
        hpos => "00101010100", --340
        vpos => "00100111111", --319
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb16
    );
    angle_sign <= "10000010" when op = "10000110" else
                    "01111111";
               

    digit_17 :
    seven_seg_dig
    port map (
        segment => segment,
        hpos => "00101111100", --380
        vpos => "00100111111", --319
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb17
    );

    digit_18 :
    seven_seg_dig
    port map (
        segment => segment,
        hpos => "00110100100", --420
        vpos => "00100111111", --319
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb18
    );
    digit_19 :
    seven_seg_dig
    port map (
        segment => segment,
        hpos => "00111001100", --460
        vpos => "00100111111", --319
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb19
    );
    
    digit_20 :
    seven_seg_dig
    port map (
        segment => angle_decimal,
        hpos => "00111110100", --500
        vpos => "00100111111", --319
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb20
    );
    angle_decimal <= "10000000" when op = "10000110" else "01111111";
    
    digit_21 :
    seven_seg_dig
    port map (
        segment => segment,
        hpos => "01000011100", --540
        vpos => "00100111111", --319
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb21
    );
    
    digit_22 :
    seven_seg_dig
    port map (
        segment => segment,
        hpos => "01001000100", --580
        vpos => "00100111111", --319
        hcount => hcount,
        vcount => vcount,
        rgb_out => rgb22
    );
    

    rgb_out <= rgb1 or rgb2 or rgb3 or rgb4 or rgb5 or rgb6 or rgb7 or rgb8 or rgb9 or rgb10 or rgb11 or rgb12 or rgb13 or rgb14 or rgb15 or rgb16 or rgb17 or rgb18 or rgb19 or rgb20 or rgb21 or rgb22 ;
end Behavioral;

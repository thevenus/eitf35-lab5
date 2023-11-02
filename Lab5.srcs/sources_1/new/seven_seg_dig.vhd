----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/16/2023 01:23:17 PM
-- Design Name: 
-- Module Name: seven_seg_dig - Behavioral
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seven_seg_dig is
    Port ( segment : in STD_LOGIC_VECTOR (7 downto 0);
           hpos : in STD_LOGIC_VECTOR (10 downto 0);
           vpos : in STD_LOGIC_VECTOR (10 downto 0);
           hcount : in STD_LOGIC_VECTOR (10 downto 0);
           vcount : in STD_LOGIC_VECTOR (10 downto 0);
           rgb_out: out STD_LOGIC_VECTOR (2 downto 0)
           );
end seven_seg_dig;

architecture Behavioral of seven_seg_dig is
    constant seg_width : integer := 4;
    constant h_seg_len : integer := 18;
    constant v_seg_len : integer := 54;
    constant seg_space : integer := 2;
    constant h_space   : integer := 6;

begin
    process (hcount, vcount, vpos, hpos, segment)
    begin
        rgb_out <= "000";
        if vcount >= vpos and vcount <= vpos + 120 then
            if hcount >= hpos and hcount <= hpos + 30 - 1 then        -- "-1" is due to the registered "hcount" output
                if (segment(7) = '0') then
                    -- digits 
                    -- segment a
                    if (segment(0) = '0') then
                        if (hcount >= hpos + h_space and hcount <= hpos + h_seg_len + h_space and vcount >= vpos and vcount <= vpos + seg_width) then
                            rgb_out <= "010";                            
                        end if;
                    end if;
                    
                    -- segment b
                    if (segment(1) = '0') then
                        if (hcount >= hpos + 26 and hcount <= hpos + 30 and vcount >= vpos + 4 and vcount <= vpos + 58) then
                            rgb_out <= "010";                            
                        end if;
                    end if;
                    
                    -- segment c
                    if (segment(2) = '0') then
                        if (hcount >= hpos + 26 and hcount <= hpos + 30 and vcount >= vpos + 62 and vcount <= vpos + 116) then
                            rgb_out <= "010";                            
                        end if;
                    end if;
                    
                    -- segment d
                    if (segment(3) = '0') then
                        if (hcount >= hpos + h_space and hcount <= hpos + h_seg_len + h_space and vcount >= vpos + 116 and vcount <= vpos + 120) then
                            rgb_out <= "010";                            
                        end if;
                    end if;
                    
                    -- segment e
                    if (segment(4) = '0') then
                        if (hcount >= hpos and hcount <= hpos + 4 and vcount >= vpos + 62 and vcount <= vpos + 116) then
                            rgb_out <= "010";                            
                        end if;
                    end if;
                    
                    -- segment f
                    if (segment(5) = '0') then
                        if (hcount >= hpos and hcount <= hpos + 4 and vcount >= vpos + 4 and vcount <= vpos + 58) then
                            rgb_out <= "010";                            
                        end if;
                    end if;
                    
                    -- segment g
                    if (segment(6) = '0') then
                        if (hcount >= hpos + h_space and hcount <= hpos + h_seg_len + h_space and vcount >= vpos+ 58 and vcount <= vpos +62) then
                            rgb_out <= "010";                            
                        end if;
                    end if;
                else
                    -- signs
                    case segment(2 downto 0) is 
                        when "000" => --Decimal
                         if ((hcount >= hpos + h_space and hcount <= hpos + h_seg_len + h_space and vcount >= vpos+ 116 and vcount <= vpos + 120) and (hcount >= hpos + 13 and hcount <= hpos + 17 and vcount >= vpos + 102 and vcount <= vpos + 120)) then
                            rgb_out <= "010";                           
                         end if;
                        when "010" => -- plus
                            if ((hcount >= hpos + h_space and hcount <= hpos + h_seg_len + h_space and vcount >= vpos+ 58 and vcount <= vpos +62) or (hcount >= hpos + 13 and hcount <= hpos + 17 and vcount >= vpos + 51 and vcount <= vpos + 69)) then
                                rgb_out <= "010";                            
                            end if;
                        when "011" => -- minus
                            if (hcount >= hpos + h_space and hcount <= hpos + h_seg_len + h_space and vcount >= vpos+ 58 and vcount <= vpos +62) then
                                rgb_out <= "010";                            
                            end if;
                        when "100" => -- mod3
                            if ((hcount >= hpos + h_space and hcount <= hpos + h_seg_len + h_space and vcount >= vpos+ 51 and vcount <= vpos + 55) or 
                                (hcount >= hpos + 6 and hcount <= hpos + 10 and vcount >= vpos + 51 and vcount <= vpos + 69) or
                                (hcount >= hpos + 13 and hcount <= hpos + 17 and vcount >= vpos + 51 and vcount <= vpos + 69) or 
                                (hcount >= hpos + 20 and hcount <= hpos + 24 and vcount >= vpos + 51 and vcount <= vpos + 69)) then
                                rgb_out <= "010";                            
                            end if;

                        when "101" => -- mult
                            if ((hcount >= hpos + h_space and hcount <= hpos + h_seg_len + h_space and vcount >= vpos+ 58 and vcount <= vpos +62) and (hcount >= hpos + 13 and hcount <= hpos + 17 and vcount >= vpos + 51 and vcount <= vpos + 69)) then
                                rgb_out <= "010";                            
                            end if;
                        when "110" => -- cordic
                            if ((hcount >= hpos and hcount <= hpos + 4 and vcount >= vpos + 62 and vcount <= vpos + 116)or(hcount >= hpos + h_space and hcount <= hpos + h_seg_len + h_space and vcount >= vpos + 116 and vcount <= vpos + 120)or(hcount >= hpos + h_space and hcount <= hpos + h_seg_len + h_space and vcount >= vpos+ 58 and vcount <= vpos +62)) then
                                rgb_out <= "010";                            
                            end if;

                        when "111" => -- equal
                            if (hcount >= hpos + h_space and hcount <= hpos + h_seg_len + h_space and ((vcount >= vpos+ 52 and vcount <= vpos +56) or (vcount >= vpos+ 62 and vcount <= vpos +66))) then
                                rgb_out <= "010";                            
                            end if;
                            
                        when others => -- zero
                            rgb_out <= "000";
                    end case;
                end if;
            end if;
        end if;
    end process;


end Behavioral;

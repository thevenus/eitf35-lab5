-------------------------------------------------------------------------------
-- Title      : keyboard_ctrl.vhd 
-- Project    : Keyboard VLSI Lab
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Description: 
-- 		        controller to handle the scan codes 
-- 		        
--
-------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;


entity keyboard_ctrl is
    port (
	     clk : in std_logic; 
	     rst : in std_logic;
	     valid_code : in std_logic;
	     scan_code_in : in unsigned(7 downto 0);
	     enter_pressed : out std_logic;
	     last_3keys : out unsigned (23 downto 0)
	 );
end keyboard_ctrl;

architecture keyboard_ctrl_arch of keyboard_ctrl is
    signal keys_reg : unsigned(23 downto 0);
    signal keys_next : unsigned(23 downto 0);
    
    type state_type is (s_wait_release, s_wait_keycode, s_load_new_dig);
    signal current_state, next_state : state_type;
begin
    registers : process (clk, rst)
    begin
        if (rst = '1') then
            keys_reg <= x"454545";
            current_state <= s_wait_release;
        elsif (rising_edge(clk)) then
            keys_reg <= keys_next;
            current_state <= next_state;
        end if;
    end process;
    
    next_state_and_output : process (current_state, valid_code, scan_code_in, keys_reg)
    begin
        next_state <= current_state;
        keys_next <= keys_reg;
        enter_pressed <= '0';
        
        case current_state is
            when s_wait_release =>
                if (valid_code = '1' and scan_code_in = 16#F0#) then
                    next_state <= s_wait_keycode;
                else
                    next_state <= s_wait_release;
                end if;
            when s_wait_keycode =>
                if (valid_code = '1' and scan_code_in /= 16#F0#) then 
                    next_state <= s_load_new_dig;
                else
                    next_state <= s_wait_keycode;
                end if;
           when s_load_new_dig =>
                if (scan_code_in = 16#66#) then -- backspace
                    keys_next <= x"454545";
                elsif (scan_code_in = 16#5A#) then -- enter
                    enter_pressed <= '1';
                    keys_next <= x"454545";
                elsif (scan_code_in = 16#79#) then -- plus
                    keys_next(23 downto 8) <=  (others => '0');
                    keys_next(7 downto 0) <= "10000010"; -- 130
                elsif (scan_code_in = 16#7B#) then -- minus
                    keys_next(23 downto 8) <=  (others => '0');
                    keys_next(7 downto 0) <= "10000011"; -- 131
                elsif (scan_code_in = 16#3A#) then -- mod3
                    keys_next(23 downto 8) <=  (others => '0');
                    keys_next(7 downto 0) <= "10000100"; -- 132
                elsif (scan_code_in = 16#7C#) then -- multiply
                    keys_next(23 downto 8) <=  (others => '0');
                    keys_next(7 downto 0) <= "10000101"; -- 133
                elsif (scan_code_in = 16#21#) then -- cordic
                    keys_next <= x"162625"; -- 134
                else                    
                    keys_next <= keys_reg(15 downto 0) & scan_code_in; 
                end if;
                next_state <= s_wait_release;
        end case;      
    end process;
    
    last_3keys <= keys_reg;
    
end keyboard_ctrl_arch;

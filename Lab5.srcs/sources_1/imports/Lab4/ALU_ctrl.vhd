library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_ctrl is
   port ( clk     : in  std_logic;
          reset   : in  std_logic;
          enter   : in  std_logic;
          sign    : in  std_logic;
          FN      : out std_logic_vector (3 downto 0);   -- ALU functions
          RegCtrl : out std_logic_vector (1 downto 0)   -- Register update control bits
        );
end ALU_ctrl;

architecture behavioral of ALU_ctrl is

-- SIGNAL DEFINITIONS HERE IF NEEDED
    -- add, sub, mod3 are unsigned operations
    type state_type is (s_inputA, s_inputB, s_add, s_sub, s_mod3, s_addSig, s_subSig, s_mod3Sig);
    signal state_reg, state_next : state_type;

begin
    state_register: process (clk, reset)
    begin
        if (reset = '1') then
            state_reg <= s_inputA;
        elsif (rising_edge(clk)) then
            state_reg <= state_next;
        end if;
    end process state_register;
    
    next_state_logic: process (enter, sign, state_reg)
    begin
        -- Default values
        state_next <= state_reg;
        FN <= "0000";
        RegCtrl <= "00";
        
        case state_reg is
            when s_inputA =>
                FN <= "0000";
                RegCtrl <= "10";
                
                if (enter = '1') then
                    state_next <= s_inputB;
                end if;
            when s_inputB =>
                FN <= "0001";
                RegCtrl <= "01";
                
                if (enter = '1') then
                    state_next <= s_add;
                end if;
            when s_add =>
                FN <= "0010";
                
                if (enter = '1') then
                    state_next <= s_sub;
                elsif (sign = '1') then
                    state_next <= s_addSig;    
                end if;
            when s_sub =>
                FN <= "0011";
                
                if (enter = '1') then
                    state_next <= s_mod3;
                elsif (sign = '1') then
                    state_next <= s_subSig;    
                end if;        
            when s_mod3 => 
                FN <= "0100";
                
                if (enter = '1') then
                    state_next <= s_add;
                elsif (sign = '1') then
                    state_next <= s_mod3Sig;    
                end if;             
            when s_addSig =>
                FN <= "1010";
                
                if (enter = '1') then 
                    state_next <= s_sub;
                elsif (sign = '1') then
                    state_next <= s_add;
                end if;
            when s_subSig =>
                FN <= "1011";
                
                if (enter = '1') then
                    state_next <= s_mod3;
                elsif (sign = '1') then
                    state_next <= s_sub;
                end if;
            when s_mod3Sig =>
                FN <= "1100";
                
                if (enter = '1') then
                    state_next <= s_add;
                elsif (sign = '1') then
                    state_next <= s_mod3;
                end if;
            end case;
    end process next_state_logic;
end behavioral;
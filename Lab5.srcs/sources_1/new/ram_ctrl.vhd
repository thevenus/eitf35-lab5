----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/25/2023 02:38:55 PM
-- Design Name: 
-- Module Name: ram_ctrl - Behavioral
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

entity ram_ctrl is
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
end ram_ctrl;

architecture Behavioral of ram_ctrl is
    component ram_8kB 
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    END component;
    
    signal read_cnt, read_cnt_next : std_logic_vector(1 downto 0);
    signal addr_cnt, addr_next : unsigned(12 downto 0);
    
    signal A_reg, A_next, B_reg, B_next, OP_reg, OP_next : std_logic_vector(7 downto 0);
    
    signal en : std_logic;
    signal we : std_logic_vector(0 downto 0);
    signal din : std_logic_vector (7 downto 0);
    signal dout : std_logic_vector (7 downto 0);
    
    type state_type is (s_init, s_write, s_addr_inc, s_start_read, s_readB, s_readOP, s_readA);
    signal state_reg, state_next : state_type;
--    signal din : std_logic_vector(7 downto 0);
begin
    -- sequential part
    process (clk, reset_p)
    begin
        if (rising_edge(clk)) then
            if (reset_p = '1') then
                read_cnt <= (others => '0');
                addr_cnt <= (others => '0');
                A_reg <= (others => '0');
                B_reg <= (others => '0');
                OP_reg <= "10000010";
                state_reg <= s_init;
            else
                read_cnt <= read_cnt_next;
                addr_cnt <= addr_next;
                A_reg <= A_next;
                B_reg <= B_next;
                OP_reg <= OP_next;
                state_reg <= state_next;
            end if;
        end if;
    end process;
    
    ram_8kB_inst : ram_8kB
    port map ( clka => clk,
               ena => en,
               wea => we,
               addra => std_logic_vector(addr_cnt),
               dina => din,
               douta => dout
    );
    en <= '1';
    
    -- RAM FSM
    process (btnc_edge, enter_pressed, state_reg, addr_cnt, read_cnt, dout, A_reg, B_reg, OP_reg, data_in)
    begin
        state_next <= state_reg;
        we <= (others => '0');
        addr_next <= addr_cnt;
        A_next <= A_reg; 
        B_next <= B_reg; 
        OP_next <= OP_reg;
        read_cnt_next <= read_cnt;
        din <= data_in;
        
        case state_reg is 
            when s_init => 
                if btnc_edge = '1' then
                    state_next <= s_write;

                elsif enter_pressed = '1' then
                    state_next <= s_start_read; 
                else
                    state_next <= s_init;
                end if;
            
            when s_write =>    
                state_next <= s_addr_inc;
                we <= "1";

            when s_addr_inc =>
                addr_next <= addr_cnt + 1;
                state_next <= s_init;
                
--                we <= "1";
            
            when s_start_read =>
                addr_next <= addr_cnt - 1;
                state_next <= s_readB;
            
            when s_readB =>
                if (read_cnt = "00") then
                    addr_next <= addr_cnt - 1;
                    state_next <= s_readB;
                elsif (read_cnt = "10") then
                    B_next <= dout;
                elsif (read_cnt = "11") then
                    state_next <= s_readOP;
                    read_cnt_next <= "00";
                end if;
                
                read_cnt_next <= read_cnt + 1;

            when s_readOP =>
                if (read_cnt = "00") then
                    addr_next <= addr_cnt - 1;
                    state_next <= s_readOP;
                elsif (read_cnt = "10") then
                    OP_next <= dout;
                elsif (read_cnt = "11") then
                    state_next <= s_readA;
                    read_cnt_next <= "00";
                end if;
 
                read_cnt_next <= read_cnt + 1;
                
            when s_readA =>
                if (read_cnt = "00") then
--                    addr_next <= addr_cnt - 1;
                    state_next <= s_readA;
                elsif (read_cnt = "10") then
                    A_next <= dout;
                elsif (read_cnt = "11") then
                    state_next <= s_init;
                    read_cnt_next <= "00";
                end if;
    
                read_cnt_next <= read_cnt + 1;
        end case;
    end process;
    
    --Taking Output
    A_out <= A_reg;
    OP_out <= OP_reg;
    B_out <= B_reg;

end Behavioral;
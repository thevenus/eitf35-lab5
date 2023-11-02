----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/13/2023 11:43:55 AM
-- Design Name: 
-- Module Name: ram_test - Behavioral
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

library work;
use work.ALU_components_pack.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ram_test is
port ( clk : in std_logic;
       reset_n : in std_logic;
       btnc : in std_logic;
       btnl : in std_logic;
       switch12 : in std_logic;
       kb_data : in std_logic;
       kb_clk : in std_logic;
       led : out std_logic_vector(7 downto 0)
);
end ram_test;

architecture Behavioral of ram_test is
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
    
    component keyboard
      port (
        clk : in std_logic;
        reset : in std_logic;
        kb_data    : in std_logic;
        kb_clk  : in std_logic;
        BCD_num : out unsigned(23 downto 0);
        seg_en : out unsigned(3 downto 0)
      );
    end component;

    signal en : std_logic;
    signal we : std_logic_vector(0 downto 0);
    signal addr : std_logic_vector (12 downto 0);
    signal din : std_logic_vector (7 downto 0);
    signal dout : std_logic_vector (7 downto 0);
    signal bcd : unsigned (23 downto 0);
    signal seg_en : unsigned (3 downto 0);
    
    signal cnt_reg, cnt_next : unsigned (12 downto 0);
    signal reset : std_logic;
    
    signal btnc_edge, btnc_debounced, btnc_sync : std_logic;
    signal btnl_edge, btnl_debounced, btnl_sync : std_logic;

begin
    reset <= not reset_n;
    
    ---- to provide a clean signal out of a bouncy one coming from the push button
    ---- input(b_Enter) comes from the pushbutton; output(Enter) goes to the FSM 
     debouncer1: debouncer
     port map ( clk          => clk,
               reset        => reset,
               button_in    => btnc,
               button_out   => btnc_debounced
             );
     
     debouncer2: debouncer
     port map ( clk         => clk,
                reset       => reset,
                button_in   => btnl,
                button_out  => btnl_debounced
              );
     
     -- Synchronize the enter and sign buttons with clock
     sync1: ff_sync
     port map (clk          => clk,
               signal_in    => btnc_debounced,
               signal_out   => btnc_sync
              );
     
     sync2: ff_sync
     port map (clk        => clk,
               signal_in  => btnl_debounced,
               signal_out => btnl_sync
              );
     
     -- Find the positive edge of the button signals, output a signal for one clock cycle
     edge1: rising_edge_detector
     port map (clk        => clk,
               rst        => reset,
               signal_in  => btnc_sync,
               edge_found => btnc_edge
              );
     
     edge2: rising_edge_detector
     port map (clk        => clk,
               rst        => reset,
               signal_in  => btnl_sync,
               edge_found => btnl_edge
              );
    -- address counter
    process (clk, reset_n) begin
      if (rising_edge(clk)) then
          if (reset_n = '0') then
              cnt_reg <= (others => '0');
          else
              cnt_reg <= cnt_next;
          end if;
      end if;
    end process;
          
    cnt_next <= cnt_reg + 1 when btnl_edge = '1' and switch12 = '0' else
                cnt_reg - 1 when btnl_edge = '1' and switch12 = '1' else 
                cnt_reg;
    -- Get input from the keyboard
    inst_keyboard : keyboard
            port map (
                clk => clk,
                reset => reset,
                kb_data => kb_data,
                kb_clk => kb_clk,
                BCD_num => bcd,
                seg_en => seg_en
            );
    
    -- RAM module
    inst_ram_8kB : ram_8kB
    port map ( clka => clk,
               ena => en,
               wea => we,
               addra => addr,
               dina => din,
               douta => dout
    );
    
    addr <= std_logic_vector(cnt_reg);
    en <= '1';
    we <= "1" when btnc_edge = '1' else "0";
    din <= std_logic_vector(bcd(7 downto 0));
    led <= dout;
end Behavioral;

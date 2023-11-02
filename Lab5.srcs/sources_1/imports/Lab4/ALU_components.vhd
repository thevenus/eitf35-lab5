library ieee;
use ieee.std_logic_1164.all;

package ALU_components_pack is

   -- Button debouncing 
   component debouncer   
   port ( clk        : in  std_logic;
          reset      : in  std_logic;
          button_in  : in  std_logic;
          button_out : out std_logic
        );
   end component;
   
   -- D-flipflop
   component dff
   generic ( W : integer );
   port ( clk     : in  std_logic;
          reset   : in  std_logic;
          d       : in  std_logic_vector(W-1 downto 0);
          q       : out std_logic_vector(W-1 downto 0)
        );
   end component;
   
   -- ADD MORE COMPONENTS HERE IF NEEDED
   
   component ff_sync
   port ( clk : in std_logic;
          signal_in : in std_logic;
          signal_out : out std_logic
   );
   end component;
   
   component rising_edge_detector
   port (
            clk : in std_logic;
            rst : in std_logic;
            signal_in : in std_logic;
            edge_found : out std_logic
    );
    end component;
    
    component falling_edge_detector
        port (
             clk : in std_logic;
             rst : in std_logic;
             kb_clk_sync : in std_logic;
             edge_found : out std_logic
         );
    end component;

   
end ALU_components_pack;

-------------------------------------------------------------------------------
-- ALU component pack body
-------------------------------------------------------------------------------
package body ALU_components_pack is

end ALU_components_pack;

-------------------------------------------------------------------------------
-- debouncer component: There is no need to use this component, thogh if you get 
--                      unwanted moving between states of the FSM because of pressing
--                      push-button this component might be useful.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
   port ( clk        : in  std_logic;
          reset      : in  std_logic;
          button_in  : in  std_logic;
          button_out : out std_logic
        );
end debouncer;

architecture behavioral of debouncer is

   signal count      : unsigned(19 downto 0);  -- Range to count 20ms with 50 MHz clock
   signal button_tmp : std_logic;
   
begin

    process ( clk )
    begin
       if clk'event and clk = '1' then
          if reset = '1' then
             count <= (others => '0');
          else
             count <= count + 1;
             button_tmp <= button_in;
             
             if (count = 0) then
                button_out <= button_tmp;
             end if;
          end if;
      end if;
    end process;

end behavioral;

------------------------------------------------------------------------------
-- component dff - D-FlipFlop 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity dff is
   generic ( W : integer
           );
   port ( clk     : in  std_logic;
          reset   : in  std_logic;
          d       : in  std_logic_vector(W-1 downto 0);
          q       : out std_logic_vector(W-1 downto 0)
        );
end dff;

architecture behavioral of dff is
begin

   process ( clk )
   begin
      if clk'event and clk = '1' then
         if reset = '1' then
            q <= (others => '0');
         else
            q <= d;
         end if;
      end if;
   end process;              

end behavioral;

------------------------------------------------------------------------------
-- BEHAVORIAL OF THE ADDED COMPONENETS HERE
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

-- 2 Flip-Flop Synchronizer
entity ff_sync is
    port ( clk : in std_logic;
          signal_in : in std_logic;
          signal_out : out std_logic
   );
end ff_sync;

architecture structural of ff_sync is
    signal signal_meta : std_logic;
    
begin
    first_ff: process (clk)
    begin
        if (rising_edge(clk)) then
            signal_meta <= signal_in;
        end if;
    end process;
    
    second_ff: process (clk)
    begin
        if (rising_edge(clk)) then
            signal_out <= signal_meta;
        end if;
    end process;
end structural;

-- Rising edge detector based on flip-flop
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;


entity rising_edge_detector is
    port (
	     clk : in std_logic;
	     rst : in std_logic;
	     signal_in : in std_logic;
	     edge_found : out std_logic
	 );
end rising_edge_detector;


architecture rising_edge_detector_arch of rising_edge_detector is
    signal signal_delayed : std_logic;
begin
    process (clk, rst)
    begin
        if (rst = '1') then
            signal_delayed <= '0';
        elsif (rising_edge(clk)) then
            signal_delayed <= signal_in;
        end if;
    end process;
    
    edge_found <= (not signal_delayed) and signal_in;
 
end rising_edge_detector_arch;

-- Falling edge detector
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;


entity falling_edge_detector is
    port (
	     clk : in std_logic;
	     rst : in std_logic;
	     kb_clk_sync : in std_logic;
	     edge_found : out std_logic
	 );
end falling_edge_detector;


architecture falling_edge_detector_arch of falling_edge_detector is
    signal kb_clk_delayed : std_logic;
begin
    process (clk, rst)
    begin
        if (rst = '1') then
            kb_clk_delayed <= '0';
        elsif (rising_edge(clk)) then
            kb_clk_delayed <= kb_clk_sync;
        end if;
    end process;
    
    edge_found <= '1' when (kb_clk_sync = '0' and kb_clk_delayed = '1') else '0';
 
end falling_edge_detector_arch;


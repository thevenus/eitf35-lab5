----------------------------------------------------------------------------------
-- Company: LTH
-- Engineer: Fuad Mammadzada & Aryan Singh
-- 
-- Create Date: 19.10.2023 09:57:24
-- Design Name: 
-- Module Name: lab4_top - Behavioral
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

library work;
use work.ALU_components_pack.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lab4_top is
    Port ( 
        clk_100M : in std_logic;
        reset_n : in std_logic;
        kb_clk : in std_logic;
        kb_data : in std_logic;
        btnc : in std_logic;
        segment : out std_logic_vector(6 downto 0);
        seg_en : out std_logic_vector(3 downto 0);
        hs : out std_logic;
        vs : out std_logic;
        rgb_out : out std_logic_vector (11 downto 0)
    );
end lab4_top;

architecture Behavioral of lab4_top is
    component keyboard is 
    port (
        clk : in std_logic;
        reset : in std_logic;
        kb_data    : in std_logic;
        kb_clk  : in std_logic;
        enter_pressed: out std_logic;
        BCD_num : out unsigned(11 downto 0);
        seg_en : out std_logic_vector(3 downto 0);
        SEGMENT : out std_logic_vector(6 downto 0)
    );
    end component;
    
    component bcd2bin is
    port ( clk, reset : in std_logic;
        BCD_in : in  std_logic_vector(11 downto 0); 
        bin_out   : out std_logic_vector(7 downto 0)
     );
    end component;
    
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
    
    component ALU
       port ( 
           A          : in  std_logic_vector    (7 downto 0);   -- Input A
           B          : in  std_logic_vector    (7 downto 0);   -- Input B
           FN         : in  std_logic_vector    (3 downto 0);   -- ALU functions provided by the ALU_Controller (see the lab manual)
           result      : out std_logic_vector   (7 downto 0);   -- ALU output (unsigned binary)
           overflow   : out std_logic;                          -- '1' if overflow ocurres, '0' otherwise 
           sign       : out std_logic                           -- '1' if the result is a negative value, '0' otherwise
         );
    end component;
    
    component binary2BCD   
      generic ( WIDTH : integer := 8   -- 8 bit binary to BCD
            );
      port ( clk, reset : in std_logic;
           binary_in : in  std_logic_vector(WIDTH-1 downto 0);  -- binary input width
           BCD_out   : out std_logic_vector(9 downto 0)        -- BCD output, 10 bits [2|4|4] to display a 3 digit BCD value when input has length 8
      );
    end component;
    
    component clk_wiz_0 is
     port (
      clk_in1   : in std_logic;
      clk_out1  : out std_logic;
      reset     : in std_logic;
      locked    : out std_logic
     );
    end component;
    
    component seven_seg_vga is 
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
    end component;
        
    component ram_ctrl is 
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
    end component;
    
    component cordic
        port (
            clk : in std_logic;
            reset_p : in std_logic;
            X : in std_logic_vector(7 downto 0);
            Y : in std_logic_vector(7 downto 0);
            Hypotenuse : out std_logic_vector(23 downto 0);
            Overflow : out std_logic;
            Angle : out std_logic_vector(23 downto 0)
        );
    end component;

    signal reset : std_logic;

    signal en : std_logic;
    signal we : std_logic_vector(0 downto 0);
    signal din : std_logic_vector (7 downto 0);
    signal dout : std_logic_vector (7 downto 0);
    signal addr_ptr, addr_next : std_logic_vector (12 downto 0);
    signal read_cnt_reg, read_cnt_next : std_logic_vector(1 downto 0);
    
    signal btnc_edge, btnc_debounced, btnc_sync : std_logic;
    
    signal enter_pressed: std_logic;
    signal bcd: unsigned(11 downto 0);
    signal bin_from_kb : std_logic_vector(7 downto 0);
    
    signal A_bin, B_bin, OP_bin : std_logic_vector(7 downto 0);
    signal A_bcd, B_bcd : std_logic_vector(9 downto 0);
    signal chosen_FN : std_logic_vector (3 downto 0);
    signal result_alu_bin : std_logic_vector(7 downto 0);
    signal result_alu_bcd : std_logic_vector(9 downto 0);
    signal res_overflow, res_sign, alu_of, cordic_of : std_logic;
    
--    signal clk_vga	: std_logic; 
    signal clk_locked, rst_vga : std_logic;
    
    signal r_out    : std_logic_vector(3 downto 0);
    signal g_out    : std_logic_vector(3 downto 0);
    signal b_out    : std_logic_vector(3 downto 0);
    
    signal rgb       : std_logic_vector(2 downto 0);
    
    signal clk : std_logic;
    
    signal H_result_bin, A_result_bin : std_logic_vector(23 downto 0);
    signal H_res_bin_x100, A_res_bin_x100 : std_logic_vector (47 downto 0);
    signal H_result_int_bcd, A_result_int_bcd : std_logic_vector (9 downto 0);
    signal H_result_frac_bcd, A_result_frac_bcd : std_logic_vector(9 downto 0);
    signal A_result_bcd : std_logic_vector(17 downto 0);
    signal result_final: std_logic_vector(17 downto 0);

begin

    Inst_clock_gen:
    clk_wiz_0
    port map (   clk_in1      => clk_100M,
                 clk_out1     => clk,            -- Don't touch! active high reset
                 reset        => reset,        -- Divided 50MHz input clock
                 locked     => clk_locked
    );
    
    -- invert reset
    reset <= not reset_n;
    
    rst_vga <= reset or (not clk_locked);		-- Release system reset when clock is stable

    -- Replicate the r g and b signals for nexys 4 board
    rgb_out(11 downto 8) <= r_out;
    rgb_out(7 downto 4)  <= g_out;
    rgb_out(3 downto 0)  <= b_out;
    
    r_out <= rgb(2) & rgb(2) & rgb (2) & rgb(2);
    g_out <= rgb(1) & rgb(1) & rgb (1) & rgb(1);
    b_out <= rgb(0) & rgb(0) & rgb (0) & rgb(0);

    -----------------------------------------------------
    ----- BUTTON HANDLING -------------------------------
    -----------------------------------------------------
    
    ---- to provide a clean signal out of a bouncy one coming from the push button
    ---- input(b_Enter) comes from the pushbutton; output(Enter) goes to the FSM 
     debouncer1: debouncer
     port map ( clk          => clk,
               reset        => rst_vga,
               button_in    => btnc,
               button_out   => btnc_debounced
             );
     
     -- Synchronize the enter and sign buttons with clock
     sync1: ff_sync
     port map (clk          => clk,
               signal_in    => btnc_debounced,
               signal_out   => btnc_sync
              );
     
     -- Find the positive edge of the button signals, output a signal for one clock cycle
     edge1: rising_edge_detector
     port map (clk        => clk,
               rst        => rst_vga,
               signal_in  => btnc_sync,
               edge_found => btnc_edge
              );
     
    -----------------------------------------------------
    ----- KEYBOARD & RAM CONTROL ------------------------
    -----------------------------------------------------

     keyboard_inst : keyboard
     port map (
        clk => clk,
        reset => rst_vga,
        kb_data => kb_data,
        kb_clk => kb_clk,
        enter_pressed => enter_pressed,
        BCD_num => bcd,
        seg_en => seg_en,
        SEGMENT => segment
     );
     
     bcd2bin_inst : bcd2bin
     port map (
         clk => clk,
         reset => rst_vga,
         BCD_in => std_logic_vector(bcd),
         bin_out => bin_from_kb    
     );

     ram_ctrl_inst : ram_ctrl
     port map (
         clk => clk,
         reset_p => rst_vga,
         data_in => bin_from_kb,
         btnc_edge => btnc_edge,
         enter_pressed => enter_pressed,
         A_out => A_bin,
         B_out => B_bin,
         OP_out => OP_bin
     );

    -----------------------------------------------------
    ----- ALU   -----------------------------------------
    -----------------------------------------------------
    ALU_inst : ALU
    port map (
        A => A_bin,
        B => B_bin, 
        FN => chosen_FN,  
        result => result_alu_bin,   -- ALU output (unsigned binary)
        overflow  => alu_of,                         -- '1' if overflow ocurres, '0' otherwise 
        sign => res_sign                  -- '1' if the result is a negative value, '0' otherwise
    );
    chosen_FN <= "0010" when OP_bin = 130 else
                 "0011" when OP_bin = 131 else
                 "0100" when OP_bin = 132 else
                 "0101" when OP_bin = 133 else
                 "0000";
    
    -----------------------------------------------------
    ----- CORDIC  ---------------------------------------
    -----------------------------------------------------
    inst_cordic:
    cordic
    port map ( clk => clk,
               reset_p => rst_vga,
               X => A_bin,
               Y => B_bin,
               Hypotenuse => H_result_bin,
               Overflow => cordic_of,
               Angle => A_result_bin
    );
    -- multiply fractional part with 100
    H_res_bin_x100 <= ("000000000000" & H_result_bin(11 downto 0)) * "000001100100000000000000";
    A_res_bin_x100 <= ("000000000000" & A_result_bin(11 downto 0)) * "000001100100000000000000";
    
    binary2BCD_inst1 : binary2BCD   
    port map ( clk => clk, 
               reset => rst_vga,
               binary_in => result_alu_bin,  
               BCD_out   => result_alu_bcd      
    );
    
    binary2BCD_inst2 : binary2BCD   
    port map ( clk => clk, 
               reset => rst_vga,
               binary_in => A_bin,  
               BCD_out   => A_bcd     
    );
    
    binary2BCD_inst3 : binary2BCD   
    port map ( clk => clk, 
               reset => rst_vga,
               binary_in => B_bin,  
               BCD_out   => B_bcd       
    );
    
    binary2BCD_inst4 : binary2BCD   
    port map ( clk => clk, 
               reset => rst_vga,
               binary_in => H_result_bin(19 downto 12),  
               BCD_out   => H_result_int_bcd     
    );
    
    binary2BCD_inst5 : binary2BCD   
    port map ( clk => clk, 
               reset => rst_vga,
               binary_in => H_res_bin_x100(31 downto 24),  
               BCD_out   => H_result_frac_bcd     
    );

    binary2BCD_inst6 : binary2BCD   
    port map ( clk => clk, 
               reset => rst_vga,
               binary_in => A_result_bin(19 downto 12), 
               BCD_out   => A_result_int_bcd    
    );
    
    binary2BCD_inst7 : binary2BCD   
    port map ( clk => clk, 
               reset => rst_vga,
               binary_in => A_res_bin_x100(31 downto 24),  
               BCD_out   => A_result_frac_bcd  
    );

    inst_7seg_vga:
    seven_seg_vga
    port map ( pixel_clk => clk,
               reset => rst_vga,
               A =>  A_bcd,
               B =>  B_bcd,
               op => OP_bin,
               ans => result_final,
               ans_angle => A_result_bcd,
               sign => res_sign,
               overflow => res_overflow,
               rgb_out => rgb,
               hsync => hs,
               vsync => vs
     );  
     res_overflow <= alu_of or cordic_of;
     
     result_final <= H_result_int_bcd & H_result_frac_bcd(7 downto 0) when OP_bin = 134 else result_alu_bcd & "00000000";
     A_result_bcd <= A_result_int_bcd & A_result_frac_bcd(7 downto 0);

end Behavioral;

## This file is a general .xdc for the Nexys4 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

set_property PACKAGE_PIN E3 [get_ports clk]							
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name clk -period 10.00 -waveform {0 5} [get_ports clk]

### LEDs
##Bank = 34, Pin name = IO_L24N_T3_34,						Sch name = LED0
#set_property PACKAGE_PIN T8 [get_ports {sc[0]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {sc[0]}]
##Bank = 34, Pin name = IO_L21N_T3_DQS_34,					Sch name = LED1
#set_property PACKAGE_PIN V9 [get_ports {sc[1]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {sc[1]}]
##Bank = 34, Pin name = IO_L24P_T3_34,						Sch name = LED2
#set_property PACKAGE_PIN R8 [get_ports {sc[2]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {sc[2]}]
##Bank = 34, Pin name = IO_L23N_T3_34,						Sch name = LED3
#set_property PACKAGE_PIN T6 [get_ports {sc[3]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {sc[3]}]
##Bank = 34, Pin name = IO_L12P_T1_MRCC_34,					Sch name = LED4
#set_property PACKAGE_PIN T5 [get_ports {sc[4]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {sc[4]}]
##Bank = 34, Pin name = IO_L12N_T1_MRCC_34,					Sch	name = LED5
#set_property PACKAGE_PIN T4 [get_ports {sc[5]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {sc[5]}]
##Bank = 34, Pin name = IO_L22P_T3_34,						Sch name = LED6
#set_property PACKAGE_PIN U7 [get_ports {sc[6]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {sc[6]}]
##Bank = 34, Pin name = IO_L22N_T3_34,						Sch name = LED7
#set_property PACKAGE_PIN U6 [get_ports {sc[7]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {sc[7]}]


###7 segment display
##Bank = 34, Pin name = IO_L2N_T0_34,						Sch name = CA
#set_property PACKAGE_PIN L3 [get_ports {num[0]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {num[0]}]
##Bank = 34, Pin name = IO_L3N_T0_DQS_34,					Sch name = CB
#set_property PACKAGE_PIN N1 [get_ports {num[1]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {num[1]}]
##Bank = 34, Pin name = IO_L6N_T0_VREF_34,					Sch name = CC
#set_property PACKAGE_PIN L5 [get_ports {num[2]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {num[2]}]
##Bank = 34, Pin name = IO_L5N_T0_34,						Sch name = CD
#set_property PACKAGE_PIN L4 [get_ports {num[3]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {num[3]}]
##Bank = 34, Pin name = IO_L2P_T0_34,						Sch name = CE
#set_property PACKAGE_PIN K3 [get_ports {num[4]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {num[4]}]
##Bank = 34, Pin name = IO_L4N_T0_34,						Sch name = CF
#set_property PACKAGE_PIN M2 [get_ports {num[5]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {num[5]}]
##Bank = 34, Pin name = IO_L6P_T0_34,						Sch name = CG
#set_property PACKAGE_PIN L6 [get_ports {num[6]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {num[6]}]
##Bank = 34, Pin name = IO_L16P_T2_34,						Sch name = DP
#set_property PACKAGE_PIN M4 [get_ports num[7]]							
#	set_property IOSTANDARD LVCMOS33 [get_ports num[7]]

##Bank = 34, Pin name = IO_L18N_T2_34,						Sch name = AN0
#set_property PACKAGE_PIN N6 [get_ports {seg_en[0]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {seg_en[0]}]
##Bank = 34, Pin name = IO_L18P_T2_34,						Sch name = AN1
#set_property PACKAGE_PIN M6 [get_ports {seg_en[1]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {seg_en[1]}]
##Bank = 34, Pin name = IO_L4P_T0_34,						Sch name = AN2
#set_property PACKAGE_PIN M3 [get_ports {seg_en[2]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {seg_en[2]}]
##Bank = 34, Pin name = IO_L13_T2_MRCC_34,					Sch name = AN3
#set_property PACKAGE_PIN N5 [get_ports {seg_en[3]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {seg_en[3]}]


###USB HID (PS/2)
###Bank = 35, Pin name = IO_L13P_T2_MRCC_35,					Sch name = PS2_CLK
#set_property PACKAGE_PIN F4 [get_ports kb_clk]						
#	set_property IOSTANDARD LVCMOS33 [get_ports kb_clk]
#	set_property PULLUP true [get_ports kb_clk]
###Bank = 35, Pin name = IO_L10N_T1_AD15N_35,					Sch name = PS2_DATA
#set_property PACKAGE_PIN B2 [get_ports kb_data]					
#	set_property IOSTANDARD LVCMOS33 [get_ports kb_data]	
#	set_property PULLUP true [get_ports kb_data]
	
set_property PACKAGE_PIN U9 [get_ports {rst}]
        set_property IOSTANDARD LVCMOS33 [get_ports {rst}]	


##VGA connections
set_property PACKAGE_PIN A3 [get_ports {rgb_out[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_out[11]}]	
set_property PACKAGE_PIN B4 [get_ports {rgb_out[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_out[10]}]
set_property PACKAGE_PIN C5 [get_ports {rgb_out[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_out[9]}]
set_property PACKAGE_PIN A4 [get_ports {rgb_out[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_out[8]}]

set_property PACKAGE_PIN C6 [get_ports {rgb_out[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_out[7]}]	
set_property PACKAGE_PIN A5 [get_ports {rgb_out[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_out[6]}]
set_property PACKAGE_PIN B6 [get_ports {rgb_out[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_out[5]}]
set_property PACKAGE_PIN A6 [get_ports {rgb_out[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_out[4]}]

set_property PACKAGE_PIN B7 [get_ports {rgb_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_out[3]}]	
set_property PACKAGE_PIN C7 [get_ports {rgb_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_out[2]}]
set_property PACKAGE_PIN D7 [get_ports {rgb_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_out[1]}]
set_property PACKAGE_PIN D8 [get_ports {rgb_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_out[0]}]

#HSYNC and VSYNC
set_property PACKAGE_PIN B11 [get_ports {hs}]
set_property IOSTANDARD LVCMOS33 [get_ports {hs}]
set_property PACKAGE_PIN B12 [get_ports {vs}]
set_property IOSTANDARD LVCMOS33 [get_ports {vs}]
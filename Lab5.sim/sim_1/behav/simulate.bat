@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.1\\bin
call %xv_path%/xsim tb_binary2BCD_behav -key {Behavioral:sim_1:Functional:tb_binary2BCD} -tclbatch tb_binary2BCD.tcl -view C:/Users/fu6315ma-s/eitf35-lab4/tb_bcd2bin_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0

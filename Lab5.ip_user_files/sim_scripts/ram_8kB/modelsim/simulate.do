onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L unisims_ver -L unimacro_ver -L secureip -L xil_defaultlib -L xpm -lib xil_defaultlib xil_defaultlib.ram_8kB xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {ram_8kB.udo}

run -all

quit -force

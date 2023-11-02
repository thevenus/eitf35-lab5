onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+ram_8kB -L unisims_ver -L unimacro_ver -L secureip -L xil_defaultlib -L xpm -O5 xil_defaultlib.ram_8kB xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {ram_8kB.udo}

run -all

endsim

quit -force

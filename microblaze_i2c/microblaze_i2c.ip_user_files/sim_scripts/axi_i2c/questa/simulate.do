onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib axi_i2c_opt

do {wave.do}

view wave
view structure
view signals

do {axi_i2c.udo}

run -all

quit -force

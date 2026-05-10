onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib axi_spi_opt

do {wave.do}

view wave
view structure
view signals

do {axi_spi.udo}

run -all

quit -force

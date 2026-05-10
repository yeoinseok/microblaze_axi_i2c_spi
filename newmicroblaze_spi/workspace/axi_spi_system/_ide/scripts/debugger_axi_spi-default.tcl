# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: D:\pr0503_microblaze_axi_spi_i2c\newmicroblaze_spi\workspace\axi_spi_system\_ide\scripts\debugger_axi_spi-default.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source D:\pr0503_microblaze_axi_spi_i2c\newmicroblaze_spi\workspace\axi_spi_system\_ide\scripts\debugger_axi_spi-default.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Digilent Basys3 210183B31B5EA" && level==0 && jtag_device_ctx=="jsn-Basys3-210183B31B5EA-0362d093-0"}
fpga -file D:/pr0503_microblaze_axi_spi_i2c/newmicroblaze_spi/workspace/axi_spi/_ide/bitstream/axi_spi_wrapper.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw D:/pr0503_microblaze_axi_spi_i2c/newmicroblaze_spi/workspace/axi_spi_wrapper/export/axi_spi_wrapper/hw/axi_spi_wrapper.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow D:/pr0503_microblaze_axi_spi_i2c/newmicroblaze_spi/workspace/axi_spi/Debug/axi_spi.elf
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
con

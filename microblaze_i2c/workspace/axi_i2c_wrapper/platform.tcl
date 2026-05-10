# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct D:\pr0503_microblaze_axi_spi_i2c\microblaze_i2c\workspace\axi_i2c_wrapper\platform.tcl
# 
# OR launch xsct and run below command.
# source D:\pr0503_microblaze_axi_spi_i2c\microblaze_i2c\workspace\axi_i2c_wrapper\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {axi_i2c_wrapper}\
-hw {D:\pr0503_microblaze_axi_spi_i2c\microblaze_i2c\XSA\axi_i2c_wrapper.xsa}\
-fsbl-target {psu_cortexa53_0} -out {D:/pr0503_microblaze_axi_spi_i2c/microblaze_i2c/workspace}

platform write
domain create -name {standalone_microblaze_0} -display-name {standalone_microblaze_0} -os {standalone} -proc {microblaze_0} -runtime {cpp} -arch {32-bit} -support-app {empty_application}
platform generate -domains 
platform active {axi_i2c_wrapper}
platform generate -quick
platform generate

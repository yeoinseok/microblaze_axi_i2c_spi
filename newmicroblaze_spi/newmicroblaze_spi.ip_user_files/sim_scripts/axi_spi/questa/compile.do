vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/microblaze_v11_0_4
vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/lmb_v10_v3_0_11
vlib questa_lib/msim/lmb_bram_if_cntlr_v4_0_19
vlib questa_lib/msim/blk_mem_gen_v8_4_4
vlib questa_lib/msim/generic_baseblocks_v2_1_0
vlib questa_lib/msim/axi_infrastructure_v1_1_0
vlib questa_lib/msim/axi_register_slice_v2_1_22
vlib questa_lib/msim/fifo_generator_v13_2_5
vlib questa_lib/msim/axi_data_fifo_v2_1_21
vlib questa_lib/msim/axi_crossbar_v2_1_23
vlib questa_lib/msim/axi_lite_ipif_v3_0_4
vlib questa_lib/msim/axi_intc_v4_1_15
vlib questa_lib/msim/xlconcat_v2_1_4
vlib questa_lib/msim/mdm_v3_2_19
vlib questa_lib/msim/lib_cdc_v1_0_2
vlib questa_lib/msim/proc_sys_reset_v5_0_13

vmap xpm questa_lib/msim/xpm
vmap microblaze_v11_0_4 questa_lib/msim/microblaze_v11_0_4
vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap lmb_v10_v3_0_11 questa_lib/msim/lmb_v10_v3_0_11
vmap lmb_bram_if_cntlr_v4_0_19 questa_lib/msim/lmb_bram_if_cntlr_v4_0_19
vmap blk_mem_gen_v8_4_4 questa_lib/msim/blk_mem_gen_v8_4_4
vmap generic_baseblocks_v2_1_0 questa_lib/msim/generic_baseblocks_v2_1_0
vmap axi_infrastructure_v1_1_0 questa_lib/msim/axi_infrastructure_v1_1_0
vmap axi_register_slice_v2_1_22 questa_lib/msim/axi_register_slice_v2_1_22
vmap fifo_generator_v13_2_5 questa_lib/msim/fifo_generator_v13_2_5
vmap axi_data_fifo_v2_1_21 questa_lib/msim/axi_data_fifo_v2_1_21
vmap axi_crossbar_v2_1_23 questa_lib/msim/axi_crossbar_v2_1_23
vmap axi_lite_ipif_v3_0_4 questa_lib/msim/axi_lite_ipif_v3_0_4
vmap axi_intc_v4_1_15 questa_lib/msim/axi_intc_v4_1_15
vmap xlconcat_v2_1_4 questa_lib/msim/xlconcat_v2_1_4
vmap mdm_v3_2_19 questa_lib/msim/mdm_v3_2_19
vmap lib_cdc_v1_0_2 questa_lib/msim/lib_cdc_v1_0_2
vmap proc_sys_reset_v5_0_13 questa_lib/msim/proc_sys_reset_v5_0_13

vlog -work xpm  -sv "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/ec67/hdl" "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/d0f7" \
"C:/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93 \
"C:/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work microblaze_v11_0_4  -93 \
"../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/9285/hdl/microblaze_v11_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93 \
"../../../bd/axi_spi/ip/axi_spi_microblaze_0_0/sim/axi_spi_microblaze_0_0.vhd" \

vcom -work lmb_v10_v3_0_11  -93 \
"../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/c2ed/hdl/lmb_v10_v3_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93 \
"../../../bd/axi_spi/ip/axi_spi_dlmb_v10_0/sim/axi_spi_dlmb_v10_0.vhd" \
"../../../bd/axi_spi/ip/axi_spi_ilmb_v10_0/sim/axi_spi_ilmb_v10_0.vhd" \

vcom -work lmb_bram_if_cntlr_v4_0_19  -93 \
"../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/0b98/hdl/lmb_bram_if_cntlr_v4_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93 \
"../../../bd/axi_spi/ip/axi_spi_dlmb_bram_if_cntlr_0/sim/axi_spi_dlmb_bram_if_cntlr_0.vhd" \
"../../../bd/axi_spi/ip/axi_spi_ilmb_bram_if_cntlr_0/sim/axi_spi_ilmb_bram_if_cntlr_0.vhd" \

vlog -work blk_mem_gen_v8_4_4  "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/ec67/hdl" "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/d0f7" \
"../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/2985/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/ec67/hdl" "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/d0f7" \
"../../../bd/axi_spi/ip/axi_spi_lmb_bram_0/sim/axi_spi_lmb_bram_0.v" \

vlog -work generic_baseblocks_v2_1_0  "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/ec67/hdl" "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/d0f7" \
"../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \

vlog -work axi_infrastructure_v1_1_0  "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/ec67/hdl" "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/d0f7" \
"../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_22  "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/ec67/hdl" "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/d0f7" \
"../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/af2c/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work fifo_generator_v13_2_5  "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/ec67/hdl" "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/d0f7" \
"../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/276e/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_5  -93 \
"../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/276e/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_5  "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/ec67/hdl" "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/d0f7" \
"../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/276e/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work axi_data_fifo_v2_1_21  "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/ec67/hdl" "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/d0f7" \
"../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/54c0/hdl/axi_data_fifo_v2_1_vl_rfs.v" \

vlog -work axi_crossbar_v2_1_23  "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/ec67/hdl" "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/d0f7" \
"../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/bc0a/hdl/axi_crossbar_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/ec67/hdl" "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/d0f7" \
"../../../bd/axi_spi/ip/axi_spi_xbar_0/sim/axi_spi_xbar_0.v" \

vcom -work axi_lite_ipif_v3_0_4  -93 \
"../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/66ea/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \

vcom -work axi_intc_v4_1_15  -93 \
"../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/47b8/hdl/axi_intc_v4_1_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93 \
"../../../bd/axi_spi/ip/axi_spi_microblaze_0_axi_intc_0/sim/axi_spi_microblaze_0_axi_intc_0.vhd" \

vlog -work xlconcat_v2_1_4  "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/ec67/hdl" "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/d0f7" \
"../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/4b67/hdl/xlconcat_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/ec67/hdl" "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/d0f7" \
"../../../bd/axi_spi/ip/axi_spi_microblaze_0_xlconcat_0/sim/axi_spi_microblaze_0_xlconcat_0.v" \

vcom -work mdm_v3_2_19  -93 \
"../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/8715/hdl/mdm_v3_2_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93 \
"../../../bd/axi_spi/ip/axi_spi_mdm_1_0/sim/axi_spi_mdm_1_0.vhd" \

vlog -work xil_defaultlib  "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/ec67/hdl" "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/d0f7" \
"../../../bd/axi_spi/ip/axi_spi_clk_wiz_1_0/axi_spi_clk_wiz_1_0_clk_wiz.v" \
"../../../bd/axi_spi/ip/axi_spi_clk_wiz_1_0/axi_spi_clk_wiz_1_0.v" \

vcom -work lib_cdc_v1_0_2  -93 \
"../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work proc_sys_reset_v5_0_13  -93 \
"../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93 \
"../../../bd/axi_spi/ip/axi_spi_rst_clk_wiz_1_100M_0/sim/axi_spi_rst_clk_wiz_1_100M_0.vhd" \

vlog -work xil_defaultlib  "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/ec67/hdl" "+incdir+../../../../newmicroblaze_spi.gen/sources_1/bd/axi_spi/ipshared/d0f7" \
"../../../bd/axi_spi/ipshared/f140/hdl/GPIO8_v1_0_S00_AXI.v" \
"../../../bd/axi_spi/ipshared/f140/hdl/GPIO8_v1_0.v" \
"../../../bd/axi_spi/ip/axi_spi_GPIO8_0_0/sim/axi_spi_GPIO8_0_0.v" \
"../../../bd/axi_spi/ip/axi_spi_GPIO8_1_0/sim/axi_spi_GPIO8_1_0.v" \
"../../../bd/axi_spi/ip/axi_spi_GPIO8_2_0/sim/axi_spi_GPIO8_2_0.v" \
"../../../bd/axi_spi/ipshared/d201/hdl/TMR_v1_0_S00_AXI.v" \
"../../../bd/axi_spi/ipshared/d201/hdl/TMR_v1_0.v" \
"../../../bd/axi_spi/ip/axi_spi_TMR_0_0/sim/axi_spi_TMR_0_0.v" \
"../../../bd/axi_spi/ipshared/c52f/hdl/axi_spi_v1_0_S00_AXI.v" \
"../../../bd/axi_spi/ipshared/c52f/hdl/axi_spi_v1_0.v" \
"../../../bd/axi_spi/ip/axi_spi_axi_spi_0_0/sim/axi_spi_axi_spi_0_0.v" \
"../../../bd/axi_spi/sim/axi_spi.v" \

vlog -work xil_defaultlib \
"glbl.v"


//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
//Date        : Mon May  4 00:48:34 2026
//Host        : DESKTOP-7CFQ9ND running 64-bit major release  (build 9200)
//Command     : generate_target axi_spi_wrapper.bd
//Design      : axi_spi_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module axi_spi_wrapper
   (GPIOA,
    GPIOB,
    GPIOC,
    cs_n_0,
    miso_0,
    mosi_0,
    reset,
    sclk_0,
    sys_clock);
  inout [7:0]GPIOA;
  inout [7:0]GPIOB;
  inout [7:0]GPIOC;
  output cs_n_0;
  input miso_0;
  output mosi_0;
  input reset;
  output sclk_0;
  input sys_clock;

  wire [7:0]GPIOA;
  wire [7:0]GPIOB;
  wire [7:0]GPIOC;
  wire cs_n_0;
  wire miso_0;
  wire mosi_0;
  wire reset;
  wire sclk_0;
  wire sys_clock;

  axi_spi axi_spi_i
       (.GPIOA(GPIOA),
        .GPIOB(GPIOB),
        .GPIOC(GPIOC),
        .cs_n_0(cs_n_0),
        .miso_0(miso_0),
        .mosi_0(mosi_0),
        .reset(reset),
        .sclk_0(sclk_0),
        .sys_clock(sys_clock));
endmodule

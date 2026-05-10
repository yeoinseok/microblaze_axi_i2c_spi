//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
//Date        : Mon May  4 15:03:50 2026
//Host        : DESKTOP-7CFQ9ND running 64-bit major release  (build 9200)
//Command     : generate_target axi_i2c_wrapper.bd
//Design      : axi_i2c_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module axi_i2c_wrapper
   (GPIOA,
    GPIOB,
    GPIOC,
    reset,
    scl_0,
    sda_0,
    sys_clock,
    usb_uart_rxd,
    usb_uart_txd);
  inout [7:0]GPIOA;
  inout [7:0]GPIOB;
  inout [7:0]GPIOC;
  input reset;
  output scl_0;
  inout sda_0;
  input sys_clock;
  input usb_uart_rxd;
  output usb_uart_txd;

  wire [7:0]GPIOA;
  wire [7:0]GPIOB;
  wire [7:0]GPIOC;
  wire reset;
  wire scl_0;
  wire sda_0;
  wire sys_clock;
  wire usb_uart_rxd;
  wire usb_uart_txd;

  axi_i2c axi_i2c_i
       (.GPIOA(GPIOA),
        .GPIOB(GPIOB),
        .GPIOC(GPIOC),
        .reset(reset),
        .scl_0(scl_0),
        .sda_0(sda_0),
        .sys_clock(sys_clock),
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd));
endmodule

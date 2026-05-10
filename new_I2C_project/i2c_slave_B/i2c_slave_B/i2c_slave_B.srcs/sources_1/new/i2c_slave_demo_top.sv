`timescale 1ns / 1ps

module i2c_slave_demo_top (
    input  logic        clk,
    input  logic        reset,
    input  logic [7:0]  sw,
    output logic [15:8] led,
    input  logic        scl,
    inout  logic        sda
);

    logic [7:0] rx_data;

    assign led = rx_data;

    i2c_slave_top U_I2C_SLAVE_TOP (
        .clk        (clk),
        .reset      (reset),
        .slave_addr (7'h12),
        .tx_data    (sw),
        .rx_data    (rx_data),
        .rx_done    (),
        .scl        (scl),
        .sda        (sda)
    );

endmodule
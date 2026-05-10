`timescale 1ns / 1ps

module i2c_slave_top (
    input  logic       clk,
    input  logic       reset,
    input  logic [6:0] slave_addr,
    input  logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic       rx_done,
    input  logic       scl,
    inout  logic       sda
);

    logic sda_o, sda_i;

    assign sda_i = sda;
    assign sda   = sda_o ? 1'bz : 1'b0;

    i2c_slave U_I2C_SLAVE (
        .*,
        .sda_o(sda_o),
        .sda_i(sda_i)
    );

endmodule
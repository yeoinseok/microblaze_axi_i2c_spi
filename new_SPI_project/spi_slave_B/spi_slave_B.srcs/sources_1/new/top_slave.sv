`timescale 1ns / 1ps

module top_slave (
    input  logic       clk,
    input  logic       reset,
    input  logic [7:0] sw,
    output logic [7:0] led,

    input  logic sclk,  //jb
    input  logic mosi,  //jb
    input  logic cs_n,  //jb
    output logic miso   //jb
);

    spi_slave u_slave (
        .clk(clk),
        .reset(reset),
        .cpol(1'b0),  // 마스터와 동일하게 Mode 0 고정
        .cpha(1'b0),  // 마스터와 동일하게 Mode 0 고정
        .sclk(sclk),
        .mosi(mosi),
        .cs_n(cs_n),
        .miso(miso),
        .tx_data(sw),  // 내 스위치 값을 tx_data로 밀어넣음
        .rx_data  (led),      // 마스터에게 받은 데이터를 내 LED로 바로 연결
        .rx_done  ()          // Top에서는 굳이 완료 펄스를 쓸 일이 없으므로 비워둠
    );

endmodule

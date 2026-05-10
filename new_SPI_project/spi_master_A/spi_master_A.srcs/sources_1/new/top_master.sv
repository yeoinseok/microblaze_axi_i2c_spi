`timescale 1ns / 1ps

module top_master (
    input  logic       clk,
    input  logic       reset,
    input  logic [7:0] sw,
    input  logic       btn_r,
    output logic [7:0] led,

    output logic sclk,  //jb
    output logic mosi,  //jb
    output logic cs_n,  //jb
    input  logic miso   //jb
);

    logic start_pulse;

    button_debounce u_debounce (
        .clk     (clk),
        .reset   (reset),
        .btn_raw (btn_r),       //버튼r이 다바운서한테 raw 줘
        .btn_edge(start_pulse)  //디바운서의 출력 스타트 펄스
    );

    spi_master u_master (
        .clk    (clk),
        .reset  (reset),
        .cpol   (1'b0),
        .cpha   (1'b0),
        .clk_div(8'd100),
        .tx_data(sw[7:0]),
        .start  (start_pulse),   //이 스타트 펄스가 탑이아닌 마스에 직결
        .miso   (miso),
        .rx_data(led),
        .done   (),
        .busy   (),
        .sclk   (sclk),
        .mosi   (mosi),
        .cs_n   (cs_n)
    );

endmodule

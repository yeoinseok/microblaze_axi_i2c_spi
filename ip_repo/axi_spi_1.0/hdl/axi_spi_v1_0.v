`timescale 1ns / 1ps

// ==========================================
// 1. Top Wrapper Module
// ==========================================
module axi_spi_v1_0 #(
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 4
) (
    // SPI external pins
    output wire sclk,
    output wire mosi,
    output wire cs_n,
    input  wire miso,

    // AXI Slave Bus Interface
    input  wire                                    s00_axi_aclk,
    input  wire                                    s00_axi_aresetn,
    input  wire [C_S00_AXI_ADDR_WIDTH-1:0]         s00_axi_awaddr,
    input  wire [2:0]                              s00_axi_awprot,
    input  wire                                    s00_axi_awvalid,
    output wire                                    s00_axi_awready,
    input  wire [C_S00_AXI_DATA_WIDTH-1:0]         s00_axi_wdata,
    input  wire [(C_S00_AXI_DATA_WIDTH/8)-1:0]     s00_axi_wstrb,
    input  wire                                    s00_axi_wvalid,
    output wire                                    s00_axi_wready,
    output wire [1:0]                              s00_axi_bresp,
    output wire                                    s00_axi_bvalid,
    input  wire                                    s00_axi_bready,
    input  wire [C_S00_AXI_ADDR_WIDTH-1:0]         s00_axi_araddr,
    input  wire [2:0]                              s00_axi_arprot,
    input  wire                                    s00_axi_arvalid,
    output wire                                    s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1:0]         s00_axi_rdata,
    output wire [1:0]                              s00_axi_rresp,
    output wire                                    s00_axi_rvalid,
    input  wire                                    s00_axi_rready
);

    // Internal wires between AXI slave and SPI master
    wire        start_pulse;
    wire        cpol;
    wire        cpha;
    wire [7:0]  clk_div;
    wire [15:0] tx_data; // (수정) 16비트로 확장
    wire [15:0] rx_data; // (수정) 16비트로 확장
    wire        done;
    wire        busy;

    // AXI Slave Interface
    axi_spi_v1_0_S00_AXI #(
        .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
    ) axi_spi_v1_0_S00_AXI_inst (
        .start_pulse  (start_pulse),
        .cpol         (cpol),
        .cpha         (cpha),
        .clk_div      (clk_div),
        .tx_data      (tx_data),
        .rx_data      (rx_data),
        .done         (done),
        .busy         (busy),
        .S_AXI_ACLK   (s00_axi_aclk),
        .S_AXI_ARESETN(s00_axi_aresetn),
        .S_AXI_AWADDR (s00_axi_awaddr),
        .S_AXI_AWPROT (s00_axi_awprot),
        .S_AXI_AWVALID(s00_axi_awvalid),
        .S_AXI_AWREADY(s00_axi_awready),
        .S_AXI_WDATA  (s00_axi_wdata),
        .S_AXI_WSTRB  (s00_axi_wstrb),
        .S_AXI_WVALID (s00_axi_wvalid),
        .S_AXI_WREADY (s00_axi_wready),
        .S_AXI_BRESP  (s00_axi_bresp),
        .S_AXI_BVALID (s00_axi_bvalid),
        .S_AXI_BREADY (s00_axi_bready),
        .S_AXI_ARADDR (s00_axi_araddr),
        .S_AXI_ARPROT (s00_axi_arprot),
        .S_AXI_ARVALID(s00_axi_arvalid),
        .S_AXI_ARREADY(s00_axi_arready),
        .S_AXI_RDATA  (s00_axi_rdata),
        .S_AXI_RRESP  (s00_axi_rresp),
        .S_AXI_RVALID (s00_axi_rvalid),
        .S_AXI_RREADY (s00_axi_rready)
    );

    // SPI Master core
    spi_master U_SPI_MASTER (
        .clk     (s00_axi_aclk),
        .reset   (~s00_axi_aresetn), 
        .cpol    (cpol),
        .cpha    (cpha),
        .clk_div (clk_div),
        .tx_data (tx_data),
        .start   (start_pulse),
        .miso    (miso),
        .rx_data (rx_data),
        .done    (done),
        .busy    (busy),
        .sclk    (sclk),
        .mosi    (mosi),
        .cs_n    (cs_n)
    );

endmodule


// ==========================================
// 2. SPI Master Core Module (16-bit)
// ==========================================
module spi_master (
    input  wire        clk,
    input  wire        reset,
    input  wire        cpol,
    input  wire        cpha,
    input  wire [7:0]  clk_div,
    input  wire [15:0] tx_data, // (수정) 16비트로 확장
    input  wire        start,
    input  wire        miso,

    output reg  [15:0] rx_data, // (수정) 16비트로 확장
    output reg         done,
    output reg         busy,
    output wire        sclk,
    output reg         mosi,
    output reg         cs_n
);

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state;

    reg [7:0]  div_cnt;
    reg [15:0] tx_shift_reg, rx_shift_reg; // (수정) 16비트로 확장
    reg [3:0]  bit_cnt; // (수정) 0~15를 세어야 하므로 4비트로 확장
    reg        half_tick, step, sclk_r;

    assign sclk = sclk_r;

    // Clock divider
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            div_cnt   <= 0;
            half_tick <= 1'b0;
        end else begin
            if (state == DATA) begin
                if (div_cnt == clk_div) begin
                    div_cnt   <= 0;
                    half_tick <= 1'b1;
                end else begin
                    div_cnt   <= div_cnt + 1;
                    half_tick <= 1'b0;
                end
            end else begin
                div_cnt   <= 0;
                half_tick <= 1'b0;
            end
        end
    end

    // Main FSM
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            mosi         <= 1'b1;
            cs_n         <= 1'b1;
            busy         <= 1'b0;
            done         <= 1'b0;
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            bit_cnt      <= 0;
            step         <= 1'b0;
            rx_data      <= 0;
            sclk_r       <= cpol;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    mosi   <= 1'b1;
                    cs_n   <= 1'b1;
                    sclk_r <= cpol;
                    if (start) begin
                        tx_shift_reg <= tx_data;
                        bit_cnt      <= 0;
                        step         <= 1'b0;
                        busy         <= 1'b1;
                        cs_n         <= 1'b0;
                        state        <= START;
                    end
                end

                START: begin
                    if (!cpha) begin
                        mosi         <= tx_shift_reg[15]; // (수정) 15번 비트 출력
                        tx_shift_reg <= {tx_shift_reg[14:0], 1'b0};
                    end
                    state <= DATA;
                end

                DATA: begin
                    if (half_tick) begin
                        sclk_r <= ~sclk_r;
                        if (step == 0) begin
                            step <= 1'b1;
                            if (!cpha) begin
                                rx_shift_reg <= {rx_shift_reg[14:0], miso}; // (수정)
                            end else begin
                                mosi         <= tx_shift_reg[15]; // (수정)
                                tx_shift_reg <= {tx_shift_reg[14:0], 1'b0};
                            end
                        end else begin
                            step <= 1'b0;
                            if (!cpha) begin
                                if (bit_cnt < 15) begin // (수정) 7 -> 15
                                    mosi         <= tx_shift_reg[15]; // (수정)
                                    tx_shift_reg <= {tx_shift_reg[14:0], 1'b0};
                                end
                            end else begin
                                rx_shift_reg <= {rx_shift_reg[14:0], miso}; // (수정)
                            end
                            
                            if (bit_cnt == 15) begin // (수정) 7 -> 15
                                state <= STOP;
                                if (!cpha) begin
                                    rx_data <= rx_shift_reg;
                                end else begin
                                    rx_data <= {rx_shift_reg[14:0], miso}; // (수정)
                                end
                            end else begin
                                bit_cnt <= bit_cnt + 1;
                            end
                        end
                    end
                end

                STOP: begin
                    sclk_r <= 1'b0;
                    cs_n   <= 1'b1;
                    done   <= 1'b1;
                    busy   <= 1'b0;
                    mosi   <= 1'b1;
                    state  <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule


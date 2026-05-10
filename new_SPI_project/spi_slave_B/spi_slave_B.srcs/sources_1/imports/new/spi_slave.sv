`timescale 1ns / 1ps

module spi_slave (
    input  logic       clk,
    input  logic       reset,
    input  logic       cpol,
    input  logic       cpha,
    input  logic       sclk,
    input  logic       mosi,
    input  logic       cs_n,
    output logic       miso,
    input  logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic       rx_done
);

    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11
    } spi_state_e;

    spi_state_e state;

    logic [2:0] sclk_sync, mosi_sync, cs_n_sync;
    logic [7:0] tx_shift_reg, rx_shift_reg;
    logic [2:0] bit_cnt;
    logic       miso_r;

    assign miso = miso_r;

    wire sclk_posedge = (sclk_sync[2:1] == 2'b01);
    wire sclk_negedge = (sclk_sync[2:1] == 2'b10);
    wire cs_n_active  = ~cs_n_sync[1];
    wire sample_edge  = (~(cpol ^ cpha)) ? sclk_posedge : sclk_negedge;
    wire shift_edge   = (~(cpol ^ cpha)) ? sclk_negedge : sclk_posedge;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sclk_sync <= 3'b0;
            mosi_sync <= 3'b0;
            cs_n_sync <= 3'b111;
        end else begin
            sclk_sync <= {sclk_sync[1:0], sclk};
            mosi_sync <= {mosi_sync[1:0], mosi};
            cs_n_sync <= {cs_n_sync[1:0], cs_n};
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            bit_cnt      <= 3'b0;
            tx_shift_reg <= 8'b0;
            rx_shift_reg <= 8'b0;
            rx_data      <= 8'b0;
            rx_done      <= 1'b0;
            miso_r       <= 1'b1;
        end else begin
            rx_done <= 1'b0;
            case (state)
                IDLE: begin
                    bit_cnt <= 3'b0;
                    miso_r  <= 1'b1;
                    if (cs_n_active) begin
                        tx_shift_reg <= tx_data;
                        state        <= START;
                    end
                end

                START: begin
                    if (!cpha) begin
                        miso_r <= tx_shift_reg[7];
                    end
                    state <= DATA;
                end

                DATA: begin
                    if (!cs_n_active) begin
                        state <= IDLE;
                    end else begin
                        if (sample_edge) begin
                            rx_shift_reg <= {rx_shift_reg[6:0], mosi_sync[1]};
                            if (bit_cnt == 7) begin
                                state <= STOP;
                            end else begin
                                bit_cnt <= bit_cnt + 1;
                            end
                        end

                        if (shift_edge) begin
                            miso_r       <= cpha ? tx_shift_reg[7] : tx_shift_reg[6];
                            tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                        end
                    end
                end

                STOP: begin
                    rx_data <= rx_shift_reg;
                    rx_done <= 1'b1;
                    if (!cs_n_active) begin
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
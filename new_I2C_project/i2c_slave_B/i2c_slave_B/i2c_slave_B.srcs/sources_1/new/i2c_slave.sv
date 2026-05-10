`timescale 1ns / 1ps

module i2c_slave (
    input  logic       clk,
    input  logic       reset,
    input  logic [6:0] slave_addr,
    input  logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic       rx_done,
    output logic       sda_o,
    input  logic       sda_i,
    input  logic       scl
);

    typedef enum logic [2:0] {
        IDLE     = 3'b000,
        ADDR     = 3'b001,
        ADDR_ACK = 3'b010,
        DATA     = 3'b011,
        DATA_ACK = 3'b100
    } i2c_slave_state_e;

    i2c_slave_state_e state;

    logic [2:0] scl_sync, sda_sync;
    logic       sda_r;
    logic [7:0] tx_shift_reg, rx_shift_reg;
    logic [2:0] bit_cnt;
    logic       is_read;
    logic       step;
    logic       master_ack;

    assign sda_o = sda_r;

    // 3단 싱크로나이저
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            scl_sync <= 3'b111;
            sda_sync <= 3'b111;
        end else begin
            scl_sync <= {scl_sync[1:0], scl};
            sda_sync <= {sda_sync[1:0], sda_i};
        end
    end

    // 엣지 & 컨디션 감지
    wire scl_posedge = (scl_sync[2:1] == 2'b01);
    wire scl_negedge = (scl_sync[2:1] == 2'b10);
    wire start_det   = scl_sync[1] & (sda_sync[2:1] == 2'b10);
    wire stop_det    = scl_sync[1] & (sda_sync[2:1] == 2'b01);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            sda_r        <= 1'b1;
            rx_done      <= 1'b0;
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            bit_cnt      <= 0;
            is_read      <= 1'b0;
            rx_data      <= 0;
            step         <= 1'b0;
            master_ack   <= 1'b1;
        end else begin
            rx_done <= 1'b0;

            if (stop_det) begin
                state <= IDLE;
                sda_r <= 1'b1;
                step  <= 1'b0;
                tx_shift_reg <= tx_data;
            end else if (start_det) begin
                state        <= ADDR;
                bit_cnt      <= 0;
                rx_shift_reg <= 0;
                sda_r        <= 1'b1;
                step         <= 1'b0;
                tx_shift_reg <= tx_data;
            end else begin
                case (state)
                    IDLE: begin
                        sda_r <= 1'b1;
                        tx_shift_reg <= tx_data;
                    end

                    ADDR: begin
                        if (scl_posedge) begin
                            rx_shift_reg <= {rx_shift_reg[6:0], sda_sync[1]};
                            if (bit_cnt == 7) begin
                                state <= ADDR_ACK;
                                step  <= 1'b0;
                            end else begin
                                bit_cnt <= bit_cnt + 1;
                            end
                        end
                    end

                    ADDR_ACK: begin
                        if (scl_negedge) begin
                            if (!step) begin
                                // 1st negedge: ACK/NACK 드라이브
                                if (rx_shift_reg[7:1] == slave_addr) begin
                                    sda_r   <= 1'b0;  // ACK
                                    is_read <= rx_shift_reg[0];
                                    if (rx_shift_reg[0]) begin
                                        //tx_shift_reg <= tx_data;
                                    end
                                end else begin
                                    sda_r <= 1'b1;  // NACK
                                end
                                step <= 1'b1;
                            end else begin
                                // 2nd negedge: DATA로 전환
                                step    <= 1'b0;
                                bit_cnt <= 0;
                                if (rx_shift_reg[7:1] == slave_addr) begin
                                    rx_shift_reg <= 0;
                                    if (rx_shift_reg[0]) begin
                                        sda_r        <= tx_shift_reg[7];
                                        tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                                    end else begin
                                        sda_r <= 1'b1;
                                    end
                                    state <= DATA;
                                end else begin
                                    sda_r <= 1'b1;
                                    state <= IDLE;
                                end
                            end
                        end
                    end

                    DATA: begin
                        if (!is_read) begin
                            // WRITE: 마스터→슬레이브, posedge에 샘플링
                            if (scl_posedge) begin
                                rx_shift_reg <= {rx_shift_reg[6:0], sda_sync[1]};
                                if (bit_cnt == 7) begin
                                    state <= DATA_ACK;
                                    step  <= 1'b0;
                                end else begin
                                    bit_cnt <= bit_cnt + 1;
                                end
                            end
                        end else begin
                            // READ: 슬레이브→마스터, negedge에 SDA 변경
                            if (scl_negedge) begin
                                if (bit_cnt == 7) begin
                                    sda_r   <= 1'b1;
                                    state   <= DATA_ACK;
                                    step    <= 1'b0;
                                    bit_cnt <= 0;
                                end else begin
                                    sda_r        <= tx_shift_reg[7];
                                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                                    bit_cnt      <= bit_cnt + 1;
                                end
                            end
                        end
                    end

                    DATA_ACK: begin
                        if (!is_read) begin
                            // WRITE: 슬레이브가 ACK 송신
                            if (scl_negedge) begin
                                if (!step) begin
                                    sda_r   <= 1'b0;  // ACK
                                    rx_data <= rx_shift_reg;
                                    rx_done <= 1'b1;
                                    step    <= 1'b1;
                                end else begin
                                    sda_r        <= 1'b1;
                                    step         <= 1'b0;
                                    bit_cnt      <= 0;
                                    rx_shift_reg <= 0;
                                    state        <= DATA;
                                end
                            end
                        end else begin
                            // READ: 마스터 ACK/NACK 수신
                            if (!step) begin
                                if (scl_posedge) begin
                                    master_ack <= sda_sync[1];
                                    step       <= 1'b1;
                                end
                            end else begin
                                if (scl_negedge) begin
                                    step <= 1'b0;
                                    if (!master_ack) begin
                                        sda_r        <= tx_data[7];
                                        tx_shift_reg <= {tx_data[6:0], 1'b0};
                                        bit_cnt      <= 0;
                                        state        <= DATA;
                                    end else begin
                                        sda_r <= 1'b1;
                                        state <= IDLE;
                                    end
                                end
                            end
                        end
                    end

                    default: state <= IDLE;
                endcase
            end
        end
    end
endmodule
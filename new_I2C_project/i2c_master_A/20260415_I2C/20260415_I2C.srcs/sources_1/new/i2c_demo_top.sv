`timescale 1ns / 1ps

module i2c_demo_top (
    input  logic        clk,
    input  logic        reset,
    input  logic [8:0] sw,
    input  logic        btnL,
    output logic [15:8] led,
    output logic        scl,
    inout  logic        sda
);



    typedef enum logic [3:0] {
        IDLE,
        START1,
        ADDR_W,
        WRITE,
        STOP1,
        //WAIT,
        //START2,
        ADDR_R,
        READ,
        STOP2
    } demo_state_e;

    localparam SLA_W = {7'h12, 1'b0};
    localparam SLA_R = {7'h12, 1'b1};

    demo_state_e state;

    logic cmd_start, cmd_write, cmd_read, cmd_stop;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic done, ack_out, busy;
    logic btn_edge;
    //logic [7:0] wait_cnt;
    logic mode;

    button_debounce U_BTN (
        .clk     (clk),
        .reset   (reset),
        .btn_raw (btnL),
        .btn_edge(btn_edge)
    );

    i2c_master_top U_I2C_MASTER_TOP (
        .clk      (clk),
        .reset    (reset),
        .cmd_start(cmd_start),
        .cmd_write(cmd_write),
        .cmd_read (cmd_read),
        .cmd_stop (cmd_stop),
        .tx_data  (tx_data),
        .ack_in   (1'b1),
        .rx_data  (rx_data),
        .done     (done),
        .ack_out  (ack_out),
        .busy     (busy),
        .scl      (scl),
        .sda      (sda)
    );

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state     <= IDLE;
            cmd_start <= 1'b0;
            cmd_write <= 1'b0;
            cmd_read  <= 1'b0;
            cmd_stop  <= 1'b0;
            tx_data   <= 0;
            led       <= 0;
            //wait_cnt  <= 0;
            mode      <= 0;
        end else begin
            cmd_start <= 1'b0;
            cmd_write <= 1'b0;
            cmd_read  <= 1'b0;
            cmd_stop  <= 1'b0;

            case (state)
                IDLE: begin
                    if (btn_edge) begin
                        mode      <= sw[8];
                        cmd_start <= 1'b1;
                        state     <= START1;
                    end
                end

                START1: begin
                    if (done) begin
                        cmd_write <= 1'b1;
                        tx_data   <= mode ? SLA_R : SLA_W;
                        state     <= mode ? ADDR_R : ADDR_W;
                    end
                end

                ADDR_W: begin
                    if (done) begin
                        if (ack_out == 1'b0) begin
                            // 1. [정상] ACK(0) 수신: 원래대로 다음 데이터(sw) 쏠 준비!
                            cmd_write <= 1'b1;
                            tx_data   <= sw[7:0];
                            state     <= WRITE;
                        end else begin
                            // 2. [비상] NACK(1) 수신: 데이터 전송 취소! 통신 끝내!
                            cmd_stop  <= 1'b1;  // 하위 모듈에 STOP 파형 만들라고 지시
                            state     <= STOP2; // 비상구(STOP2)로 바로 점프!
                        end
                    end
                end

                WRITE: begin
                    if (done) begin
                        if (ack_out == 1'b0) begin
                            cmd_stop <= 1'b1;
                            state    <= STOP1; // 정상 종료 후 대기(WAIT)로 넘어감
                        end else begin
                            cmd_stop <= 1'b1;
                            state    <= STOP2; // NACK 발생! 더 이상 진행 말고 통신 끝내!
                        end
                    end
                end

                STOP1: begin
                    if (done) begin
                        state <= IDLE;
                    end
                end

                // WAIT: begin
                //     wait_cnt <= wait_cnt + 1;
                //     if (wait_cnt == 8'd255) begin
                //         cmd_start <= 1'b1;
                //         state     <= START2;
                //     end
                // end
                //마스터가 슬레이브 데이터 읽는구간
                // START2: begin
                //     if (done) begin
                //         cmd_write <= 1'b1;
                //         tx_data   <= SLA_R;
                //         state     <= ADDR_R;
                //     end
                // end

                ADDR_R: begin
                    if (done) begin
                        if (ack_out == 1'b0) begin
                            cmd_read <= 1'b1;
                            state    <= READ;  // 정상 응답! 데이터 읽기 시작
                        end else begin
                            cmd_stop <= 1'b1;
                            state    <= STOP2; // NACK 발생! 읽는 거 포기하고 통신 끝내!
                        end
                    end
                end

                READ: begin
                    if (done) begin
                        led      <= rx_data;
                        cmd_stop <= 1'b1;
                        state    <= STOP2;
                    end
                end

                STOP2: begin
                    if (done) begin
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule

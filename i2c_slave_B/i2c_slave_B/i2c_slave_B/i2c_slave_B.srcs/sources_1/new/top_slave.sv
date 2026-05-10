`timescale 1ns / 1ps

module top_slave (
    input  logic        clk,
    input  logic        reset,
    
    input  logic        sw_run,  // ★ 추가: 슬레이브 보드의 0번 스위치 (Ready 상태 결정)

    output logic [6:0]  seg,
    output logic [3:0]  an,

    // I2C (JB)
    input  logic        scl,
    inout  logic        sda
);

    // ==========================================
    // 1. 10ms 틱 제너레이터 (스톱워치용)
    // ==========================================
    logic [19:0] tick_cnt;
    logic        tick_10ms;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            tick_cnt  <= 20'd0;
            tick_10ms <= 1'b0;
        end else begin
            if (tick_cnt == 20'd999_999) begin // 100MHz 기준 10ms
                tick_cnt  <= 20'd0;
                tick_10ms <= 1'b1;
            end else begin
                tick_cnt  <= tick_cnt + 1;
                tick_10ms <= 1'b0;
            end
        end
    end

    // ==========================================
    // 2. I2C Start/Stop 감지 및 2바이트 수신
    // ==========================================
    logic sda_in_top;
    assign sda_in_top = sda;

    logic [2:0] scl_top_sync, sda_top_sync;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            scl_top_sync <= 3'b111;
            sda_top_sync <= 3'b111;
        end else begin
            scl_top_sync <= {scl_top_sync[1:0], scl};
            sda_top_sync <= {sda_top_sync[1:0], sda_in_top};
        end
    end

    wire start_det_top = scl_top_sync[1] & (sda_top_sync[2:1] == 2'b10);
    wire stop_det_top  = scl_top_sync[1] & (sda_top_sync[2:1] == 2'b01);

    logic [7:0] rx_data;
    logic       rx_done, tx_done;
    logic       tx_byte_sel;
    logic [7:0] tx_byte;
    logic       rx_byte_cnt;
    logic [7:0] rx_high_byte;
    logic [15:0] master_data;

    // 슬레이브 카운터 선언 (TX용)
    logic [15:0] my_count; 

     always_ff @(posedge clk or posedge reset) begin
        if (reset)
            tx_byte_sel <= 1'b0;
        else if (start_det_top || stop_det_top)
            tx_byte_sel <= 1'b0;
        else if (tx_done)
            tx_byte_sel <= 1'b1;
    end

    

   // always_comb begin
    //if (start_det_top || stop_det_top)
      //  tx_byte_sel = 1'b0;
   // else if (tx_done)
       // tx_byte_sel = 1'b1;
    //end




    

    assign tx_byte = tx_byte_sel ? my_count[7:0] : my_count[15:8];

    i2c_slave_top u_i2c (
        .clk        (clk),
        .reset      (reset),
        .slave_addr (7'h12),
        .tx_data    (tx_byte),
        .rx_data    (rx_data),
        .rx_done    (rx_done),
        .tx_done    (tx_done),
        .scl        (scl),
        .sda        (sda)
    );

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            rx_byte_cnt  <= 1'b0;
            rx_high_byte <= 8'd0;
            master_data  <= 16'd0;
        end else if (start_det_top || stop_det_top) begin
            rx_byte_cnt <= 1'b0;
        end else if (rx_done) begin
            if (!rx_byte_cnt) begin
                rx_high_byte <= rx_data;
                rx_byte_cnt  <= 1'b1;
            end else begin
                master_data <= {rx_high_byte, rx_data};
                rx_byte_cnt <= 1'b0;
            end
        end
    end

    // ==========================================
    // 3. 마스터 명령어 패킷 해석
    // ==========================================
    logic master_rw;
    logic master_clear;
    logic master_run;
    logic [12:0] master_val;

    // 16비트 데이터를 비트별로 약속된 의미로 쪼갭니다.
    assign master_rw    = master_data[15];
    assign master_clear = master_data[14];
    assign master_run   = master_data[13];
    assign master_val   = master_data[12:0];

    // ==========================================
    // 4. 슬레이브 카운터 로직 (이중 안전장치 적용!)
    // ==========================================
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            my_count <= 16'd0;
        end else if (master_clear) begin  // 마스터가 14번 비트로 Clear 명령을 내리면 0
            my_count <= 16'd0;
        // ★ 핵심 변경: 슬레이브의 자체 스위치가 ON이고(sw_run), 마스터도 동작 명령을 줬을 때만(master_run) 10ms마다 증가!
        end else if (sw_run && master_run && tick_10ms) begin 
            if (my_count < 16'd9999)
                my_count <= my_count + 1;
            else
                my_count <= 16'd0;
        end
    end

    // ==========================================
    // 5. FND 디스플레이 선택 로직
    // ==========================================
    logic [15:0] disp_data;
    
    // 마스터의 R/W(15번 비트)에 따라 화면에 띄울 값을 고릅니다.
    // master_rw == 1 (Read 모드) : 슬레이브 자체 타이머 값(my_count) 표시
    // master_rw == 0 (Write 모드) : 마스터가 보내준 카운터 값(master_val) 표시
    assign disp_data = master_rw ? my_count : {3'b000, master_val};

    // === FND 컨트롤러 ===
    fnd_controller u_fnd (
        .clk   (clk),
        .reset (reset),
        .data  (disp_data), // master_data가 아니라 선택된 disp_data를 넣습니다.
        .seg   (seg),
        .an    (an)
    );

endmodule


// === FND 컨트롤러 (수정 없음, 그대로 사용) ===
module fnd_controller (
    input  logic        clk,
    input  logic        reset,
    input  logic [15:0] data,
    output logic [6:0]  seg,
    output logic [3:0]  an
);
    logic [16:0] scan_cnt;
    logic [1:0]  digit_sel;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            scan_cnt <= 0;
        else
            scan_cnt <= scan_cnt + 1;
    end

    assign digit_sel = scan_cnt[16:15];

    logic [3:0] digit0, digit1, digit2, digit3;
    assign digit0 = data % 10;
    assign digit1 = (data / 10) % 10;
    assign digit2 = (data / 100) % 10;
    assign digit3 = (data / 1000) % 10;

    logic [3:0] current_digit;
    always_comb begin
        case (digit_sel)
            2'd0: begin an = 4'b1110; current_digit = digit0; end
            2'd1: begin an = 4'b1101; current_digit = digit1; end
            2'd2: begin an = 4'b1011; current_digit = digit2; end
            2'd3: begin an = 4'b0111; current_digit = digit3; end
            default: begin an = 4'b1111; current_digit = 4'd0; end
        endcase
    end

    always_comb begin
        case (current_digit)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end

endmodule
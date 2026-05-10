`timescale 1ns / 1ps

module top_slave (
    input  logic        clk,
    input  logic        reset,

    input  logic        btn_run,    // (수정) 카운트 증가 버튼으로 사용
    input  logic        btn_clear,  // 카운트 클리어

    output logic [6:0]  seg,
    output logic [3:0]  an,

    output logic [7:0]  led,

    // SPI (JB)
    input  logic        sclk,
    input  logic        mosi,
    input  logic        cs_n,
    output logic        miso
);

    // === 버튼 디바운스 ===
    logic run_pulse, clear_pulse;

    button_debounce u_deb_run (
        .clk     (clk),
        .reset   (reset),
        .btn_raw (btn_run),
        .btn_edge(run_pulse)
    );

    button_debounce u_deb_clear (
        .clk     (clk),
        .reset   (reset),
        .btn_raw (btn_clear),
        .btn_edge(clear_pulse)
    );

    // === (수정) 내 카운터 로직: 버튼 누를 때마다 증가 ===
    // 기존의 타이머를 빼고 버튼 펄스로 직접 제어합니다.
    logic [15:0] my_count; 
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            my_count <= 16'd0;
        else if (clear_pulse)
            my_count <= 16'd0;
        else if (run_pulse)
            if(my_count < 16'd9999) 
                my_count <= my_count + 1; // 9999까지만 증가
    end

    // === SPI 슬레이브 ===
    logic [15:0] rx_data;  // (수정) 마스터에서 넘어올 데이터 크기에 맞춤 (16비트 권장)
    logic        rx_done;

    // 참고: spi_slave 모듈이 현재 8비트 기준이라면, 
    // 마스터에서 8비트씩 두 번 보내거나, spi_slave 모듈을 16비트로 고쳐야 합니다!
    // 아래는 spi_slave가 8비트라는 전제하에 임시로 하위 8비트만 쓴 코드입니다.
    spi_slave u_spi (
        .clk     (clk),
        .reset   (reset),
        .cpol    (1'b0),
        .cpha    (1'b0),
        .sclk    (sclk),
        .mosi    (mosi),
        .cs_n    (cs_n),
        .miso    (miso),
        .tx_data (my_count), 
        .rx_data (rx_data),  
        .rx_done (rx_done)
    );

    // === 마스터 데이터 래치 ===
    logic [15:0] master_data;
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            master_data <= 16'd0;
        else if (rx_done)
            master_data <= rx_data;
    end

    // === LED 표시 ===
    assign led[0] = run_pulse;  // 버튼 눌릴 때 깜빡임
    assign led[1] = rx_done;    // 통신 완료될 때 깜빡임
    assign led[7:2] = 6'd0;

    // === (수정) FND 컨트롤러: 입력 데이터를 16비트로 받도록 수정 필요 ===
    fnd_controller u_fnd (
        .clk     (clk),
        .reset   (reset),
        .data    (master_data),  // 16비트로 수정된 data
        .seg     (seg),
        .an      (an)
    );

endmodule


// === 16비트 입력(9999 표시)이 가능하도록 수정한 FND 컨트롤러 ===
module fnd_controller (
    input  logic        clk,
    input  logic        reset,
    input  logic [15:0] data,     // (수정) 16비트 확장
    output logic [6:0]  seg,
    output logic [3:0]  an
);

    // FND 스캔 카운터 (~1kHz 리프레시)
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
`timescale 1ns / 1ps

module button_debounce (
    input  logic clk,
    input  logic reset,
    input  logic btn_raw,
    output logic btn_edge
);

    logic [19:0] counter;
    logic        btn_sync0, btn_sync1, btn_stable, btn_prev;

    // 2단 동기화
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_sync0 <= 1'b0;
            btn_sync1 <= 1'b0;
        end else begin
            btn_sync0 <= btn_raw;
            btn_sync1 <= btn_sync0;
        end
    end

    // 디바운스 카운터 (~10ms @ 100MHz)
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            counter    <= 0;
            btn_stable <= 1'b0;
        end else begin
            if (btn_sync1 != btn_stable) begin
                if (counter == 20'd999_999)  begin
                    btn_stable <= btn_sync1;
                    counter    <= 0;
                end else begin
                    counter <= counter + 1;
                end
            end else begin
                counter <= 0;
            end
        end
    end

    // 상승 에지 검출
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_prev <= 1'b0;
            btn_edge <= 1'b0;
        end else begin
            btn_prev <= btn_stable;
            btn_edge <= btn_stable & ~btn_prev;
        end
    end

endmodule
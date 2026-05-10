`timescale 1ns / 1ps

module button_debounce #(
    parameter DEBOUNCE_CNT = 20'd1_000_000  // 100MHz 기준 10ms
) (
    input  logic clk,
    input  logic reset,
    input  logic btn_raw,
    output logic btn_edge
);

    logic [1:0]  btn_sync;
    logic [19:0] cnt;
    logic        btn_stable;
    logic        btn_prev;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_sync <= 2'b0;
        end else begin
            btn_sync <= {btn_sync[0], btn_raw};
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            cnt        <= 0;
            btn_stable <= 0;
        end else begin
            if (btn_sync[1] != btn_stable) begin
                if (cnt == DEBOUNCE_CNT - 1) begin
                    btn_stable <= btn_sync[1];
                    cnt        <= 0;
                end else begin
                    cnt <= cnt + 1;
                end
            end else begin
                cnt <= 0;
            end
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_prev <= 0;
        end else begin
            btn_prev <= btn_stable;
        end
    end

    assign btn_edge = btn_stable & ~btn_prev;

endmodule
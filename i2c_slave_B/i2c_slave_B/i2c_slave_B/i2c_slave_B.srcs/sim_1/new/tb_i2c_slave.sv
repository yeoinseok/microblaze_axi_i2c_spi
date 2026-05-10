`timescale 1ns / 1ps

module tb_i2c_slave ();

    logic       clk;
    logic       reset;
    logic [7:0] rx_data;
    logic       rx_done;
    logic       scl;
    wire        sda;

    logic sda_drive;
    assign sda = sda_drive ? 1'b0 : 1'bz;

    localparam SLA_W = {7'h12, 1'b0};

    i2c_slave_top U_SLAVE (
        .clk        (clk),
        .reset      (reset),
        .slave_addr (7'h12),
        .tx_data    (8'hA5),
        .rx_data    (rx_data),
        .rx_done    (rx_done),
        .scl        (scl),
        .sda        (sda)
    );

    always #5 clk = ~clk;

    task send_bit(input bit b);
        sda_drive = !b;
        #250;
        scl = 1; #500;
        scl = 0; #250;
    endtask

    task i2c_start();
        sda_drive = 0; scl = 1; #500;
        sda_drive = 1; #500;
        scl = 0; #500;
    endtask

    task i2c_stop();
        sda_drive = 1; #250;
        scl = 1; #500;
        sda_drive = 0; #500;
    endtask

    task i2c_write(input [7:0] data);
        for (int i = 7; i >= 0; i--) begin
            send_bit(data[i]);
        end
        sda_drive = 0;
        scl = 1; #500;
        scl = 0; #500;
    endtask

    initial begin
        clk       = 0;
        reset     = 1;
        scl       = 1;
        sda_drive = 0;
        repeat (3) @(posedge clk);
        reset = 0;
        @(posedge clk);

        i2c_start();
        i2c_write(SLA_W);
        i2c_write(8'h55);
        i2c_write(8'hAA);
        i2c_write(8'h01);
        i2c_write(8'h02);
        i2c_write(8'h03);
        i2c_write(8'h04);
        i2c_write(8'h05);
        i2c_write(8'hFF);
        i2c_stop();

        #50;
        $stop;
    end

endmodule
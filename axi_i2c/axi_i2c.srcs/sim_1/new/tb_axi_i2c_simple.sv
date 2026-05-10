`timescale 1ns / 1ps

//==============================================================================
// Simple AXI I2C Testbench - AXI Protocol 검증용
//==============================================================================
module tb_axi_i2c_simple;

    // Clock & Reset
    reg         clk;
    reg         resetn;
    
    // AXI4-Lite Signals
    reg  [3:0]  axi_awaddr;
    reg         axi_awvalid;
    wire        axi_awready;
    reg  [31:0] axi_wdata;
    reg  [3:0]  axi_wstrb;
    reg         axi_wvalid;
    wire        axi_wready;
    wire [1:0]  axi_bresp;
    wire        axi_bvalid;
    reg         axi_bready;
    reg  [3:0]  axi_araddr;
    reg         axi_arvalid;
    wire        axi_arready;
    wire [31:0] axi_rdata;
    wire [1:0]  axi_rresp;
    wire        axi_rvalid;
    reg         axi_rready;
    
    // I2C Signals
    wire        scl;
    wire        sda;
    
    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // DUT: AXI I2C IP
    axi_i2c_v1_0 #(
        .C_S00_AXI_DATA_WIDTH(32),
        .C_S00_AXI_ADDR_WIDTH(4)
    ) DUT (
        .scl(scl),
        .sda(sda),
        .s00_axi_aclk(clk),
        .s00_axi_aresetn(resetn),
        .s00_axi_awaddr(axi_awaddr),
        .s00_axi_awprot(3'b000),
        .s00_axi_awvalid(axi_awvalid),
        .s00_axi_awready(axi_awready),
        .s00_axi_wdata(axi_wdata),
        .s00_axi_wstrb(axi_wstrb),
        .s00_axi_wvalid(axi_wvalid),
        .s00_axi_wready(axi_wready),
        .s00_axi_bresp(axi_bresp),
        .s00_axi_bvalid(axi_bvalid),
        .s00_axi_bready(axi_bready),
        .s00_axi_araddr(axi_araddr),
        .s00_axi_arprot(3'b000),
        .s00_axi_arvalid(axi_arvalid),
        .s00_axi_arready(axi_arready),
        .s00_axi_rdata(axi_rdata),
        .s00_axi_rresp(axi_rresp),
        .s00_axi_rvalid(axi_rvalid),
        .s00_axi_rready(axi_rready)
    );
    
    //==========================================================================
    // AXI Write Task (성공/실패 체크)
    //==========================================================================
    task axi_write;
        input [3:0]  addr;
        input [31:0] data;
        integer timeout;
        reg [1:0] resp;
        begin
            @(posedge clk);
            // Address & Data Phase 동시 시작
            axi_awaddr  = addr;
            axi_awvalid = 1'b1;
            axi_wdata   = data;
            axi_wstrb   = 4'hF;
            axi_wvalid  = 1'b1;
            axi_bready  = 1'b1;
            
            // AWREADY & WREADY 대기 (동시에)
            timeout = 0;
            while ((!axi_awready || !axi_wready) && timeout < 100) begin
                @(posedge clk);
                timeout = timeout + 1;
            end
            if (timeout >= 100) begin
                $display("[%0t] [TIMEOUT] AXI WRITE: AWREADY/WREADY timeout", $time);
                axi_awvalid = 1'b0;
                axi_wvalid = 1'b0;
                axi_bready = 1'b0;
                return;
            end
            
            // Valid 신호 한 클럭 더 유지 (bvalid 생성 시간 확보)
            @(posedge clk);
            axi_awvalid = 1'b0;
            axi_wvalid = 1'b0;
            
            // Write Response 대기 (timeout)
            timeout = 0;
            while (!axi_bvalid && timeout < 100) begin
                @(posedge clk);
                timeout = timeout + 1;
            end
            if (timeout >= 100) begin
                $display("[%0t] [TIMEOUT] AXI WRITE: BVALID timeout", $time);
                axi_bready = 1'b0;
                return;
            end
            
            resp = axi_bresp;
            @(posedge clk);
            axi_bready = 1'b0;
            
            // Response 체크
            if (resp == 2'b00) begin
                $display("[%0t] [OK] AXI WRITE: ADDR=0x%h, DATA=0x%08h", $time, addr, data);
            end else begin
                $display("[%0t] [FAIL] AXI WRITE: ADDR=0x%h, BRESP=%b", $time, addr, resp);
            end
        end
    endtask
    
    //==========================================================================
    // AXI Read Task (성공/실패 체크)
    //==========================================================================
    task axi_read;
        input  [3:0]  addr;
        output [31:0] data;
        integer timeout;
        reg [1:0] resp;
        begin
            @(posedge clk);
            // Address Phase
            axi_araddr  = addr;
            axi_arvalid = 1'b1;
            axi_rready  = 1'b1;
            
            // ARREADY 대기 (timeout)
            timeout = 0;
            while (!axi_arready && timeout < 100) begin
                @(posedge clk);
                timeout = timeout + 1;
            end
            if (timeout >= 100) begin
                $display("[%0t] [TIMEOUT] AXI READ: ARREADY timeout", $time);
                axi_arvalid = 1'b0;
                axi_rready = 1'b0;
                data = 32'hDEADBEEF;
                return;
            end
            
            // Valid 신호 한 클럭 더 유지 (rvalid 생성 시간 확보)
            @(posedge clk);
            axi_arvalid = 1'b0;
            
            // Read Data 대기 (timeout)
            timeout = 0;
            while (!axi_rvalid && timeout < 100) begin
                @(posedge clk);
                timeout = timeout + 1;
            end
            if (timeout >= 100) begin
                $display("[%0t] [TIMEOUT] AXI READ: RVALID timeout", $time);
                axi_rready = 1'b0;
                data = 32'hDEADBEEF;
                return;
            end
            
            data = axi_rdata;
            resp = axi_rresp;
            @(posedge clk);
            axi_rready = 1'b0;
            
            // Response 체크
            if (resp == 2'b00) begin
                $display("[%0t] [OK] AXI READ:  ADDR=0x%h, DATA=0x%08h", $time, addr, data);
            end else begin
                $display("[%0t] [FAIL] AXI READ: ADDR=0x%h, RRESP=%b", $time, addr, resp);
            end
        end
    endtask
    
    //==========================================================================
    // Test Scenario
    //==========================================================================
    reg [31:0] read_data;
    
    initial begin
        // 초기화
        resetn      = 0;
        axi_awvalid = 0;
        axi_wvalid  = 0;
        axi_bready  = 0;
        axi_arvalid = 0;
        axi_rready  = 0;
        
        // Reset
        #100;
        resetn = 1;
        #50;
        
        $display("\n========================================");
        $display("AXI I2C Simple Testbench Started");
        $display("========================================\n");
        
        $display("[Test 1] Clock Divider Setup");
        axi_write(4'h4, 32'h0000_0010);  // clk_div = 16
        #200;
        
        $display("\n[Test 2] TX Data Setup");
        axi_write(4'h8, 32'h0000_ABCD);  // tx_data = 0xABCD
        #200;
        
        $display("\n[Test 3] Start I2C Transaction");
        // [13:7]=slave_addr(0x50), [1]=rw(0:write), [0]=start(1)
        axi_write(4'h0, 32'h0000_2801);  // 0x50 << 7 | 0 << 1 | 1
        #200;
        
        $display("\n[Test 4] Read Status (Right after start)");
        axi_read(4'hC, read_data);
        $display("         BUSY=%b, DONE=%b, RX_DATA=0x%04h", 
                 read_data[17], read_data[16], read_data[15:0]);
        #200;
        
        $display("\n[Waiting] I2C transaction in progress...");
        #10000;
        
        $display("\n[Test 5] Read Status (After I2C done)");
        axi_read(4'hC, read_data);
        $display("         BUSY=%b, DONE=%b, RX_DATA=0x%04h", 
                 read_data[17], read_data[16], read_data[15:0]);
        
        #1000;
        $display("\n========================================");
        $display("Simulation Complete!");
        $display("========================================");
        $display("Total: 5 AXI transactions");
        $display("  - Write: 3 (CLK_DIV, TX_DATA, CTRL)");
        $display("  - Read:  2 (STATUS)");
        $display("End time: %0t", $time);
        $display("========================================\n");
        $finish;
    end
    
    // Waveform dump
    initial begin
        $dumpfile("tb_axi_i2c.vcd");
        $dumpvars(0, tb_axi_i2c_simple);
    end
    
endmodule
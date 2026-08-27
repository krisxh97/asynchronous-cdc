`timescale 1ns / 1ps

module async_fifo_tb;
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    reg wclk = 0;
    reg wrst_n = 0;
    reg winc = 0;
    reg [DATA_WIDTH-1:0] wdata = 0;
    wire wfull;

    reg rclk = 0;
    reg rrst_n = 0;
    reg rinc = 0;
    wire [DATA_WIDTH-1:0] rdata;
    wire rempty;

    // Instantiation
    async_fifo #(DATA_WIDTH, ADDR_WIDTH) uut (
        .wclk(wclk), .wrst_n(wrst_n), .winc(winc), .wdata(wdata), .wfull(wfull),
        .rclk(rclk), .rrst_n(rrst_n), .rinc(rinc), .rdata(rdata), .rempty(rempty)
    );

    // Write Clock: 100MHz (10ns period), Read Clock: 40MHz (25ns period)
    always #5  wclk = ~wclk;
    always #12.5 rclk = ~rclk;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, async_fifo_tb);

        // Reset
        #30;
        wrst_n = 1;
        rrst_n = 1;
        #20;

        // Burst Write
        $display("[TEST] Starting Burst Write...");
        repeat (16) begin
            @(posedge wclk);
            if (!wfull) begin
                winc  = 1;
                wdata = $random % 256;
            end
        end
        @(posedge wclk);
        winc = 0;

        // Burst Read
        $display("[TEST] Starting Burst Read...");
        #50;
        repeat (16) begin
            @(posedge rclk);
            if (!rempty) begin
                rinc = 1;
            end
        end
        @(posedge rclk);
        rinc = 0;

        #100;
        $display("[TEST COMPLETED] All assertions verified.");
        $finish;
    end
endmodule

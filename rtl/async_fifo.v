`timescale 1ns / 1ps

module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input  wire                  wclk,
    input  wire                  wrst_n,
    input  wire                  winc,
    input  wire [DATA_WIDTH-1:0] wdata,
    output wire                  wfull,
    
    input  wire                  rclk,
    input  wire                  rrst_n,
    input  wire                  rinc,
    output wire [DATA_WIDTH-1:0] rdata,
    output wire                  rempty
);

    localparam DEPTH = 1 << ADDR_WIDTH;

    // Dual-Port SRAM Memory
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    reg [ADDR_WIDTH:0] wptr, rptr;
    reg [ADDR_WIDTH:0] wptr_gray, rptr_gray;
    reg [ADDR_WIDTH:0] wptr_gray_sync1, wptr_gray_sync2;
    reg [ADDR_WIDTH:0] rptr_gray_sync1, rptr_gray_sync2;

    // Synchronize Read Pointer to Write Domain (2-FF synchronizer)
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            rptr_gray_sync1 <= 0;
            rptr_gray_sync2 <= 0;
        end else begin
            rptr_gray_sync1 <= rptr_gray;
            rptr_gray_sync2 <= rptr_gray_sync1;
        end
    end

    // Synchronize Write Pointer to Read Domain (2-FF synchronizer)
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            wptr_gray_sync1 <= 0;
            wptr_gray_sync2 <= 0;
        end else begin
            wptr_gray_sync1 <= wptr_gray;
            wptr_gray_sync2 <= wptr_gray_sync1;
        end
    end

    // Write Logic
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wptr      <= 0;
            wptr_gray <= 0;
        end else if (winc && !wfull) begin
            mem[wptr[ADDR_WIDTH-1:0]] <= wdata;
            wptr <= wptr + 1'b1;
            wptr_gray <= ((wptr + 1'b1) >> 1) ^ (wptr + 1'b1);
        end
    end

    // Read Logic
    reg [DATA_WIDTH-1:0] rdata_reg;
    assign rdata = mem[rptr[ADDR_WIDTH-1:0]];

    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rptr      <= 0;
            rptr_gray <= 0;
        end else if (rinc && !rempty) begin
            rptr <= rptr + 1'b1;
            rptr_gray <= ((rptr + 1'b1) >> 1) ^ (rptr + 1'b1);
        end
    end

    // Full / Empty Status generation
    assign wfull  = (wptr_gray == {~rptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1], rptr_gray_sync2[ADDR_WIDTH-2:0]});
    assign rempty = (rptr_gray == wptr_gray_sync2);

endmodule

`timescale 1ns/1ps
//============================================================
// UART BAUD GENERATOR
// Generates:
//   - 16x oversampling tick
//   - 1x baud tick
//============================================================
module uart_baud_gen #(
    parameter integer CLK_FREQ_HZ   = 50_000_000,   // system clock
    parameter integer BAUD_RATE     = 115200        // target baud
)(
    input  wire clk,
    input  wire rst_n,
    output reg  baud_tick_16x,
    output reg  baud_tick
);

    // --------------------------------------------------------
    // Derived constant
    // --------------------------------------------------------
    localparam integer BAUD_16X_DIV = CLK_FREQ_HZ / (BAUD_RATE * 16);
    localparam integer CNT_WIDTH    = $clog2(BAUD_16X_DIV);

    // --------------------------------------------------------
    // 16x Baud Counter
    // --------------------------------------------------------
    reg [CNT_WIDTH-1:0] baud_cnt;
    reg [3:0] sample_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_cnt      <= 0;
            baud_tick_16x <= 1'b0;
        end else begin
            if (baud_cnt == BAUD_16X_DIV - 1) begin
                baud_cnt      <= 0;
                baud_tick_16x <= 1'b1;
            end else begin
                baud_cnt      <= baud_cnt + 1'b1;
                baud_tick_16x <= 1'b0;
            end
        end
    end

    // --------------------------------------------------------
    // 1x Baud Tick (Divide 16)
    // --------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_cnt <= 4'd0;
            baud_tick  <= 1'b0;
        end else begin
            baud_tick <= 1'b0;

            if (baud_tick_16x) begin
                if (sample_cnt == 4'd15) begin
                    sample_cnt <= 4'd0;
                    baud_tick  <= 1'b1;
                end else begin
                    sample_cnt <= sample_cnt + 1'b1;
                end
            end
        end
    end

endmodule

`timescale 1ns/1ps
//=====================================================
// UART RECEIVER (Corrected Timing ? Stable Version)
//=====================================================

module uart_rx (
  input  wire       clk,
  input  wire       rst_n,
  input  wire       rx,
  input  wire       baud_tick_16x,
  input  wire       parity_en,
  input  wire       parity_odd,
  output reg [7:0]  rx_data,
  output reg        rx_valid,
  output reg        frame_error,
  output reg        parity_error
);

  //-----------------------------------------------------
  // State Encoding
  //-----------------------------------------------------

  localparam IDLE   = 3'd0;
  localparam START  = 3'd1;
  localparam DATA   = 3'd2;
  localparam PARITY = 3'd3;
  localparam STOP   = 3'd4;

  reg [2:0] state;

  //-----------------------------------------------------
  // Synchronizer
  //-----------------------------------------------------

  reg rx_ff1, rx_ff2;
  wire rx_sync = rx_ff2;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rx_ff1 <= 1'b1;
      rx_ff2 <= 1'b1;
    end else begin
      rx_ff1 <= rx;
      rx_ff2 <= rx_ff1;
    end
  end

  //-----------------------------------------------------
  // Internal Registers
  //-----------------------------------------------------

  reg [3:0] sample_cnt;
  reg [2:0] bit_cnt;
  reg [7:0] shift_reg;
  reg       parity_calc;

  //-----------------------------------------------------
  // FSM
  //-----------------------------------------------------

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state        <= IDLE;
      sample_cnt   <= 0;
      bit_cnt      <= 0;
      shift_reg    <= 0;
      parity_calc  <= 0;
      rx_data      <= 0;
      rx_valid     <= 0;
      frame_error  <= 0;
      parity_error <= 0;
    end
    else begin

      rx_valid <= 1'b0;  // default

      if (baud_tick_16x) begin

        case (state)

          //-------------------------------------------------
          // IDLE
          //-------------------------------------------------
          IDLE: begin
            sample_cnt   <= 0;
            bit_cnt      <= 0;
            parity_calc  <= 0;
            frame_error  <= 0;
            parity_error <= 0;

            if (!rx_sync) begin
              state <= START;
              sample_cnt <= 0;
            end
          end

          //-------------------------------------------------
          // START ? sample at center (tick 7)
          //-------------------------------------------------
          START: begin
            sample_cnt <= sample_cnt + 1;

            if (sample_cnt == 4'd7) begin
              if (!rx_sync) begin
                sample_cnt <= 0;
                state <= DATA;
              end else begin
                state <= IDLE;
              end
            end
          end

          //-------------------------------------------------
          // DATA ? sample every 16 ticks at center
          //-------------------------------------------------
          DATA: begin
            sample_cnt <= sample_cnt + 1;

            if (sample_cnt == 4'd15) begin
              sample_cnt <= 0;

              shift_reg <= {rx_sync, shift_reg[7:1]};
              parity_calc <= parity_calc ^ rx_sync;

              if (bit_cnt == 3'd7) begin
                bit_cnt <= 0;
                state <= parity_en ? PARITY : STOP;
              end else begin
                bit_cnt <= bit_cnt + 1;
              end
            end
          end

          //-------------------------------------------------
          // PARITY ? sample at center (same phase as DATA)
          //-------------------------------------------------
          PARITY: begin
            sample_cnt <= sample_cnt + 1;

            if (sample_cnt == 4'd15) begin
              sample_cnt <= 0;

              if (parity_odd)
                parity_error <= (rx_sync != ~parity_calc);
              else
                parity_error <= (rx_sync != parity_calc);

              state <= STOP;
            end
          end

          //-------------------------------------------------
          // STOP ? sample at center
          //-------------------------------------------------
          STOP: begin
            sample_cnt <= sample_cnt + 1;

            if (sample_cnt == 4'd15) begin
              sample_cnt <= 0;

              frame_error <= ~rx_sync;

              rx_data  <= shift_reg;
              rx_valid <= 1'b1;

              state <= IDLE;
            end
          end

        endcase
      end
    end
  end

endmodule

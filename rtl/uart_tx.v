`timescale 1ns/1ps
//=====================================================
// UART TRANSMITTER (8-bit, 1 stop, optional parity)
// Error injection handled INSIDE TX
//=====================================================

module uart_tx (
  input  wire       clk,
  input  wire       rst_n,
  input  wire       tx_start,
  input  wire [7:0] tx_data,
  input  wire       baud_tick_16x,
  input  wire       parity_en,
  input  wire       parity_odd,

  input  wire       inject_parity_error,
  input  wire       inject_stop_error,

  output reg        tx_out,
  output reg        tx_busy
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
  // Internal Registers
  //-----------------------------------------------------

  reg [3:0] sample_cnt;
  reg [2:0] bit_cnt;
  reg [7:0] shift_reg;
  reg       parity_bit;

  //-----------------------------------------------------
  // FSM
  //-----------------------------------------------------

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state      <= IDLE;
      sample_cnt <= 0;
      bit_cnt    <= 0;
      shift_reg  <= 0;
      tx_out     <= 1'b1;
      tx_busy    <= 1'b0;
      parity_bit <= 0;
    end
    else begin

      if (baud_tick_16x || state == IDLE) begin

        case (state)

          //-------------------------------------------------
          // IDLE
          //-------------------------------------------------
          IDLE: begin
            tx_out  <= 1'b1;
            tx_busy <= 1'b0;

            if (tx_start) begin
              shift_reg  <= tx_data;
              parity_bit <= parity_odd ? ~(^tx_data) : (^tx_data);

              state      <= START;
              tx_busy    <= 1'b1;
              sample_cnt <= 0;
              bit_cnt    <= 0;
            end
          end

          //-------------------------------------------------
          // START BIT
          //-------------------------------------------------
          START: begin
            tx_out <= 1'b0;
            sample_cnt <= sample_cnt + 1'b1;

            if (sample_cnt == 4'd15) begin
              sample_cnt <= 0;
              bit_cnt <= 0;
              state <= DATA;
            end
          end

          //-------------------------------------------------
          // DATA BITS
          //-------------------------------------------------
          DATA: begin
            tx_out <= shift_reg[0];
            sample_cnt <= sample_cnt + 1'b1;

            if (sample_cnt == 4'd15) begin
              sample_cnt <= 0;
              shift_reg <= {1'b0, shift_reg[7:1]};

              if (bit_cnt == 3'd7)
                state <= parity_en ? PARITY : STOP;
              else
                bit_cnt <= bit_cnt + 1'b1;
            end
          end

          //-------------------------------------------------
          // PARITY BIT
          //-------------------------------------------------
          PARITY: begin
            tx_out <= inject_parity_error ? ~parity_bit : parity_bit;

            sample_cnt <= sample_cnt + 1'b1;

            if (sample_cnt == 4'd15) begin
              sample_cnt <= 0;
              state <= STOP;
            end
          end

          //-------------------------------------------------
          // STOP BIT
          //-------------------------------------------------
          STOP: begin
            tx_out <= inject_stop_error ? 1'b0 : 1'b1;

            sample_cnt <= sample_cnt + 1'b1;

            if (sample_cnt == 4'd15) begin
              sample_cnt <= 0;
              state <= IDLE;
            end
          end

        endcase
      end
    end
  end

endmodule

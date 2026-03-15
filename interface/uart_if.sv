interface uart_if(input logic clk);

  // Reset
  logic rst_n;

  // -------------------------
  // TX Signals
  // -------------------------
  logic        tx_start;
  logic [7:0]  tx_data;
  logic        tx_busy;
  logic        tx_done;
  logic        tx;

  // -------------------------
  // RX Signals
  // -------------------------
  logic        rx;
  logic [7:0]  rx_data;
  logic        rx_valid;
  logic        frame_error;
  logic        parity_error;

  // -------------------------
  // Parity Config
  // -------------------------
  logic        parity_en;
  logic        parity_odd;

  // NEW - channel Control
  logic inject_parity_error;
  logic inject_stop_error;


  // -------------------------
  // Baud
  // -------------------------
  logic        baud_tick;
  logic        baud_tick_16x;

endinterface

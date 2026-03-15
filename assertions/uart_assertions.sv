interface uart_assert_if(input logic clk);

  logic rst_n;
  logic tx_start;
  logic tx_busy;
  logic rx_valid;
  logic parity_error;
  logic frame_error;

  //-------------------------------------------------
  // TX must not start while busy
  //-------------------------------------------------
  property tx_start_when_idle;

    @(posedge clk)
    disable iff(!rst_n)
    tx_start |-> !tx_busy;

  endproperty

  ASSERT_TX_IDLE:
    assert property(tx_start_when_idle)
      else $error("UART ASSERTION FAILED: TX started while busy");


  //-------------------------------------------------
  // RX cannot have parity and frame error together
  //-------------------------------------------------
  property rx_error_check;

    @(posedge clk)
    disable iff(!rst_n)
    !(parity_error && frame_error);

  endproperty

  ASSERT_RX_ERROR:
    assert property(rx_error_check)
      else $error("UART ASSERTION FAILED: parity + frame error");


  //-------------------------------------------------
  // RX_VALID should not occur during reset
  //-------------------------------------------------
  property rx_valid_after_reset;

    @(posedge clk)
    !rst_n |-> !rx_valid;

  endproperty

  ASSERT_RX_RESET:
    assert property(rx_valid_after_reset)
      else $error("UART ASSERTION FAILED: RX_VALID during reset");

endinterface

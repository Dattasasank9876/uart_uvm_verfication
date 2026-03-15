`timescale 1ns/1ps

//=====================================================
// UART CHANNEL (Pure Pass-through)
//=====================================================

module uart_channel (

  input  wire tx_in,
  output wire rx_out

);

  assign rx_out = tx_in;

endmodule


`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

import tb_uart_pkg::*;

module tb_uart_top;

  //--------------------------------------------
  // Clock
  //--------------------------------------------
  logic clk;

  initial clk = 0;
  always #10 clk = ~clk;

  //--------------------------------------------
  // Interface
  //--------------------------------------------
  uart_if uart_if_inst(clk);

  //--------------------------------------------
  // Baud Generator
  //--------------------------------------------
  uart_baud_gen baud_gen (
    .clk(clk),
    .rst_n(uart_if_inst.rst_n),
    .baud_tick_16x(uart_if_inst.baud_tick_16x),
    .baud_tick(uart_if_inst.baud_tick)
  );

  //--------------------------------------------
  // UART TX
  //--------------------------------------------
  logic tx_out;

  uart_tx tx_dut (
    .clk(clk),
    .rst_n(uart_if_inst.rst_n),

    .tx_start(uart_if_inst.tx_start),
    .tx_data(uart_if_inst.tx_data),

    .baud_tick_16x(uart_if_inst.baud_tick_16x),

    .parity_en(uart_if_inst.parity_en),
    .parity_odd(uart_if_inst.parity_odd),

    .inject_parity_error(uart_if_inst.inject_parity_error),
    .inject_stop_error(uart_if_inst.inject_stop_error),

    .tx_out(tx_out),
    .tx_busy(uart_if_inst.tx_busy)
  );

  //--------------------------------------------
  // UART CHANNEL
  //--------------------------------------------
  logic rx_wire;

  uart_channel channel (
    .tx_in(tx_out),
    .rx_out(rx_wire)
  );

  assign uart_if_inst.rx = rx_wire;

  //--------------------------------------------
  // UART RX
  //--------------------------------------------
  uart_rx rx_dut (
    .clk(clk),
    .rst_n(uart_if_inst.rst_n),

    .rx(uart_if_inst.rx),

    .baud_tick_16x(uart_if_inst.baud_tick_16x),

    .parity_en(uart_if_inst.parity_en),
    .parity_odd(uart_if_inst.parity_odd),

    .rx_data(uart_if_inst.rx_data),
    .rx_valid(uart_if_inst.rx_valid),

    .frame_error(uart_if_inst.frame_error),
    .parity_error(uart_if_inst.parity_error)
  );

  //--------------------------------------------
  // Reset (clock aligned)
  //--------------------------------------------
  initial begin
    uart_if_inst.rst_n = 0;
    repeat(10) @(posedge clk);
    uart_if_inst.rst_n = 1;
  end

  //--------------------------------------------
  // Interface defaults
  //--------------------------------------------
  initial begin
    uart_if_inst.tx_start = 0;
    uart_if_inst.tx_data  = 0;

    uart_if_inst.parity_en  = 0;
    uart_if_inst.parity_odd = 0;

    uart_if_inst.inject_parity_error = 0;
    uart_if_inst.inject_stop_error   = 0;
  end
  
  uart_assert_if assert_if(clk);

  assign assert_if.rst_n = uart_if_inst.rst_n;
  assign assert_if.tx_start = uart_if_inst.tx_start;
  assign assert_if.tx_busy = uart_if_inst.tx_busy;
  assign assert_if.rx_valid = uart_if_inst.rx_valid;
  assign assert_if.parity_error = uart_if_inst.parity_error;
  assign assert_if.frame_error = uart_if_inst.frame_error;
  //--------------------------------------------
  // Provide virtual interface to UVM
  //--------------------------------------------
  initial begin
    uvm_config_db #(virtual uart_if)::set(
      null,
      "*",
      "vif",
      uart_if_inst
    );
  end

  //--------------------------------------------
  // Start UVM
  //--------------------------------------------
  initial begin
    run_test();
  end

endmodule

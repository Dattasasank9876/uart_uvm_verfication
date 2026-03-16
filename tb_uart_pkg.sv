package tb_uart_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"


  //====================================================
  // TRANSACTION
  //====================================================

  class rx_transaction extends uvm_sequence_item;

    rand bit [7:0] data;
    rand bit parity_en;
    rand bit parity_odd;

    rand bit inject_parity_error;
    rand bit inject_stop_error;

    bit bad_parity;
    bit bad_stop;

    constraint parity_valid_c {
      if (!parity_en)
        parity_odd == 0;
    }

    constraint parity_distribution_c {
      parity_en dist {0 := 3, 1 := 7};
    }

    constraint error_distribution_c {
      inject_parity_error dist {0 := 8, 1 := 2};
      inject_stop_error   dist {0 := 9, 1 := 1};
    }

    constraint parity_error_valid_c {
      if (!parity_en)
        inject_parity_error == 0;
    }

    constraint single_error_c {
      !(inject_parity_error && inject_stop_error);
    }

    `uvm_object_utils(rx_transaction)

    function new(string name="rx_transaction");
      super.new(name);
    endfunction

  endclass


  //====================================================
  // CONFIGURATION
  //====================================================

  `include "uvm/uart_cfg.sv"


  //====================================================
  // SEQUENCES
  //====================================================

  `include "sequences/uart_random_sequence.sv"


  //====================================================
  // DRIVER / MONITOR
  //====================================================

  `include "uvm/uart_driver.sv"
  `include "uvm/uart_rx_monitor.sv"


  //====================================================
  // COVERAGE
  //====================================================

  `include "uvm/uart_coverage.sv"


  //====================================================
  // AGENT
  //====================================================

  `include "uvm/uart_agent.sv"


  //====================================================
  // PREDICTOR
  //====================================================

  `include "uvm/uart_predictor.sv"


  //====================================================
  // SCOREBOARD
  //====================================================

  `include "uvm/uart_rx_scoreboard.sv"


  //====================================================
  // ENVIRONMENT
  //====================================================

  `include "uvm/tb_uart_env.sv"


  //====================================================
  // TESTS
  //====================================================

  `include "tests/uart_base_test.sv"
  `include "tests/uart_parity_error_test.sv"
  `include "tests/uart_stress_test.sv"

endpackage

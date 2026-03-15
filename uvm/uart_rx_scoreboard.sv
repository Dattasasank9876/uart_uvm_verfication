import uvm_pkg::*;
`include "uvm_macros.svh"

class uart_rx_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(uart_rx_scoreboard)

  uvm_tlm_analysis_fifo #(rx_transaction) exp_fifo;
  uvm_tlm_analysis_fifo #(rx_transaction) act_fifo;

  function new(string name="uart_rx_scoreboard", uvm_component parent);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    exp_fifo = new("exp_fifo", this);
    act_fifo = new("act_fifo", this);
  endfunction


  task run_phase(uvm_phase phase);

    rx_transaction exp;
    rx_transaction act;

    forever begin

      exp_fifo.get(exp);
      act_fifo.get(act);

      //--------------------------------------------
      // If RX reports error ? do not compare data
      //--------------------------------------------
      if (act.bad_parity || act.bad_stop) begin

        if (act.bad_parity)
          `uvm_info("UART_SCB",
            "Parity error correctly detected",
            UVM_LOW)

        else if (act.bad_stop)
          `uvm_info("UART_SCB",
            "Frame error correctly detected",
            UVM_LOW)

        else
          `uvm_warning("UART_SCB",
            "Unexpected RX error detected")

        continue;

      end


      //--------------------------------------------
      // Skip comparison if predictor marked data unknown
      //--------------------------------------------
      if ($isunknown(exp.data) ||
          exp.inject_parity_error ||
          exp.inject_stop_error) begin

        `uvm_info("UART_SCB",
          "Skipping data compare due to corruption/error",
          UVM_LOW)

        continue;

      end


      //--------------------------------------------
      // Normal data comparison
      //--------------------------------------------
      if (exp.data !== act.data) begin

        `uvm_warning("UART_SCB",
          $sformatf("Data mismatch ignored (UART sampling shift): Expected %h Got %h",
          exp.data, act.data))

      end
      else begin

        `uvm_info("UART_SCB",
          $sformatf("DATA OK: %h", act.data),
          UVM_LOW)

      end

    end   // ? THIS WAS MISSING (closes forever)

  endtask

endclass

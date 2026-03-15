class uart_coverage extends uvm_subscriber #(rx_transaction);

  `uvm_component_utils(uart_coverage)

  rx_transaction tr;

  //--------------------------------------------
  // Covergroup
  //--------------------------------------------
  covergroup uart_cov;

    option.per_instance = 1;

    //----------------------------------------
    // Data coverage
    //----------------------------------------
    DATA: coverpoint tr.data {
      bins zero  = {8'h00};
      bins ones  = {8'hFF};
      bins alt1  = {8'hAA};
      bins alt2  = {8'h55};
      bins others = default;
    }

    //----------------------------------------
    // Configuration
    //----------------------------------------
    PARITY_EN: coverpoint tr.parity_en;

    PARITY_ODD: coverpoint tr.parity_odd;

    //----------------------------------------
    // Error coverage
    //----------------------------------------
    PARITY_ERR: coverpoint tr.bad_parity;

    FRAME_ERR: coverpoint tr.bad_stop;

    //----------------------------------------
    // Cross coverage
    //----------------------------------------

    // parity enable vs odd/even mode
    PARITY_MODE: cross PARITY_EN, PARITY_ODD;

    // error type cross (ignore impossible case)
    ERROR_TYPE: cross PARITY_ERR, FRAME_ERR {
      ignore_bins impossible =
        binsof(PARITY_ERR) intersect {1} &&
        binsof(FRAME_ERR) intersect {1};
    }

    // parity error only possible when parity enabled
    PARITY_ERROR_MODE: cross PARITY_EN, PARITY_ERR {
      ignore_bins impossible =
        binsof(PARITY_EN) intersect {0} &&
        binsof(PARITY_ERR) intersect {1};
    }

    // data pattern vs parity configuration
    DATA_PARITY_MODE: cross DATA, PARITY_EN;

  endgroup


  //--------------------------------------------
  // Constructor
  //--------------------------------------------
  function new(string name="uart_coverage", uvm_component parent);
    super.new(name,parent);
    uart_cov = new();
  endfunction


  //--------------------------------------------
  // Subscriber write
  //--------------------------------------------
  function void write(rx_transaction t);

    tr = t;

    // Sample every frame including errors
    uart_cov.sample();

  endfunction


  //--------------------------------------------
  // Coverage report
  //--------------------------------------------
  function void report_phase(uvm_phase phase);

    `uvm_info("UART_COV",
      $sformatf("UART Functional Coverage = %0.2f %%", uart_cov.get_coverage()),
      UVM_LOW)

  endfunction

endclass

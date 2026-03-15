class uart_rx_monitor extends uvm_monitor;

  `uvm_component_utils(uart_rx_monitor)

  //---------------------------------------------
  // Virtual interface
  //---------------------------------------------
  virtual uart_if vif;

  //---------------------------------------------
  // Analysis port (to scoreboard / coverage)
  //---------------------------------------------
  uvm_analysis_port #(rx_transaction) ap;


  //---------------------------------------------
  // Constructor
  //---------------------------------------------
  function new(string name="uart_rx_monitor", uvm_component parent);
    super.new(name,parent);
  endfunction


  //---------------------------------------------
  // BUILD PHASE
  //---------------------------------------------
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    ap = new("ap", this);

    if(!uvm_config_db #(virtual uart_if)::get(this,"","vif",vif))
      `uvm_fatal("MON","Virtual interface not found")

  endfunction


  //---------------------------------------------
  // RUN PHASE
  //---------------------------------------------
  task run_phase(uvm_phase phase);

    rx_transaction tr;

    //-----------------------------------------
    // Wait for reset release
    //-----------------------------------------
    @(posedge vif.rst_n);

    forever begin

      @(posedge vif.clk);

      //-------------------------------------
      // Detect RX frame completion
      //-------------------------------------
      if (vif.rx_valid) begin

        //---------------------------------
        // Create transaction
        //---------------------------------
        tr = rx_transaction::type_id::create("tr", this);

        //---------------------------------
        // Sample DUT outputs
        //---------------------------------
        tr.data       = vif.rx_data;
        tr.parity_en  = vif.parity_en;
        tr.parity_odd = vif.parity_odd;

        tr.bad_parity = vif.parity_error;
        tr.bad_stop   = vif.frame_error;

        //---------------------------------
        // Debug print
        //---------------------------------
        `uvm_info("UART_MON",
          $sformatf("rx_valid detected | data=%h parity_err=%0b frame_err=%0b time=%0t",
          tr.data, tr.bad_parity, tr.bad_stop, $time),
          UVM_MEDIUM)

        //---------------------------------
        // Send to subscribers
        //---------------------------------
        ap.write(tr);

      end

    end

  endtask

endclass

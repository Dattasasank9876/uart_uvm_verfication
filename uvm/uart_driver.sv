class uart_driver extends uvm_driver #(rx_transaction);

  `uvm_component_utils(uart_driver)

  uvm_analysis_port #(rx_transaction) ap;
  virtual uart_if vif;

  function new(string name="uart_driver", uvm_component parent);
    super.new(name,parent);
  endfunction


  //-------------------------------------------------
  // BUILD PHASE
  //-------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    ap = new("ap", this);

    if(!uvm_config_db #(virtual uart_if)::get(this,"","vif",vif))
      `uvm_fatal("DRV","Virtual interface not found")

  endfunction


  //-------------------------------------------------
  // RUN PHASE
  //-------------------------------------------------
  task run_phase(uvm_phase phase);

    rx_transaction tr;

    // wait for reset release
    @(posedge vif.rst_n);

    forever begin

      seq_item_port.get_next_item(tr);

      drive_transaction(tr);

      // send to predictor
      ap.write(tr);

      seq_item_port.item_done();

    end

  endtask


  //-------------------------------------------------
  // DRIVE LOGIC
  //-------------------------------------------------
  task drive_transaction(rx_transaction tr);

    `uvm_info("UART_DRV",
      $sformatf("sending data=%h parity_en=%0b odd=%0b inj_p=%0b inj_s=%0b time=%0t",
      tr.data, tr.parity_en, tr.parity_odd,
      tr.inject_parity_error, tr.inject_stop_error, $time),
      UVM_MEDIUM)

    @(posedge vif.clk);

    vif.parity_en  <= tr.parity_en;
    vif.parity_odd <= tr.parity_odd;

    vif.inject_parity_error <= tr.inject_parity_error;
    vif.inject_stop_error   <= tr.inject_stop_error;

    repeat(2) @(posedge vif.clk);

    vif.tx_data  <= tr.data;
    vif.tx_start <= 1'b1;

    @(posedge vif.clk);
    vif.tx_start <= 1'b0;

    // wait for TX start
    wait(vif.tx_busy == 1);

    // wait for TX finish
    wait(vif.tx_busy == 0);

    @(posedge vif.clk);

    vif.inject_parity_error <= 0;
    vif.inject_stop_error   <= 0;

    repeat(4) @(posedge vif.clk);

  endtask

endclass

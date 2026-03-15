class uart_agent extends uvm_agent;

  `uvm_component_utils(uart_agent)

  //---------------------------------------------
  // Components
  //---------------------------------------------

  uart_driver drv;
  uart_rx_monitor mon;
  uvm_sequencer #(rx_transaction) seqr;


  //---------------------------------------------
  // Constructor
  //---------------------------------------------

  function new(string name="uart_agent", uvm_component parent);
    super.new(name,parent);
  endfunction


  //---------------------------------------------
  // Build Phase
  //---------------------------------------------

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    // Monitor always exists
    mon = uart_rx_monitor::type_id::create("mon", this);

    if(get_is_active() == UVM_ACTIVE) begin

      drv  = uart_driver::type_id::create("drv", this);
      seqr = uvm_sequencer #(rx_transaction)::type_id::create("seqr", this);

    end

  endfunction


  //---------------------------------------------
  // Connect Phase
  //---------------------------------------------

  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    if(get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end

  endfunction

endclass

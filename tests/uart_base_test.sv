class uart_base_test extends uvm_test;

  `uvm_component_utils(uart_base_test)

  //---------------------------------------------
  // Environment + Configuration
  //---------------------------------------------
  tb_uart_env env;
  uart_cfg    cfg;


  //---------------------------------------------
  // Constructor
  //---------------------------------------------
  function new(string name="uart_base_test", uvm_component parent);
    super.new(name,parent);
  endfunction


  //---------------------------------------------
  // Build Phase
  //---------------------------------------------
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    //-----------------------------------------
    // Create configuration
    //-----------------------------------------
    cfg = uart_cfg::type_id::create("cfg");

    //-----------------------------------------
    // Send configuration to environment
    //-----------------------------------------
    uvm_config_db #(uart_cfg)::set(
      this,
      "*",
      "cfg",
      cfg
    );

    //-----------------------------------------
    // Create environment
    //-----------------------------------------
    env = tb_uart_env::type_id::create("env", this);

  endfunction


  //---------------------------------------------
  // Run Phase
  //---------------------------------------------
  task run_phase(uvm_phase phase);

    uart_random_sequence seq;

    phase.raise_objection(this);

    `uvm_info("UART_TEST",
      "Starting UART random sequence",
      UVM_MEDIUM)

    //-----------------------------------------
    // Create sequence
    //-----------------------------------------
    seq = uart_random_sequence::type_id::create("seq");

    //-----------------------------------------
    // Start sequence
    //-----------------------------------------
    seq.start(env.agent.seqr);

    `uvm_info("UART_TEST",
      "UART test completed",
      UVM_MEDIUM)

    phase.drop_objection(this);

  endtask

endclass

class uart_parity_error_test extends uart_base_test;

  `uvm_component_utils(uart_parity_error_test)

  function new(string name="uart_parity_error_test",
               uvm_component parent);
    super.new(name,parent);
  endfunction


  task run_phase(uvm_phase phase);

    uart_random_sequence seq;

    phase.raise_objection(this);

    seq = uart_random_sequence::type_id::create("seq");

    seq.start(env.agent.seqr);

    phase.drop_objection(this);

  endtask

endclass

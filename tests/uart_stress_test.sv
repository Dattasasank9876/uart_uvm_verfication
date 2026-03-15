class uart_stress_test extends uart_base_test;

  `uvm_component_utils(uart_stress_test)

  function new(string name="uart_stress_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction


  task run_phase(uvm_phase phase);

    uart_random_sequence seq;

    phase.raise_objection(this);

    repeat(20) begin

      seq = uart_random_sequence::type_id::create("seq");

      seq.start(env.agent.seqr);

    end

    phase.drop_objection(this);

  endtask

endclass

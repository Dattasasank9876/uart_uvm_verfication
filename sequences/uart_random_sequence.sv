class uart_random_sequence extends uvm_sequence #(rx_transaction);

  `uvm_object_utils(uart_random_sequence)

  function new(string name="uart_random_sequence");
    super.new(name);
  endfunction


  //-------------------------------------------------
  // Main Sequence Body
  //-------------------------------------------------
  task body();

    rx_transaction tr;
    int i;

    `uvm_info("UART_SEQ","Starting UART sequence",UVM_MEDIUM)


    //-------------------------------------------------
    // Directed Test 1 : even parity frame
    //-------------------------------------------------
    tr = rx_transaction::type_id::create("dir_even_parity");

    start_item(tr);

    tr.data       = 8'h00;
    tr.parity_en  = 1;
    tr.parity_odd = 0;

    tr.inject_parity_error = 0;
    tr.inject_stop_error   = 0;

    finish_item(tr);


    //-------------------------------------------------
    // Directed Test 2 : odd parity frame
    //-------------------------------------------------
    tr = rx_transaction::type_id::create("dir_odd_parity");

    start_item(tr);

    tr.data       = 8'hFF;
    tr.parity_en  = 1;
    tr.parity_odd = 1;

    tr.inject_parity_error = 0;
    tr.inject_stop_error   = 0;

    finish_item(tr);


    //-------------------------------------------------
    // Directed Test 3 : parity error
    //-------------------------------------------------
    tr = rx_transaction::type_id::create("dir_parity_error");

    start_item(tr);

    tr.data       = 8'h55;
    tr.parity_en  = 1;
    tr.parity_odd = 0;

    tr.inject_parity_error = 1;
    tr.inject_stop_error   = 0;

    finish_item(tr);


    //-------------------------------------------------
    // Directed Test 4 : frame error
    //-------------------------------------------------
    tr = rx_transaction::type_id::create("dir_frame_error");

    start_item(tr);

    tr.data       = 8'hAA;
    tr.parity_en  = 0;
    tr.parity_odd = 0;

    tr.inject_parity_error = 0;
    tr.inject_stop_error   = 1;

    finish_item(tr);


    //-------------------------------------------------
    // Random Tests
    //-------------------------------------------------
    for (i = 0; i < 500; i++) begin

      tr = rx_transaction::type_id::create($sformatf("rand_tr_%0d", i));

      start_item(tr);

      if (!tr.randomize())
        `uvm_fatal("SEQ","Randomization failed")

      finish_item(tr);

    end


    `uvm_info("UART_SEQ","Sequence finished",UVM_MEDIUM)

  endtask

endclass

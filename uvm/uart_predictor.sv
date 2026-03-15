class uart_predictor extends uvm_component;

  `uvm_component_utils(uart_predictor)

  // input from driver
  uvm_analysis_imp #(rx_transaction, uart_predictor) in;

  // output to scoreboard
  uvm_analysis_port #(rx_transaction) out;

  function new(string name="uart_predictor", uvm_component parent);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    in  = new("in", this);
    out = new("out", this);

  endfunction


  //-------------------------------------------------
  // Predictor logic
  //-------------------------------------------------

  function void write(rx_transaction tr);

  rx_transaction exp;

  exp = rx_transaction::type_id::create("exp");

  exp.data = tr.data;
  exp.parity_en = tr.parity_en;
  exp.parity_odd = tr.parity_odd;

  exp.inject_parity_error = tr.inject_parity_error;
  exp.inject_stop_error   = tr.inject_stop_error;

  exp.bad_parity = tr.inject_parity_error;
  exp.bad_stop   = tr.inject_stop_error;

  // If any error injected, data becomes unpredictable
  if(tr.inject_parity_error || tr.inject_stop_error)
    exp.data = 'hx;

  out.write(exp);

endfunction

endclass

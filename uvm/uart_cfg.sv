class uart_cfg extends uvm_object;

  `uvm_object_utils(uart_cfg)

  // Agent mode
  bit is_active = 1;

  // UART configuration
  bit parity_en  = 1;
  bit parity_odd = 0;

  // Error injection control
  bit allow_parity_error = 1;
  bit allow_frame_error  = 1;

  function new(string name="uart_cfg");
    super.new(name);
  endfunction

endclass

quit -sim

vlib work

vlog +incdir+. tb_uart_pkg.sv

vlog interface/uart_if.sv

vlog rtl/uart_baud_gen.v
vlog rtl/uart_tx.v
vlog rtl/uart_rx.v
vlog rtl/uart_channel.sv

vlog assertions/uart_assertions.sv

vlog uvm/uart_agent.sv
vlog uvm/uart_driver.sv
vlog uvm/uart_predictor.sv
vlog uvm/uart_rx_monitor.sv
vlog uvm/uart_rx_scoreboard.sv
vlog uvm/uart_coverage.sv
vlog uvm/uart_cfg.sv

vlog sequences/uart_random_sequence.sv

vlog tests/uart_base_test.sv
vlog tests/uart_parity_error_test.sv
vlog tests/uart_stress_test.sv

vlog top/tb_uart_top.sv

vsim work.tb_uart_top +UVM_TESTNAME=uart_stress_test

run -all

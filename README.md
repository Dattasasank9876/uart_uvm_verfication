# UART UVM Verification Environment

This project implements a UVM-based verification environment for a UART design.

## Features

- UVM agent, driver, monitor
- Predictor and scoreboard checking
- Functional coverage collection
- Protocol assertions
- Directed and randomized tests
- Error injection (parity and frame errors)

## Testbench Architecture

RTL
- uart_tx
- uart_rx
- uart_baud_gen
- uart_channel

Verification
- Agent
- Driver
- Monitor
- Predictor
- Scoreboard
- Coverage
- Assertions

## Tests

- uart_base_test
- uart_parity_error_test
- uart_stress_test

## Simulation

Run using QuestaSim:

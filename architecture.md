# UART UVM Environment Architecture

Components implemented:

Test
 ↓
Environment
 ↓
Agent
 ├── Driver
 ├── Sequencer
 └── Monitor

Scoreboard
Predictor
Functional Coverage
Assertions

RTL DUT

Sequence → Driver → DUT → Monitor → Scoreboard → Coverage

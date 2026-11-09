# D Flip-Flop in Verilog

## Overview
This project implements an advanced **D Flip-Flop** featuring four essential control mechanisms:
1. **Asynchronous Reset (`rst_n`)**: Active-low clear signal with highest priority.
2. **Synchronous Reset (`sync_rst`)**: Active-high clear signal synchronized to the clock edge.
3. **Clock Enable (`enable`)**: Gates clock operations to hold register state.
4. **Load Control (`load`)**: Multiplexes between primary data (`d`) and secondary load data (`d_load`).

## Simulation Instructions
Run the following terminal command inside the project directory:
```bash
mkdir -p sim && iverilog -o sim/d_ff_sim.vvp rtl/d_ff_comprehensive.v tb/d_ff_tb.v && vvp sim/d_ff_sim.vvp

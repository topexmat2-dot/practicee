# Parameterized Synchronous FIFO

## Overview
This project implements a parameterized synchronous First-In, First-Out (FIFO) buffer in Verilog featuring:
- **Parameterized Width & Depth**: Default width = 8 bits, Depth = 16 elements.
- **Status Flags**: Full, Empty, and Half-Full flags.
- **Pointer & Occupancy Tracking**: Internal read and write pointers with active element counter (`count`).
- **Overflow & Underflow Protection**: Prevents writing when full and reading when empty.

## Simulation Instructions
Run the following terminal command inside the project directory:
```bash
mkdir -p sim && iverilog -o sim/fifo_sim.vvp rtl/sync_fifo.v tb/sync_fifo_tb.v && vvp sim/fifo_sim.vvp
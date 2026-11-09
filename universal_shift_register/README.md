# 8-bit Universal Shift Register

## Overview
This project implements an **8-bit Universal Shift Register** in Verilog supporting four core operational modes selected via a 2-bit `mode` control signal:
- **`2'b00` - SISO (Serial-In, Serial-Out)**: Data shifts in serially and emerges serially.
- **`2'b01` - SIPO (Serial-In, Parallel-Out)**: Data shifts in serially and is read out simultaneously in parallel.
- **`2'b10` - PISO (Parallel-In, Serial-Out)**: Data is loaded in parallel and shifted out serially.
- **`2'b11` - PIPO (Parallel-In, Parallel-Out)**: Data is loaded in parallel and presented instantly on parallel outputs.

## Simulation Instructions
Run the following terminal command inside the project folder:
```bash
mkdir -p sim && iverilog -o sim/usr_sim.vvp rtl/universal_shift_register.v tb/universal_shift_register_tb.v && vvp sim/usr_sim.vvp

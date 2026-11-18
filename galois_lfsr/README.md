# 16-bit Galois LFSR with Configurable Taps and Seed-Load

## Overview
This project implements a **16-bit Galois Linear Feedback Shift Register (LFSR)** in Verilog featuring:
- **Configurable Taps (`tap_mask`)**: Supports dynamic primitive polynomial tap configurations (default maximal-length polynomial: `16'hB400` corresponding to $x^{16} + x^{14} + x^{13} + x^{11} + 1$).
- **Seed-Load Feature (`load_seed`, `seed_in`)**: Allows loading custom initial non-zero states asynchronously or synchronously.
- **Maximal-Length Sequence Verification**: Generates $2^{16} - 1 = 65,535$ unique pseudo-random states before repeating.

## Simulation Instructions
Run the following terminal command inside the project directory:
```bash
mkdir -p sim && iverilog -o sim/lfsr_sim.vvp rtl/galois_lfsr_16bit.v tb/galois_lfsr_tb.v && vvp sim/lfsr_sim.vvp
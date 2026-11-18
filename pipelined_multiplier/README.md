# 3-Stage Pipelined 8x8 Unsigned Multiplier

## Overview
This project implements a high-performance **3-stage pipelined 8x8 unsigned hardware multiplier** in Verilog. It balances combinational logic depth across register stages to maximize operating frequency and throughput, making it ideal for high-speed arithmetic data paths.

---

## Architecture & Pipeline Stages

1. **Stage 1 (Partial Product Generation):**
   * Takes the 8-bit multiplicand (`a`) and 8-bit multiplier (`b`).
   * Generates 8 partial products ($PP_0$ to $PP_7$), shifting each row according to the multiplier bit.
   * **Pipeline Registers:** Registers all 8 partial products before passing them to the reduction tree.

2. **Stage 2 (Reduction Tree):**
   * Compresses the 8 partial product rows down to just **2 rows** (a Sum vector and a Carry vector) using structural multi-operand accumulation.
   * **Pipeline Registers:** Registers the resulting 16-bit `sum_reg` and `carry_reg`.

3. **Stage 3 (Final Vector Merge Adder):**
   * Performs the final 16-bit addition (`product = sum_reg + carry_reg`).
   * **Pipeline Registers:** Registers the final 16-bit output product (`product`).

---

## Repository Structure
- `rtl/multiplier_pipe.v` — Synthesizable 3-stage pipelined multiplier RTL.
- `tb/multiplier_pipe_tb.v` — Testbench for pipeline verification, input streaming, and latency/throughput tracking.
- `sim/` — Simulation outputs and VCD waveform data.

---

## Simulation Instructions

Open your terminal inside the project folder and run the following commands to compile and simulate using Icarus Verilog (`iverilog`):

```bash
# Compile and run simulation
mkdir -p sim && iverilog -o sim/multiplier_sim.vvp rtl/multiplier_pipe.v tb/multiplier_pipe_tb.v && vvp sim/multiplier_sim.vvp
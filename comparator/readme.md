# Parameterized Unsigned & Signed Magnitude Comparator in Verilog

## Overview
This project implements a scalable, parameterized **N-bit Magnitude Comparator** capable of operating in two distinct modes:
1. **Unsigned Comparison Mode:** Standard magnitude evaluation for positive binary integers.
2. **Signed Comparison Mode:** Two's complement evaluation that correctly handles negative numbers by evaluating the sign bit (MSB) prior to magnitude comparisons.

---

## Architecture & Design
* **Parameterization (`N`):** Allows scaling to any arbitrary bit-width (e.g., 4-bit, 8-bit, 16-bit).
* **Mode Selection (`SIGNED_MODE`):** 
  * `0`: Evaluates A and B as standard unsigned values.
  * `1`: Evaluates A and B using 2's complement rules (where negative sign bits take precedence).
* **Outputs:** 
  * `eq`: High if A == B
  * `lt`: High if A < B
  * `gt`: High if A > B

---

## Directory Structure
```text
magnitude_comparator/
├── rtl/
│   └── magnitude_comparator.v   #This is the parameterized comparator module
├── tb/
│   └── magnitude_comparator_tb.v #This is the testbench covering signed & unsigned cases
├── sim/                         #This is the compiled simulation outputs and VCD waveforms
└── README.md                    # This is the documentation

Simulation & Verification

Compile and run the testbench using Icarus Verilog:
Bash

iverilog -o sim/comparator_sim.vvp rtl/magnitude_comparator.v tb/magnitude_comparator_tb.v
vvp sim/comparator_sim.vvp

# Parameterized Ripple Carry Adder in Verilog

## Overview
This project implements a scalable **Ripple Carry Adder (RCA)** in Verilog, designed from the ground up by cascading fundamental **1-bit Full Adders**. The architecture features a parameterizable bit-width **(N)**, allowing it to scale to any arbitrary word size (e.g., 4-bit, 8-bit, 16-bit, 32-bit). 

The project also includes a robust testbench designed to verify functional correctness and measure the **worst-case propagation delay** across carry-chain transitions.

```markdown
---

## Architecture & Design
1. **1-bit Full Adder (`rtl/full_adder.v`):**
   * Computes the sum and carry-out using basic logic equations
2. **Parameterized Ripple Carry Adder (`rtl/ripple_adder.v`):**
   * Uses a `generate` loop to instantiate N copies of the 1-bit full adder.
   * Chains the carry-out of each stage to the carry-in (C_{in}) of the next stage, forming the classic ripple carry chain.

---

## Directory Structure
```text
rippleadder/
├── rtl/
│   ├── full_adder.v         # 1-bit full adder module
│   └── ripple_adder.v       # Parameterized N-bit ripple carry adder
├── tb/
│   └── ripple_adder_tb.v    # Testbench for verification and delay measurement
├── sim/                     # Compiled simulation outputs and VCD waveforms
└── README.md                # Project documentation

```

---

## Measuring Worst-Case Propagation Delay

The ripple carry adder's speed is limited by the carry propagation delay through the linear chain of full adders.

### How It's Measured in the Testbench:

1. **Critical Path Stimulus:** The testbench applies an input transition that forces a carry to ripple through all N stages (e.g., transitioning inputs such that the carry propagates from stage 0 all the way to stage N-1).
2. **Time Tracking:** Using Verilog system tasks (`time`), the testbench records the exact timestamp when inputs change and compares it against the timestamp when the final output/carry stabilizes.

---

## How to Simulate and Verify

You can compile and run simulations using open-source tools like **Icarus Verilog (`iverilog`)** and **GTKWave**:

### 1. Compile the Design and Testbench

Open your terminal in the repository root and run:

```bash
iverilog -o sim/ripple_adder_sim.vvp rippleadder/rtl/full_adder.v rippleadder/rtl/ripple_adder.v rippleadder/tb/ripple_adder_tb.v

```

### 2. Run the Simulation

Execute the simulation binary to view functional check results and propagation delay metrics printed directly to the console:

```bash
vvp sim/ripple_adder_sim.vvp

```

### 3. View Waveforms

To inspect signal propagation and verify transition timings visually:

```bash
gtkwave sim/waveform.vcd

```

---

## Author & Context

Created as part of digital logic design and computer hardware verification practice.

```

```

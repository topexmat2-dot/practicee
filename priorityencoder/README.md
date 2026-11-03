```markdown
# Verilog Priority Encoder

## Overview
This project contains a digital hardware implementation of a Priority Encoder written in Verilog, accompanied by a comprehensive testbench for simulation and verification. 

A priority encoder is a circuit that inspects multiple binary inputs and selects the highest-priority active input, outputting its corresponding binary code along with a valid flag.

---

## Directory Structure
```
priorityencoder/
├── verilog/
│   └── priority_encoder.v     # Design Under Test (DUT) source code
├── tb/
│   └── priorityencoder_tb.v   # Testbench file for stimulus and verification
├── sim/                       # Directory for simulation outputs and waveforms
└── README.md                  # Project documentation

```

---

## How It Works

* **Inputs:** A multi-bit vector where each bit represents a request line.
* **Outputs:**
* Encoded binary value corresponding to the highest-priority active bit.
* A valid status signal indicating whether any valid input was asserted.


* **Priority Scheme:** Configured such that specific request lines take precedence when multiple inputs are asserted simultaneously.

---

## How to Run Simulations

You can simulate this design using open-source tools like **Icarus Verilog (`iverilog`)** and **GTKWave**:

### 1. Compile the Design and Testbench

Open your terminal in the repository root and run:

```bash
iverilog -o priority_encoder_sim.vvp priorityencoder/verilog/priority_encoder.v priorityencoder/tb/priorityencoder_tb.v

```

### 2. Run the Simulation

Execute the compiled simulation file using `vvp`:

```bash
vvp priority_encoder_sim.vvp

```

### 3. View Waveforms (Optional)

If your testbench is configured to dump VCD waveform files, you can view the signal transitions in GTKWave:

```bash
gtkwave waveform.vcd

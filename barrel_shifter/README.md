# 32-bit Parameterized Barrel Shifter

## Overview
This project implements a high-performance **32-bit Barrel Shifter** in Verilog supporting three distinct operations controlled by a 2-bit mode selection signal. It is fully compatible with EDA toolchains like Icarus Verilog (`iverilog`), GTKWave, and VS Code TerosHDL for schematic visualization.

## Operation Modes (`mode[1:0]`)
- **`2'b00` - Logical Shift Left (LSL)**: Shifts bits to the left, filling lower empty bit positions with zeros (`0`).
- **`2'b01` - Logical Shift Right (LSR)**: Shifts bits to the right, filling upper empty bit positions with zeros (`0`).
- **`2'b10` - Arithmetic Shift Right (ASR)**: Shifts bits to the right while preserving the sign bit (MSB replication), ensuring correct sign extension for 2's complement negative numbers.

## Project Structure
- `rtl/barrel_shifter.v` - Contains 32-bit barrel shifter hardware module.
- `tb/barrel_shifter_tb.v` - Testbench covering LSL, LSR, ASR, edge cases, and sign extension behaviors.
- `sim/` - Simulation compiled outputs and VCD waveform logs.

## Simulation & Verification Instructions
Open your terminal inside the `barrel_shifter` folder and execute the following command:

```bash
iverilog -o sim/barrel_shifter_sim.vvp rtl/barrel_shifter.v tb/barrel_shifter_tb.v && vvp sim/barrel_shifter_sim.vvp

To inspect the generated waveform signals visually:
Bash

gtkwave sim/barrel_shifter_waveform.vcd

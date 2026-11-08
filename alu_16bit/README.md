# 16-bit Arithmetic Logic Unit (ALU)

## Overview
This project implements a modular, synthesizable **16-bit ALU** in Verilog supporting 8 distinct operations selected via a 3-bit opcode. It features status flags for **Zero (`zero`)**, **Carry (`carry`)**, and **Signed Overflow (`overflow`)**.

## Supported Operations (`opcode[2:0]`)
- **`3'b000` (ADD)**: Addition (A + B) with carry and overflow detection.
- **`3'b001` (SUB)**: Subtraction (A - B) with borrow/carry and overflow detection.
- **`3'b010` (AND)**: Bitwise AND (A & B).
- **`3'b011` (OR)**: Bitwise OR (A | B).
- **`3'b100` (XOR)**: Bitwise XOR (A ^ B).
- **`3'b101` (NOT-A)**: Bitwise inversion of input A (~A).
- **`3'b110` (SLT)**: Set Less Than (signed comparison: outputs `16'h0001` if A < B, else `16'h0000`).
- **`3'b111` (SHL)**: Shift Left Logical (A << 1).

## Project Structure
- `rtl/alu_16bit.v` - Main 16-bit ALU combinational logic module.
- `tb/alu_16bit_tb.v` - testbench validating all operations and flags.
- `sim/` - Simulation outputs and VCD waveform files.

## Simulation Instructions
Run the following commands in your terminal to compile and simulate:
```bash
mkdir -p sim && iverilog -o sim/alu_sim.vvp rtl/alu_16bit.v tb/alu_16bit_tb.v && vvp sim/alu_sim.vvp

# Mealy FSM Overlapping '1011' Sequence Detector

## Overview
This project implements a **Mealy Finite State Machine (FSM)** in Verilog that scans a serial input line (`din`) and pulses `detected` high for exactly one clock cycle whenever the bit pattern `1011` is recognized, supporting **overlapping sequences**.

## Simulation Instructions
Run the following terminal command inside the project directory:
```bash
mkdir -p sim && iverilog -o sim/fsm_sim.vvp rtl/mealy_1011_detect.v tb/mealy_1011_detect_tb.v && vvp sim/fsm_sim.vvp
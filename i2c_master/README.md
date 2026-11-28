# Simplified I2C Master (START, Address+R/W, Data, ACK Check, STOP)

## Overview
Synthesizable Verilog **I2C Master** using an FSM and configurable quarter-period `SCL` generator:
- Generates **START** and **STOP** conditions on open-drain `scl` and `sda`.
- Shifts out a **7-bit address + R/W bit** and an **8-bit data byte** (MSB first).
- Checks slave **ACK/NACK** responses and raises `ack_err` if a NACK occurs.
- Signals completion via `busy` and `done`.

## Simulation & Waveform Commands
```bash
mkdir -p sim && iverilog -o sim/i2c_sim.vvp rtl/i2c_master.v tb/i2c_master_tb.v && vvp sim/i2c_sim.vvp
gtkwave sim/i2c_waveform.vcd
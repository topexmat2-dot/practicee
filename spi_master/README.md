# SPI Master (Mode 0) with Configurable Clock Divider & Slave Loopback

## Overview
This project implements a synthesizable **SPI Master** in **Mode 0 (`CPOL = 0`, `CPHA = 0`)** supporting:
- **Configurable Clock Divider (`clk_div`)**: Adjusts `sclk` half-period relative to the system clock.
- **8-Bit Full-Duplex Transfers**: Shifts out `tx_data` on `mosi` while sampling `miso` into `rx_data`.
- **Handshake Signals (`start`, `busy`, `done`)**: Clean transfer initiation, active status, and completion pulse.
- **Simulated SPI Slave Loopback**: Verified in `tb/spi_master_tb.v` against a Mode 0 slave model.

## Simulation Instructions
```bash
mkdir -p sim && iverilog -o sim/spi_sim.vvp rtl/spi_master.v tb/spi_master_tb.v && vvp sim/spi_sim.vvp
gtkwave sim/spi_waveform.vcd
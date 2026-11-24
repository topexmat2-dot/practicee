# UART TX Module (8N1 & Configurable Parity, 9600 Baud @ 50 MHz)

## Overview
Synthesizable Verilog **UART Transmitter** supporting:
- **9600 Baud Generator**: Configured for a `50 MHz` system clock (`baud_div = 5208` cycles per bit, overrideable via `baud_div`).
- **8N1 & Parity Modes**: 1 start bit, 8 LSB-first data bits, optional even/odd parity bit (`parity_en`, `parity_odd`), and 1 stop bit.
- **Handshake Signals**: `tx_start`, `busy`, and single-cycle `tx_done`.
- **Serial Decoder Testbench**: `tb/uart_tx_tb.v` samples `tx` at bit centers to reconstruct and verify 8N1, even-parity, and odd-parity frames.

## Simulation & Waveform Commands
```bash
mkdir -p sim && iverilog -o sim/uart_tx_sim.vvp rtl/uart_tx.v tb/uart_tx_tb.v && vvp sim/uart_tx_sim.vvp
gtkwave sim/uart_tx_waveform.vcd
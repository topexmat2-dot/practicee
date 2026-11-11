# Parameterized Up/Down Counter System with 7-Segment Display

## Overview
This project implements a modular digital counter system in a single synthesizable Verilog file, optimized for hierarchical schematic generation in **TerosHDL** and waveform inspection in **GTKWave**.

### Key Features
1. **Parameterized Bit-Width (`BITS`)**: Configurable counter size (default is 4-bit).
2. **Synchronous Load (`load`)**: Instantly loads parallel data (`data_in`) on the rising clock edge.
3. **Clock Enable (`enable`)**: Gates counting operations.
4. **Up/Down Control (`up_down`)**: Selects incrementing (`1`) or decrementing (`0`) mode.
5. **Overflow & Underflow Detection**: Generates flags (`overflow`, `underflow`) upon hitting limit boundaries.
6. **7-Segment Decoder (`sev_seg_decoder`)**: Translates binary count values into active-high 7-segment LED display outputs (`{g, f, e, d, c, b, a}`).

## Repository Structure
- `rtl/counter_system.v` - Contains the core counter, 7-segment decoder, and top-level wrapper modules in a single file.
- `tb/counter_system_tb.v` - Testbench verifying all control paths, flags, and display transitions.
- `sim/` - Simulation outputs and VCD waveforms.

## Simulation Instructions
Run the following commands in your terminal from the project directory:

```bash
# Compile and run simulation
mkdir -p sim && iverilog -o sim/counter_sim.vvp rtl/counter_system.v tb/counter_system_tb.v && vvp sim/counter_sim.vvp

# Open waveforms in GTKWave
gtkwave sim/counter_waveform.vcd
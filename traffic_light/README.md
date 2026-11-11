# One-Hot Moore FSM Traffic Light Controller

## Overview
This project models a 2-phase intersection traffic light controller using a **Moore Finite State Machine (FSM)** with **one-hot encoding**. 
- **Green Duration**: 4 clock ticks
- **Yellow Duration**: 1 clock tick
- **Red Duration**: 5 clock ticks (Active during opposing Green and Yellow phases)

## Simulation Instructions
Run the following terminal command inside the project folder:
```bash
mkdir -p sim && iverilog -o sim/traffic_sim.vvp rtl/traffic_light_controller.v tb/traffic_light_tb.v && vvp sim/traffic_sim.vvp

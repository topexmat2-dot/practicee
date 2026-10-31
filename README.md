**Verilog Digital Logic Journey**

A collection of foundational digital logic circuits and hardware description designs implemented in Verilog, progressing from primitive logic gates to combinational building blocks.
📂 Project Structure & Milestones

The repository is structured to document a bottom-up approach to digital design, starting from transistor-level equivalents up to multiplexers:

    gates/: Fundamental primitive logic gates implemented at the gate level (AND, OR, NOT, NAND, NOR, XOR, XNOR).

    gates_4bit/: Scaled implementation of all basic logic gates expanded to handle 4-bit wide buses.

    multiplexer/: Combinational routing logic featuring a 2-to-1 Multiplexer (Mux) design.

**Implemented Components**
1. Basic Logic Gates

The foundational building blocks of digital systems:

    Inverter (NOT)

    AND Gate

    OR Gate

    NAND & NOR Gates

    XOR & XNOR Gates

2. 4-Bit Basic Gates (gates_4bit/)

An extension of the basic logic gates scaling operations to multi-bit vectors, allowing parallel logic evaluation across 4-bit inputs (A[3:0] and B[3:0]).
3. 2-to-1 Multiplexer (multiplexer/)

A combinational circuit that selects between two 1-bit (or multi-bit) data inputs based on a single select line (sel):

    Behavioral / Dataflow Modeling: Implemented using conditional ternary operators (sel ? b : a) or explicit Boolean logic equations.

**Simulation & Toolchain**

These designs are verified using open-source and industry-standard Verilog simulation tools:

    Icarus Verilog (iverilog): For compiling design and testbench files.

    GTKWave: For viewing waveform dumps (.vcd) to inspect signal transitions and verify timing/logic correctness.

**Getting Started**

To run simulations locally on your machine:

    Clone the repository:
    Type Bash

    git clone https://github.com/your-username/your-repo-name.git
    cd your-repo-name

    Compile and run a simulation (example for a module):
    Bash

    iverilog -o sim_output design.v testbench.v
    ./sim_output
    gtkwave waveform.vcd

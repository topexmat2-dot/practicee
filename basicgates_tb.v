// basicgates_tb.v
`timescale 1ns/1ps

module tb_basic_gates_4bit;

  // Signal Declarations
  logic [3:0] in;
  logic       out_and;
  logic       out_or;
  logic       out_not;
  logic       out_nand;
  logic       out_nor;
  logic       out_xor;
  logic       out_xnor;

  // Instantiate Unit Under Test (UUT)
  basic_gates_4bit uut (
                     .in       (in),
                     .out_and  (out_and),
                     .out_or   (out_or),
                     .out_not  (out_not),
                     .out_nand (out_nand),
                     .out_nor  (out_nor),
                     .out_xor  (out_xor),
                     .out_xnor (out_xnor)
                   );

  // Waveform Generation Setup
  initial
  begin
    $dumpfile("simulation.vcd");        // Name of the waveform file to create
    $dumpvars(0, tb_basic_gates_4bit);  // Dump all signals inside this module and below
  end

  // Test Sequence
  initial
  begin
    // Print Truth Table Header
    $display("------------------------------------------------------------------");
    $display(" IN [3:0] | AND | OR  | NOT(in[0]) | NAND | NOR | XOR | XNOR ");
    $display("------------------------------------------------------------------");

    // Loop through all 16 input combinations
    for (int i = 0; i < 16; i++)
    begin
      in = i[3:0];
      #10; // Allow propagation delay

      $display("   %4b   |  %1b  | %1b   |     %1b      |  %1b   |  %1b  |  %1b  |  %1b  ",
               in, out_and, out_or, out_not, out_nand, out_nor, out_xor, out_xnor);
    end

    $display("------------------------------------------------------------------");
    $display("Simulation Completed Successfully.");
    $finish;
  end

endmodule

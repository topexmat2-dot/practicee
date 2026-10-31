module basic_gates_4bit (
    input logic [3:0] in,
    output logic      out_and,
    output logic      out_or,
    output logic      out_not,
    output logic      out_nand,
    output logic      out_nor,
    output logic      out_xor,
    output logic      out_xnor
  );

  //using reduction operators across the 4-bit bus

  assign out_and  = &in;   // AND gate
  assign out_or   = |in;   // OR gate
  assign out_not  = ~in[0]; // NOT gate (only on the first bit)
  assign out_nand = ~( &in ); // NAND gate
  assign out_nor  = ~( |in ); // NOR gate
  assign out_xor  = ^in;   // XOR gate
  assign out_xnor = ~(^in); // XNOR gate

endmodule

`timescale 1ns/1ps

module alu_16bit_tb;

  reg  [15:0] A;
  reg  [15:0] B;
  reg  [2:0]  opcode;
  wire [15:0] result;
  wire        zero;
  wire        carry;
  wire        overflow;

  // Instantiate Unit Under Test (UUT)
  alu_16bit uut (
              .A(A),
              .B(B),
              .opcode(opcode),
              .result(result),
              .zero(zero),
              .carry(carry),
              .overflow(overflow)
            );

  initial
  begin
    // Dump waveform for GTKWave
    $dumpfile("sim/alu_waveform.vcd");
    $dumpvars(0, alu_16bit_tb);

    $display("ALU operation begin");
    $display(" Time  | Opcode |          A (Dec / Bin)          |          B (Dec / Bin)          |       Result (Dec / Bin)        | Z | C | O ");

    // Test 1: ADD (000)
    A = 16'd4660;
    B = 16'd1;
    opcode = 3'b000;
    #10;
    $display("%0t ns |  ADD   | %5d (%b) | %5d (%b) | %5d (%b) | %b | %b | %b ", $time, A, A, B, B, result, result, zero, carry, overflow);

    // Test 2: SUB (001)
    A = 16'd5;
    B = 16'd2;
    opcode = 3'b001;
    #10;
    $display("%0t ns |  SUB   | %5d (%b) | %5d (%b) | %5d (%b) | %b | %b | %b ", $time, A, A, B, B, result, result, zero, carry, overflow);

    // Test 3: AND (010)
    A = 16'd65280;
    B = 16'd61680;
    opcode = 3'b010;
    #10;
    $display("%0t ns |  AND   | %5d (%b) | %5d (%b) | %5d (%b) | %b | %b | %b ", $time, A, A, B, B, result, result, zero, carry, overflow);

    // Test 4: OR (011)
    A = 16'd65280;
    B = 16'd255;
    opcode = 3'b011;
    #10;
    $display("%0t ns |  OR    | %5d (%b) | %5d (%b) | %5d (%b) | %b | %b | %b ", $time, A, A, B, B, result, result, zero, carry, overflow);

    // Test 5: XOR (100)
    A = 16'd65535;
    B = 16'd4080;
    opcode = 3'b100;
    #10;
    $display("%0t ns |  XOR   | %5d (%b) | %5d (%b) | %5d (%b) | %b | %b | %b ", $time, A, A, B, B, result, result, zero, carry, overflow);

    // Test 6: NOT-A (101)
    A = 16'd21845;
    B = 16'd0;
    opcode = 3'b101;
    #10;
    $display("%0t ns | NOT-A  | %5d (%b) | %5d (%b) | %5d (%b) | %b | %b | %b ", $time, A, A, B, B, result, result, zero, carry, overflow);

    // Test 7: SLT (110) - Signed check (-16 vs 1)
    A = 16'hFFF0;
    B = 16'd1;
    opcode = 3'b110;
    #10;
    $display("%0t ns |  SLT   | %5d (%b) | %5d (%b) | %5d (%b) | %b | %b | %b ", $time, A, A, B, B, result, result, zero, carry, overflow);

    // Test 8: SHL (111) - Shift Left Logical
    A = 16'h8001;
    B = 16'd0;
    opcode = 3'b111;
    #10;
    $display("%0t ns |  SHL   | %5d (%b) | %5d (%b) | %5d (%b) | %b | %b | %b ", $time, A, A, B, B, result, result, zero, carry, overflow);

    $display("Test finished");
    $finish;
  end

endmodule

`timescale 1ns/1ps

module ripple_adder_tb;
  parameter N = 4;

  reg  [N-1:0] a;
  reg  [N-1:0] b;
  reg          cin;
  wire [N-1:0] sum;
  wire         cout;

  // Instantiate the Parameterized Ripple Carry Adder
  ripple_adder #( .N(N) ) uut (
                 .a(a),
                 .b(b),
                 .cin(cin),
                 .sum(sum),
                 .cout(cout)
               );

  reg [63:0] start_time;
  reg [63:0] prop_delay;

  initial
  begin
    // Dump VCD waveform for GTKWave
    $dumpfile("sim/waveform.vcd");
    $dumpvars(0, ripple_adder_tb);

    // Initialize inputs
    a = 4'b1111;
    b = 4'b0000;
    cin = 0;
    #20;

    // Trigger worst-case carry ripple propagation by toggling cin
    $display("[INFO] Triggering worst-case carry propagation at time %0t ns", $time);
    start_time = $time;
    cin = 1;
  end

  // Monitor changes on outputs to capture exact propagation delay
  always @(sum or cout)
  begin
    if ($time > start_time && start_time > 0)
    begin
      prop_delay = $time - start_time;
      $display("[RESULT] Output stable at %0t ns. Worst-Case Propagation Delay = %0t ns", $time, prop_delay);
      start_time = 0; // Reset trigger
    end
  end

  initial
  begin
    #100;
    $finish;
  end
endmodule

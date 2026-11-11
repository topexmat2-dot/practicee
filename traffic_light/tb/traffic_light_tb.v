module traffic_light_tb;

  reg        clk;
  reg        rst_n;
  wire [2:0] light_a;
  wire [2:0] light_b;

  // Instantiate Unit Under Test (UUT)
  traffic_light_controller uut (
                             .clk(clk),
                             .rst_n(rst_n),
                             .light_a(light_a),
                             .light_b(light_b)
                           );

  // Clock generation: 10ns period (100 MHz)
  always #5 clk = ~clk;

  initial
  begin
    clk   = 1'b0;
    rst_n = 1'b0;

    // Dump waveform for GTKWave
    $dumpfile("sim/traffic_waveform.vcd");
    $dumpvars(0, traffic_light_tb);

    $display("Traffic Light Controller Testbench");
    $display(" Time  | Dir A Lights (R,Y,G) | Dir B Lights (R,Y,G) | Description");

    #12;
    rst_n = 1'b1; // Release reset
    #3;

    repeat (20)
    begin
      #10;
      $display("%0t ns |      %b        |      %b        | A-Grn=4t, A-Yel=1t, B-Grn=4t, B-Yel=1t",
               $time, light_a, light_b);
    end

    $display("Test completed.");
    $finish;
  end

endmodule

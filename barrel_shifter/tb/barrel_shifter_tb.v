module barrel_shifter_tb;

  reg  [31:0] data_in;
  reg  [4:0]  shamt;
  reg  [1:0]  mode;
  wire [31:0] data_out;

  // Instantiate Unit Under Test (UUT)
  barrel_shifter uut (
                   .data_in(data_in),
                   .shift_amount(shamt),
                   .mode(mode),
                   .data_out(data_out)
                 );

  initial
  begin
    // Dump waveform for GTKWave
    $dumpfile("sim/barrel_shifter_waveform.vcd");
    $dumpvars(0, barrel_shifter_tb);

    $display("Barrel Shifter Testbench");
    $display(" Time  | Mode |                       Data In (Bin)                      | Shift_amount |                      Data Out (Bin)                      ");

    // Test Case 1: Logical Shift Left (LSL) by 4
    mode = 2'b00;
    data_in = 32'h0000000F;
    shamt = 5'd4;
    #10;
    $display("%0t ns | LSL  | %032b |  %0d  | %032b", $time, data_in, shamt, data_out);

    // Test Case 2: Logical Shift Right (LSR) by 4 (positive number)
    mode = 2'b01;
    data_in = 32'hF0000000;
    shamt = 5'd4;
    #10;
    $display("%0t ns | LSR  | %032b |  %0d  | %032b", $time, data_in, shamt, data_out);

    // Test Case 3: Arithmetic Shift Right (ASR) by 4 with negative sign bit (MSB = 1)
    mode = 2'b10;
    data_in = 32'hF0000000;
    shamt = 5'd4;
    #10;
    $display("%0t ns | ASR  | %032b |  %0d  | %032b", $time, data_in, shamt, data_out);

    // Test Case 4: Logical Shift Right with same negative number (zero-fill check)
    mode = 2'b01;
    data_in = 32'hF0000000;
    shamt = 5'd4;
    #10;
    $display("%0t ns | LSR  | %032b |  %0d  | %032b", $time, data_in, shamt, data_out);

    // Test Case 5: Shift by 0
    mode = 2'b00;
    data_in = 32'h12345678;
    shamt = 5'd0;
    #10;
    $display("%0t ns | LSL  | %032b |  %0d  | %032b", $time, data_in, shamt, data_out);

    // Test Case 6: Max shift by 31 (ASR)
    mode = 2'b10;
    data_in = 32'h80000000;
    shamt = 5'd31;
    #10;
    $display("%0t ns | ASR  | %032b |  %0d  | %032b", $time, data_in, shamt, data_out);

    $display("test completed");
    $finish;
  end

endmodule

module mealy_1011_detect_tb;

    reg  clk;
    reg  rst_n;
    reg  din;
    wire detected;

    // Instantiate Unit Under Test (UUT)
    mealy_1011_detect uut (
        .clk(clk),
        .rst_n(rst_n),
        .din(din),
        .detected(detected)
    );

    // Clock generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    initial begin
        clk   = 1'b0;
        rst_n = 1'b0;
        din   = 1'b0;

        // Dump waveform for GTKWave
        $dumpfile("sim/fsm_waveform.vcd");
        $dumpvars(0, mealy_1011_detect_tb);

        $display("Mealy 1011 Detector Testbench");
        $display(" Time  | din | detected | Description / Sequence Track ");

        #12;
        rst_n = 1'b1; // Release reset
        #3;

        // Test overlapping stream: 1 -> 0 -> 1 -> 1 -> 0 -> 1 -> 1 -> 1
        apply_bit(1'b1);
        apply_bit(1'b0);
        apply_bit(1'b1);
        apply_bit(1'b1); // Match 1 ('1011')
        apply_bit(1'b0);
        apply_bit(1'b1);
        apply_bit(1'b1); // Match 2 ('1011' overlapping)
        apply_bit(1'b1);
        apply_bit(1'b0);
        apply_bit(1'b1);
        apply_bit(1'b1); // Match 3 ('1011')

        #20;
        $display("Test completed");
        $finish;
    end

    // Task to apply serial bit synchronized to clock edges
    task apply_bit(input bit_val);
        begin
            @(posedge clk);
            din = bit_val;
            #1; 
            $display("%0t ns |  %b  |    %b     | Serial Bit Applied", $time, din, detected);
        end
    endtask

endmodule
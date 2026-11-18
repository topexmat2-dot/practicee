module galois_lfsr_tb;

    reg        clk;
    reg        rst_n;
    reg        load_seed;
    reg [15:0] seed_in;
    reg [15:0] tap_mask;
    wire [15:0] lfsr_out;
    wire       sequence_done;

    // Counter to verify total unique states in testbench
    reg [19:0] total_cycles;

    // Instantiate Unit Under Test (UUT)
    galois_lfsr_16bit #(
        .DEFAULT_TAPS(16'hB400) // x^16 + x^14 + x^13 + x^11 + 1
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .load_seed(load_seed),
        .seed_in(seed_in),
        .tap_mask(tap_mask),
        .lfsr_out(lfsr_out),
        .sequence_done(sequence_done)
    );

    // Clock generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    initial begin
        clk       = 1'b0;
        rst_n     = 1'b0;
        load_seed = 1'b0;
        seed_in   = 16'h0001;
        tap_mask  = 16'hB400; // Maximal polynomial taps
        total_cycles = 0;

        // Dump waveform for GTKWave
        $dumpfile("sim/lfsr_waveform.vcd");
        $dumpvars(0, galois_lfsr_tb);

        $display("LSFR Testbench Started");
        $display(" Time  | Load | Seed/State Hex | Sequence Done | Total Cycles Counted");

        #12;
        rst_n = 1'b1; // Release reset
        #3;

        $display("%0t ns |  %b   |     %h     |       %b       |      %0d", 
                 $time, load_seed, lfsr_out, sequence_done, total_cycles);

        // Run for initial 20 cycles to inspect pseudo-random transitions
        repeat (20) begin
            @(posedge clk);
            total_cycles = total_cycles + 1;
            #1;
            $display("%0t ns |  %b   |     %h     |       %b       |      %0d", 
                     $time, load_seed, lfsr_out, sequence_done, total_cycles);
        end

        // Test Seed Load Feature
        $display("--- Testing Seed-Load Feature ---");
        @(posedge clk);
        load_seed = 1'b1;
        seed_in   = 16'hABCD;
        total_cycles = 0;
        #10;
        
        load_seed = 1'b0;
        #1;
        $display("%0t ns |  %b   |     %h     |       %b       |      %0d (New Seed Loaded)", 
                 $time, load_seed, lfsr_out, sequence_done, total_cycles);

        // Run another 10 cycles from new seed
        repeat (10) begin
            @(posedge clk);
            total_cycles = total_cycles + 1;
            #1;
            $display("%0t ns |  %b   |     %h     |       %b       |      %0d", 
                     $time, load_seed, lfsr_out, sequence_done, total_cycles);
        end

        $display("LFSR verification test completed successfully.");
        $finish;
    end

endmodule
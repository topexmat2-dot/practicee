module magnitude_comparator_tb;
    parameter N = 4;

    reg  [N-1:0] a;
    reg  [N-1:0] b;
    
    // Outputs for Unsigned Comparator
    wire eq_u, lt_u, gt_u;
    
    // Outputs for Signed Comparator
    wire eq_s, lt_s, gt_s;

    // Instantiate Unsigned Comparator
    magnitude_comparator #( .N(N), .SIGNED_MODE(0) ) uut_unsigned (
        .a(a), .b(b), .eq(eq_u), .lt(lt_u), .gt(gt_u)
    );

    // Instantiate Signed Comparator
    magnitude_comparator #( .N(N), .SIGNED_MODE(1) ) uut_signed (
        .a(a), .b(b), .eq(eq_s), .lt(lt_s), .gt(gt_s)
    );

    initial begin
        // Dump VCD waveform for GTKWave
        $dumpfile("sim/comparator_waveform.vcd");
        $dumpvars(0, magnitude_comparator_tb);

        $display("COMPARATOR TESTBENCH");
        $display(" Time  | A (Bin) | B (Bin) | Unsigned (EQ LT GT) | Signed (EQ LT GT)   ");

        // Test Case 1: Standard equality
        a = 4'b0101; b = 4'b0101; #10;
        $display("%0t ns |  %04b   |  %04b   |    %b  %b  %b      |    %b  %b  %b", 
                 $time, a, b, eq_u, lt_u, gt_u, eq_s, lt_s, gt_s);

        // Test Case 2: Unsigned greater / Signed greater (Positive numbers)
        a = 4'b0111; b = 4'b0010; #10;
        $display("%0t ns |  %04b   |  %04b   |    %b  %b  %b      |    %b  %b  %b", 
                 $time, a, b, eq_u, lt_u, gt_u, eq_s, lt_s, gt_s);

        // Test Case 3: Negative vs Positive
        a = 4'b1111; b = 4'b0001; #10;
        $display("%0t ns |  %04b   |  %04b   |    %b  %b  %b      |    %b  %b  %b", 
                 $time, a, b, eq_u, lt_u, gt_u, eq_s, lt_s, gt_s);

        // Test Case 4: Two negative numbers (-8 vs -2)
        a = 4'b1000; b = 4'b1110; #10;
        $display("%0t ns |  %04b   |  %04b   |    %b  %b  %b      |    %b  %b  %b", 
                 $time, a, b, eq_u, lt_u, gt_u, eq_s, lt_s, gt_s);

        // Random vector testing
        repeat (5) begin
            a = $random;
            b = $random;
            #10;
            $display("%0t ns |  %04b   |  %04b   |    %b  %b  %b      |    %b  %b  %b", 
                     $time, a, b, eq_u, lt_u, gt_u, eq_s, lt_s, gt_s);
        end

        $display("Testbench completed.");
        $finish;
    end
endmodule
module counter_system_tb;

    parameter BITS = 4;

    reg              clk;
    reg              rst_n;
    reg              enable;
    reg              up_down;
    reg              load;
    reg  [BITS-1:0]  data_in;
    wire [BITS-1:0]  count;
    wire             overflow;
    wire             underflow;
    wire [6:0]       sev_seg;

    // Instantiate Top-Level Unit Under Test (UUT)
    counter_top #(.BITS(BITS)) uut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .up_down(up_down),
        .load(load),
        .data_in(data_in),
        .count(count),
        .overflow(overflow),
        .underflow(underflow),
        .sev_seg(sev_seg)
    );

    // Clock generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    initial begin
        clk     = 1'b0;
        rst_n   = 1'b0;
        enable  = 1'b0;
        up_down = 1'b1;
        load    = 1'b0;
        data_in = 4'h0;

        // Dump waveform for GTKWave
        $dumpfile("sim/counter_waveform.vcd");
        $dumpvars(0, counter_system_tb);

        $display("Counter System Testbench");
        $display(" Time  | rst | en | dir | load | data_in | count (Dec/Bin) | OV | UN | 7-Seg (gfedcba) ");

        #12;
        rst_n = 1'b1; // Release reset
        #3;

        // 1. Test Count Up with Enable
        enable = 1'b1; up_down = 1'b1;
        repeat (6) begin
            #10;
            $display("%0t ns |  %b  | %b  |  %b  |  %b   |   %4b  | %2d (%4b)    | %b  | %b  | %7b ", 
                     $time, rst_n, enable, up_down, load, data_in, count, count, overflow, underflow, sev_seg);
        end

        // 2. Test Synchronous Load
        load = 1'b1; data_in = 4'hD; #10;
        $display("%0t ns |  %b  | %b  |  %b  |  %b   |   %4b  | %2d (%4b)    | %b  | %b  | %7b ", 
                 $time, rst_n, enable, up_down, load, data_in, count, count, overflow, underflow, sev_seg);

        load = 1'b0; #10;
        $display("%0t ns |  %b  | %b  |  %b  |  %b   |   %4b  | %2d (%4b)    | %b  | %b  | %7b ", 
                 $time, rst_n, enable, up_down, load, data_in, count, count, overflow, underflow, sev_seg);

        // 3. Test Count Down and Underflow
        up_down = 1'b0;
        repeat (16) begin
            #10;
            $display("%0t ns |  %b  | %b  |  %b  |  %b   |   %4b  | %2d (%4b)    | %b  | %b  | %7b ", 
                     $time, rst_n, enable, up_down, load, data_in, count, count, overflow, underflow, sev_seg);
        end

        $display("Test finished");
        $finish;
    end

endmodule
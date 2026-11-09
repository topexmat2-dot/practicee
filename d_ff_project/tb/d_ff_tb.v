module d_ff_tb;

    reg  clk;
    reg  rst_n;
    reg  sync_rst;
    reg  enable;
    reg  load;
    reg  d;
    reg  d_load;
    wire q;

    // Instantiate Unit Under Test (UUT)
    d_ff_comprehensive uut (
        .clk(clk),
        .rst_n(rst_n),
        .sync_rst(sync_rst),
        .enable(enable),
        .load(load),
        .d(d),
        .d_load(d_load),
        .q(q)
    );

    // Clock generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk      = 1'b0;
        rst_n    = 1'b1;
        sync_rst = 1'b0;
        enable   = 1'b0;
        load     = 1'b0;
        d        = 1'b0;
        d_load   = 1'b0;

        // Dump waveform for GTKWave
        $dumpfile("sim/d_ff_waveform.vcd");
        $dumpvars(0, d_ff_tb);

        $display("Testbench for d_ff started.");
        $display(" Time  | rst_n | sync_rst | enable | load | d | d_load | q ");
        #3;
        
        // Test 1: Asynchronous Reset Test
        rst_n = 1'b0; d = 1'b1; #7;
        $display("%0t ns |   %b   |    %b     |   %b    |  %b   | %b |   %b    | %b", $time, rst_n, sync_rst, enable, load, d, d_load, q);
        
        rst_n = 1'b1; #10;
        $display("%0t ns |   %b   |    %b     |   %b    |  %b   | %b |   %b    | %b", $time, rst_n, sync_rst, enable, load, d, d_load, q);

        // Test 2: Enable = 0 (Holding state despite data changes)
        enable = 1'b0; d = 1'b1; #10;
        $display("%0t ns |   %b   |    %b     |   %b    |  %b   | %b |   %b    | %b", $time, rst_n, sync_rst, enable, load, d, d_load, q);

        // Test 3: Enable = 1, Load = 0 (Loading primary data 'd')
        enable = 1'b1; load = 1'b0; d = 1'b1; #10;
        $display("%0t ns |   %b   |    %b     |   %b    |  %b   | %b |   %b    | %b", $time, rst_n, sync_rst, enable, load, d, d_load, q);

        // Test 4: Enable = 1, Load = 1 (Loading secondary data 'd_load')
        load = 1'b1; d_load = 1'b0; #10;
        $display("%0t ns |   %b   |    %b     |   %b    |  %b   | %b |   %b    | %b", $time, rst_n, sync_rst, enable, load, d, d_load, q);

        // Test 5: Synchronous Reset Test
        sync_rst = 1'b1; #10;
        $display("%0t ns |   %b   |    %b     |   %b    |  %b   | %b |   %b    | %b", $time, rst_n, sync_rst, enable, load, d, d_load, q);

        sync_rst = 1'b0; d_load = 1'b1; #10;
        $display("%0t ns |   %b   |    %b     |   %b    |  %b   | %b |   %b    | %b", $time, rst_n, sync_rst, enable, load, d, d_load, q);

        $display("Test completed.");
        $finish;
    end

endmodule
module universal_shift_register_tb;
    reg       clk;
    reg       rst_n;
    reg [1:0] mode;
    reg       d_serial;
    reg [7:0] data_in;
    reg       load;
    wire [7:0] data_out;
    wire      q_serial;

    // Instantiate Unit Under Test (UUT)
    universal_shift_register uut (
        .clk(clk),
        .rst_n(rst_n),
        .mode(mode),
        .d_serial(d_serial),
        .data_in(data_in),
        .load(load),
        .data_out(data_out),
        .q_serial(q_serial)
    );

    // Clock generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk      = 1'b0;
        rst_n    = 1'b0;
        mode     = 2'b00;
        d_serial = 1'b0;
        data_in  = 8'b0;
        load     = 1'b0;

        // Dump waveform for GTKWave
        $dumpfile("sim/shift_register_waveform.vcd");
        $dumpvars(0, universal_shift_register_tb);

        $display("Starting Universal Shift Register Testbench");
        $display(" Time  | Mode | Function | d_serial |    data_in (Bin)     | load |   data_out (Bin)    | q_serial ");

        // Apply reset
        #12;
        rst_n = 1'b1;
        #3;

        // 1. Test SISO Mode (2'b00): Shift in 1, 0, 1, 1 serially
        mode = 2'b00; 
        d_serial = 1'b1; #10;
        $display("%0t ns |  %b  |   SISO   |    %b     | %b |  %b   | %b |    %b     ", $time, mode, d_serial, data_in, load, data_out, q_serial);
        d_serial = 1'b0; #10;
        $display("%0t ns |  %b  |   SISO   |    %b     | %b |  %b   | %b |    %b     ", $time, mode, d_serial, data_in, load, data_out, q_serial);
        d_serial = 1'b1; #10;
        $display("%0t ns |  %b  |   SISO   |    %b     | %b |  %b   | %b |    %b     ", $time, mode, d_serial, data_in, load, data_out, q_serial);
        d_serial = 1'b1; #10;
        $display("%0t ns |  %b  |   SISO   |    %b     | %b |  %b   | %b |    %b     ", $time, mode, d_serial, data_in, load, data_out, q_serial);

        // 2. Test SIPO Mode (2'b01): Shift in remaining bits to fill parallel output
        mode = 2'b01; 
        d_serial = 1'b0; #10;
        $display("%0t ns |  %b  |   SIPO   |    %b     | %b |  %b   | %b |    %b     ", $time, mode, d_serial, data_in, load, data_out, q_serial);
        d_serial = 1'b1; #10;
        $display("%0t ns |  %b  |   SIPO   |    %b     | %b |  %b   | %b |    %b     ", $time, mode, d_serial, data_in, load, data_out, q_serial);

        // 3. Test PIPO Mode (2'b11): Parallel Load and Parallel Output
        mode = 2'b11; 
        data_in = 8'b10101100; #10;
        $display("%0t ns |  %b  |   PIPO   |    %b     | %b |  %b   | %b |    %b     ", $time, mode, d_serial, data_in, load, data_out, q_serial);

        // 4. Test PISO Mode (2'b10): Parallel In, Serial Out
        mode = 2'b10; load = 1'b1; data_in = 8'b11110000; #10; // Load parallel data
        $display("%0t ns |  %b  |   PISO   |    %b     | %b |  %b   | %b |    %b     ", $time, mode, d_serial, data_in, load, data_out, q_serial);
        
        load = 1'b0; // Shift out serially
        #10;
        $display("%0t ns |  %b  |   PISO   |    %b     | %b |  %b   | %b |    %b     ", $time, mode, d_serial, data_in, load, data_out, q_serial);
        #10;
        $display("%0t ns |  %b  |   PISO   |    %b     | %b |  %b   | %b |    %b     ", $time, mode, d_serial, data_in, load, data_out, q_serial);

        $display("Testbench completed.");
        $finish;
    end

endmodule
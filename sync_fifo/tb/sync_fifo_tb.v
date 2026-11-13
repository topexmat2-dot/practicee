module sync_fifo_tb;

    parameter WIDTH = 8;
    parameter DEPTH = 16;

    reg                 clk;
    reg                 rst_n;
    reg                 wr_en;
    reg                 rd_en;
    reg  [WIDTH-1:0]    din;
    wire [WIDTH-1:0]    dout;
    wire                full;
    wire                empty;
    wire                half_full;
    wire [$clog2(DEPTH):0] count;

    // Instantiate Unit Under Test (UUT)
    sync_fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty),
        .half_full(half_full),
        .count(count)
    );

    // Clock generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk   = 1'b0;
        rst_n = 1'b0;
        wr_en = 1'b0;
        rd_en = 1'b0;
        din   = 8'h00;

        // Dump waveform for GTKWave
        $dumpfile("sim/fifo_waveform.vcd");
        $dumpvars(0, sync_fifo_tb);

        $display("Starting FIFO Testbench");
        $display(" Time  | rst | wr | rd |  din   |  dout  | full | empty | half | count ");

        #12;
        rst_n = 1'b1; // Release reset
        #3;

        // 1. Fill FIFO completely (Trigger Full & Half-Full flags)
        $display("--- Filling FIFO ---");
        repeat (DEPTH) begin
            @(posedge clk);
            wr_en = 1'b1;
            rd_en = 1'b0;
            din   = din + 8'h11;
            #1;
            $display("%0t ns |  %b  | %b  | %b  |  %h  |  %h  |  %b   |   %b   |  %b   |  %2d   ", 
                     $time, rst_n, wr_en, rd_en, din, dout, full, empty, half_full, count);
        end

        // Try writing when full (Overflow protection test)
        @(posedge clk);
        wr_en = 1'b1; din = 8'hFF; #1;
        $display("%0t ns |  %b  | %b  | %b  |  %h  |  %h  |  %b   |   %b   |  %b   |  %2d   (Overflow Test)", 
                 $time, rst_n, wr_en, rd_en, din, dout, full, empty, half_full, count);

        // 2. Read half of the FIFO
        $display("--- Reading Half FIFO ---");
        wr_en = 1'b0;
        repeat (8) begin
            @(posedge clk);
            rd_en = 1'b1;
            #1;
            $display("%0t ns |  %b  | %b  | %b  |  %h  |  %h  |  %b   |   %b   |  %b   |  %2d   ", 
                     $time, rst_n, wr_en, rd_en, din, dout, full, empty, half_full, count);
        end

        // 3. Simultaneous Read and Write
        $display("--- Simultaneous Read & Write ---");
        @(posedge clk);
        wr_en = 1'b1; rd_en = 1'b1; din = 8'hAA; #1;
        $display("%0t ns |  %b  | %b  | %b  |  %h  |  %h  |  %b   |   %b   |  %b   |  %2d   ", 
                 $time, rst_n, wr_en, rd_en, din, dout, full, empty, half_full, count);

        // 4. Drain FIFO completely (Trigger Empty flag & Underflow protection)
        $display("--- Draining FIFO ---");
        wr_en = 1'b0; rd_en = 1'b1;
        repeat (10) begin
            @(posedge clk);
            #1;
            $display("%0t ns |  %b  | %b  | %b  |  %h  |  %h  |  %b   |   %b   |  %b   |  %2d   ", 
                     $time, rst_n, wr_en, rd_en, din, dout, full, empty, half_full, count);
        end

        // Try reading when empty (Underflow test)
        rd_en = 1'b1; #10;
        $display("%0t ns |  %b  | %b  | %b  |  %h  |  %h  |  %b   |   %b   |  %b   |  %2d   (Underflow Test)", 
                 $time, rst_n, wr_en, rd_en, din, dout, full, empty, half_full, count);

        $display("Test completed");
        $finish;
    end

endmodule
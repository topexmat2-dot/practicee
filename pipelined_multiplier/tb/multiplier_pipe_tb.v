`timescale 1ns/1ps

module multiplier_pipe_tb;

    reg         clk;
    reg         rst_n;
    reg  [7:0]  a;
    reg  [7:0]  b;
    wire [15:0] product;

    // Instantiate Unit Under Test (UUT)
    multiplier_pipe uut (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .product(product)
    );

    // Clock generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    // Shift registers to accurately track expected values through the 3-stage pipeline
    reg [7:0] a_delay1, a_delay2, a_delay3;
    reg [7:0] b_delay1, b_delay2, b_delay3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_delay1 <= 8'd0; a_delay2 <= 8'd0; a_delay3 <= 8'd0;
            b_delay1 <= 8'd0; b_delay2 <= 8'd0; b_delay3 <= 8'd0;
        end else begin
            a_delay1 <= a;
            a_delay2 <= a_delay1;
            a_delay3 <= a_delay2;

            b_delay1 <= b;
            b_delay2 <= b_delay1;
            b_delay3 <= b_delay2;
        end
    end

    initial begin
        clk   = 1'b0;
        rst_n = 1'b0;
        a     = 8'd0;
        b     = 8'd0;

        $dumpfile("sim/multiplier_waveform.vcd");
        $dumpvars(0, multiplier_pipe_tb);

        $display("Multiplier Testbench");
        $display(" Time   |  a   |  b   | Expected | Product (Pipe) | Status");

        #12;
        rst_n = 1'b1;
        #3;

        // Apply test vectors synchronized to clock edges
        @(posedge clk); a = 8'd12;  b = 8'd10; // Expected: 120
        @(posedge clk); a = 8'd25;  b = 8'd4;  // Expected: 100
        @(posedge clk); a = 8'd255; b = 8'd2;  // Expected: 510
        @(posedge clk); a = 8'd15;  b = 8'd15; // Expected: 225

        // Zero out inputs and let the pipeline drain
        @(posedge clk); a = 8'd0; b = 8'd0;
        @(posedge clk); a = 8'd0; b = 8'd0;
        @(posedge clk); a = 8'd0; b = 8'd0;
        @(posedge clk); a = 8'd0; b = 8'd0;

        #20;
        $display("Testbench completed successfully.");
        $finish;
    end

   // Monitor block that prints the output precisely when Stage 3 finishes
    reg [15:0] expected_val;
    always @(posedge clk) begin
        if (rst_n) begin
            #1; // Small delay to let combinational adders settle after clock edge
            expected_val = {8'd0, a_delay3} * {8'd0, b_delay3};
            $display("%0t ns | %3d  | %3d  |   %5d  |     %5d      | Output Ready", 
                     $time, a_delay3, b_delay3, expected_val, product);
        end
    end

endmodule
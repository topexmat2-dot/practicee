module uart_tx_tb;

    localparam integer CLK_PERIOD_NS = 20;   // 50 MHz system clock
    localparam integer DIV_9600_50M  = 5208; // 50,000,000 / 9600 ~= 5208

    reg        clk;
    reg        rst_n;
    reg        tx_start;
    reg  [7:0] tx_data;
    reg        parity_en;
    reg        parity_odd;
    reg [31:0] baud_div;
    wire       tx;
    wire       busy;
    wire       tx_done;

    uart_tx #(
        .CLK_FREQ_HZ(50_000_000),
        .BAUD_RATE(9600)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .parity_en(parity_en),
        .parity_odd(parity_odd),
        .baud_div(baud_div),
        .tx(tx),
        .busy(busy),
        .tx_done(tx_done)
    );

    // 50 MHz clock (20 ns period)
    always #(CLK_PERIOD_NS / 2) clk = ~clk;

    // Independent serial frame decoder
    task decode_serial_frame(
        input       en_par,
        input       odd_par,
        input [7:0] expected_byte
    );
        reg [7:0] decoded_byte;
        reg       sampled_parity;
        reg       expected_parity;
        reg       stop_bit;
        integer   b;
        real      bit_time_ns;
        begin
            bit_time_ns = baud_div * CLK_PERIOD_NS;

            // Wait for falling edge of start bit (1 -> 0)
            @(negedge tx);

            // Sample center of start bit
            #(bit_time_ns * 0.5);
            if (tx !== 1'b0) begin
                $display("[ERR]  %0t ns | Start bit invalid (tx=%b)", $time, tx);
            end

            // Sample 8 data bits at mid-bit intervals (LSB first)
            decoded_byte = 8'd0;
            for (b = 0; b < 8; b = b + 1) begin
                #(bit_time_ns);
                decoded_byte[b] = tx;
            end

            // Optional parity bit check
            if (en_par) begin
                #(bit_time_ns);
                sampled_parity  = tx;
                expected_parity = odd_par ? ~(^decoded_byte) : (^decoded_byte);
            end else begin
                sampled_parity  = 1'b0;
                expected_parity = 1'b0;
            end

            // Sample stop bit
            #(bit_time_ns);
            stop_bit = tx;

            if (decoded_byte === expected_byte && stop_bit === 1'b1 &&
                (!en_par || (sampled_parity === expected_parity))) begin
                if (!en_par) begin
                    $display("[PASS] %0t ns | Mode 8N1 | Decoded=0x%02h ('%c') | Stop=%b",
                             $time, decoded_byte,
                             (decoded_byte >= 8'h20 && decoded_byte <= 8'h7E) ? decoded_byte : 8'h2E,
                             stop_bit);
                end else begin
                    $display("[PASS] %0t ns | Mode %s | Decoded=0x%02h ('%c') | Par=%b (exp %b) | Stop=%b",
                             $time, odd_par ? "8O1" : "8E1", decoded_byte,
                             (decoded_byte >= 8'h20 && decoded_byte <= 8'h7E) ? decoded_byte : 8'h2E,
                             sampled_parity, expected_parity, stop_bit);
                end
            end else begin
                $display("[FAIL] %0t ns | Exp=0x%02h Got=0x%02h | Par=%b/%b | Stop=%b",
                         $time, expected_byte, decoded_byte, sampled_parity, expected_parity, stop_bit);
            end
        end
    endtask

    task send_byte(
        input [7:0] byte_val,
        input       en_par,
        input       odd_par
    );
        begin
            @(posedge clk);
            while (busy) @(posedge clk);
            tx_data    = byte_val;
            parity_en  = en_par;
            parity_odd = odd_par;
            tx_start   = 1'b1;
            @(posedge clk);
            tx_start   = 1'b0;
        end
    endtask

    initial begin
        clk        = 1'b0;
        rst_n      = 1'b0;
        tx_start   = 1'b0;
        tx_data    = 8'h00;
        parity_en  = 1'b0;
        parity_odd = 1'b0;
        baud_div   = DIV_9600_50M;

        $dumpfile("sim/uart_tx_waveform.vcd");
        $dumpvars(0, uart_tx_tb);

        $display(" UART TX Simulation (50 MHz clock, 9600 baud -> %0d clks/bit)", DIV_9600_50M);

        #(CLK_PERIOD_NS * 3);
        rst_n = 1'b1;
        #(CLK_PERIOD_NS * 5);

        // 1. Standard 8N1 transfer ('A' = 8'h41)
        fork
            send_byte(8'h41, 1'b0, 1'b0);
            decode_serial_frame(1'b0, 1'b0, 8'h41);
        join
        @(posedge tx_done);

        // 2. Even parity transfer (8'hA5 -> 1010_0101 has four 1s -> even parity = 0)
        fork
            send_byte(8'hA5, 1'b1, 1'b0);
            decode_serial_frame(1'b1, 1'b0, 8'hA5);
        join
        @(posedge tx_done);

        // 3. Odd parity transfer (8'h3C -> 0011_1100 has four 1s -> odd parity = 1)
        fork
            send_byte(8'h3C, 1'b1, 1'b1);
            decode_serial_frame(1'b1, 1'b1, 8'h3C);
        join
        @(posedge tx_done);

        #(CLK_PERIOD_NS * 20);
        $display("UART TX verification complete.");
        $finish;
    end

endmodule
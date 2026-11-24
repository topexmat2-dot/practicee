module spi_master_tb;

    reg        clk;
    reg        rst_n;
    reg        start;
    reg  [7:0] clk_div;
    reg  [7:0] tx_data;
    wire [7:0] rx_data;
    wire       busy;
    wire       done;
    wire       sclk;
    wire       mosi;
    wire       miso;
    wire       ss_n;

    // Instantiate SPI Master (UUT)
    spi_master #(
        .DATA_WIDTH(8),
        .DIV_WIDTH(8)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .clk_div(clk_div),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .busy(busy),
        .done(done),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .ss_n(ss_n)
    );

    reg [7:0] slave_rx_byte;
    reg [7:0] slave_tx_byte;
    reg [7:0] slave_shift;
    reg       miso_reg;

    assign miso = (!ss_n) ? miso_reg : 1'b0;

    always @(negedge ss_n) begin
        slave_rx_byte <= 8'd0;
        slave_shift   <= slave_tx_byte;
        miso_reg      <= slave_tx_byte[7];
    end

    always @(posedge sclk) begin
        if (!ss_n) begin
            slave_rx_byte <= {slave_rx_byte[6:0], mosi};
        end
    end

    always @(negedge sclk) begin
        if (!ss_n) begin
            slave_shift <= {slave_shift[6:0], 1'b0};
            miso_reg    <= slave_shift[6];
        end
    end

    // Clock generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    initial begin
        clk           = 1'b0;
        rst_n         = 1'b0;
        start         = 1'b0;
        clk_div       = 8'd2; // SCLK toggles every 2 system clks -> 25 MHz SCLK
        tx_data       = 8'h00;
        slave_tx_byte = 8'h00;

        $dumpfile("sim/spi_waveform.vcd");
        $dumpvars(0, spi_master_tb);

        $display("SPI Master Testbench Starting");
        $display(" Time    | clk_div | TX Byte | Slave TX | Slave RX | Master RX | Status ");

        #12;
        rst_n = 1'b1;
        #15;

        // Transfer 1: Loopback echo test (Slave sends back 8'hA5)
        run_transfer(8'd2, 8'h3C, 8'hA5);

        // Transfer 2: Slower clock divider (clk_div = 4 -> 12.5 MHz SCLK)
        run_transfer(8'd4, 8'hF0, 8'h5A);

        // Transfer 3: Another 8-bit exchange
        run_transfer(8'd2, 8'h7E, 8'h99);

        #40;
        $display("SPI Mode 0 loopback verification completed.");
        $finish;
    end

    task run_transfer(
        input [7:0] div_val,
        input [7:0] master_byte,
        input [7:0] slave_byte
    );
        begin
            @(posedge clk);
            clk_div       = div_val;
            tx_data       = master_byte;
            slave_tx_byte = slave_byte;
            start         = 1'b1;
            @(posedge clk);
            start         = 1'b0;

            @(posedge done);
            #1;
            $display("%0t ns |   %3d   |   %h    |    %h    |    %h    |    %h     | DONE",
                     $time, clk_div, master_byte, slave_byte, slave_rx_byte, rx_data);
        end
    endtask

endmodule
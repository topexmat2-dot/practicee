module i2c_master_tb;

    reg        clk;
    reg        rst_n;
    reg        start;
    reg [15:0] quarter_div;
    reg  [6:0] slave_addr;
    reg        rw;
    reg  [7:0] tx_data;

    wire       scl_oe;
    wire       scl;
    tri1       sda; // Weak pull-up net for open-drain bus
    wire       busy;
    wire       done;
    wire       ack_err;

    // Pull-up resistors on SCL and SDA
    assign scl = scl_oe ? 1'b0 : 1'b1;
    pullup(sda);

    i2c_master #(
        .DIV_WIDTH(16)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .quarter_div(quarter_div),
        .slave_addr(slave_addr),
        .rw(rw),
        .tx_data(tx_data),
        .scl_oe(scl_oe),
        .sda(sda),
        .busy(busy),
        .done(done),
        .ack_err(ack_err)
    );

    // =========================================================================
    // Behavioral I2C Slave at 7'h50 (ACKs address 7'h50 and data byte)
    // =========================================================================
    localparam [6:0] SLAVE_ID = 7'h50;

    reg       slave_sda_oe;
    reg [7:0] rx_shift;
    reg [3:0] bit_pos;
    reg       addr_phase;
    reg       addr_matched;
    reg [7:0] last_addr_byte;
    reg [7:0] last_data_byte;

    assign sda = slave_sda_oe ? 1'b0 : 1'bz;

    // Detect START condition: SDA falls while SCL is high
    always @(negedge sda) begin
        if (scl === 1'b1) begin
            bit_pos      <= 4'd0;
            addr_phase   <= 1'b1;
            addr_matched <= 1'b0;
            slave_sda_oe <= 1'b0;
        end
    end

    // Detect STOP condition: SDA rises while SCL is high
    always @(posedge sda) begin
        if (scl === 1'b1) begin
            slave_sda_oe <= 1'b0;
        end
    end

    // Sample bits on rising SCL edge; drive ACK on 9th clock after falling SCL
    always @(posedge scl) begin
        if (bit_pos < 4'd8) begin
            rx_shift <= {rx_shift[6:0], sda};
        end
        bit_pos <= bit_pos + 4'd1;
    end

    always @(negedge scl) begin
        if (bit_pos == 4'd8) begin
            // Capture completed 8-bit byte
            if (addr_phase) begin
                last_addr_byte <= rx_shift;
                if (rx_shift[7:1] == SLAVE_ID) begin
                    addr_matched <= 1'b1;
                    slave_sda_oe <= 1'b1; // Drive ACK (0)
                end else begin
                    addr_matched <= 1'b0;
                    slave_sda_oe <= 1'b0; // NACK (1)
                end
            end else begin
                last_data_byte <= rx_shift;
                if (addr_matched) begin
                    slave_sda_oe <= 1'b1; // Drive ACK (0)
                end else begin
                    slave_sda_oe <= 1'b0;
                end
            end
        end else if (bit_pos == 4'd9) begin
            slave_sda_oe <= 1'b0; // Release SDA after ACK bit
            bit_pos      <= 4'd0;
            if (addr_phase) begin
                addr_phase <= 1'b0;
            end
        end
    end

    // 100 MHz system clock (10 ns period)
    always #5 clk = ~clk;

    task run_i2c_write(input [6:0] addr, input [7:0] data);
        begin
            @(posedge clk);
            while (busy) @(posedge clk);
            slave_addr = addr;
            rw         = 1'b0;
            tx_data    = data;
            start      = 1'b1;
            @(posedge clk);
            start      = 1'b0;

            @(posedge done);
            #1;
            $display("[INFO] %0t ns | Addr=0x%02h (R/W=%b) | Data=0x%02h | SlaveRX=[0x%02h, 0x%02h] | ack_err=%b",
                     $time, addr, rw, data, last_addr_byte, last_data_byte, ack_err);
        end
    endtask

    initial begin
        clk          = 1'b0;
        rst_n        = 1'b0;
        start        = 1'b0;
        quarter_div  = 16'd4; // SCL quarter-period = 40 ns -> SCL period = 160 ns
        slave_addr   = 7'h00;
        rw           = 1'b0;
        tx_data      = 8'h00;
        slave_sda_oe = 1'b0;
        rx_shift     = 8'd0;
        bit_pos      = 4'd0;
        addr_phase   = 1'b1;
        addr_matched = 1'b0;

        $dumpfile("sim/i2c_waveform.vcd");
        $dumpvars(0, i2c_master_tb);


        $display(" I2C Master Simulation (START, Addr+R/W, Data, ACK Check, STOP)");

        #25;
        rst_n = 1'b1;
        #30;

        // 1. Valid write to slave 7'h50 -> expect ACK (ack_err = 0)
        run_i2c_write(7'h50, 8'hA5);
        #80;

        // 2. Write to non-existent slave 7'h24 -> expect NACK (ack_err = 1)
        run_i2c_write(7'h24, 8'h3C);
        #80;

        $display("Simulation completed.");
        $finish;
    end

endmodule
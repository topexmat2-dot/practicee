module i2c_master #(
    parameter integer DIV_WIDTH = 16
)(
    input  wire                 clk,
    input  wire                 rst_n,       // Active-low async reset
    input  wire                 start,       // Pulse high when !busy to run transaction
    input  wire [DIV_WIDTH-1:0] quarter_div, // System clks per 1/4 SCL period (min 1)
    input  wire [6:0]           slave_addr,  // 7-bit target address
    input  wire                 rw,          // 0 = Write, 1 = Read
    input  wire [7:0]           tx_data,     // Data byte sent after address+R/W
    output reg                  scl_oe,      // 1 = pull SCL low, 0 = release SCL high
    inout  wire                 sda,         // Open-drain bidirectional data line
    output reg                  busy,        // High during active transaction
    output reg                  done,        // 1-cycle pulse when transaction completes
    output reg                  ack_err      // 1 if slave NACKed address or data byte
);

    localparam [3:0]
        S_IDLE      = 4'd0,
        S_START     = 4'd1,
        S_ADDR_BIT  = 4'd2,
        S_ADDR_ACK  = 4'd3,
        S_DATA_BIT  = 4'd4,
        S_DATA_ACK  = 4'd5,
        S_STOP_PREP = 4'd6,
        S_STOP      = 4'd7,
        S_DONE      = 4'd8;

    reg [3:0]           state;
    reg [1:0]           q_phase;     // 0, 1, 2, 3 within each SCL cycle
    reg [DIV_WIDTH-1:0] q_cnt;
    reg [2:0]           bit_cnt;     // 7 down to 0 (MSB first)
    reg [7:0]           shift_reg;
    reg                 sda_oe;      // 1 = drive SDA low (0), 0 = release SDA ('z')

    wire [DIV_WIDTH-1:0] eff_q_div = (quarter_div == {DIV_WIDTH{1'b0}}) ? {{(DIV_WIDTH-1){1'b0}}, 1'b1} : quarter_div;
    wire                 q_tick    = (q_cnt >= (eff_q_div - {{(DIV_WIDTH-1){1'b0}}, 1'b1}));

    // Open-drain driver: drive 0 when asserted, release ('z') otherwise
    assign sda = sda_oe ? 1'b0 : 1'bz;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= S_IDLE;
            q_phase   <= 2'd0;
            q_cnt     <= {DIV_WIDTH{1'b0}};
            bit_cnt   <= 3'd7;
            shift_reg <= 8'd0;
            scl_oe    <= 1'b0; // Bus idle: SCL high
            sda_oe    <= 1'b0; // Bus idle: SDA high
            busy      <= 1'b0;
            done      <= 1'b0;
            ack_err   <= 1'b0;
        end else begin
            done <= 1'b0;

            case (state)
                S_IDLE: begin
                    scl_oe  <= 1'b0;
                    sda_oe  <= 1'b0;
                    busy    <= 1'b0;
                    q_phase <= 2'd0;
                    q_cnt   <= {DIV_WIDTH{1'b0}};

                    if (start) begin
                        busy      <= 1'b1;
                        ack_err   <= 1'b0;
                        shift_reg <= {slave_addr, rw}; // MSB first: addr[6:0] then R/W
                        state     <= S_START;
                    end
                end

                // START: SCL high (scl_oe=0), pull SDA low (sda_oe=1)
                S_START: begin
                    scl_oe <= 1'b0;
                    if (q_tick) begin
                        q_cnt <= {DIV_WIDTH{1'b0}};
                        if (q_phase == 2'd0) begin
                            sda_oe  <= 1'b1; // SDA falls while SCL is high
                            q_phase <= 2'd1;
                        end else begin
                            scl_oe    <= 1'b1; // Pull SCL low to prepare bit 7
                            sda_oe    <= ~shift_reg[7];
                            bit_cnt   <= 3'd7;
                            q_phase   <= 2'd0;
                            state     <= S_ADDR_BIT;
                        end
                    end else begin
                        q_cnt <= q_cnt + {{(DIV_WIDTH-1){1'b0}}, 1'b1};
                    end
                end

                // Shift out 8 bits of {slave_addr, rw}
                // Phase 0: setup SDA while SCL low
                // Phase 1: raise SCL (scl_oe=0)
                // Phase 2: hold SCL high
                // Phase 3: lower SCL (scl_oe=1) and advance bit or go to ADDR_ACK
                S_ADDR_BIT: begin
                    if (q_tick) begin
                        q_cnt <= {DIV_WIDTH{1'b0}};
                        case (q_phase)
                            2'd0: begin
                                scl_oe  <= 1'b1;
                                sda_oe  <= ~shift_reg[bit_cnt];
                                q_phase <= 2'd1;
                            end
                            2'd1: begin
                                scl_oe  <= 1'b0; // Rising edge of SCL
                                q_phase <= 2'd2;
                            end
                            2'd2: begin
                                scl_oe  <= 1'b0; // SCL high period
                                q_phase <= 2'd3;
                            end
                            2'd3: begin
                                scl_oe <= 1'b1; // Falling edge of SCL
                                if (bit_cnt == 3'd0) begin
                                    sda_oe    <= 1'b0; // Release SDA for slave ACK
                                    shift_reg <= tx_data;
                                    q_phase   <= 2'd0;
                                    state     <= S_ADDR_ACK;
                                end else begin
                                    bit_cnt <= bit_cnt - 3'd1;
                                    q_phase <= 2'd0;
                                end
                            end
                        endcase
                    end else begin
                        q_cnt <= q_cnt + {{(DIV_WIDTH-1){1'b0}}, 1'b1};
                    end
                end

                // Sample slave ACK/NACK for address byte while SCL is high
                S_ADDR_ACK: begin
                    if (q_tick) begin
                        q_cnt <= {DIV_WIDTH{1'b0}};
                        case (q_phase)
                            2'd0: begin
                                scl_oe  <= 1'b1;
                                sda_oe  <= 1'b0; // Keep SDA released
                                q_phase <= 2'd1;
                            end
                            2'd1: begin
                                scl_oe  <= 1'b0; // SCL rises
                                q_phase <= 2'd2;
                            end
                            2'd2: begin
                                scl_oe  <= 1'b0;
                                if (sda !== 1'b0) begin
                                    ack_err <= 1'b1; // NACK received
                                end
                                q_phase <= 2'd3;
                            end
                            2'd3: begin
                                scl_oe  <= 1'b1; // SCL falls
                                bit_cnt <= 3'd7;
                                q_phase <= 2'd0;
                                state   <= S_DATA_BIT;
                            end
                        endcase
                    end else begin
                        q_cnt <= q_cnt + {{(DIV_WIDTH-1){1'b0}}, 1'b1};
                    end
                end

                // Shift out 8-bit data byte (MSB first)
                S_DATA_BIT: begin
                    if (q_tick) begin
                        q_cnt <= {DIV_WIDTH{1'b0}};
                        case (q_phase)
                            2'd0: begin
                                scl_oe  <= 1'b1;
                                sda_oe  <= ~shift_reg[bit_cnt];
                                q_phase <= 2'd1;
                            end
                            2'd1: begin
                                scl_oe  <= 1'b0; // SCL rises
                                q_phase <= 2'd2;
                            end
                            2'd2: begin
                                scl_oe  <= 1'b0; // SCL high
                                q_phase <= 2'd3;
                            end
                            2'd3: begin
                                scl_oe <= 1'b1; // SCL falls
                                if (bit_cnt == 3'd0) begin
                                    sda_oe  <= 1'b0; // Release SDA for data ACK
                                    q_phase <= 2'd0;
                                    state   <= S_DATA_ACK;
                                end else begin
                                    bit_cnt <= bit_cnt - 3'd1;
                                    q_phase <= 2'd0;
                                end
                            end
                        endcase
                    end else begin
                        q_cnt <= q_cnt + {{(DIV_WIDTH-1){1'b0}}, 1'b1};
                    end
                end

                // Sample slave ACK/NACK for data byte
                S_DATA_ACK: begin
                    if (q_tick) begin
                        q_cnt <= {DIV_WIDTH{1'b0}};
                        case (q_phase)
                            2'd0: begin
                                scl_oe  <= 1'b1;
                                sda_oe  <= 1'b0;
                                q_phase <= 2'd1;
                            end
                            2'd1: begin
                                scl_oe  <= 1'b0; // SCL rises
                                q_phase <= 2'd2;
                            end
                            2'd2: begin
                                scl_oe  <= 1'b0;
                                if (sda !== 1'b0) begin
                                    ack_err <= 1'b1;
                                end
                                q_phase <= 2'd3;
                            end
                            2'd3: begin
                                scl_oe  <= 1'b1;
                                sda_oe  <= 1'b1; // Pull SDA low while SCL low before STOP
                                q_phase <= 2'd0;
                                state   <= S_STOP_PREP;
                            end
                        endcase
                    end else begin
                        q_cnt <= q_cnt + {{(DIV_WIDTH-1){1'b0}}, 1'b1};
                    end
                end

                // Raise SCL while keeping SDA low so SDA can rise during STOP
                S_STOP_PREP: begin
                    scl_oe <= 1'b0;
                    sda_oe <= 1'b1;
                    if (q_tick) begin
                        q_cnt   <= {DIV_WIDTH{1'b0}};
                        q_phase <= 2'd0;
                        state   <= S_STOP;
                    end else begin
                        q_cnt <= q_cnt + {{(DIV_WIDTH-1){1'b0}}, 1'b1};
                    end
                end

                // STOP: SCL high (scl_oe=0), release SDA high (sda_oe=0)
                S_STOP: begin
                    scl_oe <= 1'b0;
                    if (q_tick) begin
                        q_cnt   <= {DIV_WIDTH{1'b0}};
                        sda_oe  <= 1'b0; // SDA rises while SCL is high
                        state   <= S_DONE;
                    end else begin
                        q_cnt <= q_cnt + {{(DIV_WIDTH-1){1'b0}}, 1'b1};
                    end
                end

                S_DONE: begin
                    busy  <= 1'b0;
                    done  <= 1'b1;
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
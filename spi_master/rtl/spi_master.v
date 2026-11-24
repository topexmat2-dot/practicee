module spi_master #(
    parameter DATA_WIDTH = 8,
    parameter DIV_WIDTH  = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire [DIV_WIDTH-1:0]  clk_div,
    input  wire [DATA_WIDTH-1:0] tx_data,
    output reg  [DATA_WIDTH-1:0] rx_data,
    output reg                   busy,
    output reg                   done,
    output reg                   sclk,
    output reg                   mosi,
    input  wire                  miso,
    output reg                   ss_n
);

    localparam IDLE     = 2'd0;
    localparam TRANSFER = 2'd1;
    localparam FINISH   = 2'd2;

    reg [1:0]            state;
    reg [DATA_WIDTH-1:0] tx_shift;
    reg [DATA_WIDTH-1:0] rx_shift;
    reg [DIV_WIDTH-1:0]  div_cnt;
    reg [3:0]            bit_cnt;    // Counts bits 0..7 (8 bits)

    wire [DIV_WIDTH-1:0] eff_div = (clk_div == {DIV_WIDTH{1'b0}}) ? {{(DIV_WIDTH-1){1'b0}}, 1'b1} : clk_div;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            tx_shift <= {DATA_WIDTH{1'b0}};
            rx_shift <= {DATA_WIDTH{1'b0}};
            rx_data  <= {DATA_WIDTH{1'b0}};
            div_cnt  <= {DIV_WIDTH{1'b0}};
            bit_cnt  <= 4'd0;
            busy     <= 1'b0;
            done     <= 1'b0;
            sclk     <= 1'b0; // CPOL = 0
            mosi     <= 1'b0;
            ss_n     <= 1'b1; // Inactive high
        end else begin
            done <= 1'b0; // Default single-cycle pulse

            case (state)
                IDLE: begin
                    sclk <= 1'b0;
                    ss_n <= 1'b1;
                    busy <= 1'b0;

                    if (start) begin
                        tx_shift <= tx_data;
                        rx_shift <= {DATA_WIDTH{1'b0}};
                        div_cnt  <= {DIV_WIDTH{1'b0}};
                        bit_cnt  <= 4'd0;
                        busy     <= 1'b1;
                        ss_n     <= 1'b0;
                        mosi     <= tx_data[DATA_WIDTH-1]; // MSB ready before first rising edge (CPHA=0)
                        state    <= TRANSFER;
                    end
                end

                TRANSFER: begin
                    if (div_cnt < eff_div - 1'b1) begin
                        div_cnt <= div_cnt + 1'b1;
                    end else begin
                        div_cnt <= {DIV_WIDTH{1'b0}};

                        if (!sclk) begin
                            // Rising edge of SCLK (CPHA=0: sample MISO)
                            sclk     <= 1'b1;
                            rx_shift <= {rx_shift[DATA_WIDTH-2:0], miso};
                        end else begin
                            // Falling edge of SCLK
                            sclk <= 1'b0;
                            if (bit_cnt == DATA_WIDTH - 1) begin
                                rx_data <= {rx_shift[DATA_WIDTH-2:0], miso};
                                state   <= FINISH;
                            end else begin
                                bit_cnt  <= bit_cnt + 1'b1;
                                mosi     <= tx_shift[DATA_WIDTH - 2 - bit_cnt];
                            end
                        end
                    end
                end

                FINISH: begin
                    sclk <= 1'b0;
                    ss_n <= 1'b1;
                    busy <= 1'b0;
                    done <= 1'b1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
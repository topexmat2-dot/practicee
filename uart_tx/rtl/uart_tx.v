module uart_tx #(
    parameter integer CLK_FREQ_HZ = 50_000_000,
    parameter integer BAUD_RATE   = 9600,
    parameter integer DIV_DEFAULT = (CLK_FREQ_HZ / BAUD_RATE)
  )(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    input  wire       parity_en,
    input  wire       parity_odd,
    input  wire [31:0] baud_div,
    output reg        tx,
    output reg        busy,
    output reg        tx_done
  );

  localparam [2:0] S_IDLE   = 3'd0;
  localparam [2:0] S_START  = 3'd1;
  localparam [2:0] S_DATA   = 3'd2;
  localparam [2:0] S_PARITY = 3'd3;
  localparam [2:0] S_STOP   = 3'd4;

  reg [2:0]  state;
  reg [31:0] baud_cnt;
  reg [2:0]  bit_idx;
  reg [7:0]  data_shifter;
  reg        parity_bit;

  wire [31:0] active_div = (baud_div == 32'd0) ? DIV_DEFAULT[31:0] : baud_div;
  wire        bit_tick   = (baud_cnt >= (active_div - 32'd1));
  wire        calc_even_parity = ^data_shifter;
  wire        calc_parity    = parity_odd ? ~calc_even_parity : calc_even_parity;

  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      state        <= S_IDLE;
      baud_cnt     <= 32'd0;
      bit_idx      <= 3'd0;
      data_shifter <= 8'd0;
      parity_bit   <= 1'b0;
      tx           <= 1'b1;
      busy         <= 1'b0;
      tx_done      <= 1'b0;
    end
    else
    begin
      tx_done <= 1'b0;

      case (state)
        S_IDLE:
        begin
          tx       <= 1'b1;
          busy     <= 1'b0;
          baud_cnt <= 32'd0;
          bit_idx  <= 3'd0;

          if (tx_start)
          begin
            data_shifter <= tx_data;
            parity_bit   <= parity_odd ? ~(^tx_data) : (^tx_data);
            busy         <= 1'b1;
            tx           <= 1'b0; // Start bit immediately on entry
            state        <= S_START;
          end
        end

        S_START:
        begin
          if (bit_tick)
          begin
            baud_cnt <= 32'd0;
            bit_idx  <= 3'd0;
            tx       <= data_shifter[0]; // LSB first
            state    <= S_DATA;
          end
          else
          begin
            baud_cnt <= baud_cnt + 32'd1;
          end
        end

        S_DATA:
        begin
          if (bit_tick)
          begin
            baud_cnt <= 32'd0;
            if (bit_idx == 3'd7)
            begin
              bit_idx <= 3'd0;
              if (parity_en)
              begin
                tx    <= parity_bit;
                state <= S_PARITY;
              end
              else
              begin
                tx    <= 1'b1; // Stop bit for 8N1
                state <= S_STOP;
              end
            end
            else
            begin
              bit_idx <= bit_idx + 3'd1;
              tx      <= data_shifter[bit_idx + 3'd1];
            end
          end
          else
          begin
            baud_cnt <= baud_cnt + 32'd1;
          end
        end

        S_PARITY:
        begin
          if (bit_tick)
          begin
            baud_cnt <= 32'd0;
            tx       <= 1'b1; // Stop bit
            state    <= S_STOP;
          end
          else
          begin
            baud_cnt <= baud_cnt + 32'd1;
          end
        end

        S_STOP:
        begin
          if (bit_tick)
          begin
            baud_cnt <= 32'd0;
            tx       <= 1'b1;
            busy     <= 1'b0;
            tx_done  <= 1'b1;
            state    <= S_IDLE;
          end
          else
          begin
            baud_cnt <= baud_cnt + 32'd1;
          end
        end

        default:
          state <= S_IDLE;
      endcase
    end
  end

endmodule

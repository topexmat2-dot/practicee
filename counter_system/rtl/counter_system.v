module up_down_counter #(
    parameter BITS = 4
  )(
    input  wire              clk,
    input  wire              rst_n,
    input  wire              enable,
    input  wire              up_down,
    input  wire              load,
    input  wire [BITS-1:0]   data_in,
    output reg  [BITS-1:0]   count,
    output reg               overflow,
    output reg               underflow
  );

  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      count     <= {BITS{1'b0}};
      overflow  <= 1'b0;
      underflow <= 1'b0;
    end
    else
    begin
      // Default flag states for each clock cycle
      overflow  <= 1'b0;
      underflow <= 1'b0;

      if (load)
      begin
        count <= data_in;
      end
      else if (enable)
      begin
        if (up_down)
        begin
          if (count == {BITS{1'b1}})
          begin
            count    <= {BITS{1'b0}}; // Wrap around to 0
            overflow <= 1'b1;
          end
          else
          begin
            count <= count + 1'b1;
          end
        end
        else
        begin
          if (count == {BITS{1'b0}})
          begin
            count     <= {BITS{1'b1}}; // Wrap around to max value
            underflow <= 1'b1;
          end
          else
          begin
            count <= count - 1'b1;
          end
        end
      end
    end
  end

endmodule

module sev_seg_decoder (
    input  wire [3:0] bin_in,
    output reg  [6:0] seg_out  // Format: {g, f, e, d, c, b, a} (active-high)
  );

  always @(*)
  begin
    case (bin_in)
      4'h0:
        seg_out = 7'b0111111; // 0
      4'h1:
        seg_out = 7'b0000110; // 1
      4'h2:
        seg_out = 7'b1011011; // 2
      4'h3:
        seg_out = 7'b1001111; // 3
      4'h4:
        seg_out = 7'b1100110; // 4
      4'h5:
        seg_out = 7'b1101101; // 5
      4'h6:
        seg_out = 7'b1111101; // 6
      4'h7:
        seg_out = 7'b0000111; // 7
      4'h8:
        seg_out = 7'b1111111; // 8
      4'h9:
        seg_out = 7'b1101111; // 9
      4'hA:
        seg_out = 7'b1110111; // A
      4'hB:
        seg_out = 7'b1111100; // b
      4'hC:
        seg_out = 7'b0111001; // C
      4'hD:
        seg_out = 7'b1011110; // d
      4'hE:
        seg_out = 7'b1111001; // E
      4'hF:
        seg_out = 7'b1110001; // F
      default:
        seg_out = 7'b0000000;
    endcase
  end

endmodule

module counter_top #(
    parameter BITS = 4
  )(
    input  wire              clk,
    input  wire              rst_n,
    input  wire              enable,
    input  wire              up_down,
    input  wire              load,
    input  wire [BITS-1:0]   data_in,
    output wire [BITS-1:0]   count,
    output wire              overflow,
    output wire              underflow,
    output wire [6:0]        sev_seg
  );

  // Instantiate Counter Core
  up_down_counter #(.BITS(BITS)) u_counter (
                    .clk(clk),
                    .rst_n(rst_n),
                    .enable(enable),
                    .up_down(up_down),
                    .load(load),
                    .data_in(data_in),
                    .count(count),
                    .overflow(overflow),
                    .underflow(underflow)
                  );

  // Instantiate 7-Segment Decoder
  sev_seg_decoder u_decoder (
                    .bin_in(count[3:0]),
                    .seg_out(sev_seg)
                  );

endmodule

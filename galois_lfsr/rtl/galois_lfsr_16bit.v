module galois_lfsr_16bit #(

    parameter [15:0] DEFAULT_TAPS = 16'hB400
  )(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        load_seed,
    input  wire [15:0] seed_in,
    input  wire [15:0] tap_mask,
    output reg  [15:0] lfsr_out,
    output wire        sequence_done
  );

  reg [17:0] cycle_count;
  wire feedback;

  assign feedback = lfsr_out[0];

  assign sequence_done = (cycle_count == 18'd65535);

  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      lfsr_out    <= 16'hACE1;
      cycle_count <= 18'd0;
    end
    else if (load_seed)
    begin

      lfsr_out    <= (seed_in == 16'h0) ? 16'h0001 : seed_in;
      cycle_count <= 18'd0;
    end
    else
    begin
      if (!sequence_done)
      begin
        cycle_count <= cycle_count + 18'd1;
      end

      if (feedback)
      begin
        lfsr_out <= (lfsr_out >> 1) ^ tap_mask;
      end
      else
      begin
        lfsr_out <= (lfsr_out >> 1);
      end
    end
  end

endmodule

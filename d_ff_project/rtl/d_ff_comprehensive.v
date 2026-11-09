module d_flipflop(
    input  wire clk,
    input  wire rst_n,
    input  wire sync_rst,
    input  wire enable,
    input  wire load,
    input  wire d,
    input  wire d_load,
    output reg  q
  );

  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      q <= 1'b0;
    end
    else if (sync_rst)
    begin
      q <= 1'b0;
    end
    else if (enable)
    begin
      if (load)
      begin
        q <= d_load;
      end
      else
      begin
        q <= d;
      end
    end

  end

endmodule

module dff (
    input clk,
    input rstn,
    input d,
    output reg q
  );

  always @(posedge clk)
  begin
    if (!rstn)
      q <= 1'b0;
    else
      q <= d;
  end
endmodule

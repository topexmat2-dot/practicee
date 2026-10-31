module mux2to1_always #(
    parameter WIDTH = 8
  ) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    input sel,
    output reg [WIDTH-1:0] y
  );
  always @(*)
  begin
    if (sel)
    begin
      y = b;
    end
    else
    begin
      y = a;
    end
  end
endmodule

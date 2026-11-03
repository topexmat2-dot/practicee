module mux2to1 #(
    parameter WIDTH = 8
  )(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             sel,
    output wire [WIDTH-1:0] y
  );

  assign y = sel ? b : a;

endmodule

module mux4to1_chained #(
    parameter WIDTH = 8
  )(
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2,
    input  wire [WIDTH-1:0] in3,
    input  wire [1:0]       sel,
    output wire [WIDTH-1:0] out
  );

  // Internal wires connecting Stage 1 outputs to Stage 2 inputs
  wire [WIDTH-1:0] stage1_low;
  wire [WIDTH-1:0] stage1_high;

  // Stage 1, Mux 0: Selects between in0 and in1 using LSB (sel[0])
  mux2to1 #(
            .WIDTH(WIDTH)
          ) mux_low (
            .a(in0),
            .b(in1),
            .sel(sel[0]),
            .y(stage1_low)
          );

  // Stage 1, Mux 1: Selects between in2 and in3 using LSB (sel[0])
  mux2to1 #(
            .WIDTH(WIDTH)
          ) mux_high (
            .a(in2),
            .b(in3),
            .sel(sel[0]),
            .y(stage1_high)
          );

  // Stage 2, Final Mux: Selects between the two stage 1 results using MSB (sel[1])
  mux2to1 #(
            .WIDTH(WIDTH)
          ) mux_final (
            .a(stage1_low),
            .b(stage1_high),
            .sel(sel[1]),
            .y(out)
          );

endmodule

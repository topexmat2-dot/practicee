module magnitude_comparator #(
    parameter N = 4,
    parameter SIGNED_MODE = 0
) (
    input wire  [N-1:0] a,
    input wire  [N-1:0] b,
    output reg  eq,
    output reg  lt,
    output reg  gt
);
    always @(*) begin
        eq = 1'b0;
        lt = 1'b0;
        gt = 1'b0;

        if (SIGNED_MODE == 1) begin
            if (a[N-1] != b[N-1]) begin
                if (a[N-1] == 1'b1)
                    lt = 1'b1;
                else
                    gt = 1'b1;
            end else begin
                if (a == b)
                    eq = 1'b1;
                else if (a < b)
                    lt = 1'b1;
                else
                    gt = 1'b1;
            end
        end else begin
            if (a == b)
                eq = 1'b1;
            else if (a < b)
                lt = 1'b1;
            else
                gt = 1'b1;
        end
    end
endmodule

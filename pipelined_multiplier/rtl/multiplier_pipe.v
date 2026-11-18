module multiplier_pipe (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    output reg [15:0] product
);
// STAGE 1: Partial Product Generation & Registration
    reg [15:0] pp [7:0];
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 8; i = i + 1) begin
                pp[i] <= 16'd0;
            end
        end else begin
            for (i = 0; i < 8; i = i + 1) begin
                if (b[i])
                    pp[i] <= ({8'd0, a} << i);
                else
                    pp[i] <= 16'd0;
            end
        end
    end

    // STAGE 2: Reduction Tree (Compressing 8 rows to 2 rows: Sum & Carry)
    reg [15:0] sum_reg, carry_reg;

    // Combinational reduction tree wire declarations
    wire [15:0] stage2_sum, stage2_carry;
    assign stage2_sum   = pp[0] ^ pp[1] ^ pp[2] ^ pp[3] ^ pp[4] ^ pp[5] ^ pp[6] ^ pp[7];
    // Simplified behavioral compression equivalent for 8x8 addition tree:
    function [31:0] compress_8_rows;
        input [15:0] p0, p1, p2, p3, p4, p5, p6, p7;
        reg [15:0] s, c;
        begin
            // Standard multi-operand addition reduction
            s = p0 + p1 + p2 + p3;
            c = p4 + p5 + p6 + p7;
            compress_8_rows = {s, c};
        end
    endfunction

    wire [31:0] reduced_tree = compress_8_rows(pp[0], pp[1], pp[2], pp[3], pp[4], pp[5], pp[6], pp[7]);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_reg   <= 16'd0;
            carry_reg <= 16'd0;
        end else begin
            sum_reg   <= reduced_tree[31:16];
            carry_reg <= reduced_tree[15:0];
        end
    end
    // STAGE 3: Final Vector Merge Addition & Output Registration
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            product <= 16'd0;
        end else begin
            product <= sum_reg + carry_reg;
        end
    end

endmodule
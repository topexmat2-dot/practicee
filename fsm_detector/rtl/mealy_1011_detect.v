module mealy_1011_detect (
    input  wire clk,
    input  wire rst_n,
    input  wire din,
    output reg  detected
);

    // State encoding
    parameter S_NONE  = 2'b00;
    parameter S_1     = 2'b01;
    parameter S_10    = 2'b10;
    parameter S_101   = 2'b11;

    reg [1:0] state, next_state;

    // State Register (Sequential Logic)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_NONE;
        end else begin
            state <= next_state;
        end
    end

    // Next State Logic (Combinational)
    always @(*) begin
        next_state = state;
        case (state)
            S_NONE: begin
                if (din) next_state = S_1;
                else     next_state = S_NONE;
            end
            S_1: begin
                if (din) next_state = S_1;    // Stays in S_1 if '1' repeats
                else     next_state = S_10;
            end
            S_10: begin
                if (din) next_state = S_101;
                else     next_state = S_NONE;
            end
            S_101: begin
                if (din) next_state = S_1;    // Overlapping: last '1' acts as start of next '1011'
                else     next_state = S_NONE;
            end
            default: next_state = S_NONE;
        endcase
    end

    // Mealy Output Logic (Combinational based on state AND input)
    always @(*) begin
        detected = 1'b0;
        case (state)
            S_NONE: detected = 1'b0;
            S_1:    detected = 1'b0;
            S_10:   detected = 1'b0;
            S_101: begin
                if (din) detected = 1'b1; // Match found for '1011'
                else     detected = 1'b0;
            end
            default: detected = 1'b0;
        endcase
    end

endmodule
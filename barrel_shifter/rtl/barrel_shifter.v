module barrel_shifter (
    input wire [31:0] data_in,
    input wire [4:0] shift_amount,
    input wire [1:0] mode,
    output reg [31:0] data_out
);

    always @(*) begin
        case (mode)
            2'b00: data_out = data_in << shift_amount;
            2'b01: data_out = data_in >> shift_amount;
            2'b10: data_out = $signed(data_in) >>> shift_amount;
            default: data_out = 32'h00000000;
        endcase
    end
endmodule
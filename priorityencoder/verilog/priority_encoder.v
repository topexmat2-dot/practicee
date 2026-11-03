module priority_encoder_8to3 (
    input wire [7:0] din,
    output reg [2:0] dout,
    output reg valid
);
    always @(*) begin
        valid = 1'b0;
        dout = 3'b000;

        if (din[7]) begin
            dout = 3'b111;
            valid = 1'b1;
        end else if (din[6]) begin
            dout = 3'b110;
            valid = 1'b1;
        end else if (din[5]) begin
            dout = 3'b101;
            valid = 1'b1;
        end else if (din[4]) begin
            dout = 3'b100;
            valid = 1'b1;
        end else if (din[3]) begin
            dout = 3'b011;
            valid = 1'b1;
        end else if (din[2]) begin
            dout = 3'b010;
            valid = 1'b1;
        end else if (din[1]) begin
            dout = 3'b001;
            valid = 1'b1;
        end else if (din[0]) begin
            dout = 3'b000;
            valid = 1'b1;
        end
    end
endmodule
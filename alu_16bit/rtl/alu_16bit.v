module alu_16bit (
    input  wire [15:0] A,
    input  wire [15:0] B,
    input  wire [2:0]  opcode,
    output reg  [15:0] result,
    output reg         zero,
    output reg         carry,
    output reg         overflow
  );

  always @(*)
  begin
    // Flag and result initialization
    carry    = 1'b0;
    overflow = 1'b0;
    result   = 16'b0;

    case (opcode)
      3'b000:
      begin // ADD
        {carry, result} = {1'b0, A} + {1'b0, B};
        overflow = (A[15] == B[15]) && (result[15] != A[15]);
      end
      3'b001:
      begin // SUB (A - B)
        {carry, result} = {1'b0, A} - {1'b0, B};
        overflow = (A[15] != B[15]) && (result[15] != A[15]);
      end
      3'b010:
      begin // AND
        result = A & B;
      end
      3'b011:
      begin // OR
        result = A | B;
      end
      3'b100:
      begin // XOR
        result = A ^ B;
      end
      3'b101:
      begin // NOT-A
        result = ~A;
      end
      3'b110:
      begin // SLT (Set Less Than - Signed)
        result = ($signed(A) < $signed(B)) ? 16'h0001 : 16'h0000;
      end
      3'b111:
      begin // SHL (Shift Left Logical by 1)
        {carry, result} = {A[15], A << 1};
      end
      default:
      begin
        result = 16'h0000;
      end
    endcase

    zero = (result == 16'h0000);
  end

endmodule
